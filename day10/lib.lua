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
---connecting device. Utilises memoization
---to complete the calc.
---@param ints integer[]
---@return integer
local function countCombos(ints)
	---@type {[integer]: integer}
	local results = {}
	local function traverse(loc)
		local total = 0
		if results[loc] then
			return results[loc]
		end
		if loc == #ints then
			results[loc] = 1
			return 1
		end
		for i=loc+1,#ints do
			local diff = ints[i] - ints[loc]
			if diff <= 3 then
				total = total + traverse(i)
			else
				break
			end
		end
		results[loc] = total
		return total
	end
	return traverse(1)
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
