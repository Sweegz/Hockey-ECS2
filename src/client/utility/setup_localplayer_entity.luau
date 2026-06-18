local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local localplayer_entity = world:entity()
local localplayer = Players.LocalPlayer
world:set(localplayer_entity, components.Player, localplayer)
world:set(components.LocalPlayer, components.LocalPlayer, localplayer_entity)

local config: T.PlayerConfig = {
	shiftlock = false,
}

world:set(localplayer_entity, components.PlayerConfig, config)
world:set(localplayer_entity, components.ShiftSprint, true)
refs[localplayer] = localplayer_entity
print("LocalPlayer", localplayer, localplayer_entity)

return {}
