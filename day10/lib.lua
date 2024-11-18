local utils = require "utils"
local lu = require "luaunit"

local M = {}


---Takes an array and returns a table
---of the counts of how many consecutive
---elements have the same difference
---@param ints integer[]
---@return {[integer]: integer}
local function countDiffs(ints)
	local counts = {}
	for i=1,(#ints-1) do
		local diff = ints[i+1]-ints[i]
		if not counts[diff] then
			counts[diff] = 0
		end
		counts[diff] = counts[diff] + 1
	end
	return counts
end
M.countDiffs = countDiffs


---Counts the combinations possible for 
---connecting device
---@param ints integer[]
---@return integer
local function countCombos(ints)
	local total = 0
	local target = ints[#ints]
	local function traverse(loc)
		if ints[loc] == target then
			total = total + 1
			return
		end
		for i=loc+1,#ints do
			local diff = ints[i] - ints[loc]
			if diff <= 3 then
				traverse(i)
			else
				break
			end
		end
	end
	traverse(1)
	return total
end
M.countCombos = countCombos

---Performs all necessary operations for
---part1
---@param filename any
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local ints = {0}
	for _, l in ipairs(lines) do
		table.insert(ints, tonumber(l))
	end
	table.sort(ints)
	table.insert(ints, ints[#ints] + 3)
	local counts = countDiffs(ints)
	print(lu.prettystr(counts))
	return counts[1] * counts[3]
end
M.part1 = part1

---Performs all necessary operations for
---part2
---@param filename any
---@return integer
local function part2(filename)
	local lines = utils.ingest(filename)
	local ints = {0}
	for _, l in ipairs(lines) do
		table.insert(ints, tonumber(l))
	end
	table.sort(ints)
	table.insert(ints, ints[#ints] + 3)
	return countCombos(ints)
end
M.part2 = part2

return M
