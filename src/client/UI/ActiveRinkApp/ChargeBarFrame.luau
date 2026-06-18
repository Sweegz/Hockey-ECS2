local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

return function()
	return vide.create("Frame")({
		Size = UDim2.new(0, 50, 0, 200),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
end
