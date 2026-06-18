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

State.Name = "GlideLeft"

local tick_in

State.onEnter = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Play(context.BLEND_DURATION)
	end

	local model = world:get(entity, components.Tool)
	if model then
		local shaft = model:FindFirstChild("Shaft")
		if shaft then
			local weld = shaft:FindFirstChild("Weld")
			if weld then
				print("Changed")
				weld.C0 = CFrame.new(-6, -1.66, 0.5) * weld.C0.Rotation
			end
		end
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)

	tick_in = tick()

	world:add(entity, components.Glide)
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

	local model = world:get(entity, components.Tool)
	if model then
		local shaft = model:FindFirstChild("Shaft")
		if shaft then
			local weld = shaft:FindFirstChild("Weld")
			if weld then
				print("Changed")
				weld.C0 = CFrame.new(2.7, -1.66, 0.5) * weld.C0.Rotation
			end
		end
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

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track and track.TimePosition < context.BLEND_DURATION then
		return
	end

	if command.glide_left then
		context.GRACE_TIME = 0
	else
		context.GRACE_TIME += dt
	end

	world:set(entity, components.StickStateMachine, context)

	if tick() < tick_in + context.BLEND_DURATION * 1.2 then
		return
	end
	if context.GRACE_TIME > context.GRACE_DURATION then
		next_state = "Default"
	end

	if Shared.isMoreRecent2(command.glide_right, command.glide_left) then
		next_state = "GlideRight"
	end

	local rink_entity = world:target(participant, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
		return next_state
	end

	if command.drop_puck then
		for puck_entity, basepart in
			world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant))
		do
			world:add(puck_entity, components.DropEvent)
		end
	end

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

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

	world:set(entity, components.Power, power)

	return next_state
end

return State
