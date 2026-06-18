local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local get_valid_mouse_hit = require(StarterPlayer.StarterPlayerScripts.Client.utility.get_valid_mouse_hit)

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

local query_shotevents = world:query(components.ShotEvent):cached()

local function shot_event()
	for entity, event in query_shotevents:iter() do
		local mouse_hit = get_valid_mouse_hit() * Vector3.new(1, 0, 1)

		local pos: Vector3 = Vector3.new(0, 0, 0)

		local variant = nil

		if event.fake then
			variant = "Fake"
		elseif event.chip then
			variant = "Chip"
		elseif event.wrist then
			variant = "Wrist"
		end

		for puck_entity, ghost in
			world:query(components.BasePart, jecs.pair(components.Owner, event.entity)):with(components.Puck):iter()
		do
			pos = ghost.Position
			if variant ~= "Fake" then
				world:set(puck_entity, components.FiredShot, pos)
			end
			break
		end

		Action:FireServer("Shoot1", {
			pos = pos,
			power = event.power,
			aim = mouse_hit,
			variant = variant,
		})

		world:remove(entity, components.ShotEvent)
		world:add(entity, components.Destroy)
	end
end

return {
	system = shot_event,
	phase = planck_runservice.Phases.PostUpdate,
}
