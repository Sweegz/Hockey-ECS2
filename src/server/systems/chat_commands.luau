local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local refs = require(ReplicatedStorage.Shared.tables.refs)

local function string_split(input: string, separator: string)
	local result = {}
	for part in string.gmatch(input, "([^" .. separator .. "]+)") do
		table.insert(result, part)
	end
	return result
end

local function get_player_from_string(player1: Player, input: string): Player?
	input = string.lower(input)
	if input == "me" then
		return player1
	end

	for _, player in pairs(game.Players:GetPlayers()) do
		local player_name = string.lower(player.Name)
		print(player_name, input)
		if string.match(player_name, "^" .. input) then
			return player
		end
	end
	return nil
end

local function team_player(player: Player, cmd: string, arg1: string)
	if not player then
		return
	end

	local target_player = get_player_from_string(player, arg1)
	if not target_player then
		return
	end

	local player_entity = refs[target_player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	for e, instance, team in
		world:query(components.Instance, components.Team, jecs.pair(components.BelongsToRink, rink_entity)):iter()
	do
		local team_attribute = instance:GetAttribute("Team")
		if string.lower(team_attribute) == cmd then
			world:add(participant_entity, jecs.pair(components.BelongsToTeam, e))
		else
			world:remove(participant_entity, jecs.pair(components.BelongsToTeam, e))
		end
	end
end

local function reset_puck(player)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
		return
	end

	for p_entity, p_part in
		world:query(components.BasePart, components.Puck):with(jecs.pair(components.BelongsToRink, rink_entity))
	do
		world:delete(p_entity)
	end

	world:set(rink_entity, jecs.pair(components.PlayState, components.RoundReset), {
		processed = false,
	})
end

local function create_start_game_request(player: Player)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if world:has(rink_entity, components.GamePeriod) then
		return
	end

	print("Start")
	world:add(rink_entity, components.StartGameRequest)
end

local function set_time(player: Player, time: number)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if not world:has(rink_entity, components.GameTime) then
		return
	end

	world:set(rink_entity, components.GameTime, time)
end

local function get_team(player: Player, letter: string): jecs.Entity?
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if letter == "h" then
		return world:target(rink_entity, components.HomeTeamLink)
	elseif letter == "a" then
		return world:target(rink_entity, components.AwayTeamLink)
	end

	return
end

local function fixfo(player: Player)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	local participant_entity = world:target(player_entity, components.CurrentParticipant)
	if not participant_entity then
		return
	end

	local rink_entity = world:target(participant_entity, components.BelongsToRink)
	if not rink_entity then
		return
	end

	if not world:has(rink_entity, components.Faceoff) then
		return
	end

	world:set(rink_entity, components.RoundTimer, {
		timestamp = os.clock(),
		duration = 2,
	})
end

local function find_smallest_team(world: jecs.World, rink_entity: jecs.Entity, team_entity: jecs.Entity)
	local min_team, min_count = nil, 10000

	local team_count = 0

	for _ in
		world:query(
			jecs.pair(components.ParticipantOf, jecs.Wildcard),
			jecs.pair(components.BelongsToTeam, team_entity)
		)
	do
		team_count += 1
	end

	for entity in world:query(components.Team, jecs.pair(components.BelongsToRink, rink_entity)) do
		if entity == team_entity then
			continue
		end

		local count = 0

		for _ in
			world:query(jecs.pair(components.ParticipantOf, jecs.Wildcard), jecs.pair(components.BelongsToTeam, entity))
		do
			count += 1
		end

		if count < min_count and count < team_count then
			min_count = count
			min_team = entity
		end
	end

	return min_team
end

local function handle_command(player: Player, message: string)
	local parts = string_split(message, "/")

	if not parts then
		return
	end

	local cmd = parts[1]
	if cmd then
		cmd = string.lower(cmd)
	end

	local arg1 = parts[2]
	if arg1 then
		arg1 = string.lower(arg1)
	end

	local arg2 = parts[3]
	if arg2 then
		arg2 = string.lower(arg2)
	end

	if message == "start game" then
		create_start_game_request(player)
	end

	if cmd == "settime" and arg1 then
		local time = tonumber(arg1)
		if time and time >= 0 then
			set_time(player, time)
		end
	end

	if cmd == "stop" then
		local sound = Workspace:FindFirstChild("Song")
		if sound then
			sound:Destroy()
		end
	end

	if (cmd == "play") and arg1 then
		local sound = Workspace:FindFirstChild("Song")
		if sound then
			sound:Destroy()
		end
		sound = Instance.new("Sound")
		sound.Name = "Song"
		sound.Parent = Workspace
		sound.SoundId = "rbxassetid://" .. arg1
		sound.Volume = 2

		print(parts)

		if parts[3] then
			local vol = tonumber(parts[3])
			if vol then
				sound.Volume = vol
			end
		end

		if parts[4] then
			local speed = tonumber(parts[4])
			if speed then
				sound.PlaybackSpeed = speed
			end
		end

		if parts[5] then
			local time_position = tonumber(parts[5])
			if time_position then
				sound.TimePosition = time_position
			end
		end

		sound:Play()
	end

	if (cmd == "sh" or cmd == "sa") and arg1 then
		local score = tonumber(arg1)
		if not score or not (score >= 0) then
			return
		end

		local team = get_team(player, message:sub(2, 2))
		if not team then
			return
		end

		world:set(team, components.Score, score)
	end

	if message == "sh+" or message == "sa+" then
		local team = get_team(player, message:sub(2, 2))
		if not team then
			return
		end

		local score = world:get(team, components.Score)
		if not score then
			return
		end

		world:set(team, components.Score, score + 1)
	end

	if message == "sh-" or message == "sa-" then
		local team = get_team(player, message:sub(2, 2))
		if not team then
			return
		end

		local score = world:get(team, components.Score)
		if not score then
			return
		end

		world:set(team, components.Score, score - 1)
	end

	if cmd == "fixfo" then
		fixfo(player)
	end

	if (cmd == "away" or cmd == "home" or cmd == "fan") and arg1 then
		team_player(player, cmd, arg1)
	end
	if cmd == "rp" or cmd == "arp" then
		reset_puck(player)
	end

	if message == "swt" then
		local player_entity = refs[player]
		if not player_entity then
			return
		end

		local participant_entity = world:target(player_entity, components.CurrentParticipant)
		if not participant_entity then
			return
		end

		local rink_entity = world:target(participant_entity, components.BelongsToRink)
		if not rink_entity then
			return
		end

		local team_entity = world:target(participant_entity, components.BelongsToTeam)
		if not team_entity then
			return
		end

		local team_to_change_to_entity = find_smallest_team(world, rink_entity, team_entity)

		world:add(participant_entity, jecs.pair(components.BelongsToTeam, team_to_change_to_entity))
	end
end

local queryA = world:query(components.Player):without(components.ChatListener):cached()
local queryB = world:query(components.Player, components.ChatListener):cached()

local function chat_listener()
	for entity, player in queryA:iter() do
		local _, event, disconnect = planck.onEvent(player.Chatted)

		world:set(entity, components.ChatListener, {
			event = event,
			disconnect = disconnect,
		})
	end

	for entity, player, listener in queryB:iter() do
		for _, chat in listener.event() do
			if player and chat then
				handle_command(player, chat)
			end
		end
	end
end

return {
	system = chat_listener,
	phase = planck_runservice.Phases.PostUpdate,
}
