local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local CheaterDataStore = DataStoreService:GetDataStore("CheaterData")

local M = ReplicatedStorage:FindFirstChild("M") :: RemoteEvent
local onEvent = planck.onEvent
local _, onCheatEvent = onEvent(M.OnServerEvent)

local function anti_cheat()
	for _, player: Player in onCheatEvent() do
		print("DETECTED", player)

		task.spawn(function()
			local success, err = pcall(function()
				CheaterDataStore:UpdateAsync(player.Name, function(oldData)
					oldData = oldData or {}

					-- Current date & time
					local time = "Cheated: " .. os.date("%Y-%m-%d %H:%M:%S", os.time())

					table.insert(oldData, time)

					return oldData
				end)
			end)

			if not success then
				warn("Failed to save join data for", player.Name, err)
			end
		end)
	end
end

return {
	system = anti_cheat,
	phase = planck_runservice.Phases.Update,
}
