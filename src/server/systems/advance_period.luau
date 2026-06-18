local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local puck = require(ServerScriptService.Server.utility.puck)
local world = require(ReplicatedStorage.Shared.world)

local function destroy_puck(entity: jecs.Entity, duration: number)
	local data = {
		duration = duration,
		created = os.clock(),
	}

	for p_entity, p_part in
		world:query(components.BasePart, components.Puck):with(jecs.pair(components.BelongsToRink, entity))
	do
		world:set(p_entity, components.Lifetime, data)
	end
end

local HORNS = SoundService:FindFirstChild("Horns")
local ENDOFPERIODHORN = HORNS:FindFirstChild("EndOfPeriod")

local function end_game(entity: jecs.Entity, winner: jecs.Entity)
	local team_name = world:get(winner, jecs.Name)
	if not team_name then
		return
	end

	local msg = Instance.new("Message")
	msg.Text = team_name .. " has won the game!"
	msg.Parent = game.Workspace
	task.delay(3, function()
		msg:Destroy()
	end)

	--[[for t_entity, score in world:query(components.Score):with(jecs.pair(components.BelongsToRink, entity)) do
		world:set(t_entity, components.Score, 0)
	end--]]

	world:set(entity, jecs.pair(components.PlayState, components.RoundEnd), {
		processed = false,
	})

	world:remove(entity, components.GameTime)
	world:remove(entity, components.GamePeriod)
	puck.drop(entity)
	destroy_puck(entity, 5)
end

local function check_if_winner(entity: jecs.Entity): jecs.Entity?
	local home_entity = world:target(entity, components.HomeTeamLink)
	local away_entity = world:target(entity, components.AwayTeamLink)
	if not home_entity or not away_entity then
		return
	end

	local home_score = world:get(home_entity, components.Score)
	local away_score = world:get(away_entity, components.Score)
	if not home_score or not away_score then
		return
	end

	if home_score > away_score then
		return home_entity
	elseif away_score > home_score then
		return away_entity
	else
		return
	end
end

local function end_period(entity: jecs.Entity, game_period: number)
	world:set(entity, jecs.pair(components.PlayState, components.RoundEnd), {
		processed = false,
	})

	puck.drop(entity)
	destroy_puck(entity, 0)

	local msg = Instance.new("Message")
	msg.Text = game_period .. " period has ended!"
	msg.Parent = game.Workspace
	task.delay(3, function()
		msg:Destroy()
	end)

	world:set(entity, components.GameTime, 300)
	world:set(entity, components.GamePeriod, game_period + 1)
end

local query = world
	:query(components.GameTime, components.GamePeriod)
	:with(jecs.pair(components.PlayState, components.RoundActive))
	:cached()

local queryB = world
	:query(components.GameTime, components.GamePeriod)
	:with(components.GameOvertime, jecs.pair(components.PlayState, components.RoundActive))
	:cached()

local function advanced_period()
	for entity, game_time, game_period in query:iter() do
		if game_time > 0 then
			continue
		end

		local winner = check_if_winner(entity)
		if winner and game_period >= 3 then
			print("X1")
			end_game(entity, winner)
			ENDOFPERIODHORN:Play()
			continue
		elseif game_period >= 3 then
			print("X2")
			world:add(entity, components.GameOvertime)
		end

		print("X3")

		end_period(entity, game_period)
		ENDOFPERIODHORN:Play()
	end

	for r_entity in queryB:iter() do
		local winner = check_if_winner(r_entity)
		if winner then
			print("Won")
			end_game(r_entity, winner)
			world:remove(r_entity, components.GameOvertime)
		end
	end
end

return {
	system = advanced_period,
	phase = planck_runservice.Phases.Last,
}
