local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")

local AudioFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.SettingsApp.Tabs.AudioFrame)
local GameplayFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.SettingsApp.Tabs.GameplayFrame)
local PerformanceFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.SettingsApp.Tabs.PerformanceFrame)
local Tab4Frame = require(StarterPlayer.StarterPlayerScripts.Client.UI.SettingsApp.Tabs.Tab4Frame)

local components = require(ReplicatedStorage.Shared.components)
local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)
local vide = require(ReplicatedStorage.Packages.vide)

local tab_gameplay = vide.source(true)
local tab_audio = vide.source(false)
local tab_performance = vide.source(false)
local tab_tab4 = vide.source(false)

local hoverTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local unHoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function TabButton(name: string, on_click: () -> ())
	local hover
	local unhover

	local background_color = vide.source(Color3.fromRGB(50, 50, 50))

	local button = vide.create("TextButton")({
		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 6),
		}),
		Name = name,
		Size = UDim2.new(0.95, 0, 0, 60),
		BackgroundTransparency = 0,
		BackgroundColor3 = background_color,
		TextSize = 30,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
		Text = name,
		Activated = on_click,
		vide.action(function(instance)
			local inProps = { Size = instance.Size + UDim2.new(0.05, 0, 0, 0) }
			local outProps = { Size = instance.Size }
			hover = TweenService:Create(instance, hoverTweenInfo, inProps)
			unhover = TweenService:Create(instance, unHoverTweenInfo, outProps)
		end),
		MouseEnter = function()
			if hover then
				hover:Play()
			end
			background_color(Color3.fromRGB(80, 80, 80))
		end,
		MouseLeave = function()
			if unhover then
				unhover:Play()
			end
			background_color(Color3.fromRGB(50, 50, 50))
		end,
	})

	return button
end

return function()
	local LocalplayerEntity = use_entity_get.useEntityGet(components.LocalPlayer, components.LocalPlayer)

	return vide.create("Frame")({
		Name = "SettingsFrame",
		Size = UDim2.new(0.5, 0, 0.7, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		BackgroundTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ClipsDescendants = true,
		vide.create("UIStroke")({
			Thickness = 2,
			Color = Color3.fromRGB(180, 180, 180),
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		}),
		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 4),
		}),
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			ItemLineAlignment = Enum.ItemLineAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 0),
		}),

		vide.create("Frame")({
			Size = UDim2.new(1, 0, 0.10, 0),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			BackgroundTransparency = 0,
			vide.create("UIStroke")({
				Thickness = 2,
				Color = Color3.fromRGB(180, 180, 180),
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			}),
			vide.create("TextLabel")({
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.new("rbxasset://fonts/families/TitilliumWeb.json", Enum.FontWeight.Bold),
				Text = "SETTINGS",
			}),
		}),

		vide.create("Frame")({
			Size = UDim2.new(1, 0, 0.9, 0),
			BackgroundTransparency = 1,
			vide.create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				HorizontalFlex = Enum.UIFlexAlignment.SpaceAround,
			}),

			vide.create("UIPadding")({
				PaddingTop = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 20),
			}),

			vide.create("Frame")({
				Size = UDim2.new(0.3, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BackgroundTransparency = 0,
				vide.create("UIPadding")({
					PaddingTop = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
				}),
				vide.create("UIListLayout")({
					FillDirection = Enum.FillDirection.Vertical,
					ItemLineAlignment = Enum.ItemLineAlignment.Center,
					HorizontalFlex = Enum.UIFlexAlignment.SpaceAround,
					Padding = UDim.new(0, 10),
				}),
				TabButton("Gameplay", function()
					tab_gameplay(true)
					tab_audio(false)
					tab_performance(false)
					tab_tab4(false)
				end),
				TabButton("Audio", function()
					tab_gameplay(false)
					tab_audio(true)
					tab_performance(false)
					tab_tab4(false)
				end),
				TabButton("Performance", function()
					tab_gameplay(false)
					tab_audio(false)
					tab_performance(true)
					tab_tab4(false)
				end),
				TabButton("Tab4", function()
					tab_gameplay(false)
					tab_audio(false)
					tab_performance(false)
					tab_tab4(true)
				end),
			}),

			vide.show(tab_gameplay, function()
				return GameplayFrame({ localplayer = LocalplayerEntity })
			end),

			vide.show(tab_audio, function()
				return AudioFrame({ localplayer = LocalplayerEntity })
			end),

			vide.show(tab_performance, function()
				return PerformanceFrame({ localplayer = LocalplayerEntity })
			end),

			vide.show(tab_tab4, function()
				return Tab4Frame({ localplayer = LocalplayerEntity })
			end),
		}),
	})
end
