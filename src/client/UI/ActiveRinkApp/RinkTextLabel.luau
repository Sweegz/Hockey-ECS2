local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)

return function(props: { rink: () -> jecs.Entity<any>?, participant: () -> jecs.Entity<any>? })
	local SizeX, SizeY = 300, 100
	local MarginX, MarginY = 10, 30
	return vide.create("TextLabel")({
		Name = "RinkTextLabel",
		Text = function()
			return "Rink:"
				.. tostring((props.rink() or "-"))
				.. " Participant:"
				.. tostring((props.participant() or "-"))
		end,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Size = UDim2.new(0, SizeX, 0, SizeY),
		Position = UDim2.new(0, MarginX, 1, -(SizeY + MarginY)),
		Transparency = 0.2,
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Regular),
	})
end
