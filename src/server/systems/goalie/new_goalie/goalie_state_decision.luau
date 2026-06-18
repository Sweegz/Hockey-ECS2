local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world
	:query(components.ThreatData, components.RelativeZone)
	:with(components.Goalie)
	:without(components.GoalieReacting)
	:cached()

local function goalie_state_decision()
	for g_entity, threat_data, zone in query:iter() do
		local threat = threat_data.threat
		local poke = threat_data.poke

		local decision = "Butterfly"

		if zone == "Front" then
			if threat == "High" and poke then
				decision = "Poke"
			elseif threat == "Medium" then
				decision = "Butterfly"
			elseif threat == "Low" then
				decision = "Standing1"
			elseif threat == "None" then
				decision = "Standing2"
			end
		elseif zone == "Side" then
			decision = "Standing3"
		elseif zone == "Behind" then
			decision = "Standing1"
		end

		world:set(g_entity, components.StateDecision, decision)
	end
end

return {
	system = goalie_state_decision,
	phase = planck_runservice.Phases.Update,
}
