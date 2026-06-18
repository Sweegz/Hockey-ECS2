local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local components = require(ReplicatedStorage.Shared.components)
local jecs = require(ReplicatedStorage.Packages.jecs)
local planck_runservice = require(ReplicatedStorage.Packages["planck-runservice"])
local world = require(ReplicatedStorage.Shared.world)

local function color() end

local function dress_character()
	for h_Entity, c_Model in
		world
			:query(components.Model)
			:with(components.Humanoid, jecs.pair(components.BelongsToTeam, jecs.Wildcard))
			:without(components.Dressed)
	do
		local team_entity = world:target(h_Entity, components.BelongsToTeam)
		if not team_entity then
			continue
		end

		local uniform = world:get(team_entity, components.Uniform)
		if not uniform then
			continue
		end

		local shirt = c_Model:FindFirstChild("Shirt")
		if shirt then
			shirt:Destroy()
		end

		world:add(h_Entity, components.Dressed)
		shirt = Instance.new("Shirt")
		shirt.Parent = c_Model

		local pants = c_Model:FindFirstChild("Pants")
		if pants then
			pants:Destroy()
		end

		pants = Instance.new("Pants")
		pants.Parent = c_Model

		shirt.ShirtTemplate = uniform.jersey[1]
		pants.PantsTemplate = uniform.pants[1]

		local primary_colors = world:get(team_entity, components.PrimaryColors)
		if not primary_colors then
			continue
		end

		if world:has(h_Entity, components.Goalie) then
			local equipment = c_Model:FindFirstChild("Equipment")
			if not equipment then
				continue
			end

			for _, descandant in equipment:GetDescendants() do
				if not descandant:IsA("BasePart") and not descandant:IsA("MeshPart") then
					continue
				end
				if CollectionService:HasTag(descandant, "PrimColor") then
					descandant.Color = primary_colors.primary
				elseif CollectionService:HasTag(descandant, "AuxColor") then
					descandant.Color = primary_colors.auxillary
				elseif CollectionService:HasTag(descandant, "TertColor") then
					descandant.Color = primary_colors.tertiary
				end
			end

			local helmet = c_Model:FindFirstChild("Helmet")
			if not helmet then
				continue
			end

			local helmet_handle = helmet:FindFirstChild("Handle")
			if not helmet_handle then
				continue
			end

			local team = world:get(team_entity, components.Team)
			if not team then
				continue
			end

			if CollectionService:HasTag(team, "Home") then
				helmet_handle.Color = primary_colors.primary
				print("Set")
			end
		end
	end
end

return {
	system = dress_character,
	phase = planck_runservice.Phases.Update,
}
