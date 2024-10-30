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

Utils = {
	inspect_table = inspect_table
}

return Utils

