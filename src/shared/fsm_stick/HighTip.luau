local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local replicator = require(ReplicatedStorage.Shared.replicator)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "HighTip"

local did_tip = false

State.onEnter = function(context: T.StickStateMachine, entity, world)
	did_tip = false
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)

	if track then
		--print(track)
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	world:set(entity, components.StickStateMachine, context)

	world:add(entity, components.PreventCollect)
	world:add(character_entity, components.PreventCollect)
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end

	world:remove(entity, components.PreventCollect)
	world:remove(character_entity, components.PreventCollect)
end

local time = 0

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

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

	local character = world:get(character_entity, components.Model)
	if not character then
		return
	end

	local rink_entity = world:target(participant, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if world:has(character_entity, components.Ragdolled) then
		return "Default"
	end

	if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
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

	local front = c_Model:FindFirstChild("GluedFront", true)
	if not front then
		return
	end

	local shaft = c_Model:FindFirstChild("Shaft", true)
	if not shaft then
		return
	end

	local box_params = OverlapParams.new()
	box_params.FilterType = Enum.RaycastFilterType.Exclude
	box_params.FilterDescendantsInstances = { character }

	if not did_tip then
		local hits = workspace:GetPartBoundsInBox(
			CFrame.new((HRP.Position + shaft.Position) / 2),
			Vector3.new(5, 2, 5),
			box_params
		)
		for _, part in ipairs(hits) do
			if part.Name == "GhostPuck" then
				local puck_entity = refs[part]
				if not puck_entity then
					return
				end
				local server_entity = replicator.client:get_server_entity(puck_entity)
				if not server_entity then
					return
				end

				Action:FireServer("Tip2", {
					stick_cframe = front.CFrame,
					dir = HRP.CFrame.LookVector,
				})
				print("TIPPED CLIENT")

				did_tip = true
				time = 0
				break
			end
		end
	end

	local next_state = nil

	--local track = Shared.getTrack(character_entity, world, State.Name)

	if time > 0.8 and did_tip then
		next_state = "Default"
	end

	if time > 0.8 and (not command.high_tip or has_puck or did_tip) then
		time = 0
		next_state = "Default"
	end

	return next_state
end

return State
