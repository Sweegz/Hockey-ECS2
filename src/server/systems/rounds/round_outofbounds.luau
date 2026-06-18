local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local world = require(ReplicatedStorage.Shared.world)

local query = world:query(jecs.pair(components.PlayState, components.RoundOutOfBounds)):with(components.Rink):cached()

local function round_outofbounds()
	for r_Entity, data in query:iter() do
		if not data.processed then
			print("RoundOutOfBounds")
			data.processed = true
			world:set(r_Entity, jecs.pair(components.PlayState, components.RoundOutOfBounds), data)

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
					cause = "OOB",
				})
			end
		end
	end
end

return {
	system = round_outofbounds,
	phase = planck_runservice.Phases.Last,
}
