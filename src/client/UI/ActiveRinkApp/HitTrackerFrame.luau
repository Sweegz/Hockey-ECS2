local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)
local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)

use_entity_get.world = world

local function HitEntry(props: {
	Data: () -> T.HitTrackerInfo,
})
	return vide.create("TextLabel")({
		Size = UDim2.new(0.95, 0, 1 / 16, 0),
		BackgroundTransparency = 1,
		TextSize = 26,
		TextWrapped = false,
		TextColor3 = function()
			if props.Data().penalty then
				return Color3.fromRGB(233, 0, 0)
			end
			return Color3.fromRGB(255, 255, 255)
		end,
		FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Regular),
		Text = function()
			local msg = props.Data().player1_name
				.. " hit "
				.. props.Data().player2_name
				.. " with "
				.. math.round(props.Data().power)
				.. "%."
				.. " Hit distance: "
				.. props.Data().hit_distance
				.. " studs."
				.. " Puck distance: "
				.. props.Data().distance_from_puck
				.. " studs."

			return msg
		end,
		LayoutOrder = 3,
	})
end

return function(props: { rink: () -> jecs.Entity<any>? })
	local HitLogs: () -> number? = use_entity_get.useEntityGet(props.rink, components.HitLogs)

	return vide.create("Frame")({
		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 4),
		}),
		Size = UDim2.new(0.5, 0, 0.8, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.6,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ClipsDescendants = true,
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			ItemLineAlignment = Enum.ItemLineAlignment.Center,
			Padding = UDim.new(0, 0),
		}),

		vide.create("Frame")({
			Size = UDim2.new(1, 0, 0.07, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.6,
			vide.create("TextLabel")({
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Regular),
				Text = "Hit Tracker",
			}),
		}),

		vide.indexes(HitLogs, function(data, i)
			return HitEntry({
				Data = data,
			})
		end),
	})
end
