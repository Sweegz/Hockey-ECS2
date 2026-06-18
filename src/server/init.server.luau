local ReplicatedStorage = game:GetService("ReplicatedStorage")

local startup = require(ReplicatedStorage.Shared.startup)

local replicator = require(ReplicatedStorage.Shared.replicator)
replicator.server:init()

local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local Send = Instance.new("RemoteEvent")
Send.Name = "Send"
Send.Parent = Remotes

local Unreliable = Instance.new("UnreliableRemoteEvent")
Unreliable.Name = "Unreliable"
Unreliable.Parent = Remotes

local Ragdoll = Instance.new("RemoteEvent")
Ragdoll.Name = "Ragdoll"
Ragdoll.Parent = Remotes

local Sound = Instance.new("RemoteEvent")
Sound.Name = "Sound"
Sound.Parent = Remotes

local Action = Instance.new("RemoteEvent")
Action.Name = "Action"
Action.Parent = Remotes

local GoalEvent = Instance.new("RemoteEvent")
GoalEvent.Name = "GoalEvent"
GoalEvent.Parent = Remotes

local Full = Instance.new("RemoteFunction")
Full.Name = "Full"
Full.Parent = Remotes

Full.OnServerInvoke = function(player: Player)
	replicator.server:mark_player_ready(player)
	return replicator.server:get_full(player)
end

local systems = {}

local function addSystems(folder)
	for _, system: Instance in folder:GetDescendants() :: { Instance } do
		if system:IsA("ModuleScript") then
			local required = (require :: any)(system)
			table.insert(systems, required)
		end
	end
end

local function addSystemsFolders(folders)
	for _, folder in folders do
		addSystems(folder)
	end
end

addSystemsFolders({
	script.systems,
	game.ReplicatedStorage.Shared.systems,
})

startup(systems)
