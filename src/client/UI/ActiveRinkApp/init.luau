local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)
local use_target = require(ReplicatedStorage.Shared.addons.use_target)

local BenchFrame = require(script.BenchFrame)
local HitTrackerFrame = require(script.HitTrackerFrame)
local RinkTextLabel = require(script.RinkTextLabel)
local ScorebugFrame = require(script.ScorebugFrame)
local StaminaContainerFrame = require(script.StaminaContainerFrame)

use_entity_get.world = world
use_target.world = world

return function(props: { hit_tracker_open: () -> boolean? })
	local LocalplayerEntity = use_entity_get.useEntityGet(components.LocalPlayer, components.LocalPlayer)
	local ActiveParticipantEntity = use_target.useTarget(LocalplayerEntity(), components.CurrentParticipant)
	local RinkEntity = use_target.useTarget(ActiveParticipantEntity, components.BelongsToRink)

	--local TeamEntity = use_target.useTarget(ActiveParticipantEntity(), components.BelongsToTeam)

	vide.effect(function()
		print("Participant", ActiveParticipantEntity())
	end)

	return vide.create("ScreenGui")({
		Name = "ActiveRinkApp",
		RinkTextLabel({ rink = RinkEntity, participant = ActiveParticipantEntity }),
		vide.show(ActiveParticipantEntity, function()
			return StaminaContainerFrame({ participant = ActiveParticipantEntity })
		end),
		vide.show(ActiveParticipantEntity, function()
			return BenchFrame({ participant = ActiveParticipantEntity })
		end),
		vide.show(RinkEntity, function()
			return ScorebugFrame({ rink = RinkEntity })
		end),

		vide.show(props.hit_tracker_open, function()
			return HitTrackerFrame({ rink = RinkEntity })
		end),
	})
end
