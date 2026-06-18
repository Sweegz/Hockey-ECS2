local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local shots = require(ServerScriptService.Server.utility.shots)
local sound_manager = require(ReplicatedStorage.Shared.utility.sound_manager)

local planes: { Instance } = {}
table.insert(planes, CollectionService:GetTagged("NetZone")) -- start with existing ones
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = planes
params.IgnoreWater = true

CollectionService:GetInstanceAddedSignal("NetZone"):Connect(function(instance: Instance)
	table.insert(planes, instance)
	params.FilterDescendantsInstances = planes
end)

CollectionService:GetInstanceRemovedSignal("NetZone"):Connect(function(instance: Instance)
	for i = #planes, 1, -1 do
		if planes[i] == instance then
			table.remove(planes, i)
			break
		end
	end
	params.FilterDescendantsInstances = planes
end)

local function blockcast_collision(
	part: BasePart,
	size: Vector3,
	params: RaycastParams,
	dir: Vector3,
	visualize: boolean
): RaycastResult?
	local result = Workspace:Blockcast(part.CFrame, size, dir, params)

	return result
end

local action = {}

local sound_folder = SoundService:FindFirstChild("Shots")
local SHOT_SOUND = sound_folder:FindFirstChild("Shot")
local SLAPSHOT_SOUND = sound_folder:FindFirstChild("Slapshot")
--local SLAPSHOT_SOUND = sound_folder:FindFirstChild("Slapshot")

local function create_sound_part()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1, 0.33, 1)
	part.Transparency = 1
	part.Parent = Workspace

	return part
end

function action.shoot1(player: Player, pos: Vector3, power: number, aim: Vector3, variant: string)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	aim = aim * Vector3.new(1, 0, 1)

	local fake = (variant == "Fake")

	for participant_entity in world:query(jecs.pair(components.ParticipantOf, player_entity)) do
		for puck_entity, basepart in
			world:query(components.BasePart, components.Puck, jecs.pair(components.Owner, participant_entity))
		do
			local dir = (aim - pos).Unit
			dir = Vector3.new(dir.X, 0, dir.Z)

			print(variant)
			local velocity, force, time = shots.calculate_vel_and_force(power, dir, variant)

			local rink_entity = world:target(puck_entity, components.BelongsToRink)
			if not rink_entity then
				continue
			end

			if not fake then
				puck.drop(puck_entity)
				puck.add_cooldown(puck_entity, 0.5)
				basepart.Position = pos
				world:set(rink_entity, components.LastShotPosition, pos)
				shots.apply_velocity(basepart, velocity)
				shots.apply_force(basepart, force, time)

				local part = create_sound_part()
				part.Position = basepart.Position
				if power > 50 then
					sound_manager.play_sound(part, SLAPSHOT_SOUND, 1.4)
				else
					sound_manager.play_sound(part, SHOT_SOUND, 2)
				end

				task.delay(2, function()
					part:Destroy()
				end)
			end

			local result = blockcast_collision(basepart, Vector3.new(1, 0.3, 1), params, velocity, false)
			if result then
				local instance = result.Instance
				if not instance then
					continue
				end

				local parent = instance.Parent
				if not parent then
					continue
				end

				local net = parent.Parent
				if not net then
					continue
				end

				local goalie = net:FindFirstChild("Goalie")
				if not goalie then
					continue
				end

				local goalie_entity = refs[goalie]
				if not goalie_entity then
					continue
				end

				local goalie_rink_entity = world:target(goalie_entity, components.BelongsToRink)

				if goalie_rink_entity ~= rink_entity then
					continue
				end

				if fake and power < 30 then
					continue
				end

				world:set(goalie_entity, components.ShotHitNet, {
					origin = basepart.Position,
					direction = dir,
					ray_result = result,
					fake = fake,
				})
			end
		end
	end
end

return action
