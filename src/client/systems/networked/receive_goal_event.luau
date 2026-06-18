local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local replicator = require(ReplicatedStorage.Shared.replicator)
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

local GoalEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GoalEvent") :: RemoteEvent

local onEvent = planck.onEvent
local _, onClientEvents = onEvent(GoalEvent.OnClientEvent)

local function receive_goal_event()
	for _, goal_event_data: T.GoalEvent in onClientEvents() do
		local net_server = goal_event_data.net :: number
		local rink_server = goal_event_data.rink :: number
		local hit_server = goal_event_data.hit :: number
		if not net_server or not rink_server or not hit_server then
			return
		end

		local net_client = replicator.client:get_client_entity(net_server)
		local rink_client = replicator.client:get_client_entity(rink_server)
		local hit_client = replicator.client:get_client_entity(hit_server)

		if not net_client or not rink_client or not hit_client then
			return
		end

		local goal_entity = world:entity()
	
        -- stylua: ignore
        world:set(goal_entity, components.GoalEvent, {
            hit = hit_client,
            net = net_client,
            rink = rink_client,
        } :: T.GoalEvent)

		world:add(goal_entity, components.Destroy)
	end
end

return {
	system = receive_goal_event,
	phase = planck_runservice.Phases.PreUpdate,
}
