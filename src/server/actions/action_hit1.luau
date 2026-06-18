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

function action.hit1(player: Player, hit: Instance, velocity: Vector3, power: number)
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

	local dir = Vector3.new(velocity.X, 0, velocity.Z).Unit

	-- Tell the client to apply hit forces

	local power_time = (power / 100) * 1.15

	local duration = power_time / 2 + 0.5

	local final_velocity = (dir * (power / 100) * 34.5) / duration

	RagdollEvent:FireClient(target_player, power, final_velocity, duration, false)

	for puck_entity in world:query(components.Puck, jecs.pair(components.Owner, target_participant)) do
		puck.drop(puck_entity, 1.5)
		puck.add_cooldown(puck_entity, 0.5)
	end

	world:set(target_participant, jecs.pair(components.Timer, components.HitVictimCooldown), 2)

	local puck_distance = nil
	for puck_entity, p_part in
		world:query(components.BasePart, components.Puck, jecs.pair(components.BelongsToRink, rink_entity))
	do
		local vector1 = (hit.Position - p_part.Position) * Vector3.new(1, 0, 1)
		puck_distance = math.round(vector1.Magnitude)
		break
	end

	world:set(target_participant, components.HitDataServer, {
		rink_entity = rink_entity,
		player1 = player,
		player2 = target_player,
		part = hit,
		start = tick(),
		duration = duration,
		power = power,
		start_position = hit.Position,
		distance_from_puck = puck_distance,
	})
end

return action
