local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local render_cache = require(ReplicatedStorage.Shared.interpolation.render_cache)
local scheduler = require(ReplicatedStorage.Shared.scheduler)

local function update()
	--render_cache.update(scheduler:getDeltaTime())
end

return {
	system = update,
	phase = planck_runservice.Phases.Update,
}
