local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local scheduler = require(ReplicatedStorage.Shared.scheduler)

local Shared = require(script.Parent.Shared)
local T = require(ReplicatedStorage.Shared.types)
local get_valid_mouse_hit = require(StarterPlayer.StarterPlayerScripts.Client.utility.get_valid_mouse_hit)

local State = {} :: T.StateStruct

State.Name = "Check"

local movement_speed_multiplier = nil

State.onEnter = function(context: T.StickStateMachine, entity, world)
	command.power_reset = false

	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local character = world:get(character_entity, components.Model)
	if not character then
		return
	end

	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	local momentum = world:get(character_entity, components.Momentum)
	if not momentum then
		return
	end

	if track then
		--print(track)
		track:Play(context.BLEND_DURATION)
	end

	context.GRACE_TIME = 0
	context.tick = tick()

	local target_pos = get_valid_mouse_hit()

	local dir = (target_pos - HRP.Position).Unit

	local pwr = power.value / 2

	local hrp_speed = HRP.AssemblyLinearVelocity.Magnitude
	if humanoid.WalkSpeed < hrp_speed then
		hrp_speed = humanoid.WalkSpeed
	end

	print(pwr)

	world:remove(entity, components.Glide)

	world:add(character_entity, components.IsMoving)

	if humanoid.WalkSpeed >= 32 and pwr >= 18.4 then
		local pwr_to_speed = pwr / 50 * 47
		-- Precompute reused values
		local threshold1 = pwr * 1.335
		local boost1 = pwr_to_speed * 1.40175
		local boost2 = pwr_to_speed * 1.086
		local boost3 = pwr_to_speed * 0.925
		local boost4 = pwr_to_speed * 1.2
		local threshold2 = pwr_to_speed * 1.035
		local threshold3 = pwr_to_speed * 1.135

		if pwr <= 25 then
			print("A")
			-- if speed is below threshold, use boost
			if hrp_speed < threshold1 then
				momentum.Velocity = dir * boost1
				movement_speed_multiplier = pwr * 1.40175
			else
				momentum.Velocity = dir * hrp_speed
				movement_speed_multiplier = hrp_speed
			end
		elseif hrp_speed < threshold2 then
			momentum.Velocity = dir * boost2
			movement_speed_multiplier = boost2
		else
			momentum.Velocity = dir * hrp_speed
			movement_speed_multiplier = hrp_speed
		end

		if pwr >= 18 then
			print("B")
			if hrp_speed < boost3 then
				momentum.Velocity = dir * boost3
				movement_speed_multiplier = boost3
			else
				momentum.Velocity = dir * hrp_speed
				movement_speed_multiplier = hrp_speed
			end
		elseif pwr > 35 then
			if hrp_speed < threshold3 then
				print("C1")
				momentum.Velocity = dir * boost4
				movement_speed_multiplier = boost4
			else
				print("C2")
				momentum.Velocity = dir * hrp_speed
				movement_speed_multiplier = hrp_speed
			end
		end
	end

	world:set(entity, components.DetectCollisions, {
		timestamp = tick(),
		duration = 0.75,
		dir = dir,
	})

	--[[
	if charge.value > 30 then
		charge.value = math.clamp(charge.value, 30, 100) / 100
		local final = dir * (charge.value ^ 0.5) * CHECK_SPEED

		local LV = Instance.new("LinearVelocity")
		LV.Parent = HRP
		LV.RelativeTo = Enum.ActuatorRelativeTo.World
		LV.Attachment0 = HRP:FindFirstChild("RootAttachment")
		LV.MaxForce = math.huge
		LV.VectorVelocity = final
		time_set = 0.4 + 0.3 * (charge.value ^ 0.5)

		local parts = Workspace:GetPartBoundsInBox(HRP.CFrame, Vector3.new(5, 6, 5))
		for _, part in ipairs(parts) do
			if part.Name == "Wall" then
				local normal = part.CFrame.LookVector
				player.Character:PivotTo(HRP.CFrame + normal)
			end
		end

		world:set(entity, components.DetectCollisions, {
			timestamp = tick(),
			duration = time_set,
			dir = dir,
		})
	end--]]

	--[[local tool = world:get(entity, components.Tool)
	if tool then
		tool.Blade.CanCollide = false
		tool.Shaft.CanCollide = false
		tool.Hat.CanCollide = false
	end--]]

	world:set(entity, components.StickStateMachine, context)
end

State.onExit = function(context: T.StickStateMachine, entity, world)
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local track = Shared.getTrack(character_entity, world, State.Name)
	if track then
		track:Stop(context.BLEND_DURATION)
	end

	local power = world:get(entity, components.Power)
	if power then
		power.value = 0
		world:set(entity, components.Power, power)
	end
end

local time = 0

State.onUpdate = function(context: T.StickStateMachine, entity, world, dt)
	time += dt
	local character_entity = world:target(entity, components.EquippedOn)
	if not character_entity then
		return
	end

	local next_state = nil

	local power = world:get(entity, components.Power)
	if not power then
		return
	end

	local character = world:get(character_entity, components.Model)
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

	local momentum = world:get(character_entity, components.Momentum)
	if not momentum then
		return
	end

	if time > 0.1 and time < 0.5 and humanoid.MoveDirection.Magnitude > 0.1 then
		local alpha = 1 - (1 - 0.8) ^ (dt / (1 / 60))
		momentum.Velocity = momentum.Velocity:Lerp(humanoid.MoveDirection * movement_speed_multiplier, 0.8 * dt)
	end

	if time > 0.5 then
		world:remove(character_entity, components.IsMoving)
	end

	if time > 0.75 then
		time = 0
		next_state = "Default"
	end

	return next_state
end

return State
