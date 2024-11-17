local lu = require "luaunit"
local lib = require "day7.lib"
local utils = require "utils"


function TestParseLine()
	local expected = {
		["light red"] = {
			["bright white"] = 1,
			["muted yellow"] = 2,
		}
	}
	local input = "light red bags contain 1 bright white bag, 2 muted yellow bags."
	local color, contents = lib.parseLine(input)
	lu.assertEquals({ [color] = contents }, expected)
end

function TestParseLine3Contents()
	local input = "pale teal bags contain 2 dark silver bags, 1 faded silver bag, 1 dotted brown bag."
	local expected = {
		["pale teal"] = {
			["dark silver"] = 2,
			["faded silver"] = 1,
			["dotted brown"] = 1,
		}
	}
	local color, contents = lib.parseLine(input)
	lu.assertEquals({ [color] = contents }, expected)
end

function TestGetBags()
	local bags = {
		["light red"] = {
			["bright white"] = 1,
			["muted yellow"] = 2,
		},
		["dark orange"] = {
			["bright white"] = 3,
			["muted yellow"] = 4,
		},
		["bright white"] = {
			["shiny gold"] = 1,
		},
		["muted yellow"] = {
			["shiny gold"] = 2,
			["faded blue"] = 9,
		},
		["shiny gold"] = {
			["dark olive"] = 1,
			["vibrant plum"] = 2,
		},
		["dark olive"] = {
			["faded blue"] = 3,
			["dotted black"] = 4,
		},
		["vibrant plum"] = {
			["faded blue"] = 5,
			["dotted black"] = 6,
		},
		["faded blue"] = {},
		["dotted black"] = {},
	}
	local l = lib.Luggage:new("day7/test.txt")
	lu.assertEquals(l.bags, bags)
end

function TestDirectlyContains()
	local expected = { "light red", "dark orange" }
	local l = lib.Luggage:new("day7/test.txt")
	local result = l:directlyContains("bright white")
	lu.assertEquals(utils.arrayToSet(result), utils.arrayToSet(expected))
end

function TestAllContains()
	local expected = { "bright white", "muted yellow", "dark orange", "light red" }
	local l = lib.Luggage:new("day7/test.txt")
	local result = l:allContains("shiny gold")
	lu.assertEquals(result, utils.arrayToSet(expected))
end

function TestPart1()
	lu.assertEquals(lib.part1("day7/test.txt"), 4)
end

function TestGatherContents()
	local l = lib.Luggage:new("day7/test.txt")
	local expected = {
		["faded blue"] = {},
		["dotted black"] = {},
		["vibrant plum"] = { ["faded blue"] = 5, ["dotted black"] = 6 },
		["dark olive"] = { ["faded blue"] = 3, ["dotted black"] = 4 },
		["shiny gold"] = { ["dark olive"] = 1, ["vibrant plum"] = 2 },
	}
	lu.assertEquals(l:gatherContents("shiny gold"), expected)
end

function TestPart2()
	lu.assertEquals(lib.part2("day7/test.txt"), 32)
end

function TestPart2_2()
	lu.assertEquals(lib.part2("day7/test2.txt"), 126)
end

os.exit(lu.LuaUnit.run())
