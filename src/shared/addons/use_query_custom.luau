local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local observers = require(ReplicatedStorage.Shared.addons.observers)
local vide = require(ReplicatedStorage.Packages.vide)

local source = vide.source
local cleanup = vide.cleanup
local effect = vide.effect

local exports = {}

local function useQuery(getQuery: () -> any)
	-- Returns a vide.source(...) bound to the given query producer.
	local entities = {} :: { jecs.Entity }
	local entity_map = {} :: { [jecs.Entity]: number }

	local state = source(entities)

	effect(function()
		local query = getQuery()

		table.clear(entities)
		table.clear(entity_map)

		if not query then
			state(entities)
			return
		end

		for entity in query:iter() do
			table.insert(entities, entity)
			entity_map[entity] = #entities
		end
		state(entities)

		local monitor = observers.monitor(query)

		monitor.added(function(entity)
			if entity_map[entity] then
				return
			end
			table.insert(entities, entity)
			entity_map[entity] = #entities
			state(entities)
		end)

		monitor.removed(function(entity)
			task.defer(function()
				local index = entity_map[entity]
				if not index then
					return
				end

				entity_map[entity] = nil
				local latest = table.remove(entities)
				if not latest then
					state(entities)
					return
				end
				if latest == entity then
					state(entities)
					return
				end

				entities[index] = latest
				entity_map[latest] = index
				state(entities)
			end)
		end)

		cleanup(monitor.disconnect)
	end)

	return state
end

exports.useQuery = useQuery

return exports
