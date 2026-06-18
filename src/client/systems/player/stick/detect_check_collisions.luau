local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

local query_detect_collisions = world:query(components.DetectCollisions):cached()

local function get_what_to_hit()
	local filter_table = CollectionService:GetTagged("Rigid")
	for _, player in Players:GetPlayers() do
		if player == Players.LocalPlayer then
			continue
		end

		local character = player.Character
		if not character then
			continue
		end

		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			table.insert(filter_table, hitbox)
		end
	end

	return filter_table
end

local function get_raycast_collision(part)
	local filter_table = get_what_to_hit()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = filter_table
	params.IgnoreWater = true

	local velocity = part.AssemblyLinearVelocity
	local dir: Vector3 = velocity.Unit

	local result = Workspace:Blockcast(part.CFrame, Vector3.new(4, 6, 1), dir * 1.05, params)
	return result
end

function detect_check_collisions()
	for entity, detect_collisions in query_detect_collisions:iter() do
		if tick() > detect_collisions.timestamp + (detect_collisions.duration + 0.4) then
			world:remove(entity, components.DetectCollisions)
			continue
		end

		local character_entity = world:target(entity, components.EquippedOn)
		if not character_entity then
			continue
		end

		local character = world:get(character_entity, components.Model)
		if not character then
			continue
		end

		local HRP = character:FindFirstChild("HumanoidRootPart")
		if not HRP then
			continue
		end

		local momentum = world:get(character_entity, components.Momentum)
		if not momentum then
			continue
		end

		--[[local LV = HRP:FindFirstChild("LinearVelocity")
		if not LV then
			continue
		end

		local velocity = LV.VectorVelocity

		if tick() > detect_collisions.timestamp + detect_collisions.duration then
			LV:Destroy()
		end--]]

		local box_params = OverlapParams.new()
		box_params.FilterType = Enum.RaycastFilterType.Exclude
		box_params.FilterDescendantsInstances = { character }

		local HIT = false

		local power = world:get(entity, components.Power)
		if not power then
			continue
		end

		local result = get_raycast_collision(HRP)
		if result then
			if CollectionService:HasTag(result.Instance, "PlayerHitbox") then
				Action:FireServer("Hit1", {
					hit = result.Instance,
					velocity = momentum.Velocity.Unit,
					power = power.value,
				})
				world:remove(entity, components.DetectCollisions)
			end
		end

		local hits = workspace:GetPartBoundsInBox(HRP.CFrame, Vector3.new(4, 6, 1), box_params)
		for _, part in ipairs(hits) do
			if CollectionService:HasTag(part, "PlayerHitbox") then
				print(part.Name)
				Action:FireServer("Hit1", {
					hit = part,
					velocity = momentum.Velocity.Unit,
					power = power.value,
				})
				world:remove(entity, components.DetectCollisions)
				break
			end
		end

		--[[local result = get_raycast_collision(HRP)
		if result then
			if CollectionService:HasTag(result.Instance, "PlayerHitbox") then
				Action:FireServer("Hit1", {
					hit = result.Instance,
					velocity = velocity.Unit,
					charge = charge.value,
				})
				LV:Destroy()
			else
				local normal_vel = velocity:Dot(result.Normal) * result.Normal
				local bounce_factor = 1
				local reflectedVelocity = velocity - normal_vel * bounce_factor
				reflectedVelocity = Vector3.new(reflectedVelocity.X, 0, reflectedVelocity.Z)
				LV.VectorVelocity = reflectedVelocity
			end
		else
			local hits = workspace:GetPartBoundsInBox(HRP.CFrame, Vector3.new(4, 6, 1), box_params)
			for _, part in ipairs(hits) do
				if CollectionService:HasTag(part, "PlayerHitbox") then
					print(part.Name)
					Action:FireServer("Hit1", {
						hit = part,
						velocity = velocity.Unit,
						charge = charge.value,
					})
					LV:Destroy()
					break
				end
			end
		end--]]
	end
end

return {
	system = detect_check_collisions,
	planck_runservice.Phases.Update,
}

--[[
local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }

		local hits = workspace:GetPartBoundsInBox(HRP.CFrame, Vector3.new(8, 8, 2), params)
		for _, part in ipairs(hits) do
			if CollectionService:HasTag(part, "PlayerHitbox") then
				Action:FireServer("Hit1", {
					hit = part,
					velocity = detect_collisions.dir,
					charge = charge.value,
				})
				world:remove(entity, components.DetectCollisions)
				local LV = HRP:FindFirstChild("LinearVelocity")
				if LV then
					LV:Destroy()
				end
			elseif CollectionService:HasTag(part, "Rigid") then
				local LV = HRP:FindFirstChild("LinearVelocity")
				if LV then
					--LV:Destroy()
				end
			end
		end


]]
