local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local DRAIN_RATE = 30
local REGEN_RATE = 15
local MAX_STAM = 100

local query_character_sprinting = world
	:query(components.Model)
	:with(components.Character, components.Sprinting)
	:without(components.MovementDisabled)
	:cached()

local query_character_not_sprinting =
	world:query(components.Model):with(components.Character):without(components.Sprinting):cached()

local query_equipped_stick = world
	:query(components.Tool)
	:with(jecs.pair(components.EquippedOn, jecs.Wildcard), components.StickStateMachine)
	:cached()

local function sprint_system()
	local localplayer_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not localplayer_entity then
		return
	end

	local current_participant = world:target(localplayer_entity, components.CurrentParticipant)
	if not current_participant then
		return
	end

	local stamina = world:get(current_participant, components.Stamina)
	if not stamina then
		return
	end

	for entity, tool in query_equipped_stick:iter() do
		local character_entity = world:target(entity, components.EquippedOn)
		if not character_entity then
			continue
		end

		if command.sprinting and not world:has(character_entity, components.MovementDisabled) then
			world:add(character_entity, components.Sprinting)
		else
			world:remove(character_entity, components.Sprinting)
		end
	end

	for character_entity, character in query_character_sprinting:iter() do
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or not humanoid:IsA("Humanoid") then
			return
		end

		if stamina > 0 then
			local new_stamina = stamina - (DRAIN_RATE * scheduler:getDeltaTime())
			world:set(current_participant, components.Stamina, new_stamina)
			humanoid.WalkSpeed = 47
		else
			world:remove(character_entity, components.Sprinting)
			humanoid.WalkSpeed = 38
			command.sprinting = false
		end
	end

	for character_entity, character in query_character_not_sprinting do
		local player_entity = world:parent(character_entity)
		if not player_entity then
			continue
		end

		local participant_entity = world:target(player_entity, components.CurrentParticipant)
		if not participant_entity then
			continue
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			return
		end

		if stamina < MAX_STAM then
			--print("Regen")
			local new_stamina = stamina + (REGEN_RATE * scheduler:getDeltaTime())
			world:set(participant_entity, components.Stamina, new_stamina)
			if not world:has(character_entity, components.MovementDisabled) then
				humanoid.WalkSpeed = 38
			end
		end
	end
end

return {
	system = sprint_system,
	phase = planck_runservice.Phases.PostUpdate,
}
