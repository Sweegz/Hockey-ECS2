local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local refs = require(ReplicatedStorage.Shared.tables.refs)
local world = require(ReplicatedStorage.Shared.world)

local SSTate = ReplicatedStorage:FindFirstChild("SSTate") :: RemoteEvent

SSTate.OnServerEvent:Connect(function(player, entity, current, previous)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	if not (world:parent(entity) == player_entity) then
		return
	end

	world:set(entity, components.ServerStickState, {
		current = current,
		previous = previous,
	})
end)

local function receive_sttate() end

return {
	system = receive_sttate,
	phase = planck_runservice.Phases.Update,
}
