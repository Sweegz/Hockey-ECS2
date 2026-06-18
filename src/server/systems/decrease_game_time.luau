local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.GameTime):with(jecs.pair(components.PlayState, components.RoundActive)):cached()

local function decrease_game_time()
	for e, game_time in query:iter() do
		local new_time = game_time - scheduler:getDeltaTime()
		world:set(e, components.GameTime, new_time)
	end
end

return {
	system = decrease_game_time,
	phase = planck_runservice.Phases.PostUpdate,
}
