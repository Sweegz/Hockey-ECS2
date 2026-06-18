local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local collision_queue = require(ReplicatedStorage.Shared.tables.collision_queue)

local query_puck_touched =
	world:query(components.Puck):with(jecs.pair(components.Connection, components.Touched)):cached()

local function out_of_bounds()
	for entity in query_puck_touched do
		local collisions = collision_queue[entity]
		if not collisions then
			continue
		end

		for _, hit: any in collisions do
			if CollectionService:HasTag(hit, "Bounds") then
				world:add(entity, components.OutOfBounds)
			end
		end
	end
end

return {
	system = out_of_bounds,
	phase = planck_runservice.Phases.Update,
}
