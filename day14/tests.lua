local lu = require("luaunit")
local utils = require("utils")
local lib = require("day14.lib")

function TestGetAndMask()
	lu.assertEquals(lib.getAndMask({16,32}), 66571960319)
end

function TestGetOrMask()
	local expected = (1 << 15) | (1 << 31)
	lu.assertEquals(lib.getOrMask({16,32}), expected)
end

function TestRunnerDoMask()
	local r = lib.Runner:new({"mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"})
	lu.assertEquals(r:doMask(8,11), 73)
	lu.assertEquals(r.memory, {[8]=73})
end

function TestPart1()
	lu.assertEquals(lib.part1("day14/test.txt"), 165)
end

function TestAndOrMasksFromAnys()
	local anys = {1,3}
	local ands, ors = lib.andOrMasksFromAnys(anys)
	lu.assertEquals(#ors, 4)
	lu.assertEquals(utils.arrayToSet(ors), utils.arrayToSet{
		tonumber(string.rep("0", 36), 2),
		tonumber(string.rep("0", 35).."1", 2),
		tonumber(string.rep("0", 33).."100", 2),
		tonumber(string.rep("0", 33).."101", 2),
	})
	lu.assertEquals(#ands, 4)
end

function TestMemRunnerDoMask()
	local lines = {
		"mask = 000000000000000000000000000000X1001X",
		"mem[42] = 100"
	}
	local mr = lib.MemRunner:new(lines)
	local expectedMemories = utils.arrayToSet({26, 27, 58, 59})
	lu.assertEquals(utils.arrayToSet(mr:doMask(42, 100)), expectedMemories)
end

function TestPart2()
	lu.assertEquals(lib.part2("day14/test2.txt"), 208)
end

os.exit(lu.LuaUnit.run())
