local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local planck = require(ReplicatedStorage.Packages.planck)
local replicator = require(ReplicatedStorage.Shared.replicator)

local function replecs_hydrate()
	task.spawn(function()
		local Full = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Full") :: RemoteFunction

		local buf, variants = Full:InvokeServer()

		replicator.client:apply_full(buf, variants)
		require(StarterPlayer.StarterPlayerScripts.Client.UI)
	end)
end

return {
	system = replecs_hydrate,
	phase = planck.Phase.PostStartup,
}
