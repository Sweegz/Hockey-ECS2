local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local fsm_goalie = require(ServerScriptService.Server.fsm_goalie)

local query_goalies_without_fsm = world
	:query(components.Model, jecs.pair(components.Goalie, jecs.Wildcard))
	:without(components.GoalieStateMachine)
	:cached()

local function load_animation_tracks(entity, source, animator: Animator)
	local animation_tracks = {}

	local tracks = world:get(entity, components.AnimationTrack)

	local debounce = false

	for _, child in source:GetChildren() do
		if child:IsA("Animation") then
			if not tracks or not tracks[child.name] then
				local animation_track = animator:LoadAnimation(child)
				animation_tracks[child.Name] = animation_track
				debounce = true
			end
		end
	end

	if debounce then
		print("Loaded animations")
		world:set(entity, components.AnimationTrack, animation_tracks)
	end
end

local function goalie_setup()
	for g_Entity, g_Model in world:query(components.Model):with(components.Goalie):without(components.CenterCFrame) do
		local net = g_Model.Parent
		if not net then
			continue
		end

		local net_center = net:FindFirstChild("Center")
		if not net_center or not net_center:IsA("BasePart") then
			continue
		end

		world:set(g_Entity, components.CenterCFrame, net_center.CFrame)
	end

	for g_Entity, g_Model in query_goalies_without_fsm:iter() do
		local data = {
			debug = false,
			current = "Standing2",
			previous = "Standing2",
			active = false,
			busy = false,
			GRACE_TIME = 0,
			GRACE_DURATION = 0.15,
			BLEND_DURATION = 0.15,
			tick = tick(),
		} :: T.GoalieStateMachine

		world:set(g_Entity, components.GoalieStateMachine, data)

		local humanoid = g_Model:FindFirstChild("Humanoid")
		if not humanoid then
			continue
		end

		local animator = humanoid:FindFirstChild("Animator")
		if not animator or not animator:IsA("Animator") then
			continue
		end

		load_animation_tracks(g_Entity, ReplicatedStorage.Animations.Goalie, animator)
		fsm_goalie.init(data, g_Entity, world)
	end
end

return {
	system = goalie_setup,
	phase = planck_runservice.Phases.Update,
}
