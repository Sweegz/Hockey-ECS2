local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck = require(ReplicatedStorage.Packages.planck)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local scheduler = require(ReplicatedStorage.Shared.scheduler)
local world = require(ReplicatedStorage.Shared.world)

local fsm_stick = require(ReplicatedStorage.Shared.fsm_stick)

local query_equipped = world
	:query(components.Tool, components.StickStateMachine)
	:with(jecs.pair(components.EquippedOn, jecs.Wildcard))
	:without(components.Unequip)
	:cached()

local function update_stick()
	for entity, tool, fsm in query_equipped:iter() do
		if not fsm.active then
			continue
		end

		fsm_stick.run(fsm, entity, world, scheduler:getDeltaTime())
	end
end

return {
	system = update_stick,
	phase = planck_runservice.Phases.PostUpdate,
}
