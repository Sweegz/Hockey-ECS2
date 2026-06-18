local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query_shadow_with_active = world
	:query(components.Ghost, components.Shadow)
	:with(jecs.pair(components.PlayState, components.RoundActive))
	:cached()

local query_shadow_without_active = world
	:query(components.Ghost, components.Shadow)
	:without(jecs.pair(components.PlayState, components.RoundActive))
	:cached()

local function shadow_puck()
	-- stylua: ignore
	for e, ghost, shadow in query_shadow_with_active:iter()
	do
		if ghost.Position.Y > 2 then
			shadow.CFrame = CFrame.new(ghost.Position.X, 0.5, ghost.Position.Z)
			if not (shadow.Transparency == 0.7) then
				shadow.Transparency = 0.7
			end
		else
			if not (shadow.Transparency == 1) then
				shadow.Transparency = 1
			end
		end
	end

	-- stylua: ignore
	for e, ghost, shadow in query_shadow_without_active:iter()
	do
		if not (shadow.Transparency == 1) then
			shadow.Transparency = 1
		end
	end
end

return {
	system = shadow_puck,
	phase = planck_runservice.Phases.PreRender,
}
