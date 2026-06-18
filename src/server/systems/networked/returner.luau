local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local replicator = require(ReplicatedStorage.Shared.replicator)
local world = require(ReplicatedStorage.Shared.world)

local compression = require(ReplicatedStorage.Shared.interpolation.compression)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local ReplicateTransform = ReplicatedStorage:WaitForChild("RT")

local onEvent = planck.onEvent
local _, onServerEvents = onEvent(ReplicateTransform.OnServerEvent)

local function returner()
	local SNAPSHOT_SIZE = 48
	local snapshots = {}

	local now = os.clock()

	for _, sender: Player, snapshotBuffer in onServerEvents() do
		local character = sender.Character
		if not character then
			continue
		end
		local character_entity = refs[character]
		if not character_entity then
			continue
		end

		local timestamp, cframe = compression.unpack_snapshot_data_for_sender(snapshotBuffer)
		local snap = {
			id = character_entity,
			timestamp = timestamp,
			cframe = cframe,
		}

		--snap.id = character_entity
		table.insert(snapshots, snap)
	end

	for entity, part in world:query(components.BasePart):with(components.Puck, components.Interpolate) do
		local payload = {
			id = entity,
			timestamp = now, -- client timestamp
			cframe = part.CFrame,
			--velocity = part.Velocity,
		}
		table.insert(snapshots, payload)
	end

	for entity, model in
		world:query(components.Model):with(jecs.pair(components.Goalie, jecs.Wildcard), components.Interpolate)
	do
		local payload = {
			id = entity,
			timestamp = now, -- client timestamp
			cframe = model.PrimaryPart.CFrame,
			--velocity = model.PrimaryPart.Velocity,
		}
		table.insert(snapshots, payload)
	end

	local bufferSize = #snapshots * SNAPSHOT_SIZE
	local snapshotBuffer = buffer.create(bufferSize)

	for i, snap in ipairs(snapshots) do
		local offset = (i - 1) * SNAPSHOT_SIZE
		compression.pack_snapshot_data(snapshotBuffer, offset, snap.timestamp, snap.cframe, snap.id)
	end

	for _, player in Players:GetPlayers() do
		if replicator.server:is_player_ready(player) then
			ReplicateTransform:FireClient(player, snapshotBuffer)
			--ReplicateTransform:FireClient(player, snapshotBuffer) UNDO THIS WHEN YOU WANT COMPRESSION
		end
	end

	--ReplicateTransform:FireAllClients(SEND_DATA)
end

RunService.PreAnimation:Connect(function(dt)
	returner()
end)

return {
	system = function() end,
	phase = planck_runservice.Phases.PreAnimation,
}
