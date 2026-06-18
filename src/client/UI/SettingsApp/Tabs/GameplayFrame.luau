local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local OnFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.SettingsApp.OnFrame)
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { localplayer: () -> jecs.Entity<any>? })
	local shift_sprint = use_entity_get.useEntityGet(props.localplayer, components.ShiftSprint)

	return vide.create("ScrollingFrame")({
		Size = UDim2.new(0.7, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0,
		vide.create("UIPadding")({
			PaddingTop = UDim.new(0, 30),
			PaddingRight = UDim.new(0, 30),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 30),
		}),
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 20),
		}),

		OnFrame({
			header_text = "Shift Sprint",
			desc_text = "Sprint with SHIFT. CTRL to mouse-lock.",
			val = shift_sprint,
		}),
	})
end
