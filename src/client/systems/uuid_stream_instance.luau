local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local uuid = require(ReplicatedStorage.Shared.tables.uuid)

local query_uuid_without_instances = world:query(components.UUID):without(components.Instance):cached()

local function uuid_stream_instance()
	for entity, id in query_uuid_without_instances:iter() do
		local instance = uuid[id]
		if not instance then
			continue
		end

		if instance:IsA("Player") then
			world:set(entity, components.Player, instance)
		elseif instance:IsA("Tool") then
			world:set(entity, components.Tool, instance)
		elseif instance:IsA("BasePart") then
			world:set(entity, components.BasePart, instance)
		elseif instance:IsA("Model") then
			world:set(entity, components.Model, instance)
		end
	end
end

return {
	system = uuid_stream_instance,
	phase = planck_runservice.Phases.First,
	runConditions = {
		planck.timePassed(1 / 3),
	},
}
