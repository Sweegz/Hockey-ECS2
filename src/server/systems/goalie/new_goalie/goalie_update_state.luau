local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local components = require(ReplicatedStorage.Shared.components)
local fsm_goalie = require(ServerScriptService.Server.fsm_goalie)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world
	:query(components.GoalieStateMachine, components.StateDecision)
	:with(jecs.pair(components.Tracking, jecs.Wildcard))
	:cached()

local function goalie_update_state()
	for g_entity, g_fsm, g_decision in query:iter() do
		if g_fsm.current ~= g_decision and not g_fsm.busy then
			print(g_decision)
			fsm_goalie.changeState(g_fsm, g_entity, world, g_decision)
		end
	end
end

return {
	system = goalie_update_state,
	phase = planck_runservice.Phases.PostUpdate,
}
