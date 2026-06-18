local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local puck_prefab = require(ServerScriptService.Server.prefabs.puck_prefab)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local world = require(ReplicatedStorage.Shared.world)

local function get_spots(parent: Model, team_name: string)
	local prefix = team_name == "Home" and "H" or "A"
	return {
		parent:FindFirstChild(prefix .. "2") :: BasePart,
		parent:FindFirstChild(prefix .. "3") :: BasePart,
		parent:FindFirstChild(prefix .. "4") :: BasePart,
		parent:FindFirstChild(prefix .. "5") :: BasePart,
	}
end

local function count_active_players_on_team(team_entity: jecs.Entity, r_Entity: jecs.Entity)
	local num_players = 0
	local num_unbenched = 0
	local num_opposite = 0

	for temp_entity in world:query(components.Team, jecs.pair(components.BelongsToRink, r_Entity)) do
		for partic in world:query(jecs.pair(components.BelongsToTeam, temp_entity), components.Active) do
			if temp_entity == team_entity then
				num_players += 1
				if not world:has(partic, components.Benched) then
					num_unbenched += 1
				end
			else
				num_opposite += 1
			end
		end
	end

	return num_players, num_unbenched, num_opposite
end

local function fill_faceoff_spots(
	r_Entity: jecs.Entity,
	team_entity: jecs.Entity,
	team_name: string,
	num_unbenched_players: number,
	faceoff_parent: Model
)
	local spots = get_spots(faceoff_parent, team_name)

	-- collect distances from each participant to each spot
	local dists_tables = { {}, {}, {}, {} }
	for participant_entity in
		world
			:query(jecs.pair(components.BelongsToTeam, team_entity))
			:without(jecs.pair(components.InFaceoff, jecs.Wildcard), components.Benched)
	do
		local player_entity = world:target(participant_entity, components.ParticipantOf)
		if not player_entity then
			continue
		end

		local player = world:get(player_entity, components.Player)
		if not player then
			continue
		end

		local character = player.Character
		if not character then
			continue
		end

		for i, spot in ipairs(spots) do
			if spot then
				dists_tables[i][participant_entity] = (character.HumanoidRootPart.Position - spot.Position).Magnitude
			end
		end
	end

	-- number of extra spots to fill (center A1/H1 is already assigned)
	local spots_to_fill = num_unbenched_players - 1
	if spots_to_fill <= 0 then
		return
	end

	local assigned = {}
	for i, spot in ipairs(spots) do
		if spots_to_fill <= 0 then
			break
		end
		local cur = dists_tables[i]
		local best_p, best_dist = nil, math.huge
		for p, dist in pairs(cur) do
			if not assigned[p] and dist < best_dist then
				best_p = p
				best_dist = dist
			end
		end

		if best_p and spot then
			world:set(best_p, jecs.pair(components.InFaceoff, r_Entity), spot.CFrame)
			assigned[best_p] = true
			spots_to_fill -= 1
		end
	end
end

local function assign_center_and_prepare(
	participant_entity: jecs.Entity,
	team_entity: jecs.Entity,
	team_name: string,
	r_Entity: jecs.Entity,
	r_Faceoff: any
)
	local center_name = team_name == "Home" and "H1" or "A1"
	local spot = r_Faceoff.center.Parent:FindFirstChild(center_name)
	if spot then
		world:set(participant_entity, jecs.pair(components.InFaceoff, r_Entity), spot.CFrame)
	end

	local _, num_unbenched, num_opposite = count_active_players_on_team(team_entity, r_Entity)
	fill_faceoff_spots(r_Entity, team_entity, team_name, num_unbenched, r_Faceoff.center.Parent)

	if team_name == "Home" then
		r_Faceoff.home_ready = true
		if num_opposite == 0 then
			r_Faceoff.away_ready = true
		end
	else
		r_Faceoff.away_ready = true
		if num_opposite == 0 then
			r_Faceoff.home_ready = true
		end
	end

	world:set(r_Entity, components.Faceoff, r_Faceoff)
	if r_Faceoff.home_ready and r_Faceoff.away_ready then
		r_Faceoff.text_label.Text = "Ready!"
		world:set(r_Entity, components.RoundTimer, {
			timestamp = os.clock(),
			duration = 4,
		})
	end
end

local function find_closest_faceoff(game_model: Model, pos: Vector3)
	local dots = game_model:FindFirstChild("Dots")
	if not dots or not dots:IsA("Model") then
		return Vector3.new(0, 1, 0)
	end

	local blue_lines = game_model:FindFirstChild("BlueLines")
	if not blue_lines then
		return Vector3.new(0, 1, 0)
	end

	-- Collect dots that are in front of any blue line where `pos` is also in front
	local candidates = {}
	for _, line in blue_lines:GetChildren() do
		if not line:IsA("BasePart") then
			continue
		end

		local look_vector = line.CFrame.LookVector
		local pos_dot = (pos - line.Position):Dot(look_vector)
		if pos_dot > 0 then
			for _, dot in dots:GetChildren() do
				if not dot:IsA("BasePart") then
					continue
				end

				local dot_dot = (dot.Position - line.Position):Dot(look_vector)
				if dot_dot > 0 then
					candidates[dot] = true
				end
			end
		end
	end

	local smallest_dist = math.huge
	local smallest_pos = Vector3.new(0, 1, 0)

	-- If we have candidate dots (on the correct side of a matching blue line), pick the nearest of them
	if next(candidates) ~= nil then
		for dot, _ in pairs(candidates) do
			local dist = (dot.Position - pos).Magnitude
			if dist < smallest_dist then
				smallest_dist = dist
				smallest_pos = dot.Position
			end
		end
		return smallest_pos
	end

	return Vector3.new(0, 1, 0)
end

local queryA = world
	:query(components.Model, jecs.pair(components.PlayState, components.RoundFaceoff))
	:with(components.Rink)
	:cached()

local queryB = world
	:query(components.Model, jecs.pair(components.PlayState, components.RoundFaceoff))
	:with(components.Rink)
	:without(components.Faceoff)
	:cached()

local queryC = world:query(components.Model, components.Faceoff):with(components.Rink):cached()

local queryD = world:query(jecs.pair(components.InFaceoff, jecs.Wildcard)):without(components.Benched):cached()

local queryE = world
	:query(components.Model, components.Faceoff)
	:with(components.Rink)
	:without(jecs.pair(components.PlayState, components.RoundFaceoff))
	:cached()

local function round_faceoff()
	for r_Entity, r_Model, data in queryA:iter() do
		if not data.processed then
			print("RoundFaceoff")
			data.processed = true
			world:set(r_Entity, jecs.pair(components.PlayState, components.RoundFaceoff), data)
			world:set(r_Entity, components.RoundTimer, {
				timestamp = os.clock(),
				duration = 30 + 2,
			})
		end

		local round_timer = world:get(r_Entity, components.RoundTimer)
		if round_timer and os.clock() > round_timer.timestamp + round_timer.duration then
			world:set(r_Entity, jecs.pair(components.PlayState, components.RoundActive), {
				processed = false,
			})
		end
	end

	-- CREATE
	for r_Entity, r_Model, data in queryB:iter() do
		print("Added faceoff")

		local game_model = r_Model:FindFirstChild("Game")
		if not game_model then
			continue
		end

		local faceoff_model = game_model:FindFirstChild("Faceoff")
		if not faceoff_model then
			continue
		end

		local primary_part = faceoff_model.PrimaryPart
		if not primary_part then
			continue
		end

		if data.cause == "OOB" then
			local last_shot_pos = world:get(r_Entity, components.LastShotPosition)
			if last_shot_pos then
				local dot_pos = find_closest_faceoff(game_model, last_shot_pos)
				faceoff_model:PivotTo(CFrame.new(dot_pos))
			end
		elseif data.cause == "Reset" then
			local last_pos = world:get(r_Entity, components.LastPosition)
			if last_pos then
				local dot_pos = find_closest_faceoff(game_model, last_pos)
				faceoff_model:PivotTo(CFrame.new(dot_pos))
			end
		else
			faceoff_model:PivotTo(CFrame.new(Vector3.new(0, 1, 0)))
		end

		local billboard_gui = primary_part:FindFirstChild("BillboardGui")
		if not billboard_gui then
			continue
		end

		local text_label = billboard_gui:FindFirstChild("TextLabel")
		if not text_label then
			continue
		end

		local home_pad = faceoff_model:FindFirstChild("Home")
		local away_pad = faceoff_model:FindFirstChild("Away")
		if not home_pad or not away_pad then
			continue
		end

		home_pad.Transparency = 0.5
		away_pad.Transparency = 0.5
		text_label.TextTransparency = 0
		billboard_gui.Enabled = true

		local p_Entity = puck_prefab(world, r_Entity, primary_part.Position + Vector3.new(0, 8, 0))
		if not p_Entity then
			continue
		end

		local p_Part = world:get(p_Entity, components.BasePart)
		if not p_Part then
			continue
		end

		p_Part.Anchored = true

		local faceoff_data = {
			center = primary_part,
			home_pad = home_pad,
			away_pad = away_pad,
			billboard_gui = billboard_gui,
			text_label = text_label,
			home_ready = false,
			away_ready = false,
		}

		world:set(r_Entity, components.Faceoff, faceoff_data)
	end

	-- UPDATE
	for r_Entity, r_Model, r_Faceoff in queryC:iter() do
		local round_timer = world:get(r_Entity, components.RoundTimer)
		if not round_timer then
			continue
		end

		local time_left = round_timer.duration - (os.clock() - round_timer.timestamp) - 1

		-- update faceoff text
		if not r_Faceoff.home_ready or not r_Faceoff.away_ready then
			r_Faceoff.text_label.Text = math.ceil(time_left) - 1
		end

		-- fade faceoff out
		if time_left < 1 then
			local transparency = (1 - time_left / 2)
			r_Faceoff.home_pad.Transparency = transparency
			r_Faceoff.away_pad.Transparency = transparency
			r_Faceoff.text_label.TextTransparency = transparency
		end

		local parts_touched = workspace:GetPartsInPart(r_Faceoff.center)

		if time_left < 1 then
			continue
		end

		for _, part in parts_touched do
			local character = part.Parent
			if not character then
				continue
			end

			local entity = refs[character]
			if not entity then
				continue
			end

			local player_entity = world:parent(entity)
			if not player_entity then
				continue
			end

			local participant_entity = world:target(player_entity, components.CurrentParticipant)
			if not participant_entity then
				continue
			end

			local team_entity = world:target(participant_entity, components.BelongsToTeam)
			if not team_entity then
				continue
			end

			local team_instance = world:get(team_entity, components.Instance)
			if not team_instance then
				continue
			end

			local team = team_instance:GetAttribute("Team")
			if not team then
				continue
			end

			if team == "Home" and not r_Faceoff.home_ready then
				assign_center_and_prepare(participant_entity, team_entity, team, r_Entity, r_Faceoff)
			elseif team == "Away" and not r_Faceoff.away_ready then
				assign_center_and_prepare(participant_entity, team_entity, team, r_Entity, r_Faceoff)
			end
		end
	end

	-- move players to faceoff
	for e, cframe in queryD:iter() do
		local player_entity = world:target(e, components.ParticipantOf)
		if not player_entity then
			continue
		end

		local player = world:get(player_entity, components.Player)
		if not player then
			continue
		end

		local character = player.Character
		if not character then
			continue
		end

		local HRP = character.HumanoidRootPart
		if not HRP then
			continue
		end

		HRP.Anchored = true
		character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		character.HumanoidRootPart.CFrame = cframe

		local gyro = HRP:FindFirstChild("BodyGyro")
		if gyro then
			gyro.P = 0
			gyro.MaxTorque = Vector3.new(0, 0, 0)
		end
	end

	-- DESTROY
	for r_Entity, r_Model, r_Faceoff in queryE:iter() do
		print("Removed faceoff")

		r_Faceoff.home_pad.Transparency = 1
		r_Faceoff.away_pad.Transparency = 1
		r_Faceoff.billboard_gui.Enabled = false
		r_Faceoff.text_label.Text = "30"

		for p_Entity, p_Part in
			world:query(components.BasePart, jecs.pair(components.BelongsToRink, r_Entity)):with(components.Puck)
		do
			p_Part.Anchored = false
		end

		for e, cframe in world:query(jecs.pair(components.InFaceoff, r_Entity)) do
			world:remove(e, jecs.pair(components.InFaceoff, r_Entity))
			local player_entity = world:target(e, components.ParticipantOf)
			if not player_entity then
				continue
			end

			local player = world:get(player_entity, components.Player)
			if not player then
				continue
			end

			local character = player.Character
			if not character then
				continue
			end

			local HRP = character.HumanoidRootPart
			if not HRP then
				continue
			end

			HRP.Anchored = false
			HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			HRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			local gyro = HRP:FindFirstChild("BodyGyro")
			if gyro then
				gyro.P = 10000
				gyro.MaxTorque = Vector3.new(0, 1000000000, 0)
			end
		end

		world:remove(r_Entity, components.Faceoff)
	end
end

return {
	system = round_faceoff,
	phase = planck_runservice.Phases.Last,
}
