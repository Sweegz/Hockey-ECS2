local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local planck = require(ReplicatedStorage.Packages.planck)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "Shooting"

local _, collectEvents, disconnectFn = nil, nil, nil

local switch_wrist_release_duration = 0.25

local global_track = nil

local wrist = false

local function get_shooting_track(power: T.Power, character_entity, world, context): AnimationTrack?
	local track = nil

	if context.previous == "GlideRight" then
		if command.wrist_shot then
			track = Shared.getTrack(character_entity, world, "RightWrist")
			wrist = true
		elseif power.value > 50 and context.tick + switch_wrist_release_duration < tick() then
			track = Shared.getTrack(character_entity, world, "RightSlap")
		else
			track = Shared.getTrack(character_entity, world, "RightWrist")
		end
	elseif context.previous == "GlideLeft" then
		if command.wrist_shot then
			track = Shared.getTrack(character_entity, world, "LeftWrist")
			wrist = true
		elseif power.value > 50 and context.tick + switch_wrist_release_duration < tick() then
			track = Shared.getTrack(character_entity, world, "LeftSlap")
		else
			track = Shared.getTrack(character_entity, world, "LeftWrist")
		end
	else
		if command.wrist_shot then
			track = Shared.getTrack(character_entity, world, "Wrist")
			wrist = true
		elseif power.value > 50 and context.tick + switch_wrist_release_duration < tick() then
			track = Shared.getTrack(character_entity, world, "Slap")
		else
			track = Shared.getTrack(character_entity, world, "Wrist")
		end
	end

	return track
end

State.onEnter = function(context: T.StickStateMachine, entity, world)
	command.power_reset = false
	wrist = false

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	global_track = get_shooting_track(power, character_entity, world, context)

	if global_track then
		global_track:Play(0)
		_, collectEvents, disconnectFn = planck.onEvent(global_track:GetMarkerReachedSignal("Shoot"))
	end

	context.GRACE_TIME = 0

	world:set(entity, components.StickStateMachine, context)
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	if global_track then
		global_track:Stop(context.BLEND_DURATION)
	end

	if disconnectFn then
		disconnectFn()
	end

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end
end

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local participant = world:target(entity, components.CurrentParticipant)
	if not participant then
		return
	end

	local next_state = nil

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	for _ in collectEvents() do
		local eventity = world:entity()
			-- stylua: ignore

		local fake = command.fake_shot or false
		local chip = command.chip_shot or false

		world:set(
			eventity,
			components.ShotEvent,
			{
				entity = participant,
				power = power.value,
				wrist = wrist,
				fake = fake,
				chip = chip,
			} :: T.ShotEvent
		)
	end

	if global_track and global_track.IsPlaying == false then
		next_state = context.previous
	end

	return next_state
end

return State
