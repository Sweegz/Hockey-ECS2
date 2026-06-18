local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local saved_snapshots = require(ReplicatedStorage.Shared.tables.saved_snapshots)
local world = require(ReplicatedStorage.Shared.world)

local query_pucks_with_owner =
	world:query(components.BasePart, components.Ghost):with(jecs.pair(components.Owner, jecs.Wildcard)):cached()

local query_b = world:query(components.BasePart, components.Ghost, components.Transform):cached()

local query_model_transforms = world:query(components.Model, components.Transform):cached()

function apply_interpolated_transforms()
	for entity, part, ghost, cframe in query_b:iter() do
		ghost.CFrame = cframe
	end

	local localplayer_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not localplayer_entity then
		return
	end

	local local_participant = world:target(localplayer_entity, components.CurrentParticipant)

	for entity, part, ghost in query_pucks_with_owner:iter() do
		ghost.CFrame = part.CFrame

		world:set(entity, components.Transform, part.CFrame)
		local snapshot = saved_snapshots[entity]
		if not snapshot then
			continue
		end

		local owner_participant = world:target(entity, components.Owner)
		if not owner_participant then
			continue
		end

		if local_participant == owner_participant then
			for stick_entity, tool, sss in
				world
					:query(components.Tool, components.StickStateMachine)
					:with(jecs.pair(components.CurrentParticipant, owner_participant))
			do
				if
					(sss.current:match("Glide") or sss.current:match("Default"))
					and (sss.previous:match("Glide") or sss.previous:match("Default"))
				then
					local glued_front = tool:FindFirstChild("GluedFront")
					if glued_front then
						ghost.CFrame = glued_front.CFrame * CFrame.Angles(0, 0, math.rad(90))
					end
				end
			end
		else
			for stick_entity, tool, sss in
				world
					:query(components.Tool, components.ServerStickState)
					:with(jecs.pair(components.CurrentParticipant, owner_participant))
			do
				if
					(sss.current:match("Glide") or sss.current:match("Default"))
					and (sss.previous:match("Glide") or sss.previous:match("Default"))
				then
					local glued_front = tool:FindFirstChild("GluedFront")
					if glued_front then
						ghost.CFrame = glued_front.CFrame * CFrame.Angles(0, 0, math.rad(90))
					end
				end
			end
		end

		--snapshot:clear()
	end

	for entity, model, cframe in query_model_transforms:iter() do
		local primary_part = model.PrimaryPart
		if primary_part then
			primary_part.CFrame = cframe
		end
	end
end

return {
	system = apply_interpolated_transforms,
	phase = planck_runservice.Phases.PreRender,
}
