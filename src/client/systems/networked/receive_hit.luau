local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local refs = require(ReplicatedStorage.Shared.tables.refs)

local RagdollEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Ragdoll") :: RemoteEvent

local onEvent = planck.onEvent
local _, onClientEvents = onEvent(RagdollEvent.OnClientEvent)

local function calculate_hit_rotation(hit_direction: Vector3, hit_power: number)
	local look_cframe = CFrame.new(Vector3.zero, hit_direction)
	local _, _, _, _, _, pitch_component = look_cframe:components()

	local pitch_angle = math.asin(pitch_component)

	local rotation_z = pitch_angle / math.rad(90)
	local rotation_x

	if hit_direction.Z < 0 then
		rotation_x = -((math.rad(90) - math.abs(pitch_angle)) / math.rad(90))
	else
		rotation_x = (math.rad(90) - math.abs(pitch_angle)) / math.rad(90)
	end

	local power_multiplier = 30
	local final_magnitude = 1 + (hit_power * power_multiplier)

	return Vector3.new(rotation_x, 0, rotation_z).Unit * final_magnitude
end

local function receive_hit()
	for _, power: number, velocity: Vector3, duration: number, shove: boolean in onClientEvents() do
		local player = Players.LocalPlayer

		local character = player.Character
		if not character then
			continue
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp or not hrp:IsA("BasePart") then
			continue
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or not humanoid:IsA("Humanoid") then
			continue
		end

		local character_entity = refs[character]
		if not character_entity then
			continue
		end

		local player_entity = world:parent(character_entity)
		if not player_entity then
			continue
		end

		local momentum = world:get(character_entity, components.Momentum)
		if not momentum then
			continue
		end

		if world:has(character_entity, components.Ragdolled) then
			continue
		end

		local dir = velocity.Unit

		--humanoid.PlatformStand = true
		--humanoid.RequiresNeck = false
		--humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)

		world:set(character_entity, components.IsHit, {
			duration = duration,
			start = tick(),
			shove = shove,
		})

		if not shove then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)

			world:set(character_entity, components.Ragdolled, tick())

			momentum.Velocity = velocity
			hrp.AssemblyLinearVelocity = velocity
			local angular = calculate_hit_rotation(dir, power / 100)
			hrp.AssemblyAngularVelocity = angular
		else
			momentum.Velocity = velocity
		end

		for e, tool in world:query(components.Tool):with(jecs.pair(jecs.ChildOf, player_entity)):iter() do
			for _, child in tool:GetChildren() do
				if child:IsA("MeshPart") then
					child.Massless = true
				end
			end
		end

		for _, child in character:GetChildren() do
			if child:IsA("BasePart") then
				--child.CustomPhysicalProperties = PhysicalProperties.new(15, 0.3, 0.01, 1, 5)
			end
		end --]]

		local gyro = hrp:FindFirstChild("BodyGyro")
		if gyro then
			gyro.P = 0
			gyro.MaxTorque = Vector3.new(0, 0, 0)
		end
	end
end

return {
	system = receive_hit,
	phase = planck_runservice.Phases.PreSimulation,
}
