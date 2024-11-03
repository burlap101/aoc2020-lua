local lu = require "luaunit"
local lib = require "day3.lib"
local utils = require "utils"

function TestCreateMap()
	local lines = {
		"abcd",
		"1234",
	}
	local expected = {
		{ "a", "b", "c", "d" },
		{ "1", "2", "3", "4" },
	}

	local result = lib.createMap(lines)
	lu.assertEquals(result, expected)
end

function TestTreeCount()
	local lines = utils.ingest("day3/test.txt")
	local map = lib.createMap(lines)

	local result, vals = lib.treeCount(map, 3, 1)
	local coords = {}
	for _, v in pairs(vals) do
		table.insert(coords, { v[1], v[2] })
	end

	local expectedCoords = {
		{ 1,  1 },
		{ 4,  2 },
		{ 7,  3 },
		{ 10, 4 },
		{ 2,  5 },
		{ 5,  6 },
		{ 8,  7 },
	}

	for i, v in ipairs(expectedCoords) do
		lu.assertEquals(coords[i], v)
	end

	lu.assertEquals(result, 7)
end

function TestMultiplyScenarios()
	local lines = utils.ingest("day3/test.txt")
	local map = lib.createMap(lines)

	local result = lib.multiplyScenarios(map, lib.scenarios)
	lu.assertEquals(result, 336)
end

os.exit(lu.LuaUnit.run())
