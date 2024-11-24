local lu = require("luaunit")
local lib = require("day11.lib")
local utils = require("utils")

function TestSurroundLocations()
	local expected = {
		"5-1",
		"7-1",
		"5-2",
		"6-2",
		"7-2",
	}
	local actual = lib.surroundingLocations("6-1", 10, 10)
	lu.assertEquals(utils.arrayToSet(actual), utils.arrayToSet(expected))
end

function TestPart1()
	lu.assertEquals(lib.part1("day11/test.txt"), 37)
end

function TestFindAdjacents()
	local seatLocs = {
		"3-3", -- This is the seat to find adjacents
		"1-1",
		"1-2",
		"1-3",
		"1-5",
		"3-4",
		"3-5",
		"4-4",
		"4-3",
		"5-5",
		"5-3",
		"5-1",
		"3-1",
		"3-2",
	}
	---@type {[string]: Seat}
	local seats = {}
	for _, loc in ipairs(seatLocs) do
		seats[loc] = lib.Seat:new(false, loc)
	end
	local actual = seats["3-3"]:findAdjacents(seats)

	local expectedLocs = {
		["1-1"] = true,
		["1-3"] = true,
		["1-5"] = true,
		["3-4"] = true,
		["4-4"] = true,
		["4-3"] = true,
		["5-1"] = true,
		["3-2"] = true,
	}
	lu.assertEquals(utils.arrayToSet(utils.keysToArray(actual)), expectedLocs)
end

function TestFindAdjacentsTopRightCorner()
	local seatLocs = {
		"3-3",
		"1-1",
		"1-2",
		"1-3",
		"1-5", -- This is the seat to find adjacents
		"3-4",
		"3-5",
		"4-4",
		"4-3",
		"5-5",
		"5-3",
		"5-1",
		"3-1",
		"3-2",
	}
	---@type {[string]: Seat}
	local seats = {}
	for _, loc in ipairs(seatLocs) do
		seats[loc] = lib.Seat:new(false, loc)
	end
	local actual = seats["1-5"]:findAdjacents(seats)

	local expectedLocs = {
		["1-3"] = true,
		["3-3"] = true,
		["3-5"] = true,
	}
	lu.assertEquals(utils.arrayToSet(utils.keysToArray(actual)), expectedLocs)
end

function TestPart2States()
	local lines = utils.ingest("day11/test.txt")
	local wa = lib.WaitingArea2:new(lines)
	local expecteds = {
		utils.ingest("day11/p2state1.txt"),
		utils.ingest("day11/p2state2.txt"),
	}
	for iexps, expected in ipairs(expecteds) do
		wa:toggle()
		if iexps == 2 then
			local expectedAdjacents = { "1-1", "1-4", "2-2", "2-3", "2-4" }
			lu.assertEquals(
				utils.arrayToSet(utils.keysToArray(wa.seats["1-3"].adjacent)),
				utils.arrayToSet(expectedAdjacents)
			)
			expectedAdjacents = { "1-9", "2-9", "2-10" }
			lu.assertEquals(
				utils.arrayToSet(utils.keysToArray(wa.seats["1-10"].adjacent)),
				utils.arrayToSet(expectedAdjacents)
			)
		end
		for index, value in ipairs(wa:serialize()) do
			lu.assertEquals(index .. value, index .. expected[index])
		end
	end
end

function TestPart2()
	lu.assertEquals(lib.part2("day11/test.txt"), 26)
end

os.exit(lu.LuaUnit.run())
