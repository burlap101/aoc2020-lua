local lib = require("day15.lib")
local lu = require("luaunit")

function TestGameNew()
	local game = lib.Game:new({0,3,6})
	lu.assertEquals(game.turn, 3)
	lu.assertEquals(game.lastSpoken, 6)
end

function TestGameTakeTurn()
	local game = lib.Game:new({0,3,6})
	game:takeTurn()
	lu.assertEquals(game.turn, 4)
	lu.assertEquals(game.lastSpoken, 0)
	game:takeTurn()
	lu.assertEquals(game.lastSpoken, 3)
end

function TestPart1()
	local numss = {
		{0,3,6}
	}
	for _, nums in ipairs(numss) do
		lu.assertEquals(lib.part1(nums), 436)
	end
end

function TestPart2()
	local numss = {
		{0,3,6}
	}
	for _, nums in ipairs(numss) do
		lu.assertEquals(lib.part2(nums), 175594)
	end
end


os.exit(lu.LuaUnit.run())
