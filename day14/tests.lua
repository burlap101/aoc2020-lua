local lu = require("luaunit")
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

os.exit(lu.LuaUnit.run())
