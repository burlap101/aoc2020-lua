local lu = require("luaunit")
local lib = require("day13.lib")
local utils = require("utils")
local mapm = require("mapm")

function TestGetBuses()
	local line = "7,13,x,x,59,x,31,19"
	local expected = {
		[7] = true,
		[13] = true,
		[59] = true,
		[31] = true,
		[19] = true,
	}
	lu.assertEquals(lib.getBuses(line), expected)
end

function TestPart1()
	lu.assertEquals(lib.part1("day13/test.txt"), 295)
end

function TestGCD()
	lu.assertEquals(lib.gcd(1071, 462), 21)
end

function TestLCM()
	lu.assertEquals(lib.lcm(21, 6), 42)
end

function TestFindForLCM()
	lu.assertEquals(lib.findForLCM(14, 2), 7)
end

function TestGetBusStagger()
	local line = "7,13,x,x,59,x,31,19"
	local expected = {7,14,63,37,26}
	lu.assertEquals(lib.getBusStagger(line), expected)
end

function TestSplit()
	local line = "7,13,x,x,59,x,31,19"
	local expected = {"7","13","x","x","59","x","31","19"}
	lu.assertEquals(utils.split(line, ","), expected)
end

function TestGetBusesIndexed()
	local line = "17,x,13,19"
	local buses = lib.getBusesIndexed(line)
	lu.assertEquals(buses, {17, -1, 13, 19})
end

function TestFindT()
	local line = "17,x,13,19"
	local buses = lib.getBusesIndexed(line)
	lu.assertEquals(lib.findT(buses), mapm.new(3417))
end

function TestSumMods()
	local bustimes = {
		[17] = 3417,
		[13] = 3419,
		[19] = 3420,
	}
	lu.assertEquals(lib.sumMods(bustimes), mapm.new(0))
end

function TestPart2()
	lu.assertEquals(lib.part2("day13/test.txt"), mapm.new(1068781))
end

os.exit(lu.LuaUnit.run())
