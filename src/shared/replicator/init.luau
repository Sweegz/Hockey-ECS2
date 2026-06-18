local ReplicatedStorage = game:GetService("ReplicatedStorage")

local replecs = require(ReplicatedStorage.Packages.replecs)
local world = require(ReplicatedStorage.Shared.world)

return replecs.create(world)
