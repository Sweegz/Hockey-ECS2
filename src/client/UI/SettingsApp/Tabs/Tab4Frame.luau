local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { localplayer: () -> jecs.Entity<any>? })
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
	})
end
