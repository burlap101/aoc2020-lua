local lu = require "luaunit"
local lib = require "day8.lib"

function TestParseLine()
	local testCases = {
		["nop"] = { op = "nop", value = nil },
		["acc +1"] = { op = "acc", value = 1 },
		["jmp -5"] = { op = "jmp", value = -5 },
	}
	for line, expected in pairs(testCases) do
		lu.assertEquals(lib.parseLine(line), expected)
	end
end

function TestPart1()
	lu.assertEquals(lib.part1("day8/test.txt"), 5)
end

function TestPart2()
	lu.assertEquals(lib.part2("day8/test.txt"), 8)
end

os.exit(lu.LuaUnit.run())
