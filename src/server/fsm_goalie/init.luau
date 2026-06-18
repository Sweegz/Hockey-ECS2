local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

local T = require(ReplicatedStorage.Shared.types)

local Blocker0 = require(script.Blocker0)
local Blocker1 = require(script.Blocker1)
local Blocker2 = require(script.Blocker2)
local Butterfly = require(script.Butterfly)
local Glove0 = require(script.Glove0)
local Glove1 = require(script.Glove1)
local Glove2 = require(script.Glove2)
local Poke = require(script.Poke)
local Standing1 = require(script.Standing1)
local Standing2 = require(script.Standing2)
local Standing3 = require(script.Standing3)

local STATE_MAP = {
	Butterfly = Butterfly,
	Standing1 = Standing1,
	Standing2 = Standing2,
	Standing3 = Standing3,
	Blocker0 = Blocker0,
	Blocker1 = Blocker1,
	Blocker2 = Blocker2,
	Glove0 = Glove0,
	Glove1 = Glove1,
	Glove2 = Glove2,
	Poke = Poke,
}

local fsm_goalie = {}

function fsm_goalie.init(context: T.GoalieStateMachine, entity: jecs.Entity, world: jecs.World)
	--local fsm = world:get(entity, components.GoalieStateMachine)
	STATE_MAP[context.current].onEnter(context, entity, world)
end

function fsm_goalie.changeState(
	context: T.GoalieStateMachine,
	entity: jecs.Entity,
	world: jecs.World,
	new_state: string
)
	--local fsm = world:get(entity, components.GoalieStateMachine)
	--if not fsm then
	--return
	--end

	local previous = context.current
	local current = new_state

	STATE_MAP[previous].onExit(context, entity, world)

	context.previous = previous
	context.current = current

	world:set(entity, components.GoalieStateMachine, context)

	STATE_MAP[current].onEnter(context, entity, world)
end

function fsm_goalie.run(context: T.GoalieStateMachine, entity: jecs.Entity, world: jecs.World, dt: number): string?
	--local fsm = world:get(entity, components.GoalieStateMachine)
	local next_state = STATE_MAP[context.current].onUpdate(context, entity, world, dt)
	if next_state then
		fsm_goalie.changeState(context, entity, world, next_state)
		return next_state
	end
	return nil
end

return fsm_goalie
