--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck = require(ReplicatedStorage.Packages.planck)
local Scheduler = planck.Scheduler

local world = require(ReplicatedStorage.Shared.world)

local planck_jabby = require(ReplicatedStorage.Packages["planck-jabby"])
local jabbyPlugin = planck_jabby.new()

local planck_run_service = require(ReplicatedStorage.Packages["planck-runservice"])
local runServicePlugin = planck_run_service.Plugin.new()

-- stylua: ignore
local scheduler = Scheduler.new(world)
    :addPlugin(jabbyPlugin)
    :addPlugin(runServicePlugin)

return scheduler
