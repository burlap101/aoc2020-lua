local lu = require("luaunit")
local lib = require("day9.lib")
local utils = require("utils")

function TestSum()
	lu.assertEquals(utils.sumArray({1,2,3,4}), 10)
end

---Tests the constructor of Summator
function TestSummatorNew()
	local nums = {}
	for i=1,5 do
		table.insert(nums, i)
	end
	local s = lib.Summator:new(nums)
	local esums = {
		[3]={1,2},
		[4]={1,3},
		[5]={1,4,2,3},
		[6]={1,5,2,4},
		[7]={2,5,3,4},
		[8]={3,5},
		[9]={4,5},
	}
	local expnums = {
		[1]={3,4,5,6},
		[2]={3,5,6,7},
		[3]={4,5,7,8},
		[4]={5,6,7,9},
		[5]={6,7,8,9},
	}
	lu.assertEquals(s.queue, nums)
	for i, ns in pairs(esums) do
		local nsmap = {}
		for _, n in ipairs(ns) do
			nsmap[n] = true
		end
		lu.assertEquals(s.sums[i], nsmap)
	end
	for i, ss in pairs(expnums) do
		local ssmap = {}
		for _, es in ipairs(ss) do
			ssmap[es] = true
		end
		lu.assertEquals(s.nums[i], ssmap)
	end
end

function TestSummatorAddNumber()
	local s = lib.Summator:new({1,2,3})
	s:addNumber(6)
	lu.assertNotIsNil(s.nums[6])
	lu.assertIsNil(s.nums[1])
end

function TestSummatorObjects()
	local s1 = lib.Summator:new({1,2})
	local s2 = lib.Summator:new({3,4})
	lu.assertFalse(s1 == s2)
end

function TestPart1()
	lu.assertEquals(lib.part1("day9/test.txt", 5), 127)
end

function TestPart2()
	lu.assertEquals(lib.part2("day9/test.txt", 127), 62)
end

os.exit(lu.LuaUnit.run())
