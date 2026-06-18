local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local saved_snapshots = require(ReplicatedStorage.Shared.tables.saved_snapshots)

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

local function drop_event()
	for p_Entity, p_Part in world:query(components.BasePart):with(components.DropEvent, components.Puck) do
		Action:FireServer("Drop", { pos = p_Part.Position })
		local snapshot = saved_snapshots[p_Entity]
		if snapshot then
			--snapshot:clear()
		end
		world:remove(p_Entity, components.DropEvent)
	end
end

return {
	system = drop_event,
	phase = planck_runservice.Phases.PostSimulation,
}
