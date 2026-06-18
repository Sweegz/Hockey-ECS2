local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local input_state = require(StarterPlayer.StarterPlayerScripts.Client.utility.input_state)

local onEvent = planck.onEvent
local _, onInputBegan = onEvent(UserInputService.InputBegan)
local _, onInputEnded = onEvent(UserInputService.InputEnded)

local function get_input_key(input): string?
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		return "Mouse1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "Mouse2"
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		return "Mouse3"
	end
	return nil
end

local function input_system()
	table.clear(input_state.pressed)
	table.clear(input_state.released)

	for _, input, game_processed_event in onInputBegan() do
		if game_processed_event then
			continue
		end

		local key = get_input_key(input)
		if not key then
			continue
		end

		if not input_state.held[key] then
			input_state.held[key] = tick()
			input_state.pressed[key] = true
		end
	end

	for _, input, game_processed_event in onInputEnded() do
		if game_processed_event then
			continue
		end

		local key = get_input_key(input)
		if not key then
			continue
		end

		if input_state.held[key] then
			input_state.held[key] = nil
			input_state.released[key] = true
		end
	end
end

return {
	system = input_system,
	phase = planck_runservice.Phases.PreSimulation,
}
