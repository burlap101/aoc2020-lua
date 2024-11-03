local M = {}

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

return M

