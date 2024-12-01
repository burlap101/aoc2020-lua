local utils = require("utils")
local lu = require("luaunit")
local mapm = require("mapm")
local M = {}


---Finds the soonest departure after supplied time
---@param time integer
---@param buses {[integer]: true}
---@return integer
---@return integer
local function findClosestDepart(time, buses)
	---@type integer
	local closestTime = nil
	local busID = nil
	for id in pairs(buses) do
		---@type integer
		local timeCalc = math.ceil(time / id) * id
		if not closestTime then
			closestTime = timeCalc
			busID = id
		elseif timeCalc < closestTime then
			closestTime = timeCalc
			busID = id
		end
	end
	return busID --[[@as integer]], closestTime
end
M.findClosestDepart = findClosestDepart

---Takes buses line and returns set of buses
---@param line string
---@return { [integer]: true }
local function getBuses(line)
	---@type {[integer]: true}
	local buses = {}
	for id in string.gmatch(line, "%d+") do
		buses[tonumber(id)] = true
	end
	return buses
end
M.getBuses = getBuses

---Finds the bus stagger times
---@param line string
---@return integer[]
local function getBusStagger(line)
	local busTimes = {}
	local i = 0
	for _, id in ipairs(utils.split(line, ",")) do
		if string.find(id, "%d+") then
			table.insert(busTimes, tonumber(id)+i)
		end
		i = i + 1
	end
	return busTimes
end
M.getBusStagger = getBusStagger

---Returns all buses but with x replaced
---by -1
---@param line string
---@return integer[]
local function getBusesIndexed(line)
	local busTimes = {}
	for _, id in ipairs(utils.split(line, ",")) do
		if string.find(id, "%d+") then
			table.insert(busTimes, tonumber(id))
		else
			table.insert(busTimes, -1)
		end
	end
	return busTimes
end
M.getBusesIndexed = getBusesIndexed

---Find the greatest common divisor of two numbers
---@param a integer
---@param b integer
---@return integer
local function gcd(a, b)
	---@type integer[]
	local remainders = {math.max(a, b), math.min(a, b)}
	while remainders[#remainders] ~= 0 do
		table.insert(remainders, remainders[#remainders-1] % remainders[#remainders])
	end
	return remainders[#remainders-1]
end
M.gcd = gcd

---Finds the lowest common multiple of two numbers
---@param a integer
---@param b integer
---@return integer
local function lcm(a, b)
	return math.floor(a * (b / gcd(a, b)))
end
M.lcm = lcm

---Finds corresponding operand given a 
---lcm result and single operand
---@param l integer
---@param a integer
---@return integer
local function findForLCM(l, a)
	local b = 2
	while lcm(a,b) ~= l do
		b = b + 1
	end
	return b
end
M.findForLCM = findForLCM

---Finds the lcm from a set of numbers
---@param as integer[]
---@return integer
local function lcmSet(as)
	if #as == 0 then
		error("set must not be empty")
	elseif #as == 1 then
		return as[1]
	end

	local acc = lcm(as[1], as[2])
	for i = 3,#as do
		acc = lcm(as[i], acc)
	end
	return acc
end
M.lcmSet = lcmSet

local function sumMods(bustimes)
	local result = mapm.new(0)
	for bus, time in pairs(bustimes) do
		result = mapm.add(result, mapm.mod(time, bus))
	end
	return result
end
M.sumMods = sumMods

---Find t
---@param as integer[]
---@return integer
local function findT(as)
	local firstv = 0
	for _, v in ipairs(as) do
		if v > 0 then
			firstv = v
			break
		end
	end
	local t = mapm.new(firstv)
	local bustimes = function(finish)
		local bustimes = {}
		for i=1,finish do
			if as[i] > 0 then
				bustimes[as[i]] = mapm.add(t, i-1)
			end
		end
		return bustimes
	end
	local zeroMapm = mapm.new(0)
	local w = firstv
	for i, v in ipairs(as) do
		if v > 0 and i > 1 then
			while sumMods(bustimes(i)) ~= zeroMapm do
				t = t + w
			end
			w = w * v
		end
	end
	return t
end
M.findT = findT


---Part1 operations
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local time = tonumber(lines[1])
	if not time then
		error("unable to parse arrival time")
	end
	local buses = getBuses(lines[2])
	local id, depart = findClosestDepart(time, buses)
	return (depart - time) * id
end
M.part1 = part1

---Part2 operations
---@param filename string
---@return integer
local function part2(filename)
	local lines = utils.ingest(filename)
	local buses = getBusesIndexed(lines[2])
	return findT(buses)
end
M.part2 = part2

return M
