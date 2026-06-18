local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { stamina: () -> number? })
	return vide.create("Frame")({
		Name = "Stamina",
		Size = UDim2.new(1, 0, 0, 5),
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		vide.create("Frame")({
			Name = "Bar",
			Size = function()
				return UDim2.new((props.stamina() or 100) / 100, 0, 1, 0)
			end,
			BackgroundColor3 = Color3.fromRGB(5, 215, 255),
		}),
	})
end
