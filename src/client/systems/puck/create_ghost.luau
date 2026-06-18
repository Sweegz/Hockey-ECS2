local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_puck_without_ghost = world:query(components.BasePart, components.Puck):without(components.Ghost):cached()

local function create_ghost()
	for entity, part in query_puck_without_ghost:iter() do
		local ghost_puck = part:clone() :: BasePart
		ghost_puck.Parent = game.Workspace.CurrentCamera
		ghost_puck.Name = "GhostPuck"
		ghost_puck.Anchored = true
		ghost_puck.Transparency = 0
		ghost_puck.CollisionGroup = "OwnedPuck"
		part.Transparency = 1
		--ghost_puck.BrickColor = BrickColor.Green()

		local weld = ghost_puck:FindFirstChild("weld")
		if weld then
			weld:Destroy()
		end

		world:set(entity, components.Ghost, ghost_puck)
	end
end

return {
	system = create_ghost,
	phase = planck_runservice.Phases.Update,
}
