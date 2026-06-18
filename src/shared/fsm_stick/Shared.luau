local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

local T = require(ReplicatedStorage.Shared.types)

local Shared = {}

function Shared.isMoreRecent2(source: number?, target: number?): boolean
	if source and target then
		return source > target
	elseif source then
		return true
	end

	return false
end

function Shared.getTrack(entity: jecs.Entity, world: jecs.World, name: string)
	local tracks = world:get(entity, components.AnimationTrack)
	if not tracks then
		return nil
	end

	local track = tracks[name]
	if not track then
		return nil
	end

	return track
end

function Shared.onEnter(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World, name: string)
	--print("onEnter", fsm.current)

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, name)
	if track then
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)
end

function Shared.onExit(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World, name: string)
	--print("onExit", fsm.current)

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end
end

function Shared.onUpdate(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World, dt: number, name: string)
	--print("onUpdate", state.current)

	local next_state = nil

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return true, false
	end

	local track = Shared.getTrack(character_entity, world, name)
	if track and track.TimePosition < context.BLEND_DURATION then
		context.busy = true
		return true, false
	else
		context.busy = false
	end

	world:set(entity, components.StickStateMachine, context)

	if next_state then
		return false, next_state
	end

	return false, false
end

return Shared
