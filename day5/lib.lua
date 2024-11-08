local utils = require "utils"
local M = {}

---Finds row number for given string
---@param s string
---@param min integer?
---@param max integer?
---@return integer
local function findRow(s, min, max)
	min = min or 0
	max = max or 127
	if min == max then
		return min
	end
	local ch = string.sub(s, 1, 1)
	if ch == "F" or ch == "L" then
		max = min + math.floor((max - min) / 2)
	else
		min = min + math.ceil((max - min) / 2)
	end
	return findRow(string.sub(s, 2), min, max)
end
M.findRow = findRow

---Finds seat num for given string
---@param s string
---@return integer
local function findSeat(s)
	return findRow(s, 0, 7)
end
M.findSeat = findSeat


---Returns seat id for string
---@param s string
---@return integer
local function seatID(s)
	local rowStr = string.sub(s, 1, 7)
	local seatStr = string.sub(s, 8)

	local rowNum = findRow(rowStr)
	local seatNum = findSeat(seatStr)

	return rowNum * 8 + seatNum
end
M.seatID = seatID

---Determines answer for part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local maxID = 0
	for _, l in ipairs(lines) do
		maxID = math.max(seatID(l), maxID)
	end
	return maxID
end
M.part1 = part1

---comment
---@param filename any
---@return integer?
local function part2(filename)
	local lines = utils.ingest(filename)
	local ids = {}
	for _, l in ipairs(lines) do
		ids[seatID(l)] = true
	end
	for i in pairs(ids) do
		if not ids[i+1] then
			return i+1
		end
	end
	error("unable to find ticket")
end
M.part2 = part2

return M
