local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)

return function(world: jecs.World, team_entity: jecs.Entity)
	local score = world:get(team_entity, components.Score)

	local query_team_scoreboards =
		world:query(components.Model):with(components.Scoreboard, jecs.pair(components.BelongsToTeam, team_entity))

	for _, model in query_team_scoreboards:iter() do
		local label = model:FindFirstChild("ScoreLabel", true)
		if label and label:IsA("TextLabel") then
			label.Text = tostring(score)
		end
	end
end
