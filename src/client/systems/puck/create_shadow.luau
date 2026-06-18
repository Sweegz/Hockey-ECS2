local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_puck_without_shadow = world:query(components.Ghost):without(components.Shadow):cached()

local function create_shadow()
	for e, ghost in query_puck_without_shadow:iter() do
		local clone = ReplicatedStorage:FindFirstChild("Shadow"):Clone()
		world:set(e, components.Shadow, clone)
		clone.Parent = game.Workspace.CurrentCamera
	end
end

return {
	system = create_shadow,
	phase = planck_runservice.Phases.Update,
}
