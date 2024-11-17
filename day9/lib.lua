local utils = require "utils"
local lu = require "luaunit"
local M = {}

---@class Summator
---@field sums {[integer]: {[integer]: true}}  map of sums to the numbers that produced thenm
---@field nums {[integer]: {[integer]: true}}  map of numbers to sums they produced
---@field queue integer[] maintains the order that numbers were entered
local Summator = {
--	sums = {},
--	nums = {},
--	queue = {},
}
M.Summator = Summator

---comment
---@param initial integer[]
---@return Summator
function Summator:new(initial)
	local o = setmetatable({}, { __index = self})
	o.sums = {}
	o.nums = {}
	o.queue = {}
	o:populate(initial)
	return o
end

---Takes an array of numbers and 
---populates it. 
---@param numbers integer[]
---@private
function Summator:populate(numbers)
	if #self.queue ~= 0 then
		error("The queue has already been populated")
	end
	for _,n in pairs(numbers) do
		self:updateSumsAndNums(n)
	end
end

---Add number to all sums and nums and add 
---to queue
---@private
---@param num integer
function Summator:updateSumsAndNums(num)
	--calculate sum with all other queue members
	for _, q in ipairs(self.queue) do
		-- Perform sum
		local s = q + num
		-- Initialise table if not already available
		if not self.sums[s] then
			self.sums[s] = {}
		end
		-- Add both operands to the table
		self.sums[s][num] = true
		self.sums[s][q] = true

		-- Initialise 
		if not self.nums[num] then
			self.nums[num] = {}
		end
		if not self.nums[q] then
			self.nums[q] = {}
		end
		self.nums[num][s] = true
		self.nums[q][s] = true
	end
	--insert into queue
	table.insert(self.queue, num)
end

---Adds the next number to the summator and removes the first
---entry from the queue
---@param num integer
function Summator:addNumber(num)
	local removed = table.remove(self.queue, 1)
	for i in pairs(self.nums[removed]) do
		self.sums[i][removed] = nil
		if  next(self.sums[i]) == nil then
			self.sums[i] = nil
		end
	end
	self.nums[removed] = nil
	self:updateSumsAndNums(num)
end


---Performs operations necessary for part1
---@param filename string
---@param qsize integer
---@return integer
local function part1(filename, qsize)
	if not qsize then
		error("qsize required")
	end
	local lines = utils.ingest(filename)
	---@type integer[]
	local nums = {}
	for _, l in ipairs(lines) do
		table.insert(nums, tonumber(l))
	end
	local smtr = Summator:new(utils.slice(nums, 1, qsize))
	for _, n in ipairs(utils.slice(nums, qsize+1)) do
		if not smtr.sums[n] then
			return n
		end
		smtr:addNumber(n)
	end
	error("no number found")
end
M.part1 = part1


---Finds contiguous set of numbers that add to 
---target and returns sum of min + max
---@param target integer
---@param allNumbers integer[]
---@return integer
local function findContiguous(target, allNumbers)
	local queue = {}
	local function increaseToTarget()
		while utils.sumArray(queue) < target do
			table.insert(queue, table.remove(allNumbers, 1))
		end
	end
	local function decreaseToTarget()
		while utils.sumArray(queue) > target do
			table.remove(queue, 1)
		end
	end
	while #allNumbers > 0 and utils.sumArray(queue) ~= target do
		if utils.sumArray(queue) < target then
			increaseToTarget()
		end
		if utils.sumArray(queue) > target then
			decreaseToTarget()
		end
	end
	return math.min(table.unpack(queue)) + math.max(table.unpack(queue))
end


---comment
---@param filename string
---@param target integer
---@return integer
local function part2(filename, target)
	local lines = utils.ingest(filename)
	---@type integer[]
	local nums = {}
	for _, l in ipairs(lines) do
		table.insert(nums, tonumber(l))
	end
	return findContiguous(target, nums)
end
M.part2 = part2


return M
