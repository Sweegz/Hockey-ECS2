local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_unequips = world:query(components.Unequip):cached()

local function remove_equipped()
	for entity in query_unequips do
		world:remove(entity, components.Unequip)
		local equipped_on = world:target(entity, components.EquippedOn)
		if equipped_on then
			world:remove(entity, jecs.pair(components.EquippedOn, equipped_on))
		end
	end
end

return {
	system = remove_equipped,
	phase = planck_runservice.Phases.Last,
}
