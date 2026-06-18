local ReplicatedStorage = game:GetService("ReplicatedStorage")

local startup = require(ReplicatedStorage.Shared.startup)

require(script.utility.collection_service)
require(script.utility.custom_handlers)

local replicator = require(ReplicatedStorage.Shared.replicator)
replicator.client:init()

local systems = {}

require(script.utility.setup_localplayer_entity)

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

--print("Adding systems")
addSystemsFolders({
	script.systems,
	game.ReplicatedStorage.Shared.systems,
})

startup(systems)
