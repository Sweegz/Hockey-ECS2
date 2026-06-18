local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local query_power = world:query(components.StickStateMachine, components.Power):cached()

local function f(x)
	return math.max(0, math.min(x, 1, 3 - x))
end

local function charging_system()
	local dt = scheduler:getDeltaTime()

	for entity, fsm, power in query_power:iter() do
		local participant = world:target(entity, components.CurrentParticipant)
		if not participant then
			continue
		end

		local rink_entity = world:target(participant, components.BelongsToRink)
		if not rink_entity then
			continue
		end

		if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
			power.value = 0
			world:set(entity, components.Power, power)
			continue
		end

		local is_charging = false
		local rate = 0

		if fsm.current == "Default" or fsm.current == "GlideRight" or fsm.current == "GlideLeft" then
			if command.power and command.power_reset then
				is_charging = true
				rate = power.rate
			end
		end
		if fsm.current == "Slapshot" and command.slapshot then
			local time_held = tick() - command.slapshot
			is_charging = true
			rate = f(time_held) * power.max
		end

		if is_charging then
			power.value = math.min(power.value + rate * dt, power.max)
		end

		world:set(entity, components.Power, power)
	end
end

return {
	system = charging_system,
	phase = planck_runservice.Phases.Last,
}
