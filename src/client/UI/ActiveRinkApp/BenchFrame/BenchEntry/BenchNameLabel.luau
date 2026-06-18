local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { player: () -> Player? })
	return vide.create("TextLabel")({
		Name = "NameLabel",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Text = function()
			local temp = props.player()
			if temp then
				return temp.Name
			end
			return "None"
		end,
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeTransparency = 0,
		FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
	})
end
