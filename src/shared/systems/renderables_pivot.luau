local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_renderables_to_move = world:query(components.Renderable, components.PivotTo):cached()

function renderables_pivot()
	for entity, renderable, pivot in query_renderables_to_move:iter() do
		renderable:PivotTo(pivot)
		world:remove(entity, components.PivotTo)
	end
end

return {
	system = renderables_pivot,
	phase = planck_runservice.Phases.PostUpdate,
}
