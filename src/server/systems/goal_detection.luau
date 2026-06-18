local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local collision_queue = require(ReplicatedStorage.Shared.tables.collision_queue)
local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local GoalEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GoalEvent") :: RemoteEvent

local query_goal_collisions =
	world:query(components.Touched):with(jecs.pair(components.GoalReceiver, jecs.Wildcard)):cached()

local function goal_detection()
	for entity, connection in query_goal_collisions:iter() do
		local collisions = collision_queue[entity]
		if not collisions then
			continue
		end

		for _, hit: any in collisions do
			local target_entity = refs[hit]
			if not target_entity or not world:has(target_entity, components.GoalActivator) then
				continue
			end

			local net_entity = world:target(entity, components.GoalReceiver)
			if not net_entity then
				continue
			end

			local team_entity = net_entity and world:target(net_entity, components.BelongsToTeam)
			if not team_entity then
				continue
			end

			local rink_entity = world:target(team_entity, components.BelongsToRink)
			local hit_rink_entity = world:target(target_entity, components.BelongsToRink)

			if rink_entity and hit_rink_entity and rink_entity == hit_rink_entity then
				local goalEntity = world:entity()

				local goal_event_data: T.GoalEvent = {
					hit = target_entity :: jecs.Entity,
					net = net_entity :: jecs.Entity,
					rink = rink_entity :: jecs.Entity,
				}

				local owner = world:target(target_entity, components.Owner)
				if owner then
					puck.drop(target_entity)
				end

				--world:remove(target_entity, components.Owner)
				world:remove(target_entity, components.GoalActivator)

				-- stylua: ignore
				world:set(goalEntity, components.GoalEvent, goal_event_data)
				GoalEvent:FireAllClients(goal_event_data)

				world:add(goalEntity, components.Destroy)

				--[[task.delay(2, function()
					local p_Entity_new = puck_prefab(world, rink_entity)
					if not p_Entity_new then
						return
					end

					local part = world:get(p_Entity_new, components.BasePart)
					if not part then
						return
					end

					part.Anchored = true
					task.wait(2)
					part.Anchored = false
				end)--]]
			end
		end
	end
end

return {
	system = goal_detection,
	phase = planck_runservice.Phases.Update,
}
