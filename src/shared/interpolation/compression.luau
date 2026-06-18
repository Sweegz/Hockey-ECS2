local compression = {}

local U16_MAX = 65535
local INV_U16_MAX = 1 / U16_MAX
local SQRT = math.sqrt
local ABS = math.abs

local function clamp(x, min, max)
	if x < min then
		return min
	end
	if x > max then
		return max
	end
	return x
end

local function map_to_u16(v)
	local mapped = (v * 0.5 + 0.5) * U16_MAX
	return math.floor(clamp(mapped, 0, U16_MAX) + 0.5)
end

local function map_from_u16(v)
	return (v * INV_U16_MAX) * 2 - 1
end

local function matrix_to_quaternion(m00, m01, m02, m10, m11, m12, m20, m21, m22)
	local trace = m00 + m11 + m22
	local x, y, z, w

	if trace > 0 then
		local s = SQRT(trace + 1) * 2
		w = 0.25 * s
		x = (m21 - m12) / s
		y = (m02 - m20) / s
		z = (m10 - m01) / s
	elseif m00 > m11 and m00 > m22 then
		local s = SQRT(1 + m00 - m11 - m22) * 2
		w = (m21 - m12) / s
		x = 0.25 * s
		y = (m01 + m10) / s
		z = (m02 + m20) / s
	elseif m11 > m22 then
		local s = SQRT(1 + m11 - m00 - m22) * 2
		w = (m02 - m20) / s
		x = (m01 + m10) / s
		y = 0.25 * s
		z = (m12 + m21) / s
	else
		local s = SQRT(1 + m22 - m00 - m11) * 2
		w = (m10 - m01) / s
		x = (m02 + m20) / s
		y = (m12 + m21) / s
		z = 0.25 * s
	end

	return x, y, z, w
end

local function quaternion_to_matrix(x, y, z, w)
	local xx = x * x
	local yy = y * y
	local zz = z * z
	local xy = x * y
	local xz = x * z
	local yz = y * z
	local wx = w * x
	local wy = w * y
	local wz = w * z

	return 1 - 2 * (yy + zz),
		2 * (xy - wz),
		2 * (xz + wy),
		2 * (xy + wz),
		1 - 2 * (xx + zz),
		2 * (yz - wx),
		2 * (xz - wy),
		2 * (yz + wx),
		1 - 2 * (xx + yy)
end

local function encode_rotation(cframe)
	local px, py, pz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cframe:GetComponents()

	local x, y, z, w = matrix_to_quaternion(m00, m01, m02, m10, m11, m12, m20, m21, m22)

	local mag = SQRT(x * x + y * y + z * z + w * w)
	x /= mag
	y /= mag
	z /= mag
	w /= mag

	local ax, ay, az, aw = ABS(x), ABS(y), ABS(z), ABS(w)
	local index = 0
	local largest = ax
	if ay > largest then
		index = 1
		largest = ay
	end
	if az > largest then
		index = 2
		largest = az
	end
	if aw > largest then
		index = 3
	end

	if (index == 0 and x < 0) or (index == 1 and y < 0) or (index == 2 and z < 0) or (index == 3 and w < 0) then
		x = -x
		y = -y
		z = -z
		w = -w
	end

	local a, b, c
	if index == 0 then
		a, b, c = y, z, w
	elseif index == 1 then
		a, b, c = x, z, w
	elseif index == 2 then
		a, b, c = x, y, w
	else
		a, b, c = x, y, z
	end

	return px, py, pz, map_to_u16(a), map_to_u16(b), map_to_u16(c), index
end

local function decode_rotation(px, py, pz, ua, ub, uc, index)
	local a = map_from_u16(ua)
	local b = map_from_u16(ub)
	local c = map_from_u16(uc)

	local x, y, z, w
	local missing = SQRT(clamp(1 - (a * a + b * b + c * c), 0, 1))

	if index == 0 then
		x = missing
		y, z, w = a, b, c
	elseif index == 1 then
		y = missing
		x, z, w = a, b, c
	elseif index == 2 then
		z = missing
		x, y, w = a, b, c
	else
		w = missing
		x, y, z = a, b, c
	end

	local m00, m01, m02, m10, m11, m12, m20, m21, m22 = quaternion_to_matrix(x, y, z, w)

	return CFrame.new(px, py, pz, m00, m01, m02, m10, m11, m12, m20, m21, m22)
end

function compression.pack_snapshot_data(bufferObj, offset, timestamp, cframe, id)
	buffer.writef32(bufferObj, offset + 0, timestamp)

	local px, py, pz, ua, ub, uc, index = encode_rotation(cframe)

	buffer.writef32(bufferObj, offset + 4, px)
	buffer.writef32(bufferObj, offset + 8, py)
	buffer.writef32(bufferObj, offset + 12, pz)
	buffer.writeu16(bufferObj, offset + 16, ua)
	buffer.writeu16(bufferObj, offset + 18, ub)
	buffer.writeu16(bufferObj, offset + 20, uc)

	local packedId = bit32.bor(id, bit32.lshift(index, 30))
	buffer.writeu32(bufferObj, offset + 22, packedId)
end

function compression.unpack_snapshot_data(bufferObj, offset)
	local value = {}
	value.timestamp = buffer.readf32(bufferObj, offset + 0)

	local px = buffer.readf32(bufferObj, offset + 4)
	local py = buffer.readf32(bufferObj, offset + 8)
	local pz = buffer.readf32(bufferObj, offset + 12)

	local ua = buffer.readu16(bufferObj, offset + 16)
	local ub = buffer.readu16(bufferObj, offset + 18)
	local uc = buffer.readu16(bufferObj, offset + 20)

	local packedId = buffer.readu32(bufferObj, offset + 22)
	local index = bit32.rshift(packedId, 30)
	local id = bit32.band(packedId, 0x3FFFFFFF)

	value.cframe = decode_rotation(px, py, pz, ua, ub, uc, index)
	value.id = id
	return value
end

function compression.pack_snapshot_data_for_sender(bufferObj, timestamp, cframe)
	compression.pack_snapshot_data(bufferObj, 0, timestamp, cframe, 0)
end

function compression.unpack_snapshot_data_for_sender(bufferObj)
	local data = compression.unpack_snapshot_data(bufferObj, 0)
	return data.timestamp, data.cframe
end

return compression
