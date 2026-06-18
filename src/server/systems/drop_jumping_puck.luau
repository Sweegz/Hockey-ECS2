local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local puck = require(ServerScriptService.Server.utility.puck)

local function drop_jumping_puck()
	for c_Entity, c_Model in
		world
			:query(components.Model)
			:with(components.Character, jecs.pair(components.CurrentParticipant, jecs.Wildcard))
	do
		local participant = world:target(c_Entity, components.CurrentParticipant)
		if not participant then
			continue
		end

		local CFRAME = c_Model.PrimaryPart.CFrame
		local VELOCITY = c_Model.PrimaryPart.AssemblyLinearVelocity

		for p_Entity, p_Part in
			world:query(components.BasePart):with(components.Puck, jecs.pair(components.Owner, participant))
		do
			if
				(VELOCITY.Y > 5 and CFRAME.Position.Y > 3)
				or math.abs(CFRAME.Rotation.X) > math.rad(10)
				or math.abs(CFRAME.Rotation.Z) > math.rad(10)
			then
				puck.drop(p_Entity)
			end
		end
	end
end

return {
	system = function() end,
	planck_runservice.Phases.Update,
}
