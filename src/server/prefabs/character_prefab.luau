local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)

local refs = require(ReplicatedStorage.Shared.tables.refs)
local stick_prefab = require(script.Parent.stick_prefab)

return function(world: jecs.World, model: Model, playerEntity: jecs.Entity): jecs.Entity
	local character_entity = world:entity()
	world:add(character_entity, jecs.pair(jecs.ChildOf, playerEntity))
	world:add(character_entity, components.Character)
	world:set(character_entity, components.Model, model)
	world:add(character_entity, replecs.networked)
	world:add(character_entity, jecs.pair(replecs.reliable, components.Character))
	--world:add(character_entity, jecs.pair(replecs.reliable, components.Model))
	world:add(character_entity, jecs.pair(replecs.reliable, components.UUID))
	world:add(character_entity, jecs.pair(replecs.pair, jecs.ChildOf))
	world:add(character_entity, jecs.pair(replecs.pair, components.PlayState))
	world:add(character_entity, jecs.pair(replecs.pair, components.CurrentParticipant))
	world:add(character_entity, jecs.pair(replecs.pair, components.BelongsToRink))
	world:add(character_entity, jecs.pair(replecs.pair, components.BelongsToTeam))

	local humanoid = model:FindFirstChild("Humanoid")
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.WalkSpeed = 24
		humanoid.AutoRotate = false
		humanoid.AutoJumpEnabled = false
		world:set(character_entity, components.Humanoid, humanoid)
	end

	local hrp = model:FindFirstChild("HumanoidRootPart")
	local CollectGrip = Instance.new("Motor6D")
	if hrp then
		local bg = Instance.new("BodyGyro")
		bg.D = 500
		bg.MaxTorque = Vector3.new(0, 1000000000, 0)
		bg.P = 10000
		bg.Parent = hrp
		--[[
		local attachment = Instance.new("Attachment")
		attachment.Parent = hrp
		local align = Instance.new("AlignOrientation")
		align.Mode = Enum.OrientationAlignmentMode.OneAttachment
		align.MaxAngularVelocity = 25
		align.Responsiveness = 25
		align.MaxTorque = 30000
		align.Parent = hrp
		align.Attachment0 = attachment--]]
		model.PrimaryPart = hrp

		local hitbox = Instance.new("Part")
		hitbox.Size = Vector3.new(4.1, 6, 4.1)
		hitbox.CanCollide = false
		hitbox.Parent = model
		hitbox.Transparency = 1
		hitbox.Massless = true
		hitbox.Name = "Hitbox"
		hitbox.Position = hrp.Position

		local hitbox_weld = Instance.new("WeldConstraint")
		hitbox_weld.Parent = hitbox
		hitbox_weld.Part0 = hrp
		hitbox_weld.Part1 = hitbox

		CollectGrip.Name = "CollectGrip"
		CollectGrip.Part0 = hrp
		CollectGrip.Parent = hrp

		task.delay(8, function()
			local RunningSound = hrp:FindFirstChild("Running", true)
			if RunningSound then
				print("Yes")
			else
				print("No")
			end
		end)
	end

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			print(descendant.Name)
			if descendant.Name == "Right Leg" then
				descendant.CollisionGroup = "Leg"
			elseif descendant.Name == "Left Leg" then
				descendant.CollisionGroup = "Leg"
			else
				descendant.CollisionGroup = "Player"
			end
		end
	end

	local torso = model:FindFirstChild("Torso")
	local ToolGrip = Instance.new("Motor6D")

	if torso and torso:IsA("BasePart") then
		ToolGrip.Name = "ToolGrip"
		ToolGrip.Part0 = torso
		ToolGrip.Parent = torso
		ToolGrip.C0 = CFrame.new(0.9, 0, 0)
		ToolGrip.C1 = CFrame.new(-1.1, 0, 0)
	end

	for _, child in model:GetChildren() do
		if child:IsA("BasePart") then
			CollectionService:AddTag(child, "PlayerHitbox")

			--local cur = child.CurrentPhysicalProperties
			--print(cur)
			--child.EnableFluidForces = false
			local new = nil
			--[[if not child.Name:match("HumanoidRootPart") then
				child.Massless = true
			end--]]
			if child.Name:match("Torso") then
				new = PhysicalProperties.new(1.4, 0.3, 0.5, 1, 1)
			end
			if child.Name:match("Head") then
				new = PhysicalProperties.new(1.6, 0.3, 0.5, 1, 1)
			end
			if child.Name:match("Arm") then
				new = PhysicalProperties.new(1.4, 0.3, 0.5, 1, 1)
			end
			if child.Name:match("Leg") then
				new = PhysicalProperties.new(1.33, 0.3, 0.5, 1, 1)
			end

			if new then
				child.CustomPhysicalProperties = new
			end
		end
	end

	local right_leg = model:FindFirstChild("Right Leg")
	if right_leg then
		CollectionService:AddTag(right_leg, "Collect")
	end

	local left_leg = model:FindFirstChild("Left Leg")
	if left_leg then
		CollectionService:AddTag(left_leg, "Collect")
	end

	model.ChildAdded:Connect(function(child)
		local bodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and bodyAttach and bodyAttach:IsA("BasePart") then
			ToolGrip.Part1 = bodyAttach
		end

		local collect = child:FindFirstChild("Front", true)
		if child:IsA("Tool") and collect and collect:IsA("BasePart") then
			CollectGrip.Part1 = collect
		end
	end)

	model.ChildRemoved:Connect(function(child)
		local bodyAttach = child:FindFirstChild("BodyAttach")
		if child:IsA("Tool") and bodyAttach and bodyAttach:IsA("BasePart") then
			if child.Parent == game.Workspace then
				ToolGrip.Part1 = nil
			end
		end
	end)

	local stick_entity = stick_prefab(world)
	world:add(stick_entity, jecs.pair(jecs.ChildOf, playerEntity))

	local participant = world:target(playerEntity, components.CurrentParticipant)
	if participant then
		world:add(character_entity, jecs.pair(components.CurrentParticipant, participant))
		world:add(stick_entity, jecs.pair(components.CurrentParticipant, participant))
	end

	local rink = world:target(playerEntity, components.BelongsToRink)
	if rink then
		world:add(character_entity, jecs.pair(components.BelongsToRink, rink))
		world:add(stick_entity, jecs.pair(components.BelongsToRink, rink))
	end

	refs[model] = character_entity
	return character_entity
end
