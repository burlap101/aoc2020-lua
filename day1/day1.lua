local utils = require "utils"

local function ingest(filename)
	local f = assert(io.open(filename, "r"))
	local lines = {}
	for l in f:lines() do
		lines[l] = l
	end
	return lines
end

local function part_one(tbl)
	for	i in pairs(tbl) do
		if tbl[tostring(2020-i)] ~= nil then
			return i * (2020 - i)
		end
	end
	error("pair not found")
end

local function pair_sum_map(tbl)
	--[[Creates a table where the value is the 
	sum of all combination of pairs.]]--
	local result = {}
	for i in pairs(tbl) do
		for j in pairs(tbl) do
			result[i + j] = {i, j}
		end
	end
	return result
end

local function part_two(tbl)
	local psmap = pair_sum_map(tbl)
	for i in pairs(tbl) do
		local temp = psmap[2020 - i]
		if temp ~= nil then
			return i * temp[1] * temp[2]
		end
	end
	error("triple not found")
end

local lines = ingest(arg[1])
print(utils.inspect_table(lines))

print("part1:", part_one(lines))
print(utils.inspect_table(pair_sum_map(lines)))
local p2_res = part_two(lines)
local p2_expected = 103927824
assert(p2_res == p2_expected, "part2 incorrect; expected="..p2_expected.." got="..p2_res)
print("part2:", p2_res)
