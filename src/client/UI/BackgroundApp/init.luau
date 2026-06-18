local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

local LobbyButton = require(script.LobbyButton)

return function()
	return vide.create("ScreenGui")({
		Name = "App",
		LobbyButton(),
	})
end
