local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local query_timers = world:query(jecs.pair(components.Timer, jecs.Wildcard)):cached()

local function timer_tick()
	for entity, time in query_timers:iter() do
		local target = world:target(entity, components.Timer)
		if time < 0 then
			if target then
				world:remove(entity, jecs.pair(components.Timer, target))
			end
			continue
		end

		local new_time = time - scheduler:getDeltaTime()
		if target then
			world:set(entity, jecs.pair(components.Timer, target), new_time)
		end
	end
end

return {
	system = timer_tick,
	phase = planck_runservice.Phases.First,
}
