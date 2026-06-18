local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_character_without_tracks =
	world:query(components.Model, components.Character):without(components.AnimationTrack):cached()

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
		world:set(entity, components.AnimationTrack, animation_tracks)
	end
end

local function load_character_tracks()
	for c_Entity, c_Model in query_character_without_tracks:iter() do
		local humanoid = c_Model:FindFirstChild("Humanoid")
		if not humanoid then
			continue
		end

		local animator = humanoid:FindFirstChild("Animator")
		if not animator or not animator:IsA("Animator") then
			continue
		end

		load_animation_tracks(c_Entity, ReplicatedStorage.Animations.Stick, animator)
	end
end

return {
	system = load_character_tracks,
	phase = planck_runservice.Phases.Update,
}
