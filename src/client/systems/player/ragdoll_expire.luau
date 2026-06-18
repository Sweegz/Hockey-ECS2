local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function ragdoll_expire()
	for c_Entity, c_Model, stun_tick in world:query(components.Model, components.Ragdolled):with(components.Character) do
		if tick() > stun_tick + 1.1 then
			local humanoid = c_Model:FindFirstChild("Humanoid")
			if not humanoid or not humanoid:IsA("Humanoid") then
				continue
			end

			local player_entity = world:parent(c_Entity)
			if not player_entity then
				continue
			end

			local HRP = c_Model:FindFirstChild("HumanoidRootPart")
			if not HRP then
				return
			end

			--humanoid.PlatformStand = false
			task.delay(0.25, function()
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
				humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)

			local gyro = HRP:FindFirstChild("BodyGyro")
			if gyro then
				gyro.P = 10000
				gyro.MaxTorque = Vector3.new(0, 1000000000, 0)
			end

			--[[for _, child in c_Model:GetChildren() do
				if child:IsA("BasePart") then
					--child.CustomPhysicalProperties = PhysicalProperties.new(4, 0.3, 0.5, 1, 0.3)
				end
			end

			for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
				for _, child in tool:GetChildren() do
					if child:IsA("MeshPart") then
						--child.CustomPhysicalProperties = PhysicalProperties.new(11.24, 0.2, 0.5, 1, 1)
					end
				end
			end--]]

			for e, power in world:query(components.Power):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
				power.value = 0
				world:set(e, components.Power, power)
			end

			world:remove(c_Entity, components.Ragdolled)
		end
	end
end

return {
	system = function() end,
	phase = planck_runservice.Phases.Update,
}
