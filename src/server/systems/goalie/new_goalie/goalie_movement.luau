local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_goalie_movement =
	world:query(components.Model, components.MoveTo):with(jecs.pair(components.Goalie, jecs.Wildcard)):cached()

local function goalie_movement()
	for g_Entity, g_Model, g_MoveTo in query_goalie_movement:iter() do
		local part_to_move = g_MoveTo.part_to_move
		local primary_part = g_Model.PrimaryPart

		local pos1 = CFrame.new(primary_part.CFrame.Position.X, 0, primary_part.CFrame.Position.Z)
		local pos2 = CFrame.new(part_to_move.CFrame.Position.X, 0, part_to_move.CFrame.Position.Z)

		local offset = (pos1.Position - pos2.Position) / 1.5

		local net_model = g_Model.Parent
		if not net_model then
			continue
		end

		local move = net_model:FindFirstChild("Move")
		if not move or not move:IsA("BasePart") then
			continue
		end

		--primary_part.Position = Vector3.new(primary_part.CFrame.X, 3.5, primary_part.CFrame.Z)
		move.CFrame = g_MoveTo.cframe + offset

		--primary_part.CFrame = primary_part.CFrame:Lerp(g_MoveTo.cframe + offset, alpha)
	end
end

return {
	system = goalie_movement,
	phase = planck_runservice.Phases.Last,
}
