local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local replicator = require(ReplicatedStorage.Shared.replicator)
local world = require(ReplicatedStorage.Shared.world)

local Action = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent

local query_unowned_pucks = world:query(components.Ghost):without(components.ClientPuckTag):cached()

local query_collect_check = world:query(components.CollectCheck):without(components.PreventCollect):cached()

local function send_collect_action(entity: jecs.Entity)
	local server_entity = replicator.client:get_server_entity(entity)
	if server_entity then
		Action:FireServer("Collect", {
			puck_entity = server_entity,
		})
	end
end

local sound = Instance.new("Sound")
sound.Name = "Click"
sound.Parent = Workspace
sound.SoundId = "rbxassetid://139595320123961"
sound.Volume = 1

local pitchsoundeffect = Instance.new("PitchShiftSoundEffect")
pitchsoundeffect.Parent = sound

local wait = false

local function collect_puck()
	local pucks = {}
	for p_Entity, p_Part in query_unowned_pucks:iter() do
		pucks[p_Entity] = p_Part.Position
	end

	for e, collect_parts in query_collect_check:iter() do
		for p_Entity, p_Pos in pairs(pucks) do
			local parts = collect_parts.parts
			local radius = collect_parts.radius

			for _, part in parts do
				local dist = (part.Position - p_Pos).Magnitude
				if dist <= radius then
					send_collect_action(p_Entity)

					break
				end
			end
		end
	end
end

return {
	system = collect_puck,
	planck_runservice.Phases.PostSimulation,
	runConditions = {
		planck.timePassed(1 / 60),
	},
}
