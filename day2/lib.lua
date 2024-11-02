local M = {}

---Splits a line from input into its components
---@param line string
---@return table
local function splitline(line)
	-- get min max
	local s = string.match(line, "%d+%-%d+")
	local minmax = {}
	for num in string.gmatch(s, "%d+") do
		table.insert(minmax, tonumber(num))
	end

	-- get character
	s = string.match(line, "%l:")
	local c = string.sub(s, 1, 1)

	-- get string
	s = string.match(line, ": %l+$")
	local pword = string.match(s, "%l+$")

	return { password = pword, character = c, min = minmax[1], max = minmax[2] }
end
M.splitline = splitline

---Performs check on string to determine if limits breached
---@param splt table
---@return boolean
local function doesConform(splt)
	-- Get count of ch
	local _, cnt = string.gsub(splt.password, splt.character, "")
	-- Check for exceedance
	if cnt > splt.max or cnt < splt.min then
		return false
	end
	return true
end
M.doesConform = doesConform

---Takes a splitline and determines conformity with part2
---@param splt table
---@return boolean
local function doesConform2(splt)
	local c1 = string.sub(splt.password, splt.min, splt.min)
	local c2 = string.sub(splt.password, splt.max, splt.max)

	local cond1 = c1 == splt.character
	local cond2 = c2 == splt.character
	return (cond1 ~= cond2)
end
M.doesConform2 = doesConform2


---Ingests a file and returns split lines
---@param filename string
---@return table
local function ingest(filename)
	-- open file
	local f = assert(io.open(filename, "r"))
	-- store result
	local lines = {}
	for l in f:lines() do
		-- append line
		table.insert(lines, splitline(l))
	end
	return lines
end
M.ingest = ingest

---Takes file and determines valid passwords
---@param filename string
---@return integer
---@return integer
local function valid_count(filename)
	--ingest and split lines
	local lines = ingest(filename)
	-- initialise count
	local count = 0
	-- intialise part2 count
	local count2 = 0
	-- iterate through lines
	for _, v in pairs(lines) do
		if doesConform(v) then
			count = count + 1
		end
		if doesConform2(v) then
			count2 = count2 + 1
		end
	end
	return count, count2
end
M.valid_count = valid_count

return M
