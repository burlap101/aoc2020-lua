local M = {}

---Creates a two-dimensional array of the supplied lines
---@param lines {integer:string}
---@return table
local function createMap(lines)
	local map = {}
	for _, l in pairs(lines) do
		local row = {}
		for i = 1, string.len(l) do
			table.insert(row, string.sub(l, i, i))
		end
		table.insert(map, row)
	end
	return map
end
M.createMap = createMap

---Performs the tree count of part1
---@param map table
---@param step_x integer
---@param step_y integer
---@return integer
---@return table
local function treeCount(map, step_x, step_y)
	local max_y = #map
	local max_x = #map[1]
	local count = 0
	local coords = {}
	local function traverse(x, y)
		table.insert(coords, {x, y, map[y][x]})
		if map[y][x] == "#" then
			count = count + 1
		end
		if y+step_y > max_y then
			return
		end
		if x+step_x > max_x then
			x = x - max_x
		end
		traverse(x+step_x, y+step_y)
	end
	traverse(1, 1)
	return count, coords
end
M.treeCount = treeCount

local function multiplyScenarios(map, scenarios)
	local result = 1
	for _, scenario in ipairs(scenarios) do
		local count = treeCount(map, scenario[1], scenario[2])
		result = result * count
	end
	return result
end
M.multiplyScenarios = multiplyScenarios

M.scenarios = {
	{1, 1},
	{3, 1},
	{5, 1},
	{7, 1},
	{1, 2},
}

return M
