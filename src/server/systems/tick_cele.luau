local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.CanCelebrate):cached()

function tick_cele()
	for entity, cele in query:iter() do
		if tick() > cele.timestamp + cele.duration then
			world:remove(entity, components.CanCelebrate)
		end
	end
end

return {
	system = tick_cele,
	phase = planck_runservice.Phases.Update,
}
