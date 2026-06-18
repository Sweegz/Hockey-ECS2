local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local usePx = require(ReplicatedStorage.Shared.addons.usePx)
local vide = require(ReplicatedStorage.Packages.vide)

vide.strict = false

local ActiveRinkApp = require(script.ActiveRinkApp)
local BackgroundApp = require(script.BackgroundApp)
local SettingsApp = require(script.SettingsApp)

local settings_open = vide.source(false)
local hit_tracker_open = vide.source(false)

UserInputService.InputBegan:Connect(function(input: InputObject, game_processed: boolean)
	if game_processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.M then
		settings_open(not settings_open())
		hit_tracker_open(false)
	end

	if input.KeyCode == Enum.KeyCode.H then
		hit_tracker_open(not hit_tracker_open())
		settings_open(false)
	end
end)

vide.mount(function()
	usePx()
	BackgroundApp().Parent = Players.LocalPlayer.PlayerGui
	ActiveRinkApp({ hit_tracker_open = hit_tracker_open }).Parent = Players.LocalPlayer.PlayerGui
	SettingsApp({ open = settings_open }).Parent = Players.LocalPlayer.PlayerGui
end)

return {}
