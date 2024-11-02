local lu = require "luaunit"
local lib = require "lib"

function TestSplitline()
	local input = "1-3 a: aaa"
	local res = lib.splitline(input)
	lu.assertEquals(res.password, "aaa")
	lu.assertEquals(res.character, "a")
	lu.assertEquals(res.min, 1)
	lu.assertEquals(res.max, 3)
end

function TestDoesConform()
	local result = lib.doesConform({password="aaa", character="a", min=1, max=3})
	lu.assertIsTrue(result)
	result = lib.doesConform({password="aaaa", character="a", min=1, max=3})
	lu.assertIsFalse(result)
	result = lib.doesConform({password="abcd", character="a", min=1, max=3})
	lu.assertIsTrue(result)
	result = lib.doesConform({password="bcde", character="a", min=1, max=3})
	lu.assertIsFalse(result)
end

function TestDoesConform2()
	local result = lib.doesConform2({password="aaa", character="a", min=1, max=3})
	lu.assertIsFalse(result)
	result = lib.doesConform2({password="aaaa", character="a", min=1, max=3})
	lu.assertIsFalse(result)
	result = lib.doesConform2({password="abcd", character="a", min=1, max=3})
	lu.assertIsTrue(result)
	result = lib.doesConform2({password="bcde", character="a", min=1, max=3})
	lu.assertIsFalse(result)
end

function TestIngest()
	local result = lib.ingest("test.txt")
	local expected = {
		{
			-- 1-3 a: abcde
			password="abcde",
			character="a",
			min=1,
			max=3,
		},
		{
			-- 1-3 b: cdefg
			password="cdefg",
			character="b",
			min=1,
			max=3,
		},
		{
			-- 2-9 c: ccccccccc
			password="ccccccccc",
			character="c",
			min=2,
			max=9,
		},
	}
	lu.assertEquals(result, expected)
end

function TestValidCount()
	local result1, result2 = lib.valid_count("test.txt")
	lu.assertEquals(result1, 2)
	lu.assertEquals(result2, 1)
end

os.exit(lu.LuaUnit.run())
