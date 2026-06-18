local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local T = require(ReplicatedStorage.Shared.types)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local nhl_teams = require(ServerScriptService.Server.game_data.nhl_teams)
local planck = require(ReplicatedStorage.Packages.planck)
local replecs = require(ReplicatedStorage.Packages.replecs)
local world = require(ReplicatedStorage.Shared.world)

local goalie_prefab = require(ServerScriptService.Server.prefabs.goalie_prefab)
local net_prefab = require(ServerScriptService.Server.prefabs.net_prefab)
local puck_prefab = require(ServerScriptService.Server.prefabs.puck_prefab)
local scoreboard_prefab = require(ServerScriptService.Server.prefabs.scoreboard_prefab)
local team_prefab = require(ServerScriptService.Server.prefabs.team_prefab)

local function setup_scoreboard(descendant: Model, home_team_entity: jecs.Entity, away_team_entity: jecs.Entity)
	local scoreboard_entity = scoreboard_prefab(world, descendant)
	local team = descendant:GetAttribute("Team")
	if team and team == "Home" then
		world:add(scoreboard_entity, jecs.pair(components.BelongsToTeam, home_team_entity))
	elseif team and team == "Away" then
		world:add(scoreboard_entity, jecs.pair(components.BelongsToTeam, away_team_entity))
	end
end

local function setup_net(
	descendant: Model,
	home_team_entity: jecs.Entity,
	away_team_entity: jecs.Entity,
	rink_entity: jecs.Entity
)
	local net = descendant:FindFirstChild("Net")
	if not net or not net:IsA("Model") then
		return
	end

	local net_entity = net_prefab(world, net)
	local team = descendant:GetAttribute("Team")

	local team_entity = nil

	if team and team == "Home" then
		team_entity = home_team_entity
	elseif team and team == "Away" then
		team_entity = away_team_entity
	end
	world:add(net_entity, jecs.pair(components.BelongsToRink, rink_entity))

	local goalie = descendant:FindFirstChild("Goalie")
	if not goalie or not goalie:IsA("Model") then
		return
	end

	local primary_part = goalie.PrimaryPart
	if not primary_part then
		warn("Found no PrimaryPart for Goalie model")
		return
	end

	primary_part:SetNetworkOwner(nil)

	local goalie_entity = goalie_prefab(world, goalie)
	world:add(goalie_entity, jecs.pair(components.Goalie, net_entity))
	world:add(goalie_entity, jecs.pair(components.BelongsToRink, rink_entity))

	if team_entity then
		world:add(net_entity, jecs.pair(components.BelongsToTeam, team_entity))
		world:add(goalie_entity, jecs.pair(components.BelongsToTeam, team_entity))
	end
end

local function setup_bench(descendant: PVInstance, home_team_entity: jecs.Entity, away_team_entity: jecs.Entity)
	local team = descendant:GetAttribute("Team")
	if team and team == "Home" then
		world:set(home_team_entity, components.Renderable, descendant)
	elseif team and team == "Away" then
		world:set(away_team_entity, components.Renderable, descendant)
	end
end

local random = Random.new(tick())

local function get_random_key_in_dict(dict: {})
	local temp_table = {}

	for key, _ in dict do
		table.insert(temp_table, key)
	end

	local random = random:NextInteger(1, #temp_table)

	local key = temp_table[random]

	return key
end

local function rinks_setup()
	local function add_rink(instance: Model)
		local entity = world:entity()
		world:set(entity, components.Model, instance)

		world:add(entity, replecs.networked)
		--world:add(entity, jecs.pair(replecs.reliable, components.Model))
		world:add(entity, jecs.pair(replecs.pair, components.PlayState))
		world:add(entity, jecs.pair(replecs.reliable, components.UUID))
		world:add(entity, jecs.pair(replecs.reliable, components.GameTime))
		world:add(entity, jecs.pair(replecs.reliable, components.GamePeriod))
		world:add(entity, jecs.pair(replecs.reliable, components.HitLogs))
		world:add(entity, jecs.pair(replecs.pair, components.HomeTeamLink))
		world:add(entity, jecs.pair(replecs.pair, components.AwayTeamLink))
		world:add(entity, components.Rink)
		world:set(entity, jecs.pair(components.PlayState, components.RoundActive), {
			processed = false,
		})
		world:set(entity, components.HitLogs, {})
		--world:set(entity, components.GameTime, 300)
		--world:set(entity, components.GamePeriod, 0)

		print("Created rink", entity)

		local away_team_entity = team_prefab(world, "Away", BrickColor.Red())
		local home_team_entity = team_prefab(world, "Home", BrickColor.Blue())
		world:add(home_team_entity, jecs.pair(components.BelongsToRink, entity))
		world:add(away_team_entity, jecs.pair(components.BelongsToRink, entity))
		world:add(entity, jecs.pair(components.HomeTeamLink, home_team_entity))
		world:add(entity, jecs.pair(components.AwayTeamLink, away_team_entity))

		local ta = nhl_teams

		for _, team_entity in { away_team_entity, home_team_entity } do
			local key = get_random_key_in_dict(ta)
			local selected = ta[key] :: T.SelectedTeamData
			ta[key] = nil

			world:set(team_entity, jecs.Name, selected.name)
			world:set(team_entity, components.Abbreviation, selected.abbreviation)
			world:set(team_entity, components.GoalHorn, selected.horn)

			local team = world:get(team_entity, components.Team)
			if team then
				team.Name = selected.name
			end

			world:set(team_entity, components.PrimaryColors, selected.colors)

			if team_entity == home_team_entity then
				world:set(team_entity, components.Uniform, selected.uniforms.home)
			elseif team_entity == away_team_entity then
				world:set(team_entity, components.Uniform, selected.uniforms.away)
			end
		end

		for _, descendant in instance:GetDescendants() do
			if descendant:IsA("Model") then
				if CollectionService:HasTag(descendant, "Scoreboard") then
					setup_scoreboard(descendant, home_team_entity, away_team_entity)
				end
				if CollectionService:HasTag(descendant, "Net") then
					print("Setup net")
					setup_net(descendant, home_team_entity, away_team_entity, entity)
				end
				if CollectionService:HasTag(descendant, "Bench") then
					print("Setup bench")
					setup_bench(descendant, home_team_entity, away_team_entity)
				end
			elseif descendant:IsA("BasePart") then
				if CollectionService:HasTag(descendant, "Joiner") then
					print("Setup joiner")
					--setup_joiner(descendant, entity)
				end
				if CollectionService:HasTag(descendant, "Bench") then
					setup_bench(descendant, home_team_entity, away_team_entity)
				end
			end
		end

		local colors = world:get(home_team_entity, components.PrimaryColors)
		local STADIUM = Workspace:FindFirstChild("Stadium")
		if STADIUM then
			local L1Seats = STADIUM:FindFirstChild("L1Seats")
			if L1Seats then
				for _, descendant in L1Seats:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.BrickColor = BrickColor.new(colors.primary)
					end
				end
			end

			local L2Seats = STADIUM:FindFirstChild("L2Seats")
			if L2Seats then
				for _, descendant in L2Seats:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.BrickColor = BrickColor.new(colors.tertiary)
					end
				end
			end

			local L3Seats = STADIUM:FindFirstChild("L3Seats")
			if L3Seats then
				for _, descendant in L3Seats:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.BrickColor = BrickColor.new(colors.tertiary)
					end
				end
			end

			local L4Seats = STADIUM:FindFirstChild("L4Seats")
			if L4Seats then
				for _, descendant in L4Seats:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.BrickColor = BrickColor.new(colors.auxillary)
					end
				end
			end
		end

		puck_prefab(world, entity, Vector3.new(0, 8, 0))
	end

	for _, instance in CollectionService:GetTagged("Rink") do
		add_rink(instance)
	end

	CollectionService:GetInstanceAddedSignal("Rink"):Connect(add_rink)
end

return {
	system = rinks_setup,
	phase = planck.Phase.Startup,
}
