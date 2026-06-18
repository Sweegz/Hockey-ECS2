local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local fsm_stick = require(ReplicatedStorage.Shared.fsm_stick)

local LocalPlayer = world:get(components.LocalPlayer, components.LocalPlayer) :: jecs.Entity

-- stylua: ignore
local query_equipping = world
	:query(components.Tool, components.StickStateMachine)
	:with(jecs.pair(jecs.ChildOf, LocalPlayer), jecs.pair(components.EquippedOn, jecs.Wildcard))
	:without(components.Unequip)
	:cached()

-- stylua: ignore
local query_sticks_without_fsm = world
	:query(components.Stick)
	:with(jecs.pair(jecs.ChildOf, LocalPlayer), jecs.pair(components.EquippedOn, jecs.Wildcard))
	:without(components.StickStateMachine)
	:cached()

local function equip_stick()
	for e in query_sticks_without_fsm do
		-- stylua: ignore
		world:set(e, components.StickStateMachine,
			{
				debug = true,
				current = "Default",
				previous = "Default",
				active = false,
				busy = false,
				GRACE_TIME = 0,
				GRACE_DURATION = 0.15,
				BLEND_DURATION = 0.17,
				tick = tick(),
			} :: T.StickStateMachine
		)
	end

	for entity, tool, fsm in query_equipping:iter() do
		if fsm.active then
			continue
		end

		local xd = world:target(entity, components.EquippedOn)
		print(xd)

		local character_entity = world:target(entity, components.EquippedOn)
		if not character_entity then
			continue
		end

		local character = world:get(character_entity, components.Model)
		if not character then
			continue
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or not humanoid:IsA("Humanoid") then
			continue
		end

		world:set(entity, components.CollectCheck, {
			radius = 2.25,
			parts = { tool:FindFirstChild("Blade") },
		})
		world:set(character_entity, components.CollectCheck, {
			radius = 1.5,
			parts = {
				character:FindFirstChild("Right Leg"),
				character:FindFirstChild("Left Leg"),
			},
		})

		local momentum = hrp:FindFirstChild("Momentum") or Instance.new("BodyVelocity")
		momentum.Parent = hrp
		momentum.MaxForce = Vector3.new(25000, 0, 25000)

		momentum.Name = "Momentum"

		world:set(character_entity, components.Momentum, momentum)

		humanoid.JumpHeight = 0
		humanoid.WalkSpeed = 38
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

		print("Equipped")

		--stylua: ignore
		world:set(entity, components.Power, {
			value = 0,
			max = 100,
			rate = 100/1.15,
		} :: T.Power)

		--humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		fsm_stick.init(fsm, entity, world)
		fsm.active = true
	end
end

return {
	system = equip_stick,
	phase = planck_runservice.Phases.Update,
}
