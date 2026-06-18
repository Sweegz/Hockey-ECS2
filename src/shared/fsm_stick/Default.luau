local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

local function player_has_puck(entity: jecs.Entity)
	local player_entity = world:parent(entity)
	if not player_entity then
		return false
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return false
	end

	for e in world:query(components.Puck):with(jecs.pair(components.Owner, participant_entity)) do
		return true
	end

	return false
end

State.Name = "Default"

State.onEnter = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)
	world:remove(entity, components.PreventCollect)
	world:remove(character_entity, components.PreventCollect)
	world:remove(entity, components.Glide)
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

	if world:has(participant, components.Celebrating) then
		return
	end

	local has_puck = false

	for _ in world:query(components.Puck, jecs.pair(components.Owner, participant)) do
		has_puck = true
		break
	end

	local next_state = nil

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track and track.TimePosition < context.BLEND_DURATION then
		return
	end

	if command.glide_left then
		next_state = "GlideLeft"
	end

	if command.glide_right then
		next_state = "GlideRight"
	end

	if world:has(character_entity, components.Ragdolled) then
		return next_state
	end

	local rink_entity = world:target(participant, components.BelongsToRink)
	if not rink_entity then
		return
	end

	local round_active = world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive))

	if has_puck and command.drop_puck then
		for puck_entity, basepart in
			world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant))
		do
			world:add(puck_entity, components.DropEvent)
		end
		return
	end

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	if not command.power or not power.value then
		if not has_puck and command.double_pokecheck and round_active then
			next_state = "Pokecheck"
		end

		if not has_puck and command.start_slapshot and round_active then
			next_state = "Slapshot"
		end

		if not has_puck and command.shove and round_active then
			next_state = "Shove"
		end

		if not has_puck and command.low_tip and round_active then
			next_state = "LowTip"
		end

		if not has_puck and command.high_tip and round_active then
			next_state = "HighTip"
		end

		if not has_puck and command.standing_block and round_active then
			next_state = "StandingBlock"
		end

		if not has_puck and command.kneel_block and round_active then
			next_state = "KneeBlock"
		end

		if not has_puck and command.pressed_lying_block and round_active then
			next_state = "LayingBlock"
		end
	end

	if not has_puck and command.raise_hand then
		next_state = "RaiseHand"
	end

	if round_active then
		if (not command.power and power.value > 0) or (command.power and tick() > command.power + 1.45) then
			if player_has_puck(entity) then
				next_state = "Shooting"
			else
				if power.value > 30 then
					next_state = "Check"
				else
					power.value = 0
				end
			end
		end
	end

	world:set(entity, components.Power, power)

	return next_state
end

return State
