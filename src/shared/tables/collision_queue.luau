local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local collision_queue = {} :: { [jecs.Entity]: { BasePart } }

return collision_queue
