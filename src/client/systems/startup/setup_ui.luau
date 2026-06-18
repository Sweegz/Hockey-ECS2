local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck = require(ReplicatedStorage.Packages.planck)

local function setup_ui()
	--require(StarterPlayer.StarterPlayerScripts.Client.UI)
end

return {
	system = setup_ui,
	phase = planck.Phase.PostStartup,
}
