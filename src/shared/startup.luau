--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Require before world
require(ReplicatedStorage.Packages.replecs)

local jabby = require(ReplicatedStorage.Packages.jabby)

local get_entity_from_part = require(ReplicatedStorage.Shared.utility.get_entity_from_part)
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

-- Required after world, before startup.
require(ReplicatedStorage.Shared.components)
require(ReplicatedStorage.Shared.listeners.hooks)
require(ReplicatedStorage.Shared.listeners.observers)

return function(systems)
	print("Starting systems")
	if #systems ~= 0 then
		scheduler:addSystems(systems)
	end

	if RunService:IsStudio() then
		jabby.set_check_function(function(player)
			return true
		end)
	else
		jabby.set_check_function(function(player)
			if player.UserId == 9434639638 or player.UserId == 40818285 then
				return true
			end
			return false
		end)
	end

	if RunService:IsClient() then
		local client = jabby.obtain_client()

		local function create_widget(_, state: Enum.UserInputState)
			if state ~= Enum.UserInputState.Begin then
				return
			end
			client.spawn_app(client.apps.home, nil)
		end

		game:GetService("ContextActionService"):BindAction("Open Jabby Home", create_widget, false, Enum.KeyCode.F4)
	end

	jabby.register({
		applet = jabby.applets.world,
		name = "world",
		configuration = {
			world = world,
			get_entity_from_part = get_entity_from_part,
		},
	})
end
