local sound_manager = {}

local cooldowns = {} :: { [Instance]: boolean }

local random = Random.new(tick())

local function get_random_sound(folder: Folder): Sound?
	local sounds = folder:GetChildren()
	if #sounds > 0 then
		local random_index = random:NextInteger(1, #sounds)
		local sound = sounds[random_index]
		if sound:IsA("Sound") then
			return sound
		end
	end
	return nil
end

function sound_manager.play_sound(parent: Instance, sound: Sound, volume: number)
	task.spawn(function()
		local sound_copy = sound:Clone()
		sound_copy.Parent = parent
		sound_copy.Volume = volume
		local length = math.ceil(sound_copy.TimeLength)
		sound_copy:Play()
		task.wait(length)
		sound_copy:Destroy()
	end)
end

function sound_manager.play_folder(parent: Instance, folder: Folder, volume: number, cooldown: number)
	if cooldowns[folder] then
		return
	end

	local sound = get_random_sound(folder)
	if not sound then
		return
	end

	cooldowns[folder] = true

	sound_manager.play_sound(parent, sound, volume)

	task.delay(cooldown, function()
		cooldowns[folder] = nil
	end)
end

return sound_manager
