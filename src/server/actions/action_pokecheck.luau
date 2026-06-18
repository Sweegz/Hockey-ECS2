local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local action = {}

function action.pokecheck(player: Player, entity, velocity: Vector3, dir1: Vector3)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local puck_part = world:get(entity, components.BasePart)
	if not puck_part then
		return
	end

	local target_participant = world:target(entity, components.Owner)
	if not target_participant then
		return
	end

	if
		world:target(target_participant, components.BelongsToTeam)
		== world:target(participant_entity, components.BelongsToTeam)
	then
		return
	end

	local vel = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local dir2 = Vector3.new(dir1.X, 0, dir1.Z)

	puck.drop(entity, 1.5)
	puck.add_cooldown(entity, 0.5)

	puck_part.AssemblyLinearVelocity = dir2 * vel

	world:set(target_participant, jecs.pair(components.Timer, components.HitVictimCooldown), 1)

	--print(player, target)
end

return action
