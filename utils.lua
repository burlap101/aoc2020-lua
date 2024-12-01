local M = {}
local lu = require "luaunit"

---Replaces non space whitespace with space, multiple
---spaces with a single space and removes spaces from
---ends
---@param s string
---@return string
local function trim(s)
	local doubles = string.gsub(s, "%s+", " ")
	local ends = string.gsub(doubles, "^ ", "")
	local starts = string.gsub(ends, " $", "")
	return starts
end
M.trim = trim

---Returns new table of values from arr
---between and including indexes [start, finish]
---@generic T 
---@param arr T[]
---@param start integer
---@param finish integer?
---@return T[]
local function slice(arr, start, finish)
	local result = {}
	local fin = finish or #arr
	if not fin then
		error("arr length is", #arr)
	end
	if fin < start then
		error("start must be smaller or equal to finish")
	end
	for i=start,fin do
		table.insert(result, arr[i])
	end
	return result
end
M.slice = slice

---Splits a string by separator
---@param s string
---@param sep string
---@return string[]
local function split(s, sep)
	local temp = s
	local result = {}
	while string.find(temp, sep) do
		local i, j = string.find(temp, sep)
		if i and j then
			table.insert(result, string.sub(temp, 1, i-1))
			temp = string.sub(temp, j+1)
		end
	end
	table.insert(result, temp)
	return result
end
M.split = split


---Takes a filepath and returns its contents per line
---@param filename string
---@return table
local function ingest(filename)
	local f = assert(io.open(filename, "r"))
	local lines = {}
	for l in f:lines() do
		table.insert(lines, l)
	end
	f:close()
	return lines
end
M.ingest = ingest

---Creates pretty representation of table
---@param tbl table
---@param indent integer
---@return string
local function inspect_table(tbl, indent)
	if indent == nil then
		indent = 0
	end
	local spaces = string.rep(" ", indent+2)
	local ends = string.rep(" ", indent)
	local result = ends .. "{\n"

	for i, v in pairs(tbl) do
		if type(v) == "table" then
			inspect_table(v, indent+2)
			result = result .. spaces .. ",\n"
		else
			result = result .. spaces .. i .. " = ".. v .. ",\n"
		end
	end
	return result .. ends .. "}"
end
M.inspect_table = inspect_table

---Takes an array and transfers all values 
---to the keys of new table
---@generic T 
---@param arr T
---@return table<T, true>
local function arrayToSet(arr)
	local result = {}
	for _, v in ipairs(arr) do
		result[v] = true
	end
	return result
end
M.arrayToSet = arrayToSet


---Takes two lists and returns a new
---one with the t1 and t2 joined
---@param t1 any
---@param t2 any
---@return table
local function joinArrays(t1, t2)
	local result = {table.unpack(t1)}
	for _, v in ipairs(t2) do
		table.insert(result, v)
	end
	return result
end
M.joinArrays = joinArrays


---Takes any table and attempts to use its
---keys to create an array. The values of the 
---original table are disregarded.
---@generic T
---@param t table<T, any>
---@return T[]
local function keysToArray(t)
	local result = {}
	for k in pairs(t) do
		table.insert(result, k)
	end
	return result
end
M.keysToArray = keysToArray

---Sum array elements
---@param arr number[]
---@return number
local function sumArray(arr)
	local result = 0
	for _, v in ipairs(arr) do
		result = result + v
	end
	return result
end
M.sumArray = sumArray

return M

