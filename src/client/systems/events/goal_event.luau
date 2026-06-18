local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_goal_events = world:query(components.GoalEvent):cached()

local function horn_play()
	task.spawn(function()
		local sound = Instance.new("Sound")
		sound.Parent = Workspace
		sound.SoundId = "rbxassetid://5818699832"
		sound.Volume = 2
		sound:Play()
		task.wait(5)
		sound:Destroy()
	end)
end

local function siren_play(net_entity: jecs.Entity)
	local model1 = world:get(net_entity, components.Model)
	if not model1 then
		return
	end

	local siren = model1:FindFirstChild("Siren", true)
	print(model1, siren)
	if siren then
		task.spawn(function()
			local l1 = siren:FindFirstChild("L1", true)
			local l2 = siren:FindFirstChild("L2", true)
			local motor = siren:FindFirstChild("Motor", true)

			if not l1:IsA("BasePart") or not l2:IsA("BasePart") or not motor:IsA("BasePart") then
				return
			end

			l1.Transparency = 0.3
			l2.Transparency = 0.3
			l1.PointLight.Enabled = true
			l2.PointLight.Enabled = true
			motor.HingeConstraint.MotorMaxTorque = 10000000

			task.wait(5)

			l1.Transparency = 1
			l2.Transparency = 1
			l1.PointLight.Enabled = false
			l2.PointLight.Enabled = false
			motor.HingeConstraint.MotorMaxTorque = 0
		end)
	end
end

local function goal_event()
	for entity, event in query_goal_events:iter() do
		local net_entity = event.net
		local _ = event.hit
		local _ = event.rink

		siren_play(net_entity)
		horn_play()
	end
end

return {
	system = goal_event,
	phase = planck_runservice.Phases.PostUpdate,
}
