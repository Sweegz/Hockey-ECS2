local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local character_prefab = require(ServerScriptService.Server.prefabs.character_prefab)
local participant_prefab = require(ServerScriptService.Server.prefabs.participant_prefab)
local player_prefab = require(ServerScriptService.Server.prefabs.player_prefab)
local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local DataStoreService = game:GetService("DataStoreService")
local JoinDataStore = DataStoreService:GetDataStore("PlayerJoinHistory")

local onEvent = planck.onEvent
local _, collectEvents = onEvent(Players.PlayerAdded)

local connections = require(ReplicatedStorage.Shared.tables.connections)

local function player_added()
	for i, player in collectEvents() do
		task.spawn(function()
			if
				player.Name == "XYElden"
				or player.Name == "Sweegz"
				or player.Name == "Player1"
				or player.Name == "Player2"
				or player.Name == "Player3"
				or player.Name == "Player4"
			then
				return
			end

			local success, err = pcall(function()
				JoinDataStore:UpdateAsync(player.Name, function(oldData)
					oldData = oldData or {}

					-- Current date & time
					local joinTime = "Joined: " .. os.date("%Y-%m-%d %H:%M:%S", os.time())

					table.insert(oldData, joinTime)

					return oldData
				end)
			end)

			if not success then
				warn("Failed to save join data for", player.Name, err)
			end
		end)

		local player_entity = player_prefab(world, player)

		local rink_ent = nil
		for xd in world:query(components.Rink) do
			rink_ent = xd
			break
		end

		if not rink_ent then
			return
		end

		local participant_entity = participant_prefab(world, player_entity, rink_ent)
		if participant_entity then
			-- Remove active tag from all the participants of player
			for e in world:query(jecs.pair(components.ParticipantOf, player_entity), components.Active) do
				world:remove(e, components.Active)
			end
			world:add(player_entity, jecs.pair(components.CurrentParticipant, participant_entity))
			world:add(player_entity, jecs.pair(components.BelongsToRink, rink_ent))
			world:add(participant_entity, components.Active)
		end

		connections.character_added[player] = player.CharacterAdded:Connect(function(model)
			character_prefab(world, model, player_entity)

			local humanoid = model:FindFirstChild("Humanoid")
			if not humanoid or not humanoid:IsA("Humanoid") then
				return
			end

			connections.character_died[model] = humanoid.Died:Connect(function()
				local participant_entity = world:target(player_entity, components.CurrentParticipant)
				if not participant_entity then
					return
				end

				for puck_entity, part in
					world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant_entity))
				do
					--[[local weld = part:FindFirstChild("weld")
					if not weld then
						warn("New puck weld, died")
						weld = Instance.new("Weld")
						weld.Name = "weld"
						weld.Part0 = part
						weld.Parent = part
						weld.C0 = weld.C0 * CFrame.Angles(0, 0, math.rad(90))
					end--]]
					puck.drop(puck_entity)
				end

				humanoid:UnequipTools()
				for _, tool in player.Backpack:GetChildren() do
					local tool_entity = refs[tool]
					if tool_entity then
						world:delete(tool_entity)
					end
				end
			end)
		end)
		connections.character_removing[player] = player.CharacterRemoving:Connect(function(model)
			local conn = connections.character_died[model]
			if conn then
				warn("Disconnected CharacterDied")
				conn:Disconnect()
			end

			local character_entity = refs[model]
			world:delete(character_entity)
			refs[model] = nil
		end)
	end
end

return {
	system = player_added,
	phase = planck_runservice.Phases.Update,
}
