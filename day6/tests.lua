local lu = require "luaunit"
local lib = require "day6.lib"

function TestGetGroups()
	local lines = {
		"abc",
		"a",
		"",
		"xyz",
		"    ",
		"h",
		"",
	}
	local expected = {
		{ "abc", "a" },
		{ "xyz" },
		{ "h" },
	}
	lu.assertEquals(lib.getGroups(lines), expected)
end

function TestGetGroupSet()
	local group = {"abc", "a", "d",}
	local expected = {["a"]=true, ["b"]=true, ["c"]=true, ["d"]=true}

	lu.assertEquals(lib.getGroupSet(group), expected)
end

function TestPart1()
	lu.assertEquals(lib.part1("day6/test.txt"), 11)
end

function TestGroupIntersection()
	local group = {
		"abc",
		"ab",
		"bc",
	}
	lu.assertEquals(lib.groupIntersection(group), {["b"] = true})
end

function TestPart2()
	lu.assertEquals(lib.part2("day6/test.txt"), 6)
end


os.exit(lu.LuaUnit.run())
