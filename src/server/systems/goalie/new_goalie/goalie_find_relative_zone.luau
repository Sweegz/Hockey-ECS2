local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.CenterCFrame, components.TrackingDirection):cached()

local function goalie_find_relative_zone()
	for g_entity, g_center_cframe, dir in query:iter() do
		local look_vector = g_center_cframe.LookVector

		if dir.z * look_vector.z > 0.1 then
			world:set(g_entity, components.RelativeZone, "Front")
		elseif dir.Z * look_vector.Z > -0.8 then
			world:set(g_entity, components.RelativeZone, "Side")
		else
			world:set(g_entity, components.RelativeZone, "Behind")
		end
	end
end

return {
	system = goalie_find_relative_zone,
	phase = planck_runservice.Phases.Update,
}
