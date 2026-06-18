local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local shots = require(ServerScriptService.Server.utility.shots)

local action = {}

function action.tip1(player: Player, stick_cframe: CFrame, dir: Vector3)
	local player_entity = refs[player]
	if not player_entity then
		return
	end

	for participant_entity in world:query(jecs.pair(components.ParticipantOf, player_entity)) do
		for p_Entity, p_Part, p_Velocity, p_prevOwner in
			world:query(
				components.BasePart,
				components.VelocityBefore,
				components.PreviousOwner,
				components.Puck,
				jecs.pair(components.Owner, participant_entity)
			)
		do
			if p_Velocity.Magnitude < 50 then
				continue
			end
			if p_prevOwner == participant_entity then
				return
			end
			print(p_Velocity.Magnitude)
			print("Tip1", p_Entity)
			puck.drop(p_Entity)
			p_Part.CFrame = stick_cframe * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-90))
			shots.lowtip(player, p_Part, stick_cframe, dir, p_Velocity)
		end
	end
end

return action
