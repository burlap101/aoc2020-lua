local lu = require "luaunit"
local lib = require "day4.lib"

function TestTrim()
	-- Test cases
	local tcs = {
		"Hello   World!",
		"Hello\nWorld!",
		"Hello World!   ",
		"\nHello\nWorld!",
	}
	for _, tc in pairs(tcs) do
		lu.assertEquals(lib.trim(tc), "Hello World!")
	end
end

function TestExtractPassport()
	local s = "byr:1985 hgt:arst"
	lu.assertEquals(lib.extractPassport(s), { byr = "1985", hgt = "arst" })
end

function TestGetPassports()
	local lines = {
		"byr:1985",
		"hgt:arst",
		" \n",
		"byr:1984",
		"cid:tsar",
	}
	local expected = {
		{byr="1985", hgt="arst"},
		{byr="1984", cid="tsar"},
	}
	lu.assertEquals(lib.getPassports(lines), expected)
end

function TestPart1()
	lu.assertEquals(lib.part1("day4/test.txt"), 2)
end

function TestYearValidator()
	lu.assertTrue(lib.yearValidator("2020", 2020, 2020))
	lu.assertFalse(lib.yearValidator("12", 12, 12))
end

function TestHeightValidator()
	lu.assertTrue(lib.heightValidator("155cm"))
	lu.assertFalse(lib.heightValidator("70cm"))
	lu.assertFalse(lib.heightValidator("155in"))
	lu.assertTrue(lib.heightValidator("70in"))
	lu.assertFalse(lib.heightValidator("seventy in"))
end

function TestHairColorValidator()
	lu.assertTrue(lib.hairColorValidator("#arst12"))
	lu.assertTrue(lib.hairColorValidator("#123456"))
	lu.assertFalse(lib.hairColorValidator("123456"))
	lu.assertFalse(lib.hairColorValidator("#arst123"))
end

function TestEyeColorValidator()
	lu.assertTrue(lib.eyeColorValidator("blu"))
	lu.assertTrue(lib.eyeColorValidator("gry"))
	lu.assertFalse(lib.eyeColorValidator("blue"))
	lu.assertFalse(lib.eyeColorValidator("pnk"))
end

function TestPart2()
	lu.assertEquals(lib.part2("day4/test_pt2_valid.txt"), 4)
	lu.assertEquals(lib.part2("day4/test_pt2_invalid.txt"), 0)
end

os.exit(lu.LuaUnit.run())
