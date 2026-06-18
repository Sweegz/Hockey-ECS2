local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)

use_entity_get.world = world

return function(props: { participant: () -> jecs.Entity<any>? })
	local SizeX, SizeY = 400, 55
	local MarginX, MarginY = 10, 100

	local StaminaComponent: () -> number? = use_entity_get.useEntityGet(props.participant, components.Stamina)

	return vide.create("Frame")({
		Name = "StaminaBar",
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Size = UDim2.new(0, SizeX, 0, SizeY),
		Position = UDim2.new(1, -(SizeX + MarginX), 1, -(SizeY + MarginY)),
		vide.create("UIStroke")({
			Thickness = 1.25,
		}),
		vide.create("Frame")({
			Name = "PercentageDisplayFrame",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = function()
				return UDim2.new((StaminaComponent() or 100) / 100, 0, 1, 0)
			end,
			vide.create("UIGradient")({
				Color = function()
					return ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 95, 156)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 139, 255)),
					})
				end,
				Rotation = -90,
			}),
		}),
	})
end
