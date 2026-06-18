local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local components = require(ReplicatedStorage.Shared.components)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local world = require(ReplicatedStorage.Shared.world)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local function get_valid_mouse_hit(): Vector3
	return mouse.Hit.Position
	--[[local cam = Workspace.CurrentCamera
	local origin = cam.CFrame.Position
	local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)

	local excluded = {}
	table.insert(excluded, CollectionService:GetTagged("Bounds"))
	table.insert(excluded, CollectionService:GetTagged("NetZone"))

	local character = player.Character
	if character then
		for _, child in character:GetDescendants() do
			if child:IsA("BasePart") then
				table.insert(excluded, child)
			end
		end
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excluded
	params.IgnoreWater = true

	local result = Workspace:Raycast(origin, ray.Direction * 5000, params)

	return result and result.Position or (origin + ray.Direction * 5000)--]]
end

return get_valid_mouse_hit
