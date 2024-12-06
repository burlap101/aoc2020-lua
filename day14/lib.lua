local M = {}
local lu = require("luaunit")
local utils = require("utils")

---Retrieve a mask to use for anding
---@param zeros integer[]
---@return integer
local function getAndMask(zeros)
	local temp = 0
	for _, i in ipairs(zeros) do
		temp = temp + 2^(i-1)
	end
	-- XOR the result to make it an AND mask
	return temp ~ (2^36 - 1)
end
M.getAndMask = getAndMask

---Retrieve a mask to use for oring
---@param ones integer[]
---@return integer
local function getOrMask(ones)
	local temp = 0
	for _, i in ipairs(ones) do
		temp = temp + 2^(i-1)
	end
	return temp
end
M.getOrMask = getOrMask

---Gets the AND and OR mask
---@param stMask string
---@return integer
---@return integer
local function getAndOrMasks(stMask)
	local ones = {}
	local zeros = {}
	for i = 1,string.len(stMask) do
		local bitnum = string.len(stMask) - (i - 1)
		local ch = string.sub(stMask,i,i)
		if ch == "0" then
			table.insert(zeros, bitnum)
		elseif ch == "1" then
			table.insert(ones, bitnum)
		end
	end
	return getAndMask(zeros), getOrMask(ones)
end
M.getAndOrMasks = getAndOrMasks

---function returning the mem addr and
---value
---@param line string
---@return integer, integer 
local function getMemoryValue(line)
	local smem, sval = string.match(line, "mem%[(%d+)%] = (%d+)")
	local mem = tonumber(smem)
	local val = tonumber(sval)
	if not mem then
		error("unable to parse mem")
	elseif not val then
		error("unable to parse val")
	end
	return mem, val
end

---@class Runner
---@field memory {[integer]: integer}
---@field andMask integer
---@field orMask integer
local Runner = {}
M.Runner = Runner

function Runner:new(lines)
	local o = setmetatable({}, {__index=self})
	o:setMasks(lines[1])
	o.memory = {}
	return o
end

function Runner:setMasks(line)
	self.andMask, self.orMask = getAndOrMasks(string.match(line, "mask = (%w+)"))
end


---Peforms masking operation, stores 
---and returns value
---@param mem integer
---@param val integer
---@return integer
function Runner:doMask(mem, val)
	val = val & self.andMask
	val = val | self.orMask
	self.memory[mem] = val
	return val
end

function Runner:getSum()
	local result = 0
	for _, v in pairs(self.memory) do
		result = result + v
	end
	return result
end

local function part1(filename)
	local lines = utils.ingest(filename)
	local r = Runner:new({table.remove(lines,1)})
	for _, line in ipairs(lines) do
		if string.find(line, "mask") then
			r:setMasks(line)
		else
			r:doMask(getMemoryValue(line))
		end
	end
	return r:getSum()
end
M.part1 = part1


local function getOnesAndAnys(stMask)
	local ones = {}
	local anys = {}
	for i = 1,string.len(stMask) do
		local bitnum = string.len(stMask) - (i - 1)
		local ch = string.sub(stMask,i,i)
		if ch == "X" then
			table.insert(anys, bitnum)
		elseif ch == "1" then
			table.insert(ones, bitnum)
		end
	end
	return ones, anys
end

---Creates masks from anys for part2
---@param anys integer[]
---@return integer[] andMasks
---@return integer[] orMasks
local function andOrMasksFromAnys(anys)
	local stMasks = {}
	local anysSet = utils.arrayToSet(anys)
	---@param i integer
	---@param acc string
	local function findMasks(i, acc)
		if i == 37 then
			table.insert(stMasks, acc)
			return
		end
		if anysSet[i] then
			findMasks(i+1, "0"..acc)
			findMasks(i+1, "1"..acc)
		else
			findMasks(i+1, "X"..acc)
		end
	end
	findMasks(1, "")
	local andMasks = {}
	local orMasks = {}
	for _, stMask in ipairs(stMasks) do
		local a, o = getAndOrMasks(stMask)
		table.insert(andMasks, a)
		table.insert(orMasks, o)
	end
	return andMasks, orMasks
end
M.andOrMasksFromAnys = andOrMasksFromAnys

---@class MemRunner: Runner
---@field memory {[integer]: integer}
---@field orMasks integer[]
---@field andMasks integer[]
---@field ones integer[]
local MemRunner = setmetatable({}, {__index=Runner})
M.MemRunner = MemRunner

function MemRunner:setMasks(line)
	local ones, anys = getOnesAndAnys(string.match(line, "mask = (%w+)"))
	self.ones = ones
	self.andMasks, self.orMasks = andOrMasksFromAnys(anys)
end

function MemRunner:orMaskFromOnes()
	local result = 0
	for _, loc in ipairs(self.ones) do
		result = result + 2^(loc-1)
	end
	return result
end

---Performs part 2 masking
---@param mem integer
---@param val integer
---@return integer[]
function MemRunner:doMask(mem, val)
	local onesMask = self:orMaskFromOnes()
	local memories = {}
	for i=1,#self.andMasks do
		mem = mem & self.andMasks[i]
		mem = mem | self.orMasks[i]
		mem = mem | onesMask
		table.insert(memories, mem)
		self.memory[mem] = val
	end
	return memories
end

function MemRunner:new(lines)
	local o = setmetatable({}, {__index=self})
	o.memory = {}
	o:setMasks(lines[1])
	return o
end

local function part2(filename)
	local lines = utils.ingest(filename)
	local r = MemRunner:new({table.remove(lines,1)})
	for _, line in ipairs(lines) do
		if string.find(line, "mask") then
			r:setMasks(line)
		else
			r:doMask(getMemoryValue(line))
		end
	end
	return r:getSum()
end
M.part2 = part2

return M
