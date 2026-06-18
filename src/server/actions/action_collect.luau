local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local function participant_has_puck(participant_entity)
	for p_Entity in world:query(components.Puck, jecs.pair(components.Owner, participant_entity)) do
		return true
	end
	return false
end

local function can_collect(player: Player, p_Entity): (boolean, jecs.Entity?, jecs.Entity?, Model?)
	local player_entity = refs[player]
	if not player_entity or not p_Entity then
		return false
	end

	if not world:has(p_Entity, components.Puck) then
		return false
	end

	if world:has(p_Entity, jecs.pair(components.Timer, components.Cooldown)) then
		return false
	end

	local rink_entity = world:target(p_Entity, components.BelongsToRink)
	if not rink_entity then
		return false
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return false
	end

	if world:has(participant_entity, jecs.pair(components.Timer, components.Cooldown)) then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local character_entity = refs[character]
	if not character_entity then
		return false
	end

	if participant_has_puck(participant_entity) then
		return false
	end

	return true, player_entity, participant_entity, character
end

local action = {}

local sound = Instance.new("Sound")
sound.Name = "Click"
sound.Parent = game.Workspace
sound.SoundId = "rbxassetid://139267724392327"
sound.RollOffMode = Enum.RollOffMode.InverseTapered
sound.Volume = 0.5

local pitchsoundeffect = Instance.new("PitchShiftSoundEffect")
pitchsoundeffect.Parent = sound

function action.collect(player: Player, p_Entity: jecs.Entity)
	if world:has(p_Entity, components.Lifetime) then
		return
	end

	local collect, player_entity, participant_entity, character = can_collect(player, p_Entity)

	if not collect or not player_entity or not participant_entity or not character then
		return
	end

	local player_character = player.Character
	if not player_character then
		return
	end

	local HRP = player_character:FindFirstChild("HumanoidRootPart")
	if not HRP or not HRP:IsA("BasePart") then
		return
	end

	local team_entity = world:target(participant_entity, components.BelongsToTeam)
	if not team_entity then
		return
	end

	--[[local cooldown = world:get(participant_entity, jecs.pair(components.Timer, components.HitVictimCooldown))
	if cooldown then
		return
	end--]]

	local p_Part = world:get(p_Entity, components.BasePart)
	if not p_Part then
		return
	end

	local owner_participant_entity = world:target(p_Entity, components.Owner)
	if owner_participant_entity then
		local owner_team_entity = world:target(owner_participant_entity, components.BelongsToTeam)
		if not owner_team_entity then
			return
		end

		if team_entity == owner_team_entity then
			return
		end

		puck.drop(p_Entity, 1.5)
		puck.add_cooldown(p_Entity, 0.5)

		local owner_player_entity = world:target(owner_participant_entity, components.ParticipantOf)
		if not owner_player_entity then
			return
		end

		local owner_player = world:get(owner_player_entity, components.Player)
		if not owner_player then
			return
		end

		local owner_character = owner_player.Character
		if not owner_character then
			return
		end

		local HRP2 = owner_character:FindFirstChild("HumanoidRootPart")
		if not HRP2 or not HRP2:IsA("BasePart") then
			return
		end

		local puck_part = world:get(p_Entity, components.BasePart)
		if not puck_part then
			return
		end

		local debounce = false
		for stick_entity, sss in
			world:query(components.ServerStickState):with(jecs.pair(components.CurrentParticipant, participant_entity))
		do
			print(sss.current)
			if sss.current:match("Hit") or sss.current:match("Check") then
				debounce = true
				break
			end
		end

		if not debounce then
			puck_part.AssemblyLinearVelocity = (HRP.AssemblyLinearVelocity - HRP2.AssemblyLinearVelocity / 2) --/ 1.5
		end
		return
	else
		puck.collect(p_Entity, participant_entity, character)
		--pitchsoundeffect.Octave = math.random(1, 1.2)
		--sound.Parent = p_Part
		--sound:Play()
	end
end

return action
