local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query =
	world:query(components.StartGameRequest):with(jecs.pair(components.PlayState, components.RoundActive)):cached()

local function start_game(rink_entity: jecs.Entity)
	world:remove(rink_entity, components.StartGameRequest)
	world:set(rink_entity, components.GamePeriod, 1)
	world:set(rink_entity, components.GameTime, 300)

	for p_entity, p_part in
		world:query(components.BasePart, components.Puck):with(jecs.pair(components.BelongsToRink, rink_entity))
	do
		world:delete(p_entity)
	end

	for t_entity, score in world:query(components.Score):with(jecs.pair(components.BelongsToRink, rink_entity)) do
		world:set(t_entity, components.Score, 0)
	end

	world:set(rink_entity, jecs.pair(components.PlayState, components.RoundStart), {
		processed = false,
	})

	local msg = Instance.new("Message")
	msg.Text = "Starting Game"
	msg.Parent = game.Workspace
	task.delay(3, function()
		msg:Destroy()
	end)
end

local HORNS = SoundService:FindFirstChild("Horns")
local ENDOFPERIODHORN = HORNS:FindFirstChild("EndOfPeriod")

local function start_game_request()
	for rink_entity in query:iter() do
		start_game(rink_entity)
		ENDOFPERIODHORN:Play()
	end
end

return {
	system = start_game_request,
	phase = planck_runservice.Phases.Update,
}
