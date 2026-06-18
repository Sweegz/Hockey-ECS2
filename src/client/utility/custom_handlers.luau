local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local replecs = require(ReplicatedStorage.Packages.replecs)
local world = require(ReplicatedStorage.Shared.world)

local refs = require(ReplicatedStorage.Shared.tables.refs)

world:set(components.Player, replecs.custom_handler, function(player: Player)
	if not refs[player] then
		print("Creating", player)
		local player_entity = world:entity()
		world:set(player_entity, components.Player, player)
		refs[player] = player_entity
	end
	return refs[player]
end)

return {}
