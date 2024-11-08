local lu = require "luaunit"
local lib = require "day5.lib"

function TestFindRow()
	local result = lib.findRow("FBFBBFF")
	lu.assertEquals(result, 44)
end

function TestFindSeat()
	local result = lib.findSeat("RLR")
	lu.assertEquals(result, 5)
end

function TestSeatID()
	local tcs = {
		{ s = "BFFFBBFRRR", id = 567 },
		{ s = "FFFBBBFRRR", id = 119 },
		{ s = "BBFFBBFRLL", id = 820 },
	}
	for _, tc in ipairs(tcs) do
		lu.assertEquals(lib.seatID(tc.s), tc.id)
	end
end

os.exit(lu.LuaUnit.run())
