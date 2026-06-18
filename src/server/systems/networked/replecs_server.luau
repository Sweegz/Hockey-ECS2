local ReplicatedStorage = game:GetService("ReplicatedStorage")

local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local replicator = require(ReplicatedStorage.Shared.replicator)

local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send") :: RemoteEvent
local UnreliableRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Unreliable") :: RemoteEvent

local function replecs_server()
	for player, buf, variants in replicator.server:collect_updates() do
		SendRemote:FireClient(player, buf, variants)
	end

	for player, buf, variants in replicator.server:collect_unreliable() do
		UnreliableRemote:FireClient(player, buf, variants)
	end
end

return {
	system = replecs_server,
	phase = planck_runservice.Phases.Update,
	runConditions = {
		planck.timePassed(1 / 60),
	},
}
