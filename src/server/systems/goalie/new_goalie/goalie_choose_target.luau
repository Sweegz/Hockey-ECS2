local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world
	:query(components.CenterCFrame)
	:with(components.GoalieStateMachine, jecs.pair(components.BelongsToRink, jecs.Wildcard))
	:cached()

local function goalie_choose_target()
	for g_Entity, g_center_cframe in query:iter() do
		local rink_entity = world:target(g_Entity, components.BelongsToRink) :: jecs.Entity

		local center_pos: Vector3 = g_center_cframe.Position

		local closest_dist = 9999
		local p_entity = nil
		local p_part = nil

		for t_entity, t_part, t_transform in
			world
				:query(components.BasePart, components.Transform, components.Puck)
				:with(jecs.pair(components.BelongsToRink, rink_entity))
				:without(components.Lifetime)
				:iter()
		do
			local dist = (t_transform.Position - center_pos).Magnitude
			if dist < closest_dist then
				p_entity = t_entity
				p_part = t_part
				closest_dist = dist
			end
		end

		if p_entity and p_part then
			world:set(g_Entity, jecs.pair(components.Tracking, p_entity), p_part)
		else
			local target = world:target(g_Entity, components.Tracking)
			if target then
				world:remove(g_Entity, jecs.pair(components.Tracking, target))
			end
			world:remove(g_Entity, components.TrackingDirection)
			world:remove(g_Entity, components.TrackingDistance)
		end
	end
end

return {
	system = goalie_choose_target,
	phase = planck_runservice.Phases.PostSimulation,
	runConditions = {
		planck.timePassed(1),
	},
}
