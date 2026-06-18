local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_run_service = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local connections = require(ReplicatedStorage.Shared.tables.connections)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local puck = require(ServerScriptService.Server.utility.puck)
local JoinDataStore = DataStoreService:GetDataStore("PlayerJoinHistory")

local onEvent = planck.onEvent
local _, collectEvents = onEvent(Players.PlayerRemoving)

local function player_removing()
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
					local joinTime = "Left: " .. os.date("%Y-%m-%d %H:%M:%S", os.time())

					table.insert(oldData, joinTime)

					return oldData
				end)
			end)

			if not success then
				warn("Failed to save join data for", player.Name, err)
			end
		end)

		local player_entity = refs[player]
		world:add(player_entity, components.Destroy)
		for entity in world:query(jecs.pair(components.ParticipantOf, player_entity)) do
			world:remove(entity, components.Active)
		end

		for participant_entity in world:query(jecs.pair(components.ParticipantOf, player_entity)) do
			for puck_entity, part in
				world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant_entity))
			do
				puck.drop(puck_entity)
			end
		end

		local listener = world:get(player_entity, components.ChatListener)
		if listener then
			listener.disconnect()
		end

		local conn1 = connections.character_added[player]
		if conn1 then
			warn("Disconnected CharacterAdded")
			conn1:Disconnect()
		end

		local conn2 = connections.character_removing[player]
		if conn2 then
			warn("Disconnected CharacterRemoving")
			conn2:Disconnect()
		end

		refs[player] = nil
	end
end

return {
	system = player_removing,
	phase = planck_run_service.Phases.Update,
}
