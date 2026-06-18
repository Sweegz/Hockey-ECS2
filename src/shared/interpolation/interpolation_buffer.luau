local ReplicatedStorage = game:GetService("ReplicatedStorage")

local render_cache = require(ReplicatedStorage.Shared.interpolation.render_cache)

local SHOW_WARNINGS = false

return function(min_buffer: number, max_buffer: number, alpha: number)
	--average latency will be the average RTT between the client & server
	local player_latencies = {} :: { [number]: { average_latency: number, deviation: number, last_latency: number? } }
	local recovery = 0.5

	local function register_packet(network_id: number, server_time: number, tick_rate: number)
		local client_now = render_cache.get_estimated_server_time(network_id)
		local latency = client_now - server_time

		if latency > 1 then
			player_latencies[network_id] = nil
			render_cache.remove(network_id)
			render_cache.add(network_id)

			if SHOW_WARNINGS then
				warn(`{network_id} latency too high, cleared cache to repredict in case of error:! {latency}`)
			end
		end
		if not player_latencies[network_id] then
			--using the difference between current and last latency, i could smooth out the deviation (the variation in latency, which correlates to packet loss)
			--this is using statistics https://en.wikipedia.org/wiki/Moving_average
			player_latencies[network_id] = { average_latency = latency, deviation = 0, last_latency = latency }
			return
		end

		local data = player_latencies[network_id]
		if data.last_latency then
			local delta = math.abs(latency - data.last_latency)
			data.deviation = data.deviation + (delta - data.deviation) * alpha
		end

		data.average_latency = data.average_latency + (latency - data.average_latency) * alpha
		data.last_latency = latency
	end

	local function get_buffer(network_id: number, tick_rate: number)
		--calculate the interpolation buffer that accounts for expected latency, possible deviations and recovery from delays
		--the buffer will be per player
		local data = player_latencies[network_id]
		if not data then
			return min_buffer
		end

		local recovery_margin = tick_rate * recovery
		local raw_buffer = data.average_latency + data.deviation + recovery_margin

		--raw_buffer = tick_rate + data.deviation * 2

		local buffer = if raw_buffer < min_buffer then min_buffer + (min_buffer - raw_buffer) * 0.2 else raw_buffer
		if buffer > max_buffer then
			if SHOW_WARNINGS then
				warn(`interpolation_buffer exceeded max! Was {buffer}, clamped to {max_buffer}`)
			end
			buffer = max_buffer
		end

		return buffer
	end

	local function remove(id: number)
		player_latencies[id] = nil
		render_cache.remove(id)
	end

	local function clear(id)
		player_latencies[id] = nil
		render_cache.remove(id)
		render_cache.add(id)
	end

	return {
		register_packet = register_packet,
		get_buffer = get_buffer,
		remove = remove,
		player_latencies = player_latencies,
		clear = clear,
	}
end
