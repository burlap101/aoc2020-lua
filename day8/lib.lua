local utils = require "utils"
local lu = require "luaunit"

local M = {}

---@enum Operation
local Operation = {
	acc = 1,
	jmp = 2,
	nop = 3,
}
M.Operation = Operation

---@class Statement
---@field op string
---@field value integer?
local Statement = {}
M.Statement = Statement

---Takes single line and creates a Statement
---@param line string
---@return Statement
local function parseLine(line)
	local op = string.match(line, "(%l%l%l)")
	local vstr = string.match(line, "(%+?-?%d+)")
	local value = nil
	if vstr then
		value = tonumber(vstr)
	end
	return { op = op, value = value }
end
M.parseLine = parseLine

---Parses input lines and creates array
---of statements
---@param lines string[]
---@return Statement[]
local function getProgram(lines)
	local result = {}
	for _, l in ipairs(lines) do
		table.insert(result, parseLine(l))
	end
	return result
end
M.getProgram = getProgram

---@class ProgramStats
---@field nextCounter integer
---@field counter integer
---@field statement Statement
local ProgramStats = {}
M.ProgramStats = ProgramStats

---Runs a program until a duplicate statement is
---encountered then returns accumulator value
---@param program Statement[]
---@return function(): integer, ProgramStats
local function runProgram(program)
	---@type {[integer]: Statement}
	local linesAccessed = {}
	local counter = 1
	return function()
		local acc = 0
		-- Get statement
		local stmt = program[counter]
		local prevCounter = counter
		-- Keep set of lines accessed
		linesAccessed[counter] = stmt
		-- Check for and perform operation
		if stmt.op == "nop" then
			counter = counter + 1
		elseif stmt.op == "acc" then
			acc = acc + stmt.value
			counter = counter + 1
		else
			counter = counter + stmt.value
		end
		if linesAccessed[counter] == nil then
			return acc, {nextCounter=counter, counter=prevCounter, statement=stmt}
		end
	end
end
M.runProgram = runProgram

local function part1(filename)
	local lines = utils.ingest(filename)
	local program = getProgram(lines)
	local total = 0
	for acc in runProgram(program) do
		total = total + acc
	end
	return total
end
M.part1 = part1

---@class LineEntry
---@field num integer
---@field statement Statement


---comment
---@param filename string
---@return integer
local function part2(filename)
	local lines = utils.ingest(filename)
	local program = getProgram(lines)
	local targetLine = #program
	---@type {[integer]: true}
	local alteredLines = {}
	---@type LineEntry
	local savedAlteredLine = {}
	local runCount = 0
	while true do
		---@type LineEntry[]
		local log = {}
		local total = 0
		runCount = runCount + 1
		for acc, stats in runProgram(program) do
			total = total + acc
			if stats.counter == targetLine then
				return total
			end
			-- Log
			---@type LineEntry
			local entry = {num=stats.counter, statement=stats.statement}
			table.insert(log, entry)
		end
		-- Restore altered line
		if next(savedAlteredLine) ~= nil then
			program[savedAlteredLine.num] = {op=savedAlteredLine.statement.op, value=savedAlteredLine.statement.value}
		end
		for _, line in ipairs(log) do
			if line.statement.op == "jmp" and not alteredLines[line.num] then
				savedAlteredLine = {num=line.num, statement={op=line.statement.op, value=line.statement.value}}
				program[line.num].op = "nop"
				alteredLines[line.num] = true
				break
			elseif line.statement.op == "nop" and not alteredLines[line.num] then
				savedAlteredLine = {num=line.num, statement={op=line.statement.op, value=line.statement.value}}
				program[line.num].op = "jmp"
				alteredLines[line.num] = true
				break
			end
		end
	end
end
M.part2 = part2


return M
