local ReplicatedStorage = game:GetService("ReplicatedStorage")

local T = require(ReplicatedStorage.Shared.types)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

function table_push(t, value, maxSize)
	maxSize = maxSize or 15

	-- shift elements right
	for i = math.min(#t, maxSize - 1), 1, -1 do
		t[i + 1] = t[i]
	end

	-- insert new value at front
	t[1] = value

	-- remove overflow
	if #t > maxSize then
		t[maxSize + 1] = nil
	end
end

local function is_penalty(hit_distance: number, distance_from_puck: number)
	if hit_distance >= 40 then
		return true
	end

	if distance_from_puck >= 25 then
		return true
	end

	return false
end

local function add_to_hit_tracker(
	rink_entity: jecs.Entity,
	player1: Player,
	player2: Player,
	power: number,
	hit_distance: number,
	distance_from_puck: number,
	penalty: boolean
)
	local player1_name = player1.Name or "..."
	local player2_name = player2.Name or "..."

	local hit_logs = world:get(rink_entity, components.HitLogs)
	if hit_logs then
		local msg2 = {
			player1_name = player1_name,
			player2_name = player2_name,
			power = power,
			hit_distance = hit_distance,
			distance_from_puck = distance_from_puck,
			penalty = penalty,
		}

		table_push(hit_logs, msg2, 16)
		world:set(rink_entity, components.HitLogs, hit_logs)
	end
end

local function hit_expire()
	for entity, hit_data in world:query(components.HitDataServer):iter() do
		if tick() > hit_data.start + hit_data.duration then
			world:remove(entity, components.HitDataServer)

			local rink_entity = hit_data.rink_entity
			local player1 = hit_data.player1
			local player2 = hit_data.player2
			local power = hit_data.power
			local distance_from_puck = hit_data.distance_from_puck
			local start_pos = hit_data.start_position * Vector3.new(1, 0, 1)

			task.delay(0.5, function()
				local final_pos = hit_data.part.Position * Vector3.new(1, 0, 1)
				local hit_distance = math.round((start_pos - final_pos).Magnitude)
				local penalty = is_penalty(hit_distance, distance_from_puck)
				add_to_hit_tracker(rink_entity, player1, player2, power, hit_distance, distance_from_puck, penalty)
			end)
		end
	end
end

return {
	system = hit_expire,
	phase = planck_runservice.Phases.Update,
}
