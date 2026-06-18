local ReplicatedStorage = game:GetService("ReplicatedStorage")

local interpolation_config = require(ReplicatedStorage.Shared.interpolation.interpolation_config)

local player_tick_rates
local buffer_tracker

local client_clock_info = {} :: {
	[number]: {
		last_clock_at: number,
		last_clock_duration: number,
		render_at: number?,
	},
}

local function init(dependencies: {
	player_tick_rates: { [number]: number },
	buffer_tracker: any,
})
	player_tick_rates = player_tick_rates
	player_tick_rates = dependencies.player_tick_rates
	buffer_tracker = dependencies.buffer_tracker
end

local function get_buffer(id: number): number
	return buffer_tracker.get_buffer(id, 1 / interpolation_config.TICK_RATE)
end

local function on_snapshot_update(snapshot: { [number]: number })
	local now = os.clock()

	for id, current_send_time in snapshot do
		local info = client_clock_info[id]

		if not info then
			print("Ok")
			info = {
				last_clock_at = current_send_time,
				last_clock_duration = now,
				render_at = nil,
			}
			client_clock_info[id] = info
		end

		if current_send_time > info.last_clock_at then
			info.last_clock_at = current_send_time
			info.last_clock_duration = now

			if not info.render_at then
				local delay = get_buffer(id)
				info.render_at = current_send_time - delay
			end
		end
	end
end

local function update(deltaTime: number)
	local now = os.clock()

	for id, info in client_clock_info do
		local delay = get_buffer(id)

		--predict the current server time based on the last known tick and time difference
		--advance the render at by the delta time and calculate error from the dynamic delay
		--snap if the error is too big, fall slightly behind to correct overshoot and speed up to catch uip

		local estimated_server_time = info.last_clock_at + (now - info.last_clock_duration)
		local render_at = (info.render_at or (estimated_server_time - delay)) + deltaTime

		local render_time_error = delay - (estimated_server_time - render_at)

		if math.abs(render_time_error) > 0.1 then
			render_at = estimated_server_time - delay
		elseif render_time_error > 0.001 then
			--print("Reduced", render_time_error)
			render_at = math.max(estimated_server_time - delay, render_at - 0.01 * deltaTime)
		elseif render_time_error < -0.001 then
			--print("Increased", render_time_error)
			render_at = math.min(estimated_server_time - delay, render_at + 0.01 * deltaTime)
		end

		info.render_at = render_at
	end
end

local function get_target_render_time(id: number): number
	local info = client_clock_info[id]
	if not info or not info.render_at then
		warn(`render_cache: No render time for network ID {id}`)
		return 0
	end
	return info.render_at
end

local function get_estimated_server_time(id: number): number
	local info = client_clock_info[id]
	if not info then
		warn(`render_cache: No estimated server time for network ID {id}`)
		return 0
	end
	return info.last_clock_at + (os.clock() - info.last_clock_duration)
end

local function add(id: number)
	if not client_clock_info[id] then
		client_clock_info[id] = {
			last_clock_at = 0,
			last_clock_duration = 0,
			render_at = nil,
		}
	end
end

local function remove(id: number)
	client_clock_info[id] = nil
end

return {
	init = init,
	get_buffer = get_buffer,
	on_snapshot_update = on_snapshot_update,
	update = update,
	get_target_render_time = get_target_render_time,
	get_estimated_server_time = get_estimated_server_time,
	add = add,
	remove = remove,
}
