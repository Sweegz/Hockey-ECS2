local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

local puck = {}

function puck.destroy_weld(part)
	local weld = part:FindFirstChild("weld")
	if weld then
		weld.Part1 = nil
	end

	part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

function puck.add_cooldown(entity: jecs.Entity, duration: number)
	world:set(entity, jecs.pair(components.Timer, components.Cooldown), duration)
end

local function set_model_collision_group(character: Model, group: string)
	for _, descendant in character:GetChildren() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = group
		end
	end
end

local function set_with_puck(character: Model)
	for _, descendant in character:GetChildren() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "PlayerWithPuck"
		end
	end

	local stick = character:FindFirstChild("Stick")
	if stick then
		for _, descendant in stick:GetChildren() do
			if descendant:IsA("MeshPart") then
				descendant.CollisionGroup = "StickWithPuck"
			end
		end
	end
end

local function stop_with_puck(character: Model)
	for _, descendant in character:GetChildren() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Player"
		end
	end

	local right_leg = character:FindFirstChild("Right Leg")
	if right_leg and right_leg:IsA("BasePart") then
		right_leg.CollisionGroup = "Leg"
	end

	local left_leg = character:FindFirstChild("Left Leg")
	if left_leg and left_leg:IsA("BasePart") then
		left_leg.CollisionGroup = "Leg"
	end

	local stick = character:FindFirstChild("Stick")
	if stick then
		for _, descendant in stick:GetChildren() do
			if descendant:IsA("MeshPart") then
				descendant.CollisionGroup = "Stick"
			end
		end
	end
end

function puck.drop(puck_entity: jecs.Entity, cooldown: number?)
	local owner_participant_entity = world:target(puck_entity, components.Owner)
	if not owner_participant_entity then
		return
	end

	puck.add_cooldown(owner_participant_entity, cooldown or 1)

	local player_entity = world:target(owner_participant_entity, components.ParticipantOf)
	if player_entity then
		local player = world:get(player_entity, components.Player)
		if player then
			local character = Workspace:FindFirstChild(player.Name)
			if character then
				task.delay(0.5, function()
					stop_with_puck(character)
				end)
			end
		end
	end

	local part = world:get(puck_entity, components.BasePart)
	if part then
		puck.destroy_weld(part)
		part:SetNetworkOwner(nil)
		--print("Removed Network")
		part.Orientation = Vector3.new(0, 0, 0)
		part.CollisionGroup = "Puck"
	end

	world:set(puck_entity, components.PreviousOwner, owner_participant_entity)
	world:remove(puck_entity, jecs.pair(components.Owner, owner_participant_entity))
	print("Dropped")
end

function puck.collect(puck_entity: jecs.Entity, participant_entity: jecs.Entity, character: Model)
	print("Collected")
	world:add(puck_entity, jecs.pair(components.Owner, participant_entity))

	local player_entity = world:target(participant_entity, components.ParticipantOf)
	local player = nil
	if player_entity then
		player = world:get(player_entity, components.Player)
	end

	local part = world:get(puck_entity, components.BasePart)

	if part then
		world:set(puck_entity, components.VelocityBefore, part.AssemblyLinearVelocity)

		local front = character:FindFirstChild("Front", true)
		if not front or not front:IsA("BasePart") then
			return
		end

		local LV = part:FindFirstChild("ShotVelocity")
		if LV then
			LV:Destroy()
		end

		local LV2 = part:FindFirstChild("PokeVelocity")
		if LV2 then
			return
		end

		local weld = part:FindFirstChild("weld")
		if weld then
			weld:Destroy()
		end
		weld = nil

		part.CFrame = front.CFrame * CFrame.Angles(0, 0, 0)
		if not weld then
			print("new weld")
			weld = Instance.new("WeldConstraint")
			weld.Name = "weld"
			weld.Part0 = part
			weld.Part1 = nil
			weld.Parent = part
			weld.Enabled = true
		end

		set_with_puck(character)

		weld.Part1 = front

		--part:SetNetworkOwner(player)
		--print("Set network")
		part.CollisionGroup = "OwnedPuck"
		part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

		if player and player:IsA("Player") then
			--set_model_collision_group(character, "PlayerWithPuck")
		end
	end

	puck.add_cooldown(puck_entity, 0.5)
end

return puck
