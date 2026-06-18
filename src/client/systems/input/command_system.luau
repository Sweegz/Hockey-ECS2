local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local input_state = require(StarterPlayer.StarterPlayerScripts.Client.utility.input_state)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local LAST_POKE_TICK = 0
local DOUBLE_TAP_TIME = 0.3

local LAST_SPRINT_TICK = 0

function isMoreRecent(source: number?, target: number?): boolean
	if source and target then
		return source > target
	elseif source then
		return true
	end

	return false
end

local function command_system()
	local localplayer_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not localplayer_entity then
		return
	end

	local shift_sprint = world:get(localplayer_entity, components.ShiftSprint)

	command.shove = input_state.pressed["Q"]
	command.celebrate = input_state.pressed["T"]
	command.drop_puck = input_state.pressed["Z"]
	command.start_slapshot = input_state.pressed["Z"]
	command.cancel_slapshot = input_state.pressed["X"]
	command.pressed_lying_block = input_state.pressed["X"]
	command.power = input_state.held["Mouse1"]
	command.glide_left = input_state.held["F"]
	command.glide_right = input_state.held["G"]
	command.raise_hand = input_state.held["Space"]
	command.sprint = input_state.held["W"]
	command.fake_shot = input_state.held["Q"]
	command.chip_shot = input_state.held["E"]
	command.wrist_shot = input_state.held["X"]
	command.slapshot = input_state.held["Z"]
	command.low_tip = input_state.held["E"]
	command.high_tip = input_state.held["R"]
	command.lying_block = input_state.held["X"]
	command.kneel_block = input_state.held["C"]
	command.standing_block = input_state.held["V"]
	--command.pokecheck = input_state.pressed["Mouse1"]
	command.pokecheck = input_state.held["Mouse1"]

	if input_state.pressed["Mouse1"] then
		command.power_reset = true
	end

	if input_state.released["Mouse1"] then
		command.power_reset = false
	end

	if shift_sprint then
		if input_state.pressed["LeftControl"] then
			command.mouse_lock = not command.mouse_lock
		end

		if
			input_state.pressed["LeftShift"]
			and input_state.held["W"]
			and isMoreRecent(input_state.held["LeftShift"], input_state.held["W"])
		then
			command.sprinting = true
		end

		if input_state.released["LeftShift"] then
			command.sprinting = false
		end
	else
		if input_state.pressed["LeftShift"] then
			command.mouse_lock = not command.mouse_lock
		end

		local CUR_SPRINT_TICK = command.sprint
		if CUR_SPRINT_TICK then
			if LAST_SPRINT_TICK ~= CUR_SPRINT_TICK then
				if CUR_SPRINT_TICK - LAST_SPRINT_TICK < DOUBLE_TAP_TIME then
					command.sprinting = true
				end
				LAST_SPRINT_TICK = CUR_SPRINT_TICK
			end
		else
			command.sprinting = false
		end
	end

	local CUR_POKE_TICK = command.pokecheck
	if CUR_POKE_TICK then
		if LAST_POKE_TICK ~= CUR_POKE_TICK then
			if CUR_POKE_TICK - LAST_POKE_TICK < DOUBLE_TAP_TIME then
				command.double_pokecheck = true
			end
			LAST_POKE_TICK = CUR_POKE_TICK
		end
	else
		command.double_pokecheck = false
	end
end

return {
	system = command_system,
	phase = planck_runservice.Phases.PreSimulation,
}
