local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

return function(world: jecs.World, name: string, color: BrickColor)
	local team = Instance.new("Team")
	team.TeamColor = color
	team.Name = name
	team.Parent = game:GetService("Teams")
	team.AutoAssignable = false
	CollectionService:AddTag(team, name)

	local entity = world:entity()

	world:set(entity, components.Team, team)
	world:set(entity, components.Score, 0)

	world:add(entity, replecs.networked)
	world:add(entity, jecs.pair(replecs.reliable, components.Score))
	world:add(entity, jecs.pair(replecs.reliable, components.Abbreviation))
	--world:add(entity, jecs.pair(replecs.reliable, components.Model))
	world:add(entity, jecs.pair(replecs.reliable, components.UUID))
	world:add(entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(entity, jecs.pair(replecs.pair, components.PlayState))

	return entity
end
