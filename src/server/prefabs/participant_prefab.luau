local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, player: jecs.Entity, rink: jecs.Entity): jecs.Entity?
	local has_participant =
		world:query(jecs.pair(components.ParticipantOf, player), jecs.pair(components.BelongsToRink, rink))

	for e in has_participant:iter() do
		return e
	end

	local participant_entity = world:entity()
	world:add(participant_entity, jecs.pair(components.ParticipantOf, player))
	world:add(participant_entity, jecs.pair(components.BelongsToRink, rink))

	local stamina_data = 100

	world:set(participant_entity, components.Stamina, stamina_data)

	world:add(participant_entity, replecs.networked)
	world:add(participant_entity, jecs.pair(replecs.pair, components.ParticipantOf))

	world:add(participant_entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(participant_entity, jecs.pair(replecs.pair, components.BelongsToTeam))
	world:add(participant_entity, jecs.pair(replecs.reliable, components.Stamina))
	world:add(participant_entity, jecs.pair(replecs.reliable, components.Active))
	world:add(participant_entity, jecs.pair(replecs.reliable, components.Benched))
	world:add(participant_entity, jecs.pair(replecs.reliable, components.CanCelebrate))
	world:add(participant_entity, jecs.pair(replecs.pair, components.PlayState))

	return participant_entity
end
