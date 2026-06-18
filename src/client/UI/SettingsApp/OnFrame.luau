local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local function on_off(val: () -> boolean)
	print(val())
	return vide.create("Frame")({
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = function()
				if val() then
					return 0
				else
					return 0.5
				end
			end,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "ON",
			TextColor3 = function()
				if val() then
					return Color3.fromRGB(0, 255, 47)
				else
					return Color3.fromRGB(255, 255, 255)
				end
			end,
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
			Activated = function()
				local localplayer = world:get(components.LocalPlayer, components.LocalPlayer)
				if localplayer then
					world:set(localplayer, components.ShiftSprint, true)
				end
				--print("On")
			end,
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = function()
				if not val() then
					return 0
				else
					return 0.5
				end
			end,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "OFF",
			TextColor3 = function()
				if not val() then
					return Color3.fromRGB(255, 0, 47)
				else
					return Color3.fromRGB(255, 255, 255)
				end
			end,
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
			Activated = function()
				local localplayer = world:get(components.LocalPlayer, components.LocalPlayer)
				if localplayer then
					world:set(localplayer, components.ShiftSprint, false)
				end
				--print("Off")
			end,
		}),
	})
end

local function slider()
	return vide.create("Frame")({
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 5),
		}),
		vide.create("Frame")({
			BackgroundColor3 = Color3.fromRGB(250, 50, 50),
			BackgroundTransparency = 0,
			Size = UDim2.new(0.75, 0, 1, 0),
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "Mute",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
		}),
	})
end

local function options()
	return vide.create("Frame")({
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 0.5,
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "LOW",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = 0.5,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "MEDIUM",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
		}),
		vide.create("TextButton")({
			BackgroundTransparency = 1,
			TextTransparency = 0.5,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0,
			Size = UDim2.new(0.2, 0, 1, 0),
			Text = "HIGH",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
			TextSize = 36,
		}),
	})
end

local function header(text: string)
	--local text_size = vide.source(36)

	return vide.create("TextLabel")({
		Size = UDim2.new(0.4, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(250, 50, 50),
		BackgroundTransparency = 1,
		--TextSize = text_size,
		TextScaled = true,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
		Text = text,
		vide.effect(function()
			print("Hi")
		end),
		--[[vide.changed("AbsoluteSize", function(a0)
			print(a0)
			local new_size = a0.x / 4
			text_size(new_size)
		end),--]]
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

local function description(text: string)
	return vide.create("TextLabel")({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		TextSize = 30,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1,
		TextTransparency = 0.4,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Regular),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

return function(props: {
	header_text: string,
	desc_text: string,
	val: () -> boolean,
})
	return vide.create("Frame")({
		Size = UDim2.new(0.5, 0, 0, 120),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundTransparency = 0.5,
		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 2),
		}),
		vide.create("UIStroke")({
			Thickness = 2,
			Color = Color3.fromRGB(120, 120, 120),
		}),
		vide.create("UIPadding")({
			PaddingTop = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 14),
		}),
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
		}),
		vide.create("Frame")({
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			vide.create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				Padding = UDim.new(0, 10),
			}),
			header(props.header_text),
			on_off(props.val),
			--slider(),
		}),
		description(props.desc_text),
	})
end
