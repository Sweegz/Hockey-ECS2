local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

local query =
	world:query(components.Model, components.GoalieStateMachine, jecs.pair(components.Tracking, jecs.Wildcard)):cached()

local function goalie_autoglove()
	for g_Entity, g_Model, g_fsm, p_part in query:iter() do
		local p_entity = world:target(g_Entity, components.Tracking) :: jecs.Entity

		if p_part.AssemblyLinearVelocity.Y < 0.2 then
			continue
		end

		local left_arm = g_Model:FindFirstChild("LA")
		if not left_arm then
			continue
		end

		local dist = (p_part.Position - left_arm.PrimaryPart.CFrame.Position).Magnitude
		if dist < 1 then
			--world:add(p_entity, jecs.pair(components.Owner, g_Entity))
			p_part.CFrame = left_arm.In.CFrame
			p_part.weld.Part1 = left_arm.In

			local data: T.Lifetime = {
				duration = 2,
				created = os.clock(),
			}

			world:set(p_entity, components.Lifetime, data)

			local rink_entity = world:target(g_Entity, components.BelongsToRink)
			if not rink_entity then
				continue
			end

			print("Glove")

			task.delay(1, function()
				world:set(rink_entity, jecs.pair(components.PlayState, components.RoundReset), {
					processed = false,
				})
			end)
		end
	end
end

return {
	system = goalie_autoglove,
	phase = planck_runservice.Phases.First,
}
