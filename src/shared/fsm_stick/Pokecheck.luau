local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local replicator = require(ReplicatedStorage.Shared.replicator)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)

local State = {} :: T.StateStruct

State.Name = "Pokecheck"

local pokechecked = false

State.onEnter = function(context: T.StickStateMachine, entity, world)
	pokechecked = false

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
	world:remove(entity, components.PreventCollect)
	world:remove(character_entity, components.PreventCollect)

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end
end

local time = 0

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	time += dt
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local character = world:get(character_entity, components.Model)
	if not character then
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

	if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
		return "Default"
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

	local shaft = c_Model:FindFirstChild("Front", true)
	if not shaft then
		return
	end

	local blade = c_Model:FindFirstChild("Blade", true)
	if not blade then
		return
	end

	local box_params = OverlapParams.new()
	box_params.FilterType = Enum.RaycastFilterType.Exclude
	box_params.FilterDescendantsInstances = { character }

	local next_state = nil

	if not pokechecked then
		local pucks = {}

		for p_Entity, p_Part in world:query(components.Ghost):without(components.ClientPuckTag):iter() do
			pucks[p_Entity] = p_Part.Position
		end

		for e, collect_parts in world:query(components.CollectCheck):with(components.Stick):iter() do
			for p_Entity, p_Pos in pairs(pucks) do
				local parts = collect_parts.parts

				for _, part in parts do
					local dist = (part.Position - p_Pos).Magnitude
					if dist <= 3 then
						local server_entity = replicator.client:get_server_entity(p_Entity)
						if not server_entity then
							return
						end

						Action:FireServer("Pokecheck", {
							entity = server_entity,
							velocity = HRP.AssemblyLinearVelocity,
							dir = HRP.CFrame.LookVector,
						})

						pokechecked = true
						return
					end
				end
			end
		end
	end

	--local track = Shared.getTrack(character_entity, world, State.Name)

	if time > 0.8 or has_puck then
		time = 0
		next_state = "Default"
	end

	return next_state
end

return State
