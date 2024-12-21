local lu = require("luaunit")
local utils = require("utils")
local lib = require("day16.lib")

function TestGetFields()
	local lines = {
		"class: 1-2 or 3-4",
		"some thing: 5-6 or 7-81",
		"",
		"another line: 9-10 or 11-12",
	}
	local expected = {
		["class"] = {
			fst = {
				lo = 1,
				hi = 2,
			},
			snd = {
				lo = 3,
				hi = 4,
			}
		},
		["some thing"] = {
			fst = {
				lo = 5,
				hi = 6,
			},
			snd = {
				lo = 7,
				hi = 81,
			}
		}
	}
	lu.assertEquals(lib.getFields(lines), expected)
end

function TestGetTickets()
	local lines = {
		"nearby tickets:",
		"1,2,3",
		"44,55,66",
	}
	local expected = {
		{ 1,  2,  3 },
		{ 44, 55, 66 },
	}
	lu.assertEquals(lib.getNearbyTickets(lines), expected)
end

function TestCheckTicket()
	local lines = {
		"class: 1-2 or 3-4",
		"some thing: 5-6 or 7-81",
		"",
		"your ticket:",
		"7,1,14",
		"",
		"nearby tickets:",
		"1,2,3",
		"44,55,99",
	}
	local expected = { 99 }
	local chkr = lib.Checker:new(lines)
	lu.assertEquals(chkr:checkTicket({ 44, 55, 99 }), expected)
end

function TestPart1()
	lu.assertEquals(lib.part1("day16/test.txt"), 71)
end

function TestGetMyTicket()
	local lines = {
		"seat: 13-40 or 45-50",
		"",
		"your ticket:",
		"7,1,14",
		"",
		"nearby tickets:",
		"7,3,47",
	}
	lu.assertEquals(lib.getMyTicket(lines), { 7, 1, 14 })
end

function TestDetermineFields()
	local lines = utils.ingest("day16/test2.txt")
	local chkr = lib.Checker:new(lines)
	lu.assertEquals(chkr:determineFields(), {"row","class","seat"})
end

os.exit(lu.LuaUnit.run())
