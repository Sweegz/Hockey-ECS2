local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world
	:query(components.BasePart, components.Transform)
	:with(components.Puck, jecs.pair(components.PlayState, components.RoundActive))
	:without(components.Lifetime)
	:cached()

function last_position()
	for e, part, cframe in query:iter() do
		local rink_entity = world:target(e, components.BelongsToRink)
		if rink_entity then
			world:set(rink_entity, components.LastPosition, cframe.Position)
		end
	end
end

return {
	system = last_position,
	planck_runservice.Phases.Update,
}
