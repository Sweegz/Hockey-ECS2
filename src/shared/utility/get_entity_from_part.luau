--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local refs = require(ReplicatedStorage.Shared.tables.refs)
local world = require(ReplicatedStorage.Shared.world)

return function(part: BasePart)
	for entity, model in world:query(components.Model):iter() do -- this should be your query
		if not part:IsDescendantOf(model) then
			continue
		end
		if model.Name == "Rink" and not (part.Name == "Indicator") then
			continue
		end
		return entity, model
	end

	local partEntity = refs[part]
	if partEntity then
		return partEntity, part
	end
	return nil
end
