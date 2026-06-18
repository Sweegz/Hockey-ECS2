local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

function Shared.onEnter(context: T.GoalieStateMachine, entity: jecs.Entity, world: jecs.World, name: string)
	local track = Shared.getTrack(entity, world, name)
	if track then
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)
end

function Shared.onExit(context: T.GoalieStateMachine, entity: jecs.Entity, world: jecs.World, name: string)
	local track = Shared.getTrack(entity, world, name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end
end

function Shared.onUpdate(
	context: T.GoalieStateMachine,
	entity: jecs.Entity,
	world: jecs.World,
	dt: number,
	name: string
)
end

return Shared
