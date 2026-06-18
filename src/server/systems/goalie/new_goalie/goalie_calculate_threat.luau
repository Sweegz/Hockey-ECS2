local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.TrackingDistance, jecs.pair(components.Tracking, jecs.Wildcard)):cached()

local function goalie_calculate_threat()
	for g_entity, dist, tracked_part in query:iter() do
		local tracked_entity = world:target(g_entity, components.Tracking) :: jecs.Entity

		local threat_level = "Low"
		local poke = false

		if dist < 15 then
			threat_level = "High"
		elseif dist < 35 then
			threat_level = "Medium"
		elseif dist < 60 then
			threat_level = "Low"
		else
			threat_level = "None"
		end

		if world:has(tracked_entity, jecs.pair(components.Owner, jecs.Wildcard)) then
			poke = true
		else
			poke = false
		end

		world:set(g_entity, components.ThreatData, {
			threat = threat_level,
			poke = poke,
			dist = dist,
		})
	end
end

return {
	system = goalie_calculate_threat,
	phase = planck_runservice.Phases.First,
}
