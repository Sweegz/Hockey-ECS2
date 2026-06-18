local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local has_no_transform = world:query(components.Renderable):without(components.Transform):cached()

local function renderables_add_transform()
	for entity, renderable in has_no_transform:iter() do
		world:set(entity, components.Transform, renderable:GetPivot())
	end
end

return {
	system = renderables_add_transform,
	phase = planck_runservice.Phases.PreUpdate,
}
