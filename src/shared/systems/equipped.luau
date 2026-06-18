local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local equipped_queue = require(ReplicatedStorage.Shared.tables.equipped_queue)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local function equipped_tool()
	for entity, parent_instance in equipped_queue do
		local parent_entity = refs[parent_instance]
		if parent_entity then
			world:add(entity, jecs.pair(components.EquippedOn, parent_entity))
		else
			world:add(entity, components.Unequip)
		end
	end
end

return {
	system = equipped_tool,
	phase = planck_runservice.Phases.PreUpdate,
}
