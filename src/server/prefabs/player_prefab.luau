local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

local refs = require(ReplicatedStorage.Shared.tables.refs)

return function(world: jecs.World, player: Player): jecs.Entity
	local player_entity = world:entity()
	world:set(player_entity, components.Player, player)
	world:set(player_entity, jecs.Name, player.Name)
	world:add(player_entity, replecs.networked)
	--world:add(player_entity, jecs.pair(replecs.reliable, components.Player))
	world:set(player_entity, jecs.pair(replecs.custom, components.Player))
	world:add(player_entity, jecs.pair(replecs.pair, components.CurrentParticipant))
	world:add(player_entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(player_entity, jecs.pair(replecs.pair, components.BelongsToTeam))
	world:add(player_entity, jecs.pair(replecs.pair, components.PlayState))

	refs[player] = player_entity
	return player_entity
end
