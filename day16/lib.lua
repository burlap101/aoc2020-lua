local M = {}
local utils = require("utils")
local lu = require("luaunit")

---@class Range
---@field lo integer
---@field hi integer

---@class Field
---@field fst Range
---@field snd Range

---comment
---@param lines string[]
---@return { [string]: Field }
local function getFields(lines)
	local fields = {}
	for _, line in ipairs(lines) do
		local name, fstLo, fstHi, sndLo, sndHi = string.match(line, "(.+): (%d+)-(%d+) or (%d+)-(%d+)")
		if not name then
			break
		end
		for _, snum in ipairs({ fstLo, fstHi, sndLo, sndHi }) do
			if not tonumber(snum) then
				error("failed to parse to number: " .. snum)
			end
		end
		fields[name] = {
			fst = {
				lo = tonumber(fstLo),
				hi = tonumber(fstHi),
			},
			snd = {
				lo = tonumber(sndLo),
				hi = tonumber(sndHi),
			}
		}
	end
	return fields
end
M.getFields = getFields

---Parses nearby tickets
---@param lines string[]
---@return integer[][]
local function getNearbyTickets(lines)
	local startIndex = 0
	for i, line in ipairs(lines) do
		if string.find(line, "nearby tickets") then
			startIndex = i + 1
		end
	end
	---@type integer[][]
	local tickets = {}
	for i = startIndex, #lines do
		local nums = {}
		table.insert(tickets, nums)
		for snum in string.gmatch(lines[i], "%d+") do
			local num = tonumber(snum)
			if not num then
				error("failed to parse num " .. snum)
			end
			table.insert(nums, num)
		end
	end
	return tickets
end
M.getNearbyTickets = getNearbyTickets

local function getMyTicket(lines)
	local startIndex = 0
	for i, line in ipairs(lines) do
		if string.find(line, "your ticket") then
			startIndex = i + 1
		end
	end
	---@type integer[]
	local ticket = {}
	for snum in string.gmatch(lines[startIndex], "%d+") do
		local num = tonumber(snum)
		if not num then
			error("failed to parse num " .. snum)
		end
		table.insert(ticket, num)
	end
	return ticket
end
M.getMyTicket = getMyTicket

---@class Checker
---@field myTicket integer[]
---@field tickets integer[][]
---@field validTickets integer[][]
---@field fields {[string]: Field}
---@field cols {[string]: true}[]
local Checker = {}
M.Checker = Checker

function Checker:new(lines)
	local o = setmetatable({}, { __index = self })
	o.fields = getFields(lines)
	o.tickets = getNearbyTickets(lines)
	o.myTicket = getMyTicket(lines)
	o.validTickets = o:getValidTickets()
	o.cols = o:getInitCols()
	return o
end

---Gets all the valid tickets for the checker
---@return table
---@private
function Checker:getValidTickets()
	local valids = {}
	for _, ticket in ipairs(self.tickets) do
		if #self:checkTicket(ticket) == 0 then
			table.insert(valids, ticket)
		end
	end
	return valids
end

---Gets a representation of ticket cols with all
---names of fields for future elimination
---@return { [string]: true }[]
---@private
function Checker:getInitCols()
	---@type {[string]: true}
	local names = {}
	for name in pairs(self.fields) do
		names[name] = true
	end
	---@type {[string]: true}[]
	local result = {}
	for _ in pairs(self.myTicket) do
		table.insert(result, utils.copy(names))
	end
	return result
end

---Gets the departure field product number
---@return integer
function Checker:departureProduct()
	local product = 1
	local fieldNames = self:determineFields()
	for i, name in ipairs(fieldNames) do
		if string.find(name, "^departure") then
			product = product * self.myTicket[i]
		end
	end
	return product
end

---Determines the fieldnames for the tickets
---@return string[]
---@private
function Checker:determineFields()
	local areDetermined = function()
		for i, col in ipairs(self.cols) do
			local namesArr = utils.keysToArray(col)
			if #namesArr > 1 then
				return false
			elseif #namesArr < 1 then
				error("no options available for column #"..i)
			end
		end
		return true
	end
	for _, ticket in ipairs(self.validTickets) do
		if areDetermined() then
			break
		end
		self:processTicket(ticket)
	end
	if not areDetermined() then
		print(lu.prettystr(self.cols))
		error("failed to determine field names.")
	end
	---@type string[]
	local fieldNames = {}
	for _, col in ipairs(self.cols) do
		local name = next(col)
		table.insert(fieldNames, name)
	end
	return fieldNames
end

---Processes a ticket and eliminates cols that it can
---@param ticket integer[]
function Checker:processTicket(ticket)
	for i, num in ipairs(ticket) do
		local potentialNames = utils.keysToArray(self.cols[i])
		if #potentialNames > 1 then
			local nonNames = self:determineWhatNot(num, i)
			for _, name in ipairs(nonNames) do
				self.cols[i][name] = nil
				if #utils.keysToArray(self.cols[i]) == 1 then
					local lastName = next(self.cols[i])
					self:lockInFieldNameForColumn(lastName, i)
				end
			end
		end
	end
end

---Locks in a field name for a column by removing it
---from all other columns
---@param name string
---@param colNo integer
function Checker:lockInFieldNameForColumn(name, colNo)
	for i, names in ipairs(self.cols) do
		if i ~= colNo then
			-- if name exists in names then remove it and 
			-- if final one left lock it in.
			if names[name] then
				names[name] = nil
				if #utils.keysToArray(names) == 1 then
					local lastName = next(names)
					self:lockInFieldNameForColumn(lastName, i)
				end
			end
		end
	end
end

---Determines names that cannot occur for the column
---@param num integer
---@param colNo integer
---@return string[]
function Checker:determineWhatNot(num, colNo)
	local names = {}
	for name in pairs(self.cols[colNo]) do
		local field = self.fields[name]
		if num >= field.fst.lo and num <= field.fst.hi then
			goto continue
		elseif num >= field.snd.lo and num <= field.snd.hi then
			goto continue
		end
		table.insert(names, name)
		::continue::
	end
	return names
end


---Obtain the ticketScanningErrorRate
---@return integer
function Checker:ticketScanningErrorRate()
	local result = 0
	for _, ticket in ipairs(self.tickets) do
		for _, num in ipairs(self:checkTicket(ticket)) do
			result = result + num
		end
	end
	return result
end

---Returns all bad nums on a ticket
---@param ticket integer[]
---@return integer[]
function Checker:checkTicket(ticket)
	local badNums = {}
	for _, num in ipairs(ticket) do
		if not self:checkNum(num) then
			table.insert(badNums, num)
		end
	end
	return badNums
end

---Determines if the supplied number falls within any field ranges
---@param num integer
---@return boolean
function Checker:checkNum(num)
	for _, field in pairs(self.fields) do
		for _, fstsnd in pairs(field) do
			if num >= fstsnd.lo and num <= fstsnd.hi then
				return true
			end
		end
	end
	return false
end


---Operations for part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local chkr = Checker:new(lines)
	return chkr:ticketScanningErrorRate()
end
M.part1 = part1

local function part2(filename)
	local lines = utils.ingest(filename)
	local chkr = Checker:new(lines)
	return chkr:departureProduct()
end
M.part2 = part2

return M
