local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "LayingBlock"

local global_track = nil
local finished = false

State.onEnter = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)

	if track then
		--print(track)
		track:Play(context.BLEND_DURATION)
		global_track = track
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	finished = false

	world:set(entity, components.StickStateMachine, context)

	world:add(entity, components.PreventCollect)
	world:add(character_entity, components.PreventCollect)

	world:add(character_entity, components.MovementDisabled)

	local character = world:get(character_entity, components.Model)
	local player_entity = world:parent(character_entity)
	for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
		for _, child in tool:GetChildren() do
			if child:IsA("MeshPart") then
				--child.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.3, 0.01, 1, 5)
			end
		end
	end

	for _, child in character:GetChildren() do
		if child:IsA("BasePart") then
			--child.CustomPhysicalProperties = PhysicalProperties.new(0.4, 0.3, 0.01, 1, 5)
		end
	end

	local character = world:get(character_entity, components.Model)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 0
	end

	print("Laying")
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Stop(0)
	end

	world:remove(entity, components.PreventCollect)
	world:remove(character_entity, components.PreventCollect)

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end

	world:remove(character_entity, components.MovementDisabled)

	local character = world:get(character_entity, components.Model)
	local player_entity = world:parent(character_entity)
	for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
		for _, child in tool:GetChildren() do
			if child:IsA("MeshPart") then
				--child.CustomPhysicalProperties = PhysicalProperties.new(11.24, 0.2, 0.5, 1, 1)
			end
		end
	end

	print("Exit")

	for _, child in character:GetChildren() do
		if child:IsA("BasePart") then
			--child.CustomPhysicalProperties = PhysicalProperties.new(4, 0.3, 0.5, 1, 0.3)
		end
	end

	local character = world:get(character_entity, components.Model)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 38
	end
end

local time = 0

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	time += dt
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local participant = world:target(entity, components.CurrentParticipant)
	if not participant then
		return
	end

	local rink_entity = world:target(participant, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if world:has(character_entity, components.Ragdolled) then
		return "Default"
	end

	local has_puck = false

	for p_Entity in world:query(components.Puck, jecs.pair(components.Owner, participant)) do
		has_puck = true
		break
	end

	local c_Model = world:get(character_entity, components.Model)
	if not c_Model then
		return
	end

	local HRP = c_Model:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local next_state = nil

	--local track = Shared.getTrack(character_entity, world, State.Name)

	if global_track.TimePosition > 0.8 and not finished then
		global_track:AdjustSpeed(0)
	end

	if not command.lying_block and global_track.TimePosition > 0.8 then
		finished = true
		global_track:AdjustSpeed(1)
	end

	if has_puck or not global_track.IsPlaying then
		time = 0
		next_state = "Default"
	end

	return next_state
end

return State
