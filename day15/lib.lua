local lu = require("luaunit")
local utils = require("utils")
local M = {}

---@class Game
---@field spoken {[integer]: integer[]}
---@field turn integer
---@field lastSpoken integer
local Game = {}
M.Game = Game

---Game constructor
---@param startNums integer[]
---@return table|Game
function Game:new(startNums)
	local o = setmetatable({}, {__index = self})
	o.spoken = {}
	for turn, num in ipairs(startNums) do
		o.turn = turn
		o.spoken[num] = {o.turn}
		o.lastSpoken = num
	end
	return o
end

function Game:takeTurn()
	self.turn = self.turn + 1
	local nextSpoken = nil
	if #self.spoken[self.lastSpoken] == 1 then
		nextSpoken = 0
	else
		local spokenRecord = self.spoken[self.lastSpoken]
		nextSpoken = spokenRecord[#spokenRecord] - spokenRecord[#spokenRecord-1]
	end
	local nextSC = self.spoken[nextSpoken] or {}
	self.spoken[nextSpoken] = nextSC
	table.insert(nextSC, self.turn)
	self.lastSpoken = nextSpoken
end

---comment
---@param nums integer[]
local function part1(nums)
	local g = Game:new(nums)
	while g.turn ~= 2020 do
		g:takeTurn()
	end
	return g.lastSpoken
end
M.part1 = part1

local function part2(nums)
	local g = Game:new(nums)
	while g.turn ~= 30000000 do
		g:takeTurn()
	end
	return g.lastSpoken
end
M.part2 = part2

return M
