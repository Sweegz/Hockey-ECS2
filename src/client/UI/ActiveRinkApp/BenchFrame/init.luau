local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local use_target = require(ReplicatedStorage.Shared.addons.use_target)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local BenchEntry = require(script.BenchEntry)

local source = vide.source
local read = vide.read
local cleanup = vide.cleanup
local effect = vide.effect
local observers = require(ReplicatedStorage.Shared.addons.observers)

return function(props: { participant: () -> jecs.Entity<any>? })
	local TeamEntity = use_target.useTarget(props.participant(), components.BelongsToTeam)

	local entities = {} :: { jecs.Entity }
	local entity_map = {} :: { [jecs.Entity]: number }

	local teammates = source(entities)

	effect(function()
		local team = TeamEntity()

		local query =
			read(world:query(components.Active, jecs.pair(components.BelongsToTeam, team :: jecs.Entity<any>)))

		table.clear(entities)
		table.clear(entity_map)
		if not query then
			teammates(entities)
			return
		end
		for entity in query:iter() do
			table.insert(entities, entity)
			entity_map[entity] = #entities
		end
		teammates(entities)

		local monitor = observers.monitor(query)
		monitor.added(function(entity)
			if entity_map[entity] then
				return
			end
			table.insert(entities, entity)
			entity_map[entity] = #entities
			print("Added", entity)
			teammates(entities)
		end)

		monitor.removed(function(entity)
			task.defer(function()
				local index = entity_map[entity]
				if not index then
					return
				end
				if entity == props.participant() then
					return
				end
				entity_map[entity] = nil
				local latest = table.remove(entities)
				if not latest then
					print("A")
					teammates(entities)
					return
				end
				if latest == entity then
					teammates(entities)
					return
				end
				entities[index] = latest
				entity_map[latest] = index
				teammates(entities)
			end)
		end)

		cleanup(monitor.disconnect)
	end)

	return vide.create("Frame")({
		Name = "BenchFrame",
		Size = UDim2.new(0, 200, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 10, 0.4, 0),
		Transparency = 0.2,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		vide.create("UIListLayout")({}),
		vide.create("UIStroke")({
			Thickness = 3,
			Transparency = 0.3,
		}),
		vide.values(teammates, function(entity)
			return BenchEntry({
				participant = entity,
			})
		end),
	})
end
