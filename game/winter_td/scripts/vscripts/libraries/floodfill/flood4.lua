-- 4-way stack-based recursive floodfill
-- See http://en.wikipedia.org/wiki/Flood_fill#Stack-based_recursive_implementation_.28Four-way.29

local function flood4(x, y, grid, wantedValue, filledValue)
	if not grid:has(x,y) then return end
	local actualValue = grid:get(x,y)
	if actualValue and (actualValue == wantedValue) then
		grid:set(x,y,filledValue)
		flood4(x+1,y,grid, wantedValue, filledValue)
		flood4(x-1,y,grid, wantedValue, filledValue)
		flood4(x,y+1,grid, wantedValue, filledValue)
		flood4(x,y-1,grid, wantedValue, filledValue)
	end
end

return flood4
