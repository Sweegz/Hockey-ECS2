local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

local query_out_of_bounds =
	world:query(components.BasePart):with(components.Puck, components.OutOfBounds):without(components.Lifetime):cached()

local function teleport_oob_pucks()
	for entity, part in query_out_of_bounds do
		local rink_entity = world:target(entity, components.BelongsToRink)
		if not rink_entity then
			continue
		end

		local rink_model = world:get(rink_entity, components.Model)
		if not rink_model then
			continue
		end

		local primary_part = rink_model.PrimaryPart
		if not primary_part then
			return
		end

		world:set(rink_entity, jecs.pair(components.PlayState, components.RoundOutOfBounds), {
			processed = false,
		})

		local data: T.Lifetime = {
			duration = 2,
			created = os.clock(),
		}

		world:set(entity, components.Lifetime, data)
	end
end

return {
	system = teleport_oob_pucks,
	phase = planck_runservice.Phases.Update,
}
