local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local collision_queue = require(ReplicatedStorage.Shared.tables.collision_queue)

local query_puck_collisions = world
	:query(components.BasePart, components.Touched)
	:with(components.Puck)
	:without(components.OutOfBounds, jecs.pair(components.Owner, jecs.Wildcard))
	:cached()

local BOARD_SOUNDS = SoundService:FindFirstChild("Boards")
local POST_SOUNDS = SoundService:FindFirstChild("Posts")

local SoundEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sound") :: RemoteEvent

local function send_puck_sounds()
	for entity, basepart, connection in query_puck_collisions:iter() do
		local collisions = collision_queue[entity]
		if not collisions then
			continue
		end

		for _, hit: any in collisions do
			--print(hit)
			if basepart.AssemblyLinearVelocity.Magnitude > 5 then
				if hit.Name == "Glass" or hit.Name == "Wall" then
					local data: T.SoundEvent = {
						part = hit,
						sound_path = BOARD_SOUNDS,
						volume = 1,
						length = 0.2,
					}

					SoundEvent:FireAllClients(data)
				elseif hit.Name == "Post" then
					local data: T.SoundEvent = {
						part = hit,
						sound_path = POST_SOUNDS,
						volume = 1,
						length = 0.2,
					}

					SoundEvent:FireAllClients(data)
				end
			end
		end
	end
end

return {
	system = send_puck_sounds,
	phase = planck_runservice.Phases.PostSimulation,
}
