local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local world = require(ReplicatedStorage.Shared.world)

local query = world:query(jecs.pair(components.PlayState, components.RoundReset)):with(components.Rink):cached()

local function round_reset()
	for r_Entity, data in query:iter() do
		if not data.processed then
			print("RoundReset")
			data.processed = true
			world:set(r_Entity, jecs.pair(components.PlayState, components.RoundReset), data)

			world:set(r_Entity, components.RoundTimer, {
				timestamp = tick(),
				duration = 5,
			})
			world:add(r_Entity, components.PlayIntermissionMusic)
		end

		local round_timer = world:get(r_Entity, components.RoundTimer)
		if round_timer then
			if tick() > round_timer.timestamp + round_timer.duration then
				world:set(r_Entity, jecs.pair(components.PlayState, components.RoundFaceoff), {
					processed = false,
					cause = "Reset",
				})
			end
		end
	end
end

return {
	system = round_reset,
	phase = planck_runservice.Phases.Last,
}
