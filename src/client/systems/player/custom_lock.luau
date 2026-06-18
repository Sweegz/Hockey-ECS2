local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function calculate_raw_move_vector(humanoid: Humanoid, camera_relative_move_vector: Vector3): Vector3
	local camera = Workspace.CurrentCamera
	if not camera then
		return camera_relative_move_vector
	end
	local cam_cframe = camera.CFrame

	if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		return cam_cframe:VectorToWorldSpace(camera_relative_move_vector)
	end

	local c, s
	local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = cam_cframe:GetComponents()
	if R12 < 1 and R12 > -1 then
		-- X and Z components from back vector.
		c = R22
		s = R02
	else
		-- In this case the camera is looking straight up or straight down.
		-- Use X components from right and up vectors.
		c = R00
		s = -R01 * math.sign(R12)
	end
	local norm = math.sqrt(c * c + s * s)
	return Vector3.new(
		(c * camera_relative_move_vector.X + s * camera_relative_move_vector.Z) / norm,
		0,
		(c * camera_relative_move_vector.Z - s * camera_relative_move_vector.X) / norm
	)
end

local function custom_lock()
	local localplayer_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not localplayer_entity then
		return
	end

	local localplayer = world:get(localplayer_entity, components.Player)
	if not localplayer then
		return
	end

	local character = localplayer.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local camera = Workspace:FindFirstChild("Camera")
	if not camera then
		return
	end

	local gyro = HRP:FindFirstChild("BodyGyro")
	if not gyro then
		return
	end

	local direction = nil
	local current_look = Vector3.new(HRP.CFrame.LookVector.X, 0, HRP.CFrame.LookVector.Z).Unit

	local config = world:get(localplayer_entity, components.PlayerConfig)

	local force_lock = world:get(localplayer_entity, components.ForceLock)

	if gyro.MaxTorque.Y > 0 then
		humanoid.AutoRotate = false
	else
		humanoid.AutoRotate = true
	end

	if command.mouse_lock or force_lock then
		local _, cameraOrientationY = camera.CFrame:ToOrientation()
		gyro.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.Angles(0, cameraOrientationY, 0)
	elseif humanoid.MoveDirection.Magnitude > 0 then
		gyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), humanoid.MoveDirection)
	else
		gyro.CFrame = HRP.CFrame
	end
end

return {
	system = custom_lock,
	phase = planck_runservice.Phases.PreRender,
}
