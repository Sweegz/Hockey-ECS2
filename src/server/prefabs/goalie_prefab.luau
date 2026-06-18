local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, instance: Model)
	local entity = world:entity()

	world:set(entity, components.Model, instance)

	world:add(entity, replecs.networked)
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	--world:add(entity, jecs.pair(replecs.unreliable, components.Transform))
	world:add(entity, jecs.pair(replecs.pair, components.BelongsToTeam))
	world:add(entity, jecs.pair(replecs.pair, components.PlayState))
	world:add(entity, jecs.pair(components.Reconcile, components.Transform))
	world:add(entity, jecs.pair(replecs.pair, components.Goalie))
	world:add(entity, components.Interpolate)
	world:add(entity, components.Goalie)

	local humanoid = instance:FindFirstChild("Humanoid")
	if humanoid then
		world:set(entity, components.Humanoid, humanoid)
	end

	return entity
end
