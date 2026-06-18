local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local RagdollEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Ragdoll") :: RemoteEvent

local action = {}

function action.hit2(player: Player, hit: Instance, velocity: Vector3, dir1: Vector3)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	if not hit:IsA("BasePart") and not hit:IsA("MeshPart") then
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

	local source = character:FindFirstChild("HumanoidRootPart")
	if not source or not source:IsA("BasePart") then
		return
	end

	local hit_character = hit:FindFirstAncestorOfClass("Model")
	if not hit_character then
		return
	end

	local humanoid = hit_character:FindFirstChild("Humanoid")
	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end

	local target = hit_character:FindFirstChild("HumanoidRootPart")
	if not target or not target:IsA("BasePart") then
		return
	end

	local target_player = Players:GetPlayerFromCharacter(hit_character)
	if not target_player then
		return
	end

	local target_player_entity = refs[target_player]
	if not target_player_entity then
		return
	end

	local target_participant = world:target(target_player_entity, components.CurrentParticipant)
	if not target_participant then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if
		world:target(target_participant, components.BelongsToTeam)
		== world:target(participant_entity, components.BelongsToTeam)
	then
		return
	end

	local attach = target:FindFirstChild("RootAttachment")
	if not attach or not attach:IsA("Attachment") then
		return
	end

	local vel = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local dir2 = Vector3.new(dir1.X, 0, dir1.Z)

	local final_velocity = dir2 * math.max(30, vel)

	RagdollEvent:FireClient(target_player, 20, final_velocity, 0.2, true)

	for puck_entity in world:query(components.Puck, jecs.pair(components.Owner, target_participant)) do
		puck.drop(puck_entity, 1.5)
		puck.add_cooldown(puck_entity, 0.5)
	end

	world:set(target_participant, jecs.pair(components.Timer, components.HitVictimCooldown), 1)

	local puck_distance = nil
	for puck_entity, p_part in
		world:query(components.BasePart, components.Puck, jecs.pair(components.BelongsToRink, rink_entity))
	do
		puck_distance = math.round((hit.Position - p_part.Position).Magnitude)
		break
	end

	world:set(target_participant, components.HitDataServer, {
		rink_entity = rink_entity,
		player1 = player,
		player2 = target_player,
		part = hit,
		start = tick(),
		duration = 0.2,
		power = 20,
		start_position = hit.Position,
		distance_from_puck = puck_distance,
	})
end

return action
