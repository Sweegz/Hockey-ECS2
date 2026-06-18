local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "Blocker0"

State.onEnter = function(context: T.GoalieStateMachine, entity, world)
	if context.debug then
		print("Enter:", State.Name)
	end
	local track = Shared.getTrack(entity, world, State.Name)
	if track then
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.GoalieStateMachine, context)
end

State.onExit = function(context: T.GoalieStateMachine, entity, world)
	if context.debug then
		print("Exit:", State.Name)
	end
	local track = Shared.getTrack(entity, world, State.Name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end
end

State.onUpdate = function(context: T.GoalieStateMachine, entity, world, dt) end

return State
