local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

function line_to_plane_intersection(
	line_point: Vector3,
	line_direction: Vector3,
	plane_point: Vector3,
	plane_normal: Vector3
): Vector3
	local denominator = line_direction:Dot(plane_normal)
	if denominator == 0 then
		return line_point
	end
	local distance = ((plane_point - line_point):Dot(plane_normal)) / denominator
	return line_point + line_direction * distance
end

local target_to_anim = {
	["Tar1"] = "Butterfly",
	["Tar2"] = "Glove1",
	["Tar3"] = "Butterfly",
	["Tar4"] = "Blocker1",
	["Tar5"] = "Blocker0",
	["Tar6"] = "Standing3",
	["Tar7"] = "Glove0",
	["Tar8"] = "Blocker0",
	["Tar9"] = "Standing3",
	["Tar10"] = "Glove2",
	["Tar11"] = "Blocker2",
}

local query = world
	:query(components.Model, components.CenterCFrame, components.ShotHitNet, components.ThreatData)
	:without(components.GoalieReacting)
	:cached()

local function goalie_reaction()
	for g_entity, g_model, g_center_cframe, g_reaction, threat in query:iter() do
		world:remove(g_entity, components.ShotHitNet)

		local CC_DURATION = 1.6
		local GOALIE_PLANE_X_OFFSET = -1

		local hit = g_reaction.ray_result.Instance
		if not hit then
			continue
		end

		local primary_part = g_model.PrimaryPart
		if not primary_part then
			continue
		end

		local part_to_move = primary_part

		local decision: string? = target_to_anim[hit.Name]

		local dir = (g_reaction.origin - g_center_cframe.Position).Unit
		if dir.Z * g_center_cframe.LookVector.Z < -0 then
			continue
		end

		if g_reaction.fake then
			CC_DURATION *= 0.5
		end

		if not decision then
			warn("No good.")
			continue
		end

		if decision:match("Blocker0") then
			if threat.dist < 40 then
				decision = "Blocker1"
			end
			--
		elseif decision:match("Glove0") then
			if threat.dist < 40 then
				decision = "Glove1"
			end
		end

		if decision:match("Blocker") then
			part_to_move = g_model.RA.PrimaryPart
		elseif decision:match("Glove") then
			part_to_move = g_model.LA.PrimaryPart
		end

		world:set(g_entity, components.StateDecision, decision)
		local pos1 = Vector3.new(g_center_cframe.Position.X, 0, g_center_cframe.Position.Z)
		local pos2 = Vector3.new(g_reaction.origin.X, 0, g_reaction.origin.Z)
		local look = CFrame.lookAt(pos1, pos2)

		local goalie_plane_intersection = line_to_plane_intersection(
			g_reaction.origin,
			g_reaction.direction,
			primary_part.CFrame.Position, -- + Vector3.new(GOALIE_PLANE_X_OFFSET * primary_part.CFrame.LookVector.X, 0, 0),
			look.LookVector
		)

		local final_pos = CFrame.new(goalie_plane_intersection.X, primary_part.CFrame.Y, goalie_plane_intersection.Z)
			* look.Rotation

		world:set(g_entity, components.MoveTo, {
			part_to_move = part_to_move,
			cframe = final_pos,
			speed = 4,
		})

		local net = g_model.Parent
		if not net then
			continue
		end

		--[[local align_position: AlignPosition = net:FindFirstChild("AlignPosition", true)
		if align_position then
			align_position.MaxVelocity = 28
			align_position.Responsiveness = 24
		end --]]

		world:set(g_entity, components.GoalieReacting, {
			created = tick(),
			duration = CC_DURATION,
		})
	end
end

return {
	system = goalie_reaction,
	phase = planck_runservice.Phases.Update,
}
