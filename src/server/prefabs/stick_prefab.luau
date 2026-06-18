local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

local tool_prefab = require(script.Parent.tool_prefab)

return function(world: jecs.World)
	local stick_entity = tool_prefab(world, ReplicatedStorage:FindFirstChild("Stick"):Clone() :: Tool)
	world:set(stick_entity, jecs.Name, "Stick")

	world:add(stick_entity, components.Stick)

	world:add(stick_entity, jecs.pair(replecs.reliable, components.Stick))
	world:add(stick_entity, jecs.pair(replecs.pair, components.PlayState))
	world:add(stick_entity, jecs.pair(replecs.pair, components.CurrentParticipant))
	world:add(stick_entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(stick_entity, jecs.pair(replecs.pair, components.BelongsToTeam))
	world:add(stick_entity, jecs.pair(replecs.reliable, components.ServerStickState))

	return stick_entity
end
