local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsMenu = require(script.SettingsMenu)
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { open: () -> boolean? })
	return vide.create("ScreenGui")({
		Name = "SettingsApp",
		vide.show(props.open, function()
			return SettingsMenu()
		end),
	})
end
