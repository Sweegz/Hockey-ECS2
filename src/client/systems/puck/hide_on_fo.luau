local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_with_fo =
	world:query(components.Ghost):with(jecs.pair(components.PlayState, components.RoundFaceoff)):cached()

local query_without_fo =
	world:query(components.Ghost):without(jecs.pair(components.PlayState, components.RoundFaceoff)):cached()

local function hide_on_fo()
	for e, ghost in query_with_fo:iter() do
		if not (ghost.Transparency == 1) then
			ghost.Transparency = 1
		end
	end

	for e, ghost in query_without_fo:iter() do
		if not (ghost.Transparency == 0) then
			ghost.Transparency = 0
		end
	end
end

return {
	system = hide_on_fo,
	phase = planck_runservice.Phases.PreRender,
}
