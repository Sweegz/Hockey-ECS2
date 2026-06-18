local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

local query_goal_events = world:query(components.GoalEvent):cached()

local function destroy_entity(entity: jecs.Entity, duration: number)
	local data: T.Lifetime = {
		duration = duration,
		created = os.clock(),
	}

	world:set(entity, components.Lifetime, data)
end

local function increment_opposing_teams_score(net_entity: jecs.Entity, rink_entity: jecs.Entity)
	-- stylua: ignore

	-- Loop through all the teams in rink and update their scores, if not belonging to the team of the net
	for team_entity, score in world:query(components.Score, components.Team, jecs.pair(components.BelongsToRink, rink_entity)) do
		local net_team_entity = world:target(net_entity, components.BelongsToTeam)

		if not net_team_entity then
			continue
		end

		if team_entity == net_team_entity then
			continue
		end

		world:set(team_entity, components.Score, score + 1)
	end

	for participant_entity in world:query(components.Active, jecs.pair(components.BelongsToRink, rink_entity)) do
		local team_entity = world:target(participant_entity, components.BelongsToTeam)
		local net_team_entity = world:target(net_entity, components.BelongsToTeam)

		if not net_team_entity then
			continue
		end

		if team_entity == net_team_entity then
			world:set(participant_entity, components.CanCelebrate, {
				timestamp = tick(),
				duration = 10,
				tag = "Negative",
			})
		else
			world:set(participant_entity, components.CanCelebrate, {
				timestamp = tick(),
				duration = 10,
				tag = "Default",
			})
		end
	end
end

local function goal_event()
	for entity, event in query_goal_events:iter() do
		local hit_entity = event.hit
		local net_entity = event.net
		local rink_entity = event.rink

		increment_opposing_teams_score(net_entity, rink_entity)
		world:set(rink_entity, jecs.pair(components.PlayState, components.RoundGoal), {
			processed = false,
		})
		world:set(rink_entity, components.Music, nil)

		local data: T.Lifetime = {
			duration = 6,
			created = os.clock(),
		}

		world:set(hit_entity, components.Lifetime, data)
	end
end

return {
	system = goal_event,
	phase = planck_runservice.Phases.PostUpdate,
}
