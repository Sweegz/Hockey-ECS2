local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local queryA = world:query(components.Instance):without(components.UUID):cached()

local function instances_add_uuid()
	for entity, instance in queryA:iter() do
		local UUID: string = HttpService:GenerateGUID(false)

		CollectionService:AddTag(instance, "Replicated")
		instance:SetAttribute("UUID", UUID)

		world:set(entity, components.UUID, UUID)
	end
end

return {
	system = instances_add_uuid,
	phase = planck_runservice.Phases.First,
}
