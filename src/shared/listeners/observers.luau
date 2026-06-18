--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local ob = require(ReplicatedStorage.Shared.addons.ob)
local update_scoreboards = require(ReplicatedStorage.Shared.utility.update_scoreboards)

local observers = {}

observers.score_changed = ob.observer(world:query(components.Score), function(entity: jecs.Entity, id, data)
	if RunService:IsServer() then
		update_scoreboards(world, entity)
	end
end)

observers.score_changed = ob.observer(
	world:query(components.Scoreboard, jecs.pair(components.BelongsToTeam, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if RunService:IsServer() then
			local team_entity = world:target(entity, components.BelongsToTeam)
			update_scoreboards(world, team_entity)
		end
	end
)

observers.team = ob.observer(
	world:query(jecs.pair(components.BelongsToTeam, jecs.Wildcard), jecs.pair(components.ParticipantOf, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if RunService:IsServer() then
			local player_entity = world:target(entity, components.ParticipantOf)
			if not player_entity then
				return
			end

			local player = world:get(player_entity, components.Player)
			if not player then
				return
			end

			local team_entity = world:target(entity, components.BelongsToTeam)
			if not team_entity then
				player.Team = Teams:FindFirstChild("Fans")
				player:LoadCharacterAsync()
				return
			end

			local team = world:get(team_entity, components.Team)
			if not team then
				player.Team = Teams:FindFirstChild("Fans")
				player:LoadCharacterAsync()
				return
			end

			player.Team = team
			if player.Character and player.Character.Humanoid then
				player.Character.Humanoid.Health = 0
				task.delay(0.1, function()
					player:LoadCharacterAsync()
				end)
			end
		end
	end
)

observers.tool_owner_changed = ob.observer(
	world:query(components.Tool, jecs.pair(jecs.ChildOf, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if RunService:IsServer() then
			local tool = world:get(entity, components.Tool)
			if not tool then
				return
			end

			local player_entity = world:target(entity, jecs.ChildOf)
			if not player_entity then
				return
			end

			local player = world:get(player_entity, components.Player)
			if not player then
				return
			end

			tool.Parent = player.Backpack
		end
	end
)

ob.observer(
	world:query(components.Rink, jecs.pair(components.PlayState, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if not RunService:IsServer() then
			return
		end

		local new = world:target(entity, components.PlayState)

		for e in world:query(jecs.pair(components.BelongsToRink, entity)) do
			world:set(e, jecs.pair(components.PlayState, new), data)
		end
	end
)

ob.observer(world:query(jecs.pair(components.BelongsToRink, jecs.Wildcard)), function(entity: jecs.Entity, id, data)
	if not RunService:IsServer() then
		return
	end

	local rink_entity = world:target(entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	local play_state = world:target(rink_entity, components.PlayState)
	if not play_state then
		return
	end

	local play_data = world:get(rink_entity, jecs.pair(components.PlayState, play_state))
	if not play_data then
		return
	end

	world:set(entity, jecs.pair(components.PlayState, play_state), play_data)
end)

ob.observer(
	world:query(components.Player, jecs.pair(components.CurrentParticipant, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if not RunService:IsServer() then
			return
		end

		local new = world:target(entity, components.CurrentParticipant)
		local rink = world:target(new, components.BelongsToRink)

		for e in world:query(jecs.pair(components.CurrentParticipant, entity)) do
			world:add(e, jecs.pair(components.CurrentParticipant, new))
			world:add(e, jecs.pair(components.BelongsToRink, rink))
		end
	end
)

ob.observer(
	world:query(jecs.pair(components.CurrentParticipant, jecs.Wildcard)),
	function(entity: jecs.Entity, id, data)
		if not RunService:IsServer() then
			return
		end

		local participant_entity = world:target(entity, components.CurrentParticipant)
		if not participant_entity then
			return
		end

		local team_entity = world:target(participant_entity, components.BelongsToTeam)
		if not team_entity then
			return
		end
		world:add(entity, jecs.pair(components.BelongsToTeam, team_entity))
	end
)

observers.character_added = ob.observer(world:query(components.Character), function(entity, id, data) end)

return observers
