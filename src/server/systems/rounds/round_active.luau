local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local world = require(ReplicatedStorage.Shared.world)

local query = world:query(jecs.pair(components.PlayState, components.RoundActive)):with(components.Rink):cached()

local function round_active()
	for r_Entity, data in query:iter() do
		world:remove(r_Entity, components.RoundTimer)

		if not data.processed then
			print("RoundActive")
			data.processed = true
			world:set(r_Entity, jecs.pair(components.PlayState, components.RoundActive), data)
		end

		--[[local puck_exists = false
		for p_Entity in
			world:query(components.Puck, jecs.pair(components.BelongsToRink, r_Entity)):without(components.Lifetime)
		do
			puck_exists = true
			break
		end

		if not puck_exists then
			puck_prefab(world, r_Entity, Vector3.new(0, 8, 0))
		end

		--]]
	end
end

return {
	system = round_active,
	phase = planck_runservice.Phases.Last,
}
