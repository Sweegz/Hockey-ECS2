local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)

local refs = {} :: { [Instance]: jecs.Entity }

return refs
