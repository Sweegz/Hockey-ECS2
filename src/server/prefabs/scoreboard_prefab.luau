local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, instance: Model)
	local entity = world:entity()

	world:set(entity, components.Model, instance)
	world:add(entity, components.Scoreboard)

	world:add(entity, replecs.networked)
	world:add(entity, jecs.pair(replecs.reliable, components.Scoreboard))
	--world:add(entity, jecs.pair(replecs.reliable, components.Model))
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	world:add(entity, jecs.pair(replecs.pair, components.BelongsToTeam))

	return entity
end
