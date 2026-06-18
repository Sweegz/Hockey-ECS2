local ReplicatedStorage = game:GetService("ReplicatedStorage")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local use_entity_get = require(ReplicatedStorage.Shared.addons.use_entity_get)
local use_entity_has = require(ReplicatedStorage.Shared.addons.use_entity_has)
local use_target = require(ReplicatedStorage.Shared.addons.use_target)
local vide = require(ReplicatedStorage.Packages.vide)
local world = require(ReplicatedStorage.Shared.world)

use_entity_get.world = world
use_entity_has.world = world
use_target.world = world

--local DEFAULT_STAMINA = 100
--local FONT_ARIMO_BOLD = Font.new("rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Bold)
--local FONT_PIXEL_BOLD = Font.new("rbxasset://fonts/families/PressStart2P.json", Enum.FontWeight.Bold)

local BenchButtons = require(script.BenchButtons)
local BenchColorGradient = require(script.BenchColorGradient)
local BenchNameLabel = require(script.BenchNameLabel)
local BenchStaminaContainer = require(script.BenchStaminaContainer)

return function(props: { participant: jecs.Entity })
	local StaminaComponent: () -> number? = use_entity_get.useEntityGet(props.participant, components.Stamina)
	local PlayerEntity = use_target.useTarget(props.participant, components.ParticipantOf)
	local PlayerComponent: () -> Player? = use_entity_get.useEntityGet(PlayerEntity(), components.Player)
	local BenchedComponent = use_entity_has.useEntityHas(props.participant, components.Benched)

	return vide.create("Frame")({
		Name = "BenchEntry",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Transparency = 0.1,
		vide.create("UIListLayout")({}),
		vide.create("UIPadding")({ PaddingTop = UDim.new(0, 5) }),
		BenchColorGradient({ benched = BenchedComponent }),
		BenchNameLabel({ player = PlayerComponent }),
		BenchButtons({ participant = props.participant }),
		BenchStaminaContainer({ stamina = StaminaComponent }),
	})
end
