local lib = require("day19.lib")
local lu = require("luaunit")
local utils = require("utils")

TestDay19 = {}

function TestDay19.testCreateRule()
	local testsArr = {
		{ "0: 1 2",        lib.Rule:new { num = 0, left = { 1, 2 } } },
		{ '1: "a"',        lib.Rule:new { num = 1, value = "a" } },
		{ "20: 1 3 | 4 5", lib.Rule:new { num = 20, left = { 1, 3 }, right = { 4, 5 } } }
	}

	---@class TestCaseTestDay19TestCreateRule
	---@field input string
	---@field expected Rule

	---@type TestCaseTestDay19TestCreateRule[]
	local tests = {}

	for _, tc in ipairs(testsArr) do
		---@type TestCaseTestDay19TestCreateRule
		local tcase = {
			input = tc[1],
			expected = tc[2]
		}
		table.insert(tests, tcase)
	end

	for _, tt in ipairs(tests) do
		local actual = lib.createRule(tt.input)
		lu.assertEquals(actual, tt.expected)
	end
end

function TestDay19.testPart1()
	local count = lib.part1("day19/test.txt")
	lu.assertEquals(count, 2)
end

TestRule = {}
function TestRule.testToStrings()
	local testsArr = {
		{ lib.Rule:new { num = 0, left = { 1, 2 } },                     "1 2", nil },
		{ lib.Rule:new { num = 1, left = { 3, 4 }, right = { 55, 66 } }, "3 4", "55 66" }
	}

	for _, tc in ipairs(testsArr) do
		local left, right = tc[1]:toStrings()
		lu.assertEquals(left, tc[2])
		lu.assertEquals(right, tc[3])
	end
end

TestRuleSet = {}
function TestRuleSet.testAdd()
	local rules = {
		lib.Rule:new { num = 0, left = { 1, 2 }, right = { 3, 2 } },
		lib.Rule:new { num = 1, left = {}, right = {}, value = "a" },
		lib.Rule:new { num = 2, left = { 1, 1 }, right = { 3, 1 } },
		lib.Rule:new { num = 3, left = {}, right = {}, value = "b" },
	}
	local rs = lib.RuleSet:new {}
	for _, r in ipairs(rules) do
		rs:add(r.num, r)
	end
	local expectedRules = {}
	local expectedLeaves = {}
	for _, r in ipairs(rules) do
		expectedRules[r.num] = r
		if r.value ~= nil then
			expectedLeaves[r.num] = r.value
		end
	end
	local expected = lib.RuleSet:new { rules = expectedRules, leaves = expectedLeaves }
	lu.assertEquals(rs, expected)
end

TestResultStrings = {}
function TestResultStrings.testBreakdownAccLine()
	local rules = {
		lib.Rule:new { num = 0, left = { 1, 2 }, right = { 3, 2 } },
		lib.Rule:new { num = 1, left = {}, right = {}, value = "a" },
		lib.Rule:new { num = 2, left = { 1, 1 }, right = { 3, 1 } },
		lib.Rule:new { num = 3, left = {}, right = {}, value = "b" },
	}
	local rs = lib.RuleSet:new {}
	for _, r in ipairs(rules) do
		rs:add(r.num, r)
	end
	local acc = {
		{ 1, 2 },
		{ 3, 2 }
	}
	local expected = {
		{ 1, 1, 1 },
		{ 3, 2 },
		{ 1, 3, 1 },
	}
	local rstrs = lib.ResultStrings:new(rs)
	rstrs:breakdownAccLine(1, acc)
	lu.assertEquals(acc, expected)
end

function TestResultStrings.testGenerateStrings()
	local rules = {
		lib.Rule:new { num = 0, left = { 1, 2 }, right = { 3, 2 } },
		lib.Rule:new { num = 1, left = {}, right = {}, value = "a" },
		lib.Rule:new { num = 2, left = { 1, 1 }, right = { 3, 1 } },
		lib.Rule:new { num = 3, left = {}, right = {}, value = "b" },
	}
	local rs = lib.RuleSet:new {}
	for _, r in ipairs(rules) do
		rs:add(r.num, r)
	end
	local rstrs = lib.ResultStrings:new(rs)
	local expected = {
		["aaa"] = true,
		["baa"] = true,
		["aba"] = true,
		["bba"] = true
	}
	lu.assertEquals(rstrs.results, expected)
end

function TestResultStrings.testFromTestInput()
	---@class TestResultStrings.TestFromTestInput.TestCase
	---@field input string
	---@field expected boolean

	---@type TestResultStrings.TestFromTestInput.TestCase[]
	local tests = {
		{ input = "ababbb",  expected = true },
		{ input = "bababa",  expected = false },
		{ input = "abbbab",  expected = true },
		{ input = "aaabbb",  expected = false },
		{ input = "aaaabbb", expected = false }
	}

	-- Build RuleSet
	local rset = lib.RuleSet:new {}
	local lines = utils.ingest("day19/test.txt")
	for _, line in ipairs(lines) do
		if not string.find(line, ":") then
			break
		end
		local rule = lib.createRule(line)
		rset:add(rule.num, rule)
	end

	-- Build ResultStrings
	local rstrs = lib.ResultStrings:new(rset)

	for _, tt in ipairs(tests) do
		lu.assertEquals(rstrs.results[tt.input] or false, tt.expected)
	end
end


os.exit(lu.LuaUnit.run())
