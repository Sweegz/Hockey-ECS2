local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local random = Random.new(tick())

local function get_random_sound(instance: Instance): Sound?
	local sounds = instance:GetChildren()
	if #sounds > 0 then
		local random_index = random:NextInteger(1, #sounds)
		local sound = sounds[random_index]
		if sound:IsA("Sound") then
			return sound
		end
	end
	return nil
end

local MUSIC = SoundService:FindFirstChild("Music")

local function ease_out(t)
	return 1 - ((1 - t) ^ 2)
end

local function ease_in(t)
	return t * t
end

local queryA = world:query(components.Rink):with(components.PlayIntermissionMusic):without(components.Music):cached()

local queryB = world:query(components.Music):with(jecs.pair(components.PlayState, components.RoundActive)):cached()

local function play_music()
	for e in queryA:iter() do
		local sound = get_random_sound(MUSIC)
		if sound then
			print("PLAY MUSIC")
			sound:Play()
			world:set(e, components.Music, {
				sound = sound,
				volume = sound.Volume,
				time_position = sound.TimePosition,
			})
		end
		world:remove(e, components.PlayIntermissionMusic)
	end --]]

	for e, sound_data in queryB:iter() do
		world:remove(e, components.Music)
		print("REMOVE MUSIC")
		if not sound_data then
			continue
		end

		task.defer(function()
			for t = 0, sound_data.volume, 0.01 do
				sound_data.sound.Volume = sound_data.sound.Volume * (1 - ease_out(t))
				task.wait(0.01)
			end
			print("Stopped")
			sound_data.sound:Stop()
			sound_data.sound.Volume = sound_data.volume
			sound_data.sound.TimePosition = sound_data.time_position
		end)
		--sound:Stop()
	end
end

return {
	system = play_music,
	planck_runservice.Phases.PreSimulation,
}
