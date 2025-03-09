local lu = require("luaunit")
local lib = require("day18.lib")

TestLexer = {}

function TestLexer:testNextToken()
	local input = "1 + 2 * (3 + 4)"

	---@class TestCaseTestLexerTestNextToken
	---@field expectedType TokenType
	---@field expectedLiteral string

	local testsArr = {
		{ lib.TokenType.INT,      "1" },
		{ lib.TokenType.PLUS,     "+" },
		{ lib.TokenType.INT,      "2" },
		{ lib.TokenType.ASTERISK, "*" },
		{ lib.TokenType.LPAREN,   "(" },
		{ lib.TokenType.INT,      "3" },
		{ lib.TokenType.PLUS,     "+" },
		{ lib.TokenType.INT,      "4" },
		{ lib.TokenType.RPAREN,   ")" },
	}

	---@type TestCaseTestLexerTestNextToken[]
	local tests = {}
	for _, tc in ipairs(testsArr) do
		---@type TestCaseTestLexerTestNextToken
		local tcase = {
			expectedType = tc[1],
			expectedLiteral = tc[2],
		}
		table.insert(tests, tcase)
	end

	local l = lib.Lexer:new(input)
	for _, tt in ipairs(tests) do
		local tok = l:nextToken()
		lu.assertEquals(tok.type, tt.expectedType)
		lu.assertEquals(tok.literal, tt.expectedLiteral)
	end
end

---Common tests for integer literals
---@param il ast.Expression
---@param value integer
local function testIntegerLiteral(il, value)
	lu.assertIsTrue(lib.IntegerLiteral:isInstance(il))
	local integ = il --[[@as ast.IntegerLiteral]]
	lu.assertEquals(integ.value, value)
	lu.assertEquals(integ:tokenLiteral(), tostring(value))
end

---Common tests for infix expressions
---@param exp ast.Expression
---@param left any
---@param operator string
---@param right any
local function testInfixExpression(exp, left, operator, right)
	lu.assertIsTrue(lib.InfixExpression:isInstance(exp))
	local opExp = exp --[[@as ast.InfixExpression]]
	testIntegerLiteral(opExp.left, left)
	lu.assertEquals(opExp.operator, operator)
	testIntegerLiteral(opExp.right, right)
end

TestParser = {}

---Checks parser errors and generates lu failure
---@param p any
local function checkParserErrors(p)
	local errors = p.errors
	if #errors == 0 then
		return
	end
	local failMsg = "parser has " .. #errors .. " errors"
	for _, msg in ipairs(errors) do
		failMsg = failMsg .. "\nparser error: " .. msg
	end
	lu.fail(failMsg)
end

function TestParser:testIntegerLiteralExpression()
	local input = "5"
	local l = lib.Lexer:new(input)
	local p = lib.Parser:new(l)
	local stmt = p:parseExpressionStatement()
	checkParserErrors(p)

	lu.assertIsTrue(lib.IntegerLiteral:isInstance(stmt.expression))
	local literal = stmt.expression --[[@as ast.IntegerLiteral]]
	lu.assertEquals(literal.value, 5)
	lu.assertEquals(literal:tokenLiteral(), "5")
end

function TestParser:testParsingInfixExpressions()
	---@class TestCaseTestParserTestParsingInfixExpressions
	---@field input string
	---@field leftValue integer
	---@field operator string
	---@field rightValue integer

	local infixTestsArr = {
		{ "5 + 5", 5, "+", 5 },
		{ "5 * 5", 5, "*", 5 },
	}

	---@type TestCaseTestParserTestParsingInfixExpressions[]
	local infixTests = {}
	for _, tc in ipairs(infixTestsArr) do
		---@type TestCaseTestParserTestParsingInfixExpressions
		local testCase = {
			input = tc[1],
			leftValue = tc[2],
			operator = tc[3],
			rightValue = tc[4],
		}
		table.insert(infixTests, testCase)
	end

	for _, tt in ipairs(infixTests) do
		local l = lib.Lexer:new(tt.input)
		local p = lib.Parser:new(l)
		local stmt = p:parseExpressionStatement()
		checkParserErrors(p)

		lu.assertIsTrue(lib.InfixExpression:isInstance(stmt.expression))
		local exp = stmt.expression --[[@as ast.InfixExpression]]
		testInfixExpression(exp, tt.leftValue, tt.operator, tt.rightValue)
	end
end

function TestParser:testOperatorPrecedenceParsing()
	---@class TestCaseTestParserTestOperatorPrecedenceParsing
	---@field input string
	---@field expected string

	local testsArr = {
		{
			"1 + 2 * 3",
			"((1 + 2) * 3)"
		},
		{
			"1 * (2 + 3)",
			"(1 * (2 + 3))"
		}
	}

	---@type TestCaseTestParserTestOperatorPrecedenceParsing[]
	local tests = {}
	for _, tc in ipairs(testsArr) do
		---@type TestCaseTestParserTestOperatorPrecedenceParsing
		local test = {
			input = tc[1],
			expected = tc[2],
		}
		table.insert(tests, test)
	end

	for _, tt in ipairs(tests) do
		local l = lib.Lexer:new(tt.input)
		local p = lib.Parser:new(l)
		local stmt = p:parseExpressionStatement()
		checkParserErrors(p)
		local actual = stmt:toString()
		lu.assertEquals(actual, tt.expected)
	end
end

TestEvaluator = {}

---Tests eval
---@param input string
---@return object.Object?
local function testEval(input)
	local l = lib.Lexer:new(input)
	local p = lib.Parser:new(l)
	local stmt = p:parseExpressionStatement()
	return lib.eval(stmt)
end

---Test integer object
---@param obj any
---@param expected any
local function testIntegerObject(obj, expected)
	lu.assertIsTrue(lib.Integer:isInstance(obj))
	local result = obj --[[@as object.Integer]]
	lu.assertEquals(result.value, expected)
end

function TestEvaluator:testEvalIntegerExpression()
	---@class TestCaseTestEvaluatorTestEvalIntegerExpression
	---@field input string
	---@field expected integer

	---@type TestCaseTestEvaluatorTestEvalIntegerExpression[]
	local tests = {
		{ input = "5",         expected = 5 },
		{ input = "10",        expected = 10 },
		{ input = "5+5+5+5",   expected = 20 },
		{ input = "2*2*2*2*2", expected = 32 },
		{ input = "5+2*10",    expected = 70 },
		{ input = "5*2+10",    expected = 20 },
		{ input = "2*(5+10)",  expected = 30 },
	}

	for _, tt in ipairs(tests) do
		local evaluated = testEval(tt.input)
		testIntegerObject(evaluated, tt.expected)
	end
end

TestParts = {}

---Tests part1 result
function TestParts:testPart1()
	lu.assertEquals(lib.part1("day18/test.txt"), 13632)
end

---Tests part2 result
function TestParts:testPart2()
	lu.assertEquals(lib.part2("day18/test.txt"), 23340)
end

os.exit(lu.LuaUnit.run())
