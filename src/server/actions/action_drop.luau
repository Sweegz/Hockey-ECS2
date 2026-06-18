local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local action = {}

function action.drop(player: Player, pos: CFrame)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	for participant_entity in world:query(jecs.pair(components.ParticipantOf, player_entity)) do
		for puck_entity, basepart in
			world:query(components.BasePart, jecs.pair(components.Owner, participant_entity)):with(components.Puck)
		do
			basepart.Position = pos
			puck.drop(puck_entity)
			puck.add_cooldown(puck_entity, 0.5)
		end
	end
end

return action
