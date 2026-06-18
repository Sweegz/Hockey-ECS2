local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_lifetimes = world:query(components.Lifetime):cached()

local function lifetimes_expire()
	for entity, lifetime in query_lifetimes:iter() do
		if os.clock() > lifetime.created + lifetime.duration then
			world:add(entity, components.Destroy)
		end
	end
end

return {
	system = lifetimes_expire,
	phase = planck_runservice.Phases.Update,
}
