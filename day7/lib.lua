local utils = require "utils"
local lu = require "luaunit"

local M = {}

---comment
---@param line string
---@return string 
---@return table<string, integer>>
local function parseLine(line)
	local contents = {}
	local ocolor, iline = string.match(line, "^([%l ]+) *bags? contain (.*)$")
	local interbagpattern = " bags?,"
	local endbagpattern = " bags?%.$"
	local nobagpattern = "no other bags.$"

	if string.match(iline, nobagpattern) then
		return utils.trim(ocolor), {}
	end

	local i, j = string.find(iline, endbagpattern)
	while i do
		local cnt, color = string.match(iline, "^ *(%d+) *([%l%p ]+) *bag")
		contents[utils.trim(color)] = tonumber(cnt)
		if not j then
			error("unable to detect bagpattern correctly")
		end
		i, j = string.find(iline, interbagpattern)
		if not i then
			i, j = string.find(iline, endbagpattern)
		end
		iline = string.sub(iline, j+1)
		i, j = string.find(iline, endbagpattern)
	end
	return utils.trim(ocolor), contents
end
M.parseLine = parseLine


---@class Luggage
---@field bags table<string, table<string, integer>>
---@field getBags function(string): table<string, table<string, integer>>
local Luggage = {
	bags = {}
}
M.Luggage = Luggage


---comment
---@param lines string[]
---@return table<string, table<string, integer>>
local function getBags(lines)
	local result = {}
	for _, l in ipairs(lines) do
		local color, contents = parseLine(l)
		result[color] = contents
	end
	return result
end


---Constructor for Luggage
---@param filename string
---@return Luggage
function Luggage:new(filename)
	local o = {}
	local lines = utils.ingest(filename)
	setmetatable(o, self)
	self.__index = self
	self.bags = getBags(lines)
	return o
end


---Returns array of all bags that directly contain 
---bag with name
---@param name string
---@return string[]
function Luggage:directlyContains(name)
	local result = {}
	for i, bgs in pairs(self.bags) do
		if bgs[name] then
			table.insert(result, i)
		end
	end
	return result
end

---Creates table of all contents and so on 
---down into one usable table.
---@param name string
---@return table<string, table<string, integer>>
function Luggage:gatherContents(name)
	local result = {}
	local bagQ = {name}
	local function traverse()
		local bagName = table.remove(bagQ)
		local contents = self.bags[bagName]
		result[bagName] = contents
		bagQ = utils.joinArrays(bagQ, utils.keysToArray(contents))
		if #bagQ == 0 then
			return
		end
		traverse()
	end
	traverse()
	return result
end


---Returns all bags names that directly
---and indirectly contain the named bag
---@param name string
---@return table<string, true>
function Luggage:allContains(name)
	local result = {}
	local bagQ = self:directlyContains(name)
	local function traverse()
		local bag = table.remove(bagQ)
		result[bag] = true
		bagQ = utils.joinArrays(
			bagQ,
			self:directlyContains(bag)
		)
		if #bagQ == 0 then
			return
		end
		traverse()
	end
	traverse()
	return result
end


---Performs all operations necessary
---for part1
---@param filename string
---@return integer
local function part1(filename)
	local l = Luggage:new(filename)
	local bgs = l:allContains("shiny gold")
	local cnt = 0
	for _ in pairs(bgs) do
		cnt = cnt + 1
	end
	return cnt
end
M.part1 = part1


---comment
---@param bags {[string]: {[string]: integer}}
---@param startLeaf string
---@return integer
local function calculateTotal(startLeaf, bags)
	local function traverse(leaf)
		local total = 1
		local contents = bags[leaf]
		for bg, cnt in pairs(contents) do
			total = total + cnt * traverse(bg)
		end
		return total
	end
	return traverse(startLeaf) - 1
end


---Performs all necessary operations to 
---complete part2.
---@param filename string
---@return integer
local function part2(filename)
	local l = Luggage:new(filename)
	local bgs = l:gatherContents("shiny gold")
	return calculateTotal("shiny gold", bgs)
end
M.part2 = part2


return M
