local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.CenterCFrame, jecs.pair(components.Tracking, jecs.Wildcard)):cached()

local function goalie_dist_and_dir()
	for g_Entity, g_center_cframe, part in query:iter() do
		local dist = (part.Position - g_center_cframe.Position).Magnitude
		local dir = (part.Position - g_center_cframe.Position).Unit

		if dist then
			world:set(g_Entity, components.TrackingDistance, dist)
		end

		if dir then
			world:set(g_Entity, components.TrackingDirection, dir)
		end
	end
end

return {
	system = goalie_dist_and_dir,
	phase = planck_runservice.Phases.PostSimulation,
}
