local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, instance: Model)
	local entity = world:entity()

	world:set(entity, components.Model, instance)
	world:add(entity, components.Net)

	world:add(entity, replecs.networked)
	--world:add(entity, jecs.pair(replecs.reliable, components.Model))
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	world:add(entity, jecs.pair(replecs.reliable, components.Net))
	world:add(entity, jecs.pair(replecs.pair, components.PlayState))
	world:add(entity, jecs.pair(replecs.pair, components.BelongsToTeam))

	for _, child in instance:GetChildren() do
		if child:IsA("BasePart") and CollectionService:HasTag(child, "GoalHitbox") then
			local hitbox_entity = world:entity()
			world:set(hitbox_entity, components.BasePart, child)
			world:add(hitbox_entity, jecs.pair(components.GoalReceiver, entity))
			world:add(hitbox_entity, components.Touched)
			--world:set(hitbox, components.TouchConnection, addConnection(child.Touched))
		end
	end

	return entity
end
