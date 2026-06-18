--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local components = require(ReplicatedStorage.Shared.components)
local equipped_queue = require(ReplicatedStorage.Shared.tables.equipped_queue)
local jecs = require(ReplicatedStorage.Packages.jecs)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local world = require(ReplicatedStorage.Shared.world)

world:added(components.Tool, function(entity, id, data)
	if data:IsA("Tool") then
		if not RunService:IsClient() then
			return
		end
		refs[data] = entity
		data.Equipped:Connect(function()
			local parent = data.Parent
			if not parent then
				return
			end
			print("Inserted")
			table.insert(equipped_queue, entity, parent)
		end)
		data.Unequipped:Connect(function()
			local parent = data.Parent
			if not parent then
				return
			end
			print("Removed")
			table.insert(equipped_queue, entity, parent)
		end)
	end
end)

world:removed(components.Tool, function(entity, id)
	local tool = world:get(entity, components.Tool)
	if tool and tool:IsA("Tool") then
		refs[tool] = nil
		tool:Destroy()
	end
end)

-- IsA Transitivity
world:set(components.IsA, jecs.OnAdd, function(component, id)
	local second = jecs.pair_second(world, id)
	assert(second ~= component, "circular")

	local is_tag = jecs.is_tag(world, second)
	world:added(component, function(entity, _, value)
		if is_tag then
			world:add(entity, second)
		else
			world:set(entity, second, value)
		end
	end)

	if not is_tag then
		world:changed(component, function(entity, _, value)
			world:set(entity, second, value)
		end)
	end

	local r = jecs.record(world, second) :: jecs.Record
	local archetype = r.archetype
	if not archetype then
		return
	end
	local types = archetype.types

	for _, id in types do
		if jecs.is_tag(world, id) then
			world:add(component, id)
		else
			local metadata = world:get(second, id)
			if not world:has(component, id) then
				world:set(component, id, metadata)
			end
		end
	end

	-- jecs.bulk_insert(world, component, ids, values)
end)

world:added(components.Instance, function(entity, id, data)
	if data:IsA("PVInstance") then
		refs[data] = entity
	end
end)

world:added(components.Ghost, function(entity, id, data)
	if data:IsA("PVInstance") then
		refs[data] = entity
	end
end)

world:removed(components.Ghost, function(entity, id)
	for instance, e in refs do
		if e == entity then
			refs[instance] = nil
			instance:Destroy()
		end
	end
end)

world:added(components.Shadow, function(entity, id, data)
	if data:IsA("PVInstance") then
		refs[data] = entity
	end
end)

world:removed(components.Shadow, function(entity, id)
	for instance, e in refs do
		if e == entity then
			refs[instance] = nil
			instance:Destroy()
		end
	end
end)

world:removed(components.Instance, function(entity, id)
	for instance, e in refs do
		if e == entity then
			refs[instance] = nil
			instance:Destroy()
		end
	end
end)

world:add(components.Renderable, jecs.pair(components.IsA, components.Instance))
world:add(components.BasePart, jecs.pair(components.IsA, components.Renderable))
world:add(components.Model, jecs.pair(components.IsA, components.Renderable))
world:add(components.Tool, jecs.pair(components.IsA, components.Renderable))

return {}
