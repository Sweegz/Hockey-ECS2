local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local world = require(ReplicatedStorage.Shared.world)

local refs = require(ReplicatedStorage.Shared.tables.refs)
local uuid = require(ReplicatedStorage.Shared.tables.uuid)

local function add_instance(instance: Instance)
	local UUID = instance:GetAttribute("UUID") :: string
	uuid[UUID] = instance
end

function remove_instance(instance: Instance)
	local UUID = instance:GetAttribute("UUID") :: string
	uuid[UUID] = nil

	local entity = refs[instance]
	if entity then
		world:remove(entity, components.Renderable)
		world:remove(entity, components.BasePart)
		world:remove(entity, components.Model)
		world:remove(entity, components.Instance)
	end
end

for _, instance in CollectionService:GetTagged("Replicated") do
	add_instance(instance)
end
CollectionService:GetInstanceAddedSignal("Replicated"):Connect(add_instance)
CollectionService:GetInstanceRemovedSignal("Replicated"):Connect(remove_instance)

local function add_siren(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end

	local siren = ReplicatedStorage:WaitForChild("Siren")
	if not siren:IsA("Model") then
		return
	end

	local clone = siren:Clone()
	clone.Parent = instance
	clone:PivotTo(instance.CFrame)
end

for _, instance in CollectionService:GetTagged("Alarm") do
	add_siren(instance)
end
CollectionService:GetInstanceAddedSignal("Alarm"):Connect(add_siren)

return {}
