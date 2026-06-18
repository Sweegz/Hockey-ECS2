local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local T = require(ReplicatedStorage.Shared.types)
local sound_manager = require(ReplicatedStorage.Shared.utility.sound_manager)

local SoundEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sound") :: RemoteEvent

local onEvent = planck.onEvent
local _, onClientEvents = onEvent(SoundEvent.OnClientEvent)

local function receive_goal_event()
	for _, sound_event_data: T.SoundEvent in onClientEvents() do
		local part = sound_event_data.part
		if not part then
			continue
		end

		local sound_path = sound_event_data.sound_path
		if not sound_path then
			continue
		end

		local volume = sound_event_data.volume
		if not volume then
			continue
		end

		local length = sound_event_data.length
		if not length then
			continue
		end

		sound_manager.play_folder(part, sound_path, volume, length)
		print(part, sound_path, volume, length)
	end
end

return {
	system = receive_goal_event,
	phase = planck_runservice.Phases.PostSimulation,
}
