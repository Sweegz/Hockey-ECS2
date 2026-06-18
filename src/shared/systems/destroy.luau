local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_destroy = world:query(components.Destroy):cached()

local function destroy()
	for entity in query_destroy do
		world:delete(entity)
	end
end

return {
	system = destroy,
	phase = planck_runservice.Phases.Last,
}
