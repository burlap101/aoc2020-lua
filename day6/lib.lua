local utils = require "utils"
local lu = require "luaunit"
local M = {}


---Takes extracted text lines and returns list of groups.
---@param lines string[]
---@return string[][]
local function getGroups(lines)
	---@type table[string]
	local groups = {}
	---@type string[]
	local group = {}
	for i, l in ipairs(lines) do
		if string.match(l, "^%s*$") then
			table.insert(groups, group)
			group = {}
		elseif not lines[i + 1] then
			table.insert(group, l)
			table.insert(groups, group)
		else
			table.insert(group, l)
		end
	end
	return groups
end
M.getGroups = getGroups


---Takes group and returns the set of unique answers.
---@param group string[]
---@return table<string, boolean>
local function getGroupSet(group)
	---@type table<string, boolean>
	local result = {}
	for _, answers in ipairs(group) do
		for i = 1, string.len(answers) do
			result[string.sub(answers, i, i)] = true
		end
	end
	return result
end
M.getGroupSet = getGroupSet


---Takes the keys from one table and makes them into an array
---@generic T: any
---@param s table<T, any>
---@return T[]
local function keySetToArray(s)
	local arr = {}
	for i in pairs(s) do
		table.insert(arr, i)
	end
	return arr
end
M.keySetToArray = keySetToArray

---Performs intersection operation
---on two key sets
---@param fst table<string, true>
---@param snd table<string, true>
---@return table<string, true>
local function intersection(fst, snd)
	local result = {}
	for i in pairs(fst) do
		if snd[i] then
			result[i] = true
		end
	end
	return result
end

---Gets the intersection of answers for 
---the group
---@param group string[]
---@return table<string, true>
local function groupIntersection(group)
	local _, fst = next(group)
	local result = getGroupSet({fst})
	for _, answers in pairs(group) do
		local candidate = getGroupSet({answers})
		result = intersection(candidate, result)
	end
	return result
end
M.groupIntersection = groupIntersection


---Performs operations for part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local groups = getGroups(lines)
	local total = 0
	for _, g in pairs(groups) do
		local gs = getGroupSet(g)
		total = total + #keySetToArray(gs)
	end
	return total
end
M.part1 = part1


local function part2(filename)
	local lines = utils.ingest(filename)
	local groups = getGroups(lines)
	local total = 0
	for _, g in pairs(groups) do
		local gi = groupIntersection(g)
		local res = keySetToArray(gi)
		total = total + #res
	end
	return total
end
M.part2 = part2

return M
