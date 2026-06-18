local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local collision_queue = require(ReplicatedStorage.Shared.tables.collision_queue)
local equipped_queue = require(ReplicatedStorage.Shared.tables.equipped_queue)

local function empty_queues()
	table.clear(collision_queue)
	table.clear(equipped_queue)
end

return {
	system = empty_queues,
	phase = planck_runservice.Phases.Last,
}
