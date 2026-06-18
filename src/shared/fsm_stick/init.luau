local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

local Check = require(script.Check)
local Default = require(script.Default)
local GlideLeft = require(script.GlideLeft)
local GlideRight = require(script.GlideRight)
local HighTip = require(script.HighTip)
local KneeBlock = require(script.KneeBlock)
local LayingBlock = require(script.LayingBlock)
local LowTip = require(script.LowTip)
local Pokecheck = require(script.Pokecheck)
local RaiseHand = require(script.RaiseHand)
local Shooting = require(script.Shooting)
local Shove = require(script.Shove)
local Slapshot = require(script.Slapshot)
local StandingBlock = require(script.StandingBlock)
local T = require(script.Parent.types)
local replicator = require(script.Parent.replicator)

local STATE_MAP = {
	Default = Default,
	GlideLeft = GlideLeft,
	GlideRight = GlideRight,
	Shooting = Shooting,
	Check = Check,
	LowTip = LowTip,
	HighTip = HighTip,
	Shove = Shove,
	RaiseHand = RaiseHand,
	StandingBlock = StandingBlock,
	LayingBlock = LayingBlock,
	KneeBlock = KneeBlock,
	Slapshot = Slapshot,
	Pokecheck = Pokecheck,
}

local fsm_stick = {}

function fsm_stick.init(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World)
	STATE_MAP[context.current].onEnter(context, entity, world)
end

local SSTate = ReplicatedStorage:FindFirstChild("SSTate") :: RemoteEvent

function fsm_stick.changeState(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World, new_state: string)
	local previous = context.current
	local current = new_state

	STATE_MAP[previous].onExit(context, entity, world)

	context.previous = previous
	context.current = current

	world:set(entity, components.StickStateMachine, context)

	STATE_MAP[current].onEnter(context, entity, world)

	local server_entity = replicator.client:get_server_entity(entity)
	if server_entity then
		SSTate:FireServer(server_entity, context.current, context.previous)
	end
end

function fsm_stick.run(context: T.StickStateMachine, entity: jecs.Entity, world: jecs.World, dt: number): string?
	local next_state = STATE_MAP[context.current].onUpdate(context, entity, world, dt)
	if next_state then
		fsm_stick.changeState(context, entity, world, next_state)
		return next_state
	end
	return nil
end

return fsm_stick
