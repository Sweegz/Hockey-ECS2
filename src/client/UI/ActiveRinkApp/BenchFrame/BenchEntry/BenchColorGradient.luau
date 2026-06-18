local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { benched: () -> boolean })
	return vide.create("UIGradient")({
		Color = function()
			if props.benched() then
				return ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 73)),
					ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 40, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
				})
			end

			return ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 126, 73)),
				ColorSequenceKeypoint.new(0.35, Color3.fromRGB(6, 100, 58)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
			})
		end,
	})
end
