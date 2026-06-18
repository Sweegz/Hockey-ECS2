local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local replicator = require(ReplicatedStorage.Shared.replicator)

local collect = require(ReplicatedStorage.Shared.addons.collect)

local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send") :: RemoteEvent
local UnreliableRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Unreliable") :: RemoteEvent

local updates = collect(SendRemote.OnClientEvent)
local unreliables = collect(UnreliableRemote.OnClientEvent)

local function replecs_client(world: jecs.World)
	for buf, variants in updates do
		replicator.client:apply_updates(buf, variants)
	end
	for buf, variants in unreliables do
		replicator.client:apply_unreliable(buf, variants)
	end
end

return {
	system = replecs_client,
	phase = planck_runservice.Phases.Update,
}
