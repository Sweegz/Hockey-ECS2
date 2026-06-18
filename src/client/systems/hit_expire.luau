local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function hit_expire()
	for e, model, hit_data in world:query(components.Model, components.IsHit):iter() do
		if tick() > hit_data.start + hit_data.duration then
			world:remove(e, components.IsHit)

			local humanoid = model:FindFirstChild("Humanoid")
			if not humanoid or not humanoid:IsA("Humanoid") then
				continue
			end

			local player_entity = world:parent(e)
			if not player_entity then
				continue
			end

			for e, power in world:query(components.Power):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
				power.value = 0
				world:set(e, components.Power, power)
			end

			local HRP = model:FindFirstChild("HumanoidRootPart")
			if not HRP then
				return
			end

			if not hit_data.shove then
				task.delay(0.25, function()
					world:remove(e, components.Ragdolled)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end

			task.delay(0.25, function()
				local gyro = HRP:FindFirstChild("BodyGyro")
				if gyro then
					gyro.P = 10000
					gyro.MaxTorque = Vector3.new(0, 1000000000, 0)
				end

				for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
					for _, child in tool:GetChildren() do
						if child:IsA("MeshPart") then
							child.Massless = false
						end
					end
				end
			end)
		end
	end
end

return {
	system = hit_expire,
	phase = planck_runservice.Phases.Update,
}
