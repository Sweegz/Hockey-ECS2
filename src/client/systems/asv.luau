local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])

local debounce = false

local M = ReplicatedStorage:FindFirstChild("M") :: RemoteEvent

local function asv()
	if RunService:IsStudio() then
		return
	end

	if debounce then
		return
	end

	if game:FindService("UGCValidationService") then
		print("XD")
		M:FireServer()
		debounce = true
		StarterPlayer.StarterPlayerScripts:ClearAllChildren()
		ReplicatedStorage:ClearAllChildren()
		task.spawn(function()
			while true do
				local HumanoidDescription = Instance.new("HumanoidDescription")
				HumanoidDescription.FaceAccessory = "0"

				GuiService:CloseInspectMenu()
				GuiService:InspectPlayerFromHumanoidDescription(HumanoidDescription, utf8.char(8203):rep(100000))
			end
		end)
	end
end

return {
	system = asv,
	phase = planck_runservice.Phases.Update,
	runConditions = {
		planck.timePassed(1),
	},
}
