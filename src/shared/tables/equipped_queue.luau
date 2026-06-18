local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local equipped_queue = {} :: { [jecs.Entity]: Instance }

return equipped_queue
