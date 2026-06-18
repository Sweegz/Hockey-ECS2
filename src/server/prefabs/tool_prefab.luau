local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, tool: Tool)
	local entity = world:entity()
	world:set(entity, components.Tool, tool)
	world:set(entity, jecs.Name, "Tool")

	world:add(entity, replecs.networked)
	--world:add(entity, jecs.pair(replecs.reliable, components.Tool))
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	--world:add(entity, jecs.pair(replecs.pair, components.EquippedOn))
	world:add(entity, jecs.pair(replecs.pair, jecs.ChildOf))
	world:add(entity, jecs.pair(replecs.reliable, jecs.Name))

	return entity
end
