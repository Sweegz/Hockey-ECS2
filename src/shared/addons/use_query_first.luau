local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local observers = require(ReplicatedStorage.Shared.addons.observers)
local query_first = require(ReplicatedStorage.Shared.addons.query_first)
local vide = require(ReplicatedStorage.Packages.vide)

local source = vide.source
local read = vide.read
local cleanup = vide.cleanup
local effect = vide.effect

local exports = {
	world = (nil :: any) :: jecs.World,
}

type Derivable<T> = (() -> T) | T

function useQueryFirst<T...>(query: Derivable<jecs.Query<T...>?>, predicator: ((entity: jecs.Entity, T...) -> boolean)?)
	local entity = source(nil :: jecs.Entity?)

	effect(function()
		local query = read(query) :: jecs.Query<...any>
		if not query then
			entity(nil)
			return
		end

		local monitor = observers.monitor(query)
		query_first(query, predicator :: any)

		monitor.added(function()
			entity(query_first(query, predicator :: any))
		end)
		monitor.removed(function()
			task.defer(function()
				entity(query_first(query, predicator :: any))
			end)
		end)
		entity(query_first(query, predicator :: any))
		cleanup(monitor.disconnect)
	end)

	return entity
end

exports.useQueryFirst = useQueryFirst

return exports
