local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "RaiseHand"

State.onEnter = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)

	if track then
		--print(track)
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end
end

local time = 0

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	time += dt
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local participant = world:target(entity, components.CurrentParticipant)
	if not participant then
		return
	end

	local rink_entity = world:target(participant, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if world:has(character_entity, components.Ragdolled) then
		return "Default"
	end

	local has_puck = false

	for p_Entity in world:query(components.Puck, jecs.pair(components.Owner, participant)) do
		has_puck = true
		break
	end

	local c_Model = world:get(character_entity, components.Model)
	if not c_Model then
		return
	end

	local HRP = c_Model:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local next_state = nil

	--local track = Shared.getTrack(character_entity, world, State.Name)

	if has_puck or (not command.raise_hand and time > 0.4) then
		time = 0
		next_state = "Default"
	end

	return next_state
end

return State
