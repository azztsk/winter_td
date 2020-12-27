-- A Grid data structure

local grid = {_map = {}, _top_width = 0, _top_height = 0, _bottom_width = 0, _bottom_height = 0}
grid.__index = grid

function grid:new(map)
	local g = setmetatable({},grid)
	local trueWidth = arraySize(map[1])
	local trueHeight = arraySize(map)
	g._top_width, g._top_height = #map[1], #map
	g._bottom_width, g._bottom_height = g._top_width - trueWidth + 1, g._top_height - trueHeight + 1
	g._map = {}
	g._saveMap = {}
	g._saveProgress = false
	for y = g._bottom_height,g._top_height do g._map[y] = {}
		for x=g._bottom_width,g._top_width do
			g._map[y][x] = {x = x, y = y, v = map[y][x]}
		end
	end
	return g
end

function grid:save()
	self._saveMap = {}
	self._saveProgress = true
end

function grid:undo()
	for y,xArray in pairs(self._saveMap) do
		for x,value in pairs(xArray) do
			self._map[y][x].v = value.v
		end
	end
	--self:printGrid()
	self._saveProgress = false
end

function grid:has(x,y)
	return self._map[y] and self._map[y][x]
end

function grid:set(x,y,value)
	if self._saveProgress then
		if not self._saveMap[y] then self._saveMap[y] = {} end

		if not self._saveMap[y][x] then self._saveMap[y][x] = {v = self._map[y][x].v} end
	end
	self._map[y][x].v = value
	return self
end

function grid:get(x,y)
	return self._map[y][x].v
end

function grid:isFlooded()
	for y = 1, self._height do
		for x = 1, self._width do
			if self._map[y][x].v == 0 then return false end
		end
	end
	return true
end

function grid:reset()
	for y = 1, self._height do
		for x = 1, self._width do self._map[y][x].v = 0 end
	end
	return self
end

function grid:printGrid()
	for y = self._bottom_height,self._top_height do line = ""
		for x=self._bottom_width,self._top_width do
			line = line .. self:get(x,y)
		end
		print(line)
	end
end

function arraySize(t)
	local count = 0
	for k,v in pairs(t) do
		count = count+1
	end
	return count
end
return grid
