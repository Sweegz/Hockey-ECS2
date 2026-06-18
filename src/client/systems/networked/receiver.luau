local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local compression = require(ReplicatedStorage.Shared.interpolation.compression)
local interpolation_buffer = require(ReplicatedStorage.Shared.interpolation.interpolation_buffer)
local interpolation_config = require(ReplicatedStorage.Shared.interpolation.interpolation_config)
local interpolation_math = require(ReplicatedStorage.Shared.interpolation.interpolation_math)
local render_cache = require(ReplicatedStorage.Shared.interpolation.render_cache)
local replicator = require(ReplicatedStorage.Shared.replicator)
local saved_snapshots = require(ReplicatedStorage.Shared.tables.saved_snapshots)
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local snapshots = require(ReplicatedStorage.Shared.interpolation.snapshots)

local player_tick_rates = {} :: { [number]: number }
local tick_rate = interpolation_config.TICK_RATE
local last_received_cframe = {}

type NetworkedPayload = {
	timestamp: number,
	cframe: CFrame,
	entity: number,
}

local min_buffer, max_buffer, alpha = 0.018, 0.5, 0.1
local buffer_tracker = interpolation_buffer(min_buffer, max_buffer, alpha)
render_cache.init({
	player_tick_rates = player_tick_rates,
	buffer_tracker = buffer_tracker,
})

local function check_cframe_changes(cframe: CFrame, last: CFrame, magnitude: number, rotation: number)
	if not last then
		return true
	end
	local changed = (last.Position - cframe.Position).Magnitude >= magnitude
		or not last.Rotation:FuzzyEq(cframe.Rotation, rotation)
	return changed
end

local query_pucks_with_owner =
	world:query(components.BasePart, components.Ghost):with(jecs.pair(components.Owner, jecs.Wildcard)):cached()

local query_interpolated_models = world:query(components.Model, components.Interpolated):cached()

local query_interpolated_pucks_without_owner =
	world:query(components.Ghost, components.BasePart, components.Interpolated):cached()

local RT = ReplicatedStorage:WaitForChild("RT")
local onEvent = planck.onEvent
local _, onClientEvents = onEvent(RT.OnClientEvent)

local function CFrameChanged(cframe1: CFrame?, cframe2: CFrame?): boolean
	if cframe1 == cframe2 then
		return false
	end
	if cframe1 == nil or cframe2 == nil then
		return true
	end
	return cframe1:FuzzyEq(cframe2, 0.0001) == false
end

RT.OnClientEvent:Connect(function(snapshot_buffer)
	local SNAPSHOT_SIZE = 48
	local total_snapshots = buffer.len(snapshot_buffer) / SNAPSHOT_SIZE

	for i = 0, total_snapshots - 1 do
		local offset = i * SNAPSHOT_SIZE
		local data = compression.unpack_snapshot_data(snapshot_buffer, offset)

		local client_id = data.id
		local cframe = data.cframe
		local timestamp = data.timestamp --]]

		-- validate entity
		local client_entity = replicator.client:get_client_entity(client_id) :: any
		if not client_entity then
			continue
		end

		local parent = world:parent(client_entity)
		if parent and parent == world:get(components.LocalPlayer, components.LocalPlayer) then
			continue
		end

		if not client_id then
			continue
		end

		-- ensure interpolated snapshot exists
		if not world:has(client_entity, components.Interpolated) then
			saved_snapshots[client_entity] = snapshots(interpolation_math.linear)
			render_cache.add(client_entity)
			world:add(client_entity, components.Interpolated)
		end

		local snapshot = saved_snapshots[client_entity]
		if not snapshot then
			continue
		end

		-- register packet arrival
		buffer_tracker.register_packet(client_entity, timestamp, 1 / tick_rate)

		-- notify time tracker
		render_cache.on_snapshot_update({ [client_entity] = timestamp })

		-- handle large time jumps
		local latest = snapshot:get_latest()
		local target_time = render_cache.get_target_render_time(client_entity)
		if latest and (timestamp - latest.t) < 5 and target_time then
			if math.abs(target_time - latest.t) > 5 then
				snapshot:clear()
				warn("Clearing Snapshot due to large time difference during ownership changes")
			end
		end

		if not CFrameChanged(cframe, last_received_cframe[client_entity]) then
			continue
		end

		-- avoid pushing near-identical CFrames for models
		--[[if world:has(client_entity, components.Model) then
			if not check_cframe_changes(cframe, last_received_cframe[client_entity], 0.1, 0.1) then
				continue
			end
		else
			if not check_cframe_changes(cframe, last_received_cframe[client_entity], 0.01, 0.001) then
				continue
			end
			end--]]

		last_received_cframe[client_entity] = cframe

		-- compute velocity
		local velocity = interpolation_math.velocity_at(latest, timestamp, cframe)

		-- push snapshot
		snapshot:push(timestamp, cframe, velocity)
	end
end)

local query_fired_shots = world:query(components.BasePart, components.Ghost, components.FiredShot):cached()

local query_pucks_with_owner =
	world:query(components.BasePart, components.Ghost):with(jecs.pair(components.Owner, jecs.Wildcard)):cached()

local query_b = world:query(components.Ghost, components.Transform):cached()

local query_model_transforms = world:query(components.Model, components.Transform):cached()

RunService.PreAnimation:Connect(function(dt)
	render_cache.update(dt)

	for entity, part, ghost, shot in query_fired_shots:iter() do
		local owner = world:target(entity, components.Owner)
		if owner then
			local snapshot = saved_snapshots[entity]
			if not snapshot then
				warn("Could not retrieve snapshot. Please report this bug to the owner.")
				world:remove(entity, components.FiredShot)
				continue
			end

			if not snapshot.cache then
				warn("Could not retrieve snapshot cache. Please report this bug to the owner.")
				world:remove(entity, components.FiredShot)
				continue
			end

			--world:remove(entity, jecs.pair(components.Owner, owner))

			snapshot:clear()

			world:set(entity, components.Transform, CFrame.new(shot))
			--ghost.CFrame = CFrame.new(shot)
		else
			world:remove(entity, components.FiredShot)
		end
	end

	for entity, model in query_interpolated_models:iter() do
		local target_time = render_cache.get_target_render_time(entity :: any)
		local render_cframe = saved_snapshots[entity]:get_at(target_time)
		if render_cframe then
			local primary_part = model.PrimaryPart
			if primary_part then
				primary_part.Anchored = true
				--primary_part.CFrame = render_cframe
				world:set(entity, components.Transform, render_cframe)
			else
				warn("Did not find PrimaryPart for", model.Name)
			end
		end
	end

	for entity, ghost, part in query_interpolated_pucks_without_owner:iter() do
		local target_time = render_cache.get_target_render_time(entity :: any)
		--print(target_time, saved_snapshots[entity]:get_latest().t)
		local render_cframe = saved_snapshots[entity]:get_at(target_time)
		--local estimated_server_time = render_cache.get_estimated_server_time(entity :: any)
		if render_cframe then
			--ghost.CFrame = render_cframe
			world:set(entity, components.Transform, render_cframe)
		end
	end
end)

local function receiver()

	--[[for entity, model in query_interpolated_models:iter() do
		local target_time = render_cache.get_target_render_time(entity :: any)
		local render_cframe = saved_snapshots[entity]:get_at(target_time)
		if render_cframe then
			local primary_part = model.PrimaryPart
			if primary_part then
				--primary_part.CFrame = render_cframe
				world:set(entity, components.Transform, render_cframe)
			else
				warn("Did not find PrimaryPart for", model.Name)
			end
		end
	end

	for entity, ghost, part in query_interpolated_pucks_without_owner:iter() do
		local target_time = render_cache.get_target_render_time(entity :: any)
		--print(target_time, saved_snapshots[entity]:get_latest().t)
		local render_cframe = saved_snapshots[entity]:get_at(target_time)
		--local estimated_server_time = render_cache.get_estimated_server_time(entity :: any)
		if render_cframe then
			--ghost.CFrame = render_cframe
			world:set(entity, components.Transform, render_cframe)
		end
	end

	for entity, part, ghost in query_pucks_with_owner:iter() do
		--ghost.CFrame = part.CFrame
		world:set(entity, components.Transform, part.CFrame)
		local snapshot = saved_snapshots[entity]
		if not snapshot then
			return
		end
		--snapshot:clear()
	end

	for entity, part, ghost, shot in world:query(components.BasePart, components.Ghost, components.FiredShot):iter() do
		local owner = world:target(entity, components.Owner)
		if owner then
			local snapshot = saved_snapshots[entity]
			for i, v in snapshot.cache do
				snapshot.cache[i] = {
					t = v.t,
					value = ghost.CFrame,
				}
				--print(k, v)
			end
			world:set(entity, components.Transform, CFrame.new(shot))
			--ghost.CFrame = CFrame.new(shot)
		else
			world:remove(entity, components.FiredShot)
		end
	end
	render_cache.update(scheduler:getDeltaTime())--]]
end

return {
	system = receiver,
	phase = planck_runservice.Phases.PreRender,
}
