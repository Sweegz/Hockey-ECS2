local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vide = require(ReplicatedStorage.Packages.vide)

return function()
	local SizeX, SizeY = 180, 50
	local MarginX, MarginY = 10, 30
	return vide.create("TextButton")({
		Name = "LobbyButton",
		Text = "Lobby",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Size = UDim2.new(0, SizeX, 0, SizeY),
		Position = UDim2.new(1, -(SizeX + MarginX), 1, -(SizeY + MarginY)),
		Transparency = 0.2,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Activated = function()
			print("Clicked")
		end,
		FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Regular),
	})
end
