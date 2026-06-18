local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

return function(props: { participant: jecs.Entity })
	return vide.create("Frame")({
		Name = "Buttons",
		LayoutOrder = 3,
		BackgroundTransparency = 1,
		vide.create("UIPadding")({
			PaddingTop = UDim.new(0, 5),
		}),
		Size = UDim2.new(1, 0, 0, 30),
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
		}),
		vide.create("TextButton")({
			Name = "UnbenchButton",
			BackgroundColor3 = Color3.fromRGB(10, 185, 105),
			Size = UDim2.new(0.5, 0, 1, 0),
			Text = "UB",
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Bold),
			Activated = function()
				print("Unbenched")
				world:remove(props.participant, components.Benched)
			end,
		}),
		vide.create("TextButton")({
			Name = "BenchButton",
			BackgroundColor3 = Color3.fromRGB(225, 5, 40),
			Size = UDim2.new(0.5, 0, 1, 0),
			Text = "B",
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Bold),
			Activated = function()
				print("Benched")
				world:add(props.participant, components.Benched)
			end,
		}),
	})
end
