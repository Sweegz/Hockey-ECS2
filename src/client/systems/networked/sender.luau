local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)

local compression = require(ReplicatedStorage.Shared.interpolation.compression)
local interpolation_config = require(ReplicatedStorage.Shared.interpolation.interpolation_config)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local player = Players.LocalPlayer
local ReplicateTransform = ReplicatedStorage:WaitForChild("RT")

local tick_rate = interpolation_config.TICK_RATE
local interval = 1 / tick_rate

local function sender()
	local character = player.Character
	if not character then
		return
	end

	local primary_part = character.PrimaryPart
	if not primary_part then
		return
	end

	local character_entity = refs[character]
	if not character_entity then
		return
	end

	interval -= scheduler:getDeltaTime()
	if interval <= 0 then
		interval = 1 / tick_rate

		local SNAPSHOT_SIZE = 48
		local snapshotBuffer = buffer.create(SNAPSHOT_SIZE)

		-- pack the snapshot
		compression.pack_snapshot_data_for_sender(snapshotBuffer, os.clock(), primary_part.CFrame)

		-- send
		ReplicateTransform:FireServer(snapshotBuffer)
	end
end

return {
	system = sender,
	phase = planck_runservice.Phases.PreSimulation,
}
