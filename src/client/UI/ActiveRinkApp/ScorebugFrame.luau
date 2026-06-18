local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)
local use_target = require(ReplicatedStorage.Shared.addons.use_target)

use_entity_get.world = world
use_target.world = world

local function format_to_minutes_and_seconds(s: number)
	return string.format("%02i:%02i", s / 60, s % 60)
end

return function(props: { rink: () -> jecs.Entity<any>? })
	local SizeX, SizeY = 352, 71

	local GameTime: () -> number? = use_entity_get.useEntityGet(props.rink(), components.GameTime)
	local GamePeriod: () -> number? = use_entity_get.useEntityGet(props.rink(), components.GamePeriod)

	local HomeTeam = use_target.useTarget(props.rink(), components.HomeTeamLink)
	local AwayTeam = use_target.useTarget(props.rink(), components.AwayTeamLink)

	local HomeScore: () -> number? = use_entity_get.useEntityGet(HomeTeam(), components.Score)
	local AwayScore: () -> number? = use_entity_get.useEntityGet(AwayTeam(), components.Score)

	local HomeAbbreviation: () -> number? = use_entity_get.useEntityGet(HomeTeam(), components.Abbreviation)
	local AwayAbbreviation: () -> number? = use_entity_get.useEntityGet(AwayTeam(), components.Abbreviation)

	return vide.create("Frame")({
		Name = "Scorebug",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, SizeX, 0, SizeY),
		Position = UDim2.new(0.5, 0, 0.01, 0),
		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 5),
		}),
		vide.create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
		}),
		vide.create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 71, 1, 0),
			vide.create("ImageLabel")({
				BackgroundTransparency = 1,
				Image = "rbxassetid://97931996591237",
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(0.7, 0, 0.7, 0),
				Position = UDim2.new(0, 10, 0, 4),
			}),
		}),
		vide.create("Frame")({
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.new(0, 71, 1, 0),
			Name = "TimePeriodFrame",
			vide.create("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
			vide.create("Frame")({
				BackgroundColor3 = Color3.fromRGB(205, 205, 205),
				Size = UDim2.new(0.6, 0, 0, 2),
				LayoutOrder = 1,
			}),
			vide.create("TextLabel")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.5, -1),
				Text = function()
					local game_period = GamePeriod()
					if game_period then
						return tostring(game_period)
					end

					return ""
				end,
				TextSize = 24,
				FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
				LayoutOrder = 2,
				TextColor3 = Color3.fromRGB(29, 49, 60),
			}),
			vide.create("TextLabel")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.5, -1),
				Text = function()
					local game_time = GameTime()
					if game_time then
						return format_to_minutes_and_seconds(game_time)
					end

					return ""
				end,
				TextSize = 24,
				FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
				LayoutOrder = 0,
				TextColor3 = Color3.fromRGB(29, 49, 60),
			}),
		}),
		vide.create("Frame")({
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			BackgroundColor3 = Color3.fromRGB(0, 255, 255),
			Size = UDim2.new(0, 210, 1, 0),
			vide.create("UIListLayout")({}),
			vide.create("Frame")({
				Size = UDim2.new(1, 0, 0.68, 0),
				LayoutOrder = 0,
				vide.create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				vide.create("Frame")({
					Size = UDim2.new(0.5, 0, 1, 0),
					LayoutOrder = 0,
					BackgroundColor3 = Color3.fromRGB(161, 37, 47),
					vide.create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 10),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					vide.create("TextLabel")({
						Size = UDim2.new(0.6, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = function()
							local abr = AwayAbbreviation()
							if abr then
								return tostring(abr)
							end

							return "AWAY"
						end,
						TextSize = 24,
						FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					}),
					vide.create("TextLabel")({
						Size = UDim2.new(0.2, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = function()
							local score = AwayScore()
							if score then
								return tostring(score)
							end

							return "-"
						end,
						TextSize = 32,
						FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					}),
				}),

				vide.create("Frame")({
					Size = UDim2.new(0.5, 0, 1, 0),
					LayoutOrder = 0,
					BackgroundColor3 = Color3.fromRGB(11, 32, 87),
					vide.create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 10),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					vide.create("TextLabel")({
						Size = UDim2.new(0.6, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = function()
							local abr = HomeAbbreviation()
							if abr then
								return tostring(abr)
							end

							return "HOME"
						end,
						TextSize = 24,
						FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					}),
					vide.create("TextLabel")({
						Size = UDim2.new(0.2, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = function()
							local score = HomeScore()
							if score then
								return tostring(score)
							end

							return "-"
						end,
						TextSize = 32,
						FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					}),
				}),
			}),
			vide.create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.32, 0),
				LayoutOrder = 1,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				vide.create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				vide.create("TextLabel")({
					LayoutOrder = 0,
					BackgroundTransparency = 1,
					Text = "0",
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					Size = UDim2.new(0.25, 0, 1, 0),
					TextColor3 = Color3.fromRGB(29, 49, 60),
				}),
				vide.create("TextLabel")({
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Text = "Shots",
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					Size = UDim2.new(0.25, 0, 1, 0),
					TextColor3 = Color3.fromRGB(29, 49, 60),
				}),
				vide.create("TextLabel")({
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Text = "0",
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold),
					Size = UDim2.new(0.25, 0, 1, 0),
					TextColor3 = Color3.fromRGB(29, 49, 60),
				}),
			}),
		}),
	})
end
