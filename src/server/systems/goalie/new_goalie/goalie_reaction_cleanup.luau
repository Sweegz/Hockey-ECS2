local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local query = world:query(components.GoalieReacting):cached()

local function goalie_reaction_cleanup()
	for entity, reacting in query:iter() do
		if tick() > reacting.created + reacting.duration then
			world:remove(entity, components.GoalieReacting)
			print("Ended Reaction")
		end
	end
end

return {
	system = goalie_reaction_cleanup,
	phase = planck_runservice.Phases.First,
}
