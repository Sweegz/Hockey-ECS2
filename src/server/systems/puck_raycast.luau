local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local query_puck_raycasts = world:query(components.BasePart, components.Puck):with(components.Raycasting):cached()

local rigids: { Instance } = {}

table.insert(rigids, CollectionService:GetTagged("Rigid"))

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = rigids

-- Update table when instances are added
CollectionService:GetInstanceAddedSignal("Rigid"):Connect(function(instance: Instance)
	table.insert(rigids, instance)
	params.FilterDescendantsInstances = rigids
end)

CollectionService:GetInstanceRemovedSignal("Rigid"):Connect(function(instance: Instance)
	for i = #rigids, 1, -1 do
		if rigids[i] == instance then
			table.remove(rigids, i)
			break
		end
	end
	params.FilterDescendantsInstances = rigids
end)

local function blockcast_collision(
	part: BasePart,
	size: Vector3,
	params: RaycastParams,
	dist: number,
	dt: number,
	visualize: boolean
): RaycastResult?
	local velocity = part.AssemblyLinearVelocity
	if velocity.Magnitude > 0 then
		local check_distance = velocity.Magnitude * dt * dist
		local direction = velocity.Unit

		if (direction * check_distance).Magnitude > 1020 then
			return nil
		end

		local result = Workspace:Blockcast(part.CFrame, size, direction * check_distance, params)

		return result
	end
	return nil
end

local function puck_raycast()
	for entity, part in query_puck_raycasts:iter() do
		local result = blockcast_collision(part, Vector3.new(1, 0.3, 1), params, 1.25, scheduler:getDeltaTime(), false)
		if not result then
			continue
		end

		print(result.Instance)

		if
			CollectionService:HasTag(result.Instance, "Rigid")
			or CollectionService:HasTag(result.Instance, "PlayerHitbox")
		then
			local hit_name = result.Instance.Name

			if not (hit_name == "Wall") and not (hit_name == "Hitbox") then
				local LV = part:FindFirstChild("VectorForce")
				if LV then
					LV:Destroy()
				end
				continue
			end
		end
	end
end

return {
	system = puck_raycast,
	phase = planck_runservice.Phases.PreSimulation,
}
