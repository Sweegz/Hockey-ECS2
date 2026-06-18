--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local collision_queue = require(ReplicatedStorage.Shared.tables.collision_queue)

local function on_touched(hit: BasePart, entity: jecs.Entity)
	if not collision_queue[entity] then
		collision_queue[entity] = {}
	end
	table.insert(collision_queue[entity], hit)
end

local query_touch_without_connection = world
	:query(components.BasePart, components.Touched)
	:without(jecs.pair(components.Connection, components.Touched))
	:cached()

local function add_touch_connection()
	for entity, basepart in query_touch_without_connection:iter() do
		local connection = basepart.Touched:Connect(function(hit: BasePart)
			on_touched(hit, entity)
		end)
		world:set(entity, jecs.pair(components.Connection, components.Touched), connection)
	end
end

return {
	system = add_touch_connection,
	phase = planck_runservice.Phases.Update,
}
