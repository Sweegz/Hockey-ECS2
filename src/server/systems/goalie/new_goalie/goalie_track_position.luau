local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world
	:query(
		components.Model,
		components.CenterCFrame,
		components.TrackingDirection,
		components.RelativeZone,
		components.ThreatData
	)
	:without(components.GoalieReacting)
	:cached()

local function goalie_track_position()
	for g_entity, g_model, g_center_cframe, dir, zone, threat in query:iter() do
		local final_pos = nil

		local RADIUS = 8

		local net = g_model.Parent
		if not net then
			continue
		end

		RADIUS = RADIUS - math.min(6, (math.max(0, 50 - threat.dist) / 10))

		if zone == "Front" then
			dir = Vector3.new(dir.x, 0, dir.Z)
			local pos = g_center_cframe.Position + dir * RADIUS

			local target_pos = CFrame.new(pos.X, 3.5, pos.Z)

			local pos1 = Vector3.new(g_center_cframe.Position.X, 0, g_center_cframe.Position.Z)
			--local pos2 = Vector3.new(p_cframe.X, 0, p_cframe.Z)
			local look = CFrame.lookAlong(pos1, dir)

			final_pos = target_pos * look.Rotation
		elseif zone == "Behind" then
			dir = Vector3.new(dir.X, 0, 0)
			local pos = g_center_cframe.Position + dir * 6
			final_pos = CFrame.new(pos.X, 3.7, pos.Z)
				* CFrame.Angles(0, math.rad(90) + math.rad(90 * g_center_cframe.LookVector.Z), 0)
		elseif zone == "Side" then
			dir = Vector3.new(dir.X, 0, 0)
			local pos = g_center_cframe.Position + dir * 6

			if dir.X > 0 then
				final_pos = CFrame.new(pos.X, 3.7, pos.Z + (1 * g_center_cframe.LookVector.Z))
					* CFrame.Angles(0, math.rad(-90), 0)
			else
				final_pos = CFrame.new(pos.X, 3.7, pos.Z + (1 * g_center_cframe.LookVector.Z))
					* CFrame.Angles(0, math.rad(90), 0)
			end
		end

		--[[local align_position: AlignPosition = net:FindFirstChild("AlignPosition", true)
		if align_position then
			align_position.MaxVelocity = 40
			align_position.Responsiveness = 40
		end--]]

		if final_pos then
			world:set(g_entity, components.MoveTo, {
				part_to_move = g_model.PrimaryPart,
				cframe = final_pos,
				speed = 3.5,
			})
		end
	end
end

return {
	system = goalie_track_position,
	phase = planck_runservice.Phases.Update,
}
