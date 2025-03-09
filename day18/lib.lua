local M = {}
local utils = require("utils")

---Determines if char is a digit
---@param ch any
---@return boolean
local function isDigit(ch)
	if string.match(ch, "[0-9]") then
		return true
	end
	return false
end

---@enum TokenType
local TokenType = {
	ILLEGAL = "ILLEGAL",
	EOF = "EOF",
	INT = "INT",
	PLUS = "+",
	ASTERISK = "*",
	LPAREN = "(",
	RPAREN = ")",
}
M.TokenType = TokenType

---@class Token
---@field type TokenType
---@field literal string
local Token = {}
M.Token = Token

---Constructor for a Token
---@param t Token
---@return Token
function Token:new(t)
	t = setmetatable(t or {}, { __index = self })
	return t
end

---@class Lexer
---@field input string
---@field position integer
---@field readPosition integer
---@field ch string
local Lexer = {}
M.Lexer = Lexer

---Constructor for a Lexer
---@param input string
---@return Lexer
function Lexer:new(input)
	local l = setmetatable({}, { __index = self })
	l.input = input
	l.readPosition = 1
	l.position = 1
	l.ch = ""
	l:readChar()
	return l
end

---Progresses the lexer to the next char
function Lexer:readChar()
	if self.readPosition > string.len(self.input) then
		self.ch = ""
	else
		self.ch = string.sub(self.input, self.readPosition, self.readPosition)
	end
	self.position = self.readPosition
	self.readPosition = self.readPosition + 1
end

---Reads a number from the input
---@return string
function Lexer:readNumber()
	local position = self.position
	while isDigit(self.ch) do
		self:readChar()
	end
	return string.sub(self.input, position, self.position - 1)
end

---Returns the next char in the input without incrementing position
---@return string
function Lexer:peekChar()
	if self.readPosition > string.len(self.input) then
		return ""
	end
	return string.sub(self.input, self.readPosition, self.readPosition)
end

---Skips whitespace on the inputs
function Lexer:skipWhitespace()
	while string.match(self.ch, "[ \t\n\r]") do
		self:readChar()
	end
end

---Retrieves next token and progresses Lexer
---@return Token
function Lexer:nextToken()
	---@type Token
	local tok
	self:skipWhitespace()
	if self.ch == "+" then
		tok = Token:new { type = TokenType.PLUS, literal = self.ch }
	elseif self.ch == "*" then
		tok = Token:new { type = TokenType.ASTERISK, literal = self.ch }
	elseif self.ch == "(" then
		tok = Token:new { type = TokenType.LPAREN, literal = self.ch }
	elseif self.ch == ")" then
		tok = Token:new { type = TokenType.RPAREN, literal = self.ch }
	else
		if isDigit(self.ch) then
			tok = Token:new { type = TokenType.INT, literal = self:readNumber() }
			-- Early exit necessary as we progress readPosition past last
			-- character of the number
			return tok
		else
			tok = Token:new { type = TokenType.ILLEGAL, self.ch }
		end
	end
	self:readChar()
	return tok
end

---@class ast.Node
---@field metatable table
local Node = {}
M.Node = Node

function Node:tokenLiteral()
	error("not implemented")
end

---Determines if object is of correct type
---@param obj table
---@return boolean
function Node:isInstance(obj)
	return getmetatable(obj) == self.metatable
end

---@class ast.Expression:ast.Node
local Expression = utils.inheritsFrom(Node)
M.Expression = Expression

---@class ast.Statement:ast.Node
local Statement = utils.inheritsFrom(Node)
M.Statement = Statement

---@class ast.ExpressionStatement:ast.Statement
---@field token Token
---@field expression ast.Expression?
local ExpressionStatement = utils.inheritsFrom(Statement)
ExpressionStatement.metatable = {
	__index = ExpressionStatement,
	__tostring = function(t)
		return t:toString()
	end
}
M.ExpressionStatement = ExpressionStatement

---Constructor for an ExpressionStatement
---@param es ast.ExpressionStatement
---@return ast.ExpressionStatement
function ExpressionStatement:new(es)
	es = setmetatable(es or {}, self.metatable)
	return es
end

---String representation of the ExpressionStatement
---@return string
function ExpressionStatement:toString()
	if self.expression then
		return tostring(self.expression)
	end
	return ""
end

---Getter for token.literal
---@return string
function ExpressionStatement:tokenLiteral()
	return self.token.literal
end

---@class ast.IntegerLiteral:ast.Expression
---@field token Token
---@field value integer
local IntegerLiteral = utils.inheritsFrom(Expression)
IntegerLiteral.metatable = {
	__index = IntegerLiteral,
	__tostring = function(t)
		return t:toString()
	end
}
M.IntegerLiteral = IntegerLiteral

---Constructor for IntegerLiteral
---@param il ast.IntegerLiteral
---@return ast.IntegerLiteral
function IntegerLiteral:new(il)
	il = setmetatable(il or {}, self.metatable)
	return il
end

---Getter for token.literal
---@return string
function IntegerLiteral:tokenLiteral()
	return self.token.literal
end

---String representation of integer literal
---@return string
function IntegerLiteral:toString()
	return self.token.literal
end

---@class ast.InfixExpression:ast.Expression
---@field token Token  the operator token e.g. +
---@field left ast.Expression
---@field operator string
---@field right ast.Expression?
local InfixExpression = utils.inheritsFrom(Expression)
InfixExpression.metatable = {
	__index = InfixExpression,
	__tostring = function(t)
		return t:toString()
	end
}
M.InfixExpression = InfixExpression

---Constructor for InfixExpression
---@param ie ast.InfixExpression
---@return ast.InfixExpression
function InfixExpression:new(ie)
	ie = setmetatable(ie or {}, self.metatable)
	return ie
end

---Getter for token.literal
---@return string
function InfixExpression:tokenLiteral()
	return self.token.literal
end

function InfixExpression:toString()
	local out = ""
	out = out .. "("
	out = out .. tostring(self.left)
	out = out .. " " .. self.operator .. " "
	if not pcall(tostring, self.right) then
		print(self.right:tokenLiteral())
	end
	out = out .. tostring(self.right)
	out = out .. ")"
	return out
end

---@enum Precedence
local Precedence = {
	LOWEST = 1,
	SUM = 4,
	PRODUCT = 4, -- Setting to same precedence as SUM (part1)
	CALL = 7,
}
M.Precedence = Precedence

---@type {[TokenType]: Precedence}
local precedences = {
	[TokenType.PLUS] = Precedence.SUM,
	[TokenType.ASTERISK] = Precedence.PRODUCT,
	[TokenType.LPAREN] = Precedence.CALL,
}

---@alias PrefixParseFn fun(): ast.Expression?
---@alias InfixParseFn fun(e: ast.Expression?): ast.Expression?

---@class Parser
---@field lexer Lexer
---@field curToken Token
---@field peekToken Token
---@field errors string[]
---@field prefixParseFns {[TokenType]: PrefixParseFn}
---@field infixParseFns {[TokenType]: InfixParseFn}
local Parser = {}
M.Parser = Parser

function Parser:new(lexer)
	local p = setmetatable({}, { __index = self })
	p.lexer = lexer
	p.errors = {}

	-- Progress parser two steps
	p:nextToken()
	p:nextToken()

	-- Declare and register all prefix functions
	p.prefixParseFns = {}
	p:registerPrefix(TokenType.INT, p:parseIntegerLiteral())
	p:registerPrefix(TokenType.LPAREN, p:parseGroupedExpression())

	-- Declare and register infix functions
	p.infixParseFns = {}
	p:registerInfix(TokenType.PLUS, p:parseInfixExpression())
	p:registerInfix(TokenType.ASTERISK, p:parseInfixExpression())

	return p
end

---IntegerLiteral prefix parse function
---@return PrefixParseFn
function Parser:parseIntegerLiteral()
	return function()
		local lit = IntegerLiteral:new { token = self.curToken }
		local numValue = tonumber(self.curToken.literal)
		local success, value = pcall(math.floor, numValue)
		if not success then
			local msg = "could not parse " .. self.curToken.literal .. " as integer"
			table.insert(self.errors, msg)
			return nil
		end
		lit.value = value
		return lit
	end
end

---Registers a prefix parse function for the parser
---@param tt TokenType
---@param fn PrefixParseFn
function Parser:registerPrefix(tt, fn)
	self.prefixParseFns[tt] = fn
end

---Registers an infix parse function for the parser
---@param tt any
---@param fn any
function Parser:registerInfix(tt, fn)
	self.infixParseFns[tt] = fn
end

---Getter for errors
---@return string[]
function Parser:getErrors()
	return self.errors
end

---Set tokens and progress lexer
function Parser:nextToken()
	self.curToken = self.peekToken
	self.peekToken = self.lexer:nextToken()
end

---Parse an expression statement
---@return ast.ExpressionStatement
function Parser:parseExpressionStatement()
	local stmt = ExpressionStatement:new { token = self.curToken }
	stmt.expression = self:parseExpression(Precedence.LOWEST)
	return stmt
end

---Adds the error to the parser
---@param t any
function Parser:noPrefixParseFnError(t)
	local msg = "no prefix parse function for " .. tostring(t) .. " found"
	table.insert(self.errors, msg)
end

---Determines the precedence of the parser's peekToken
---@return integer|Precedence
function Parser:peekPrecedence()
	local p = precedences[self.peekToken.type]
	if p ~= nil then
		return p
	end
	return Precedence.LOWEST
end

function Parser:parseExpression(precedence)
	local prefix = self.prefixParseFns[self.curToken.type]
	if prefix == nil then
		self:noPrefixParseFnError(self.curToken.type)
		return nil
	end
	local leftExp = prefix()
	while precedence < self:peekPrecedence() do
		local infix = self.infixParseFns[self.peekToken.type]
		if infix == nil then
			return leftExp
		end
		self:nextToken()
		leftExp = infix(leftExp)
	end
	return leftExp
end

---Determines the precedence of the parser's curToken
---@return Precedence
function Parser:curPrecedence()
	local p = precedences[self.curToken.type]
	if p ~= nil then
		return p
	end
	return Precedence.LOWEST
end

---Parses an infix expression e.g. 5 + 5
---@return InfixParseFn
function Parser:parseInfixExpression()
	return function(left)
		local expression = InfixExpression:new {
			token = self.curToken,
			operator = self.curToken.literal,
			left = left,
		}
		local precedence = self:curPrecedence()
		self:nextToken()
		expression.right = self:parseExpression(precedence)
		return expression
	end
end

---Handles the peek error and inserts it into parser errors
---@param tt any
function Parser:peekError(tt)
	local msg = "expected next token to be " .. tt .. " got " .. self.peekToken .. " instead"
	table.insert(self.errors, msg)
end

---Determines if supplied token type matches peek token type
---@param t TokenType
---@return boolean
function Parser:peekTokenIs(t)
	return self.peekToken.type == t
end

---Determines if the next token is the one expected
---@param t TokenType
---@return boolean
function Parser:expectPeek(t)
	if self:peekTokenIs(t) then
		self:nextToken()
		return true
	else
		self:peekError(t)
		return false
	end
end

---Parenthesised expression parsing function
---@return PrefixParseFn
function Parser:parseGroupedExpression()
	return function()
		self:nextToken()
		local exp = self:parseExpression(Precedence.LOWEST)
		if not self:expectPeek(TokenType.RPAREN) then
			return nil
		end
		return exp
	end
end

---@alias object.ObjectType string

---@enum ObjectTypes
local ObjectTypes = {
	INTEGER_OBJ = "INTEGER",
	ERROR_OBJ = "ERROR",
}
M.ObjectTypes = ObjectTypes

---@class object.Object
---@field metatable fun(obj: table): boolean
local Object = {}
Object.metatable = nil
M.Object = Object

---ABC method
---@return object.ObjectType
function Object:type()
	error("not implemented")
end

---ABC method
---@return string
function Object:inspect()
	error("not implemented")
end

---Common method for determining if an object is an instance of another
---@param obj table
---@return boolean
function Object:isInstance(obj)
	return getmetatable(obj) == self.metatable
end

---@class object.Integer:object.Object
---@field value integer
local Integer = utils.inheritsFrom(Object)
Integer.metatable = {
	__index = Integer
}
M.Integer = Integer

---comment
---@param i object.Integer
---@return object.Integer
function Integer:new(i)
	i = setmetatable(i or {}, self.metatable)
	return i
end

---Gets the integer as string
---@return string
function Integer:inspect()
	return tostring(self.value)
end

---Returns object type
---@return object.ObjectType
function Integer:type()
	return ObjectTypes.INTEGER_OBJ
end

---@class object.Error:object.Object
---@field message string
local Error = utils.inheritsFrom(Object)
Error.metatable = {
	__index = Error,
}
M.Error = Error

---Constructor for Error object
---@param e object.Error
---@return object.Error
function Error:new(e)
	e = setmetatable(e or {}, self.metatable)
	return e
end

---Getter for object type
---@return string
function Error:type()
	return ObjectTypes.ERROR_OBJ
end

---String representation of the error
---@return string
function Error:inspect()
	return "ERROR: " .. self.message
end

---Determines if objct is an Error
---@param obj object.Object?
---@return boolean
local function isError(obj)
	if obj ~= nil then
		return obj:type() == ObjectTypes.ERROR_OBJ
	end
	return false
end
M.isError = isError

---Creates a new Error obj
---@param format string
---@param ... unknown
---@return object.Error
local function newError(format, ...)
	return Error:new { message = string.format(format, ...) }
end
M.newError = newError

---Handles eval of expressions
---@param exps ast.Expression[]
---@return object.Object[]
local function evalExpressions(exps)
	---@type object.Object[]
	local result = {}

	for _, e in ipairs(exps) do
		local evaluated = M.eval(e)
		if isError(evaluated) then
			return { evaluated }
		end
		table.insert(result, evaluated)
	end
	return result
end

---Evals integer infix expressions
---@param operator string
---@param left object.Object
---@param right object.Object
---@return object.Integer|object.Error
local function evalIntegerInfixExpression(operator, left, right)
	local l = left --[[@as object.Integer]]
	local leftVal = l.value
	local r = right --[[@as object.Integer]]
	local rightVal = r.value

	if operator == "+" then
		return Integer:new { value = leftVal + rightVal }
	elseif operator == "*" then
		return Integer:new { value = leftVal * rightVal }
	end
	return newError(
		"unknown operator: %s %s %s",
		left:type(),
		operator,
		right:type()
	)
end

---Determines if valid infix expression then forwards it onto the integer infix expression eval
---@param operator string
---@param left object.Object
---@param right object.Object
---@return object.Error|object.Integer
local function evalInfixExpression(operator, left, right)
	if left:type() == ObjectTypes.INTEGER_OBJ and right:type() == ObjectTypes.INTEGER_OBJ then
		return evalIntegerInfixExpression(operator, left, right)
	elseif left:type() ~= right:type() then
		return newError(
			"type mismatch: %s %s %s",
			left:type(),
			operator,
			right:type()
		)
	end
	return newError(
		"unknown operator: %s %s %s",
		left:type(),
		operator,
		right:type()
	)
end

---Main eval function
---@param node any
---@return object.Object?
local function eval(node)
	if ExpressionStatement:isInstance(node) then
		local es = node --[[@as ast.ExpressionStatement]]
		return eval(es.expression)
	elseif IntegerLiteral:isInstance(node) then
		local intLit = node --[[@as ast.IntegerLiteral]]
		return Integer:new { value = intLit.value }
	elseif InfixExpression:isInstance(node) then
		local n = node --[[@as ast.InfixExpression]]
		local left = eval(n.left)
		assert(left)
		if isError(left) then
			return left
		end
		local right = eval(n.right)
		assert(right)
		if isError(right) then
			return right
		end
		return evalInfixExpression(n.operator, left, right)
	end
	return nil
end
M.eval = eval

---Setup lexer and parser and invoke eval
---@param input any
---@return object.Object?
local function performEval(input)
	local l = Lexer:new(input)
	local p = Parser:new(l)
	local stmt = p:parseExpressionStatement()
	return eval(stmt)
end

---Perform all operations necessary for part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local result = 0
	for _, l in ipairs(lines) do
		local evaluated = performEval(l)
		assert(evaluated)
		if not Integer:isInstance(evaluated) then
			error("got a non integer of type " .. evaluated:type() .. " with value " .. evaluated:inspect())
		end
		local integ = evaluated --[[@as object.Integer]]
		result = result + integ.value
	end
	return result
end
M.part1 = part1

---Performs all operations necessary for part2
---@param filename string
---@return integer
local function part2(filename)
	-- Just need to alter the precedence of the "+" token type
	precedences[TokenType.PLUS] = 5
	return part1(filename)
end
M.part2 = part2

return M
