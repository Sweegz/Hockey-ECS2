local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function puck_owned_by_client()
	local localplayer_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not localplayer_entity then
		return
	end

	local current_participant = world:target(localplayer_entity, components.CurrentParticipant)
	if not current_participant then
		return
	end

	for p_Entity in world:query(jecs.pair(components.Owner, current_participant)):without(components.ClientPuckTag) do
		world:add(p_Entity, components.ClientPuckTag)
	end

	for p_Entity in world:query(components.ClientPuckTag):without(jecs.pair(components.Owner, current_participant)) do
		world:remove(p_Entity, components.ClientPuckTag)
	end
end

return {
	system = puck_owned_by_client,
	planck_runservice.Phases.Update,
}
