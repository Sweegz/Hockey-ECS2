local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local refs = require(ReplicatedStorage.Shared.tables.refs)
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local dir_change = false
local is_moving = false
local glide = false

local localplayer = Players.LocalPlayer

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { game.Workspace.Rink.Game.Collisions }

local function movement()
	local character = localplayer.Character
	if not character then
		return
	end

	local character_entity = refs[character]
	if not character_entity then
		return
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local momentum = world:get(character_entity, components.Momentum)
	if not momentum then
		return
	end

	local is_moving = world:has(character_entity, components.IsMoving)

	for e, fsm in world:query(components.StickStateMachine):iter() do
		if world:has(e, components.Glide) then
			glide = true
		else
			glide = false
		end
	end

	if humanoid.WalkSpeed > 47 then
		humanoid.WalkSpeed = 47
	elseif humanoid.WalkSpeed < 47 and humanoid.WalkSpeed > 38 then
		humanoid.WalkSpeed = 38
	end

	if not world:has(character_entity, components.IsHit) then
		momentum.MaxForce = Vector3.new(25000, 0, 25000)
		momentum.Parent = hrp
		local glide_speed_modifier = nil
		if humanoid.MoveDirection.Magnitude > 0 then
			local max_glide_velocity = 60
			if humanoid.WalkSpeed > 33 then
				max_glide_velocity = 80
			end
			if (momentum.Velocity + humanoid.MoveDirection * humanoid.WalkSpeed).Magnitude <= max_glide_velocity then
				glide_speed_modifier = 0.04
				if not dir_change then
					dir_change = true
					local velocity_reference = momentum
					velocity_reference.Velocity = velocity_reference.Velocity * 0.825
				end
			else
				if momentum.Velocity.Magnitude > humanoid.WalkSpeed + 1 and not is_moving then
					local velocity_reference2 = momentum
					velocity_reference2.Velocity = velocity_reference2.Velocity * 0.825
				end
				dir_change = false
				glide_speed_modifier = 0.06064
			end
			local _ = nil
			glide_speed_modifier = glide_speed_modifier
				+ if not glide
					then hrp.AssemblyAngularVelocity.Magnitude / 18 * 0.005
					else hrp.AssemblyAngularVelocity.Magnitude / 18 * 0.04
		else
			glide_speed_modifier = 0.1
		end

		local dt = scheduler:getDeltaTime()
		local frame_rate = 1 / 60

		if not is_moving then
			if hrp.AssemblyAngularVelocity.Magnitude <= 10 then
				if momentum.Velocity.X ~= (0 / 0) then
					momentum.Velocity = hrp.AssemblyLinearVelocity
				end
				local walk_speed = humanoid.WalkSpeed
				local alpha = 1 - (1 - glide_speed_modifier) ^ (dt / frame_rate)
				momentum.Velocity = momentum.Velocity:Lerp(humanoid.MoveDirection * walk_speed, alpha)
			else
				--print("2")
				--local gg = 1 - (1 - 0.6) ^ (dt / frame_rate)
				local desired_dir_velocity = nil
				if momentum.Velocity.Magnitude > 0 then
					desired_dir_velocity = (momentum.Velocity / momentum.Velocity.Magnitude):Lerp(
						humanoid.MoveDirection,
						0.6
					)
				else
					print("Ok")
					desired_dir_velocity = Vector3.new(0, 0, 0):Lerp(humanoid.MoveDirection, 0.6)
				end

				if desired_dir_velocity then
					local walk_speed2 = humanoid.WalkSpeed
					local alpha = 1 - (1 - glide_speed_modifier) ^ (dt / frame_rate)
					momentum.Velocity = momentum.Velocity:Lerp(desired_dir_velocity * walk_speed2, alpha)
				end
			end
		end
	else
		local raycastResult = workspace:Raycast(hrp.Position, momentum.Velocity * Vector3.new(1, 0, 1), raycastParams)
		if raycastResult and raycastResult.Distance <= 2 then
			momentum.MaxForce = Vector3.new(0, 0, 0)
		end
	end
end

return {
	system = movement,
	phase = planck_runservice.Phases.PreRender,
}
