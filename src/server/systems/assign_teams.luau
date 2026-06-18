local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function find_smallest_team(world: jecs.World, rink_entity: jecs.Entity)
	local min_team, min_count = nil, 10000

	for entity in world:query(components.Team, jecs.pair(components.BelongsToRink, rink_entity)) do
		local count = 0

		for _ in
			world:query(jecs.pair(components.ParticipantOf, jecs.Wildcard), jecs.pair(components.BelongsToTeam, entity))
		do
			count += 1
		end

		if count < min_count then
			min_count = count
			min_team = entity
		end
	end

	return min_team
end

local query_participants_without_team = world
	:query(jecs.pair(components.ParticipantOf, jecs.Wildcard), jecs.pair(components.BelongsToRink, jecs.Wildcard))
	:without(jecs.pair(components.BelongsToTeam, jecs.Wildcard))
	:cached()

local function assign_teams()
	for entity in query_participants_without_team:iter() do
		local rink_entity = world:target(entity, components.BelongsToRink)
		if not rink_entity then
			continue
		end

		local team_entity = find_smallest_team(world, rink_entity)
		if team_entity then
			world:add(entity, jecs.pair(components.BelongsToTeam, team_entity))
		end

		for e in world:query(jecs.pair(components.CurrentParticipant, entity)) do
			world:add(e, jecs.pair(components.BelongsToTeam, team_entity))
		end
	end
end

return {
	system = assign_teams,
	phase = planck_runservice.Phases.Update,
}
