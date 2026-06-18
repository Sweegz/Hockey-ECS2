local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TouchInputService = game:GetService("TouchInputService")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local replicator = require(ReplicatedStorage.Shared.replicator)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "Slapshot"

local Shoot = "SlapShoot"
local Wind1 = "SlapWind1"
local Wind2 = "SlapWind2"

local time = 0
local time_since_shot = 0

local phase1 = false
local phase2 = false
local shot = false
local shot_tick = tick()
local sent_shot = false
local cancelled = false

local part_that_was_shot = nil

State.onEnter = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	phase1 = false
	phase2 = false
	shot = false
	sent_shot = false
	cancelled = false
	part_that_was_shot = nil

	time = 0
	time_since_shot = 0

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	local track = Shared.getTrack(character_entity, world, Wind1)
	if track then
		track:Play(0.3)
	end

	context.GRACE_TIME = 0

	local player_entity = world:parent(character_entity)
	if not player_entity then
		return
	end
	world:set(player_entity, components.ForceLock, 2000)

	for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
		for _, child in tool:GetChildren() do
			if child:IsA("MeshPart") then
				child.CanCollide = false
			end
		end
	end

	local character = world:get(character_entity, components.Model)
	if not character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
	end

	world:set(entity, components.StickStateMachine, context)
	world:add(character_entity, components.MovementDisabled)
	world:add(entity, components.PreventCollect)
	world:add(character_entity, components.PreventCollect)
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, Shoot)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	track = Shared.getTrack(character_entity, world, Wind1)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	track = Shared.getTrack(character_entity, world, Wind2)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end

	world:remove(entity, components.PreventCollect)
	world:remove(character_entity, components.PreventCollect)
	world:remove(character_entity, components.MovementDisabled)

	local player_entity = world:parent(character_entity)
	if not player_entity then
		return
	end
	world:remove(player_entity, components.ForceLock)

	for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
		for _, child in tool:GetChildren() do
			if child:IsA("MeshPart") then
				child.CanCollide = true
			end
		end
	end

	local character = world:get(character_entity, components.Model)
	if not character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 38
	end
end

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

local get_valid_mouse_hit = require(StarterPlayer.StarterPlayerScripts.Client.utility.get_valid_mouse_hit)

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	time += dt
	if shot then
		time_since_shot += dt
	end

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local participant = world:target(entity, components.CurrentParticipant)
	if not participant then
		return
	end

	local character = world:get(character_entity, components.Model)
	if not character then
		return
	end

	local next_state = nil

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	if time > 0.3 and not phase1 and not shot then
		phase1 = true
		local track = Shared.getTrack(character_entity, world, Wind2)
		if track then
			track:Play(1.5)
		end
	end

	if time > (0.3 + 1.5) and not phase2 and not shot then
		phase2 = true
		local track = Shared.getTrack(character_entity, world, Wind2)
		if track then
			track:AdjustWeight(0, 1.5)
		end
	end

	if not shot and command.cancel_slapshot then
		print("Default")
		return "Default"
	end

	if time > 0.3 and not command.slapshot and not shot then
		shot = true
		shot_tick = tick()
		local player_entity = world:parent(character_entity)
		if not player_entity then
			return
		end
		world:set(player_entity, components.ForceLock, 0)

		local track = Shared.getTrack(character_entity, world, Shoot)
		if track then
			track:Play()
		end

		track = Shared.getTrack(character_entity, world, Wind1)
		if track then
			track:Stop()
		end

		track = Shared.getTrack(character_entity, world, Wind2)
		if track then
			track:Stop()
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
		end
	end

	local box_params = OverlapParams.new()
	box_params.FilterType = Enum.RaycastFilterType.Exclude
	box_params.FilterDescendantsInstances = { character }

	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local front = character:FindFirstChild("Front", true)

	if not sent_shot and shot then
		local right_leg = character:FindFirstChild("Right Leg", true)
		if front and right_leg then
			local hits = workspace:GetPartBoundsInBox(
				CFrame.new((right_leg.Position + front.Position) / 2),
				Vector3.new(7, 2, 7),
				box_params
			)
			for _, part in ipairs(hits) do
				if part.Name == "GhostPuck" then
					part_that_was_shot = part
				end
			end
		end
	end

	if (not sent_shot) and part_that_was_shot and time_since_shot > -0.1 then
		local puck_entity = refs[part_that_was_shot]
		if not puck_entity then
			return
		end
		local server_entity = replicator.client:get_server_entity(puck_entity)
		if not server_entity then
			return
		end
		Action:FireServer("Slapshot", {
			entity = server_entity,
			pos = part_that_was_shot.Position,
			power = power.value,
			aim = get_valid_mouse_hit() * Vector3.new(1, 0, 1),
			dir = HRP.CFrame.LookVector,
		})
		sent_shot = true
	end

	local shoot_track = Shared.getTrack(character_entity, world, Shoot)
	if shot and time_since_shot > 0.5 then
		next_state = "Default"
	end

	return next_state
end

return State
