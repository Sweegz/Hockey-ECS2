local compression = {}

export type NetworkableCFrame = {
	Position: Vector3,
	Rotation: { x: number, y: number, z: number },
}

local function decode_cframe(data: NetworkableCFrame): CFrame
	local position = data.Position
	local rotation = data.Rotation

	local x = rotation.x
	local y = rotation.y
	local z = rotation.z
	local w_sign = rotation.w_sign or 1

	local sum = x * x + y * y + z * z
	local w_squared = 1 - sum

	local w = 0
	if w_squared > 0 then
		w = math.sqrt(w_squared)
	end

	w = w * w_sign

	return CFrame.new(position.X, position.Y, position.Z, x, y, z, w)
end

local function encode_cframe(cframe: CFrame): NetworkableCFrame
	local position = cframe.Position

	local axis, angle = cframe:ToAxisAngle()

	local half = angle * 0.5
	local sin_half = math.sin(half)

	local x = axis.X * sin_half
	local y = axis.Y * sin_half
	local z = axis.Z * sin_half
	local w = math.cos(half)

	local w_sign = 1
	if w < 0 then
		w_sign = -1
	end

	return {
		Position = position,
		Rotation = {
			x = x,
			y = y,
			z = z,
			w_sign = w_sign,
		},
	}
end

function compression.pack_snapshot_data(
	snapshot_buffer: buffer,
	offset: number,
	timestamp: number,
	cframe: CFrame,
	id: number
)
	buffer.writef32(snapshot_buffer, offset + 0, timestamp)
	buffer.writef32(snapshot_buffer, offset + 4, cframe.Position.X)
	buffer.writef32(snapshot_buffer, offset + 8, cframe.Position.Y)
	buffer.writef32(snapshot_buffer, offset + 12, cframe.Position.Z)

	local networkable = encode_cframe(cframe)

	buffer.writef32(snapshot_buffer, offset + 16, networkable.Rotation.x)
	buffer.writef32(snapshot_buffer, offset + 20, networkable.Rotation.y)
	buffer.writef32(snapshot_buffer, offset + 24, networkable.Rotation.z)
	buffer.writei32(snapshot_buffer, offset + 28, id)
end

function compression.unpack_snapshot_data(snapshot_buffer: buffer, offset: number): any
	local value = {}
	value.timestamp = buffer.readf32(snapshot_buffer, offset + 0)

	local x = buffer.readf32(snapshot_buffer, offset + 4)
	local y = buffer.readf32(snapshot_buffer, offset + 8)
	local z = buffer.readf32(snapshot_buffer, offset + 12)

	local rx = buffer.readf32(snapshot_buffer, offset + 16)
	local ry = buffer.readf32(snapshot_buffer, offset + 20)
	local rz = buffer.readf32(snapshot_buffer, offset + 24)

	value.cframe = decode_cframe({
		Position = vector.create(x, y, z) :: any,
		Rotation = { x = rx, y = ry, z = rz },
	})
	value.id = buffer.readi32(snapshot_buffer, offset + 28)

	return value
end

function compression.pack_snapshot_data_for_sender(snapshot_buffer: buffer, timestamp: number, cframe: CFrame)
	local offset = 0

	buffer.writef32(snapshot_buffer, offset + 0, timestamp)

	buffer.writef32(snapshot_buffer, offset + 4, cframe.Position.X)
	buffer.writef32(snapshot_buffer, offset + 8, cframe.Position.Y)
	buffer.writef32(snapshot_buffer, offset + 12, cframe.Position.Z)

	local networkable = encode_cframe(cframe)

	buffer.writef32(snapshot_buffer, offset + 16, networkable.Rotation.x)
	buffer.writef32(snapshot_buffer, offset + 20, networkable.Rotation.y)
	buffer.writef32(snapshot_buffer, offset + 24, networkable.Rotation.z)
end

function compression.unpack_snapshot_data_for_sender(snapshot_buffer: buffer)
	local offset = 0
	local timestamp = buffer.readf32(snapshot_buffer, offset + 0)
	local x = buffer.readf32(snapshot_buffer, offset + 4)
	local y = buffer.readf32(snapshot_buffer, offset + 8)
	local z = buffer.readf32(snapshot_buffer, offset + 12)

	local rx = buffer.readf32(snapshot_buffer, offset + 16)
	local ry = buffer.readf32(snapshot_buffer, offset + 20)
	local rz = buffer.readf32(snapshot_buffer, offset + 24)

	local cframe = decode_cframe({
		Position = vector.create(x, y, z) :: any,
		Rotation = { x = rx, y = ry, z = rz },
	})

	return timestamp, cframe
end

return compression
