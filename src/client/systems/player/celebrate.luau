local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local command = require(StarterPlayer.StarterPlayerScripts.Client.utility.command)
local components = require(ReplicatedStorage.Shared.components)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local refs = require(ReplicatedStorage.Shared.tables.refs)

local function celebrate()
	for e, track in world:query(components.Celebrating) do
		if track.IsPlaying == false then
			world:remove(e, components.Celebrating)
		end
	end

	local player_entity = world:get(components.LocalPlayer, components.LocalPlayer)
	if not player_entity then
		return
	end

	local player = world:get(player_entity, components.Player)
	if not player then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local character_entity = refs[character]
	if not character_entity then
		return
	end

	local participant = world:target(player_entity, components.CurrentParticipant)
	if not participant then
		return
	end

	local can_celebrate = world:get(participant, components.CanCelebrate)

	if can_celebrate and can_celebrate.tag then
		if can_celebrate.tag == "Default" then
			if command.celebrate then
				for e, fsm in world:query(components.StickStateMachine):iter() do
					if fsm.current == "Default" then
						world:remove(participant, components.CanCelebrate)

						local tracks = world:get(character_entity, components.AnimationTrack)
						if not tracks then
							return
						end

						local track = tracks["DefaultCelly"]
						if not track then
							return
						end

						if track then
							track:Play(0.4)
						end

						world:set(participant, components.Celebrating, track)
					end
				end
			end
		elseif can_celebrate.tag == "Negative" then
			if command.celebrate then
				for e, fsm in world:query(components.StickStateMachine):iter() do
					if fsm.current == "Default" then
						world:remove(participant, components.CanCelebrate)

						local tracks = world:get(character_entity, components.AnimationTrack)
						if not tracks then
							return
						end

						local track = tracks["NegativeCelly1"]
						if not track then
							return
						end

						if track then
							track:Play(0.4)
						end

						world:set(participant, components.Celebrating, track)
					end
				end
			end
		end
	end
end

return {
	system = celebrate,
	phase = planck_runservice.Phases.Update,
}
