local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local action_collect = require(ServerScriptService.Server.actions.action_collect)
local action_drop = require(ServerScriptService.Server.actions.action_drop)
local action_hit1 = require(ServerScriptService.Server.actions.action_hit1)
local action_hit2 = require(ServerScriptService.Server.actions.action_hit2)
local action_pokecheck = require(ServerScriptService.Server.actions.action_pokecheck)
local action_shoot1 = require(ServerScriptService.Server.actions.action_shoot1)
local action_slapshot = require(ServerScriptService.Server.actions.action_slapshot)
local action_tip1 = require(ServerScriptService.Server.actions.action_tip1)
local action_tip2 = require(ServerScriptService.Server.actions.action_tip2)
local refs = require(ReplicatedStorage.Shared.tables.refs)

local ActionEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action") :: RemoteEvent
local onEvent = planck.onEvent
local _, onActionEvents = onEvent(ActionEvent.OnServerEvent)

local function receive_action()
	for _, player: Player, action: string, data in onActionEvents() do
		if not data then
			continue
		end

		if not player then
			continue
		end

		local player_entity = refs[player]
		if not player_entity then
			continue
		end

		local current_participant = world:target(player_entity, components.CurrentParticipant)
		if not current_participant then
			continue
		end

		local rink_entity = world:target(current_participant, components.BelongsToRink)
		if not rink_entity then
			continue
		end

		if not world:has(rink_entity, jecs.pair(components.PlayState, components.RoundActive)) then
			continue
		end

		if action == "Collect" then
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			if data.puck_entity then
				-- COLLECT THE PUCK
				--print("Collect")
				action_collect.collect(player, data.puck_entity)
			end
		elseif action == "Drop" then
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			-- DROP THE PUCK
			if data.pos then
				action_drop.drop(player, data.pos)
			end
		elseif action == "Pokecheck" then
			if data.entity and data.velocity and data.dir then
				action_pokecheck.pokecheck(player, data.entity, data.velocity, data.dir)
			end
		elseif action == "Shoot1" then
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			if data.pos and data.power and data.aim then
				-- SHOOT THE PUCK (DEFAULT)
				action_shoot1.shoot1(player, data.pos, data.power, data.aim, data.variant)
			end
		elseif action == "Hit1" then
			if data.hit and data.velocity and data.power then
				action_hit1.hit1(player, data.hit, data.velocity, data.power)
			end
			-- Hit1
		elseif action == "Hit2" then
			if data.hit and data.velocity and data.dir then
				action_hit2.hit2(player, data.hit, data.velocity, data.dir)
			end
			-- Hit2
		elseif action == "Slapshot" then
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			if data.entity and data.pos and data.power and data.aim and data.dir then
				-- SHOOT THE PUCK (DEFAULT)
				print("Slap!")
				action_slapshot.slapshot(player, data.entity, data.pos, data.power, data.aim, data.dir)
			end
		elseif action == "Tip1" then
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			if data.stick_cframe and data.dir then
				action_tip1.tip1(player, data.stick_cframe, data.dir)
			end
			-- Tip1
		elseif action == "Tip2" then
			print("TIPPED SERVER")
			if world:has(current_participant, jecs.pair(components.Timer, components.HitVictimCooldown)) then
				continue
			end

			if data.stick_cframe and data.dir then
				print("d")
				action_tip2.tip2(player, data.stick_cframe, data.dir)
			end
		end
	end
end

return {
	system = receive_action,
	phase = planck_runservice.Phases.PreUpdate,
}
