local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local puck = require(ServerScriptService.Server.utility.puck)
local world = require(ReplicatedStorage.Shared.world)

local function poke(puck: BasePart, dir: Vector3)
	local LV = Instance.new("LinearVelocity")
	LV.Parent = puck
	LV.MaxForce = math.huge
	LV.Name = "PokeVelocity"
	LV.Attachment0 = puck:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", puck)

	local final_velocity = dir * 40
	final_velocity += Vector3.new(0, 20, 0)

	LV.VectorVelocity = final_velocity
	puck.AssemblyLinearVelocity = final_velocity

	game:GetService("Debris"):AddItem(LV, 0.3)
end

local function goalie_poke()
	for g_Entity, g_Model, g_center_cframe, g_fsm in
		world:query(components.Model, components.CenterCFrame, components.GoalieStateMachine):iter()
	do
		if g_fsm.current ~= "Poke" then
			continue
		end

		local rink_entity = world:target(g_Entity, components.BelongsToRink)
		if not rink_entity then
			continue
		end

		local primary_part = g_Model.PrimaryPart
		if not primary_part then
			continue
		end

		local center_pos: Vector3 = g_center_cframe.Position

		for p_Entity, p_Part in
			world:query(components.BasePart):with(components.Puck, jecs.pair(components.BelongsToRink, rink_entity))
		do
			local dist = (primary_part.Position - p_Part.Position).Magnitude
			if dist < 10 then
				local dir = (p_Part.Position - center_pos).Unit
				puck.drop(p_Entity)
				g_fsm.busy = true
				world:set(g_Entity, components.GoalieStateMachine, g_fsm)
				poke(p_Part, dir)
				task.delay(1, function()
					g_fsm.busy = false
					world:set(g_Entity, components.GoalieStateMachine, g_fsm)
				end)
			end
		end
	end
end

return {
	system = goalie_poke,
	phsae = planck_runservice.Phases.PreSimulation,
}
