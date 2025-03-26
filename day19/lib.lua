local utils = require("utils")
local lu = require("luaunit")
local M = {}

---@class Rule
---@field left integer[]
---@field right integer[]
---@field parents {[integer]: true}
---@field num integer
---@field value string?
local Rule = {}
M.Rule = Rule

---Constructor for a rule
---@param r Rule
---@return Rule
function Rule:new(r)
	assert(r.num)
	r = setmetatable(r or {}, { __index = self })
	r.left = r.left or {}
	r.right = r.right or {}
	r.parents = r.parents or {}
	return r
end

function Rule:addParent(parentIdx)
	self.parents[parentIdx] = true
end

---Creates raw rule strings from Rule
---@return string?
---@return string?
function Rule:toStrings()
	local left
	if #self.left > 0 then
		left = table.concat(self.left, " ")
	end
	local right
	if #self.right > 0 then
		right = table.concat(self.right, " ")
	end
	return left, right
end

---@class RuleSet
---@field rules {[integer]: Rule}
---@field leaves {[integer]: string}
local RuleSet = {}
M.RuleSet = RuleSet

---Constructor for a set of Rules
---@param rs RuleSet
---@return RuleSet
function RuleSet:new(rs)
	rs = setmetatable(rs or {}, { __index = self })
	rs.rules = rs.rules or {}
	rs.leaves = rs.leaves or {}
	return rs
end

---Add the rule to the rules
---@param idx integer
---@param rule Rule
function RuleSet:add(idx, rule)
	self.rules[idx] = rule
	if rule.value then
		self.leaves[idx] = rule.value
	end
end

---Populates parent field of corresponding rule left and right fields
---@param idx integer
function RuleSet:addParents(idx)
	local rule = self.rules[idx]
	for _, jdx in ipairs(rule.left) do
		self.rules[jdx]:addParent(idx)
	end
	for _, jdx in ipairs(rule.right) do
		self.rules[jdx]:addParent(idx)
	end
end

---@class ResultStrings
---@field results {[string]: true}
---@field ruleSet RuleSet
local ResultStrings = {}
M.ResultStrings = ResultStrings

---Constructor for a ResultStrings object
---@param ruleSet RuleSet
---@return ResultStrings
function ResultStrings:new(ruleSet)
	local rs = setmetatable({}, { __index = self })
	rs.results = rs.results or {}
	rs.ruleSet = ruleSet
	rs:generateRuleStrings()
	return rs
end

---Generates the rulestrings
---@private
function ResultStrings:generateRuleStrings()
	print("Generating full string list.... ")
	---@type integer[][]
	local acc = {}
	-- Start at 0 and then begin adding rules
	local r = self.ruleSet.rules[0]
	table.insert(acc, { table.unpack(r.left) })
	if r.right ~= nil then
		table.insert(acc, { table.unpack(r.right) })
	end
	for idx in ipairs(acc) do
		self:breakdownAccLine(idx, acc)
	end
	for _, entry in ipairs(acc) do
		local estr = ""
		for _, rnum in ipairs(entry) do
			estr = estr .. self.ruleSet.rules[rnum].value
		end
		self.results[estr] = true
	end
	print()
end

---@enum Side
local Side = {
	left = 1,
	right = 2,
}
M.Side = Side


---Breaks down an accumulator entry into leaves only.
---Adds new arrays to be evaluated as new entries to acc
---@param idx integer location in accumulator being expanded
---@param acc number[][]
function ResultStrings:breakdownAccLine(idx, acc)
	local i = 1
	while i ~= #acc[idx] + 1 do
		local nexti = i + 1
		local entry = { table.unpack(acc[idx]) }
		local rule = self.ruleSet.rules[entry[i]]
		if #rule.left > 0 then
			acc[idx] = utils.insertListInList(entry, i, rule.left)
			-- Remove substituted rule
			table.remove(acc[idx], i + #rule.left)
			-- Go back to start and reevaluate
			nexti = 1
		end
		if #rule.right > 0 then
			local newEntry = utils.insertListInList(entry, i, rule.right)
			-- Remove substituted rule
			table.remove(newEntry, i + #rule.right)
			-- Add to the accumulator
			table.insert(acc, newEntry)
		end
		i = nexti
		io.write("Accumulator size: "..#acc.."              \r")
	end
end

---Takes a rule line and creates a rule object
---@param line string
---@return Rule
local function createRule(line)
	---Splits string of nums and returns numarray
	---@param s string
	---@return integer[]
	local function numArray(s)
		local res = {}
		for sNum in string.gmatch(s, "%d+") do
			table.insert(res, tonumber(sNum))
		end
		return res
	end
	local colonSplit = utils.split(line, ":")
	local ruleNum = tonumber(colonSplit[1])
	assert(ruleNum)
	local splt = utils.split(colonSplit[2], "|")
	local i, j = string.find(splt[1], "[ab]")
	if i and j then
		local value = string.sub(splt[1], i, j)
		local rule = Rule:new { num = ruleNum, value = value }
		return rule
	end
	local left = numArray(splt[1])
	local right = {}
	if #splt > 1 then
		right = numArray(splt[2])
	end
	local rule = Rule:new { left = left, right = right, num = ruleNum }
	return rule
end
M.createRule = createRule

---Performs all operations required for part1
---@param filename string
---@return integer
local function part1(filename)
	-- Build RuleSet
	local rset = RuleSet:new {}
	local lines = utils.ingest(filename)
	---@type string[]
	local tests = {}
	for _, line in ipairs(lines) do
		if not string.find(line, ":") then
			if string.find(line, "[ab]") then
				table.insert(tests, line)
			end
		else
			local rule = createRule(line)
			rset:add(rule.num, rule)
		end
	end

	-- Build ResultStrings
	local rstrs = ResultStrings:new(rset)

	-- Count amount of valid tests
	local validCount = 0
	for _, test in ipairs(tests) do
		if rstrs.results[test] then
			validCount = validCount + 1
		end
	end
	return validCount
end
M.part1 = part1

return M
