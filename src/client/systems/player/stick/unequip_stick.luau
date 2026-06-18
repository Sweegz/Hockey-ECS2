local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function stop_animation_tracks(tracks)
	if tracks then
		for _, track in tracks do
			track:Stop()
		end
	end
end

local query_unequip = world
	:query(components.Tool, components.StickStateMachine)
	:with(components.Unequip, jecs.pair(components.EquippedOn, jecs.Wildcard))
	:cached()

local function unequip_stick()
	local player_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	for entity, tool, fsm in query_unequip:iter() do
		print(world:target(entity, components.EquippedOn))
		local character_entity = world:target(entity, components.EquippedOn)
		if not character_entity then
			continue
		end

		local character = world:get(character_entity, components.Model)
		if not character then
			continue
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local LV = character:FindFirstChild("LinearVelocity", true)
		if LV then
			LV:Destroy()
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or not humanoid:IsA("Humanoid") then
			continue
		end

		world:remove(entity, components.CollectCheck)
		world:remove(character_entity, components.CollectCheck)
		world:remove(entity, components.DetectCollisions)
		world:remove(player_entity, components.ForceLock)

		local momentum = hrp:FindFirstChild("Momentum")
		if momentum then
			momentum:Destroy()
		end
		world:remove(character_entity, components.Momentum)

		humanoid.JumpHeight = 7.2
		humanoid.WalkSpeed = 16
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

		stop_animation_tracks(world:get(character_entity, components.AnimationTrack))
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

		for puck_entity, basepart in
			world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant_entity))
		do
			world:add(puck_entity, components.DropEvent)
		end

		fsm.GRACE_TIME = 0
		fsm.active = false
		fsm.current = "Default"
		fsm.previous = "Default"

		world:remove(entity, components.Power)
		world:remove(character_entity, components.MovementDisabled)
		world:remove(character_entity, components.IsMoving)
		world:remove(entity, components.Glide)

		--[[for _, child in tool:GetChildren() do
			if child:IsA("MeshPart") then
				child.CustomPhysicalProperties = PhysicalProperties.new(11.24, 0.2, 0.5, 1, 1)
				if child.Name == "Blade" then
					child.CanCollide = true
				end
			end
		end

		print("Exit")

		for _, child in character:GetChildren() do
			if child:IsA("BasePart") then
				child.CustomPhysicalProperties = PhysicalProperties.new(4, 0.3, 0.5, 1, 0.3)
			end
		end--]]

		world:set(entity, components.StickStateMachine, fsm)
		world:remove(character_entity, components.Sprinting)

		local player = world:get(player_entity, components.Player)
		if not player then
			continue
		end

		tool.Parent = game.Lighting
		task.delay(2, function()
			tool.Parent = player.Backpack
		end)

		print("Unequipped")
	end
end

return {
	system = unequip_stick,
	phase = planck_runservice.Phases.Update,
}
