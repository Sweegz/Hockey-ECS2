local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local has_transform = world
	:query(components.Renderable, components.Transform)
	:with(jecs.pair(components.Reconcile, components.Transform))
	:cached()

local function transforms_reconcile()
	for entity, renderable, transform in has_transform:iter() do
		local cframe = renderable:GetPivot()
		if cframe ~= transform then
			world:set(entity, components.Transform, cframe)
		end
	end
end

return {
	system = transforms_reconcile,
	phase = planck_runservice.Phases.PostSimulation,
}
