local lu = require("luaunit")
local lib = require("day10.lib")

function TestCountDiffs()
	local nums = {1, 6, 9, 12, 15, 16, 18, 20}
	local expected = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[5] = 1,
	}
	lu.assertEquals(lib.countDiffs(nums), expected)
end

function TestPart1()
	lu.assertEquals(lib.part1("day10/test.txt"), 220)
end

function TestPart2Basic()
	lu.assertEquals(lib.part2("day10/test2.txt"), 8)
end

function TestPart2()
	lu.assertEquals(lib.part2("day10/test.txt"), 19208)
end

os.exit(lu.LuaUnit.run())
