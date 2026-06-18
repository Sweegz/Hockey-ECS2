local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

local T = require(ReplicatedStorage.Shared.types)
local refs = require(ReplicatedStorage.Shared.tables.refs)

return function(world: jecs.World, rink: jecs.Entity, position: Vector3): jecs.Entity?
	local template = ReplicatedStorage:FindFirstChild("Puck")
	if not template:IsA("BasePart") then
		return
	end

	local rink_model = world:get(rink, components.Model)
	if not rink_model then
		return
	end

	local clone = template:Clone()
	clone.Parent = rink_model
	clone.Transparency = 1

	local primary_part = rink_model.PrimaryPart
	if not primary_part then
		return
	end

	clone.Position = position
	clone.Orientation = Vector3.new(0, 0, 0)
	local entity = world:entity()

	world:add(entity, replecs.networked)
	world:add(entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(entity, jecs.pair(replecs.pair, components.Owner))
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	world:add(entity, jecs.pair(replecs.reliable, components.Puck))
	world:add(entity, jecs.pair(replecs.reliable, components.Touched))
	world:add(entity, jecs.pair(components.Reconcile, components.Transform))
	world:add(entity, jecs.pair(replecs.pair, components.PlayState))
	world:add(entity, components.Raycasting)

	world:add(entity, jecs.pair(components.BelongsToRink, rink))
	world:set(entity, components.BasePart, clone)
	world:add(entity, components.Puck)
	world:add(entity, components.GoalActivator)
	world:add(entity, components.Interpolate)

	clone:SetNetworkOwner(nil)

	world:set(entity, jecs.pair(components.Timer, components.Cooldown), 2)

	world:add(entity, components.Touched)

	refs[clone] = entity

	return entity
end
