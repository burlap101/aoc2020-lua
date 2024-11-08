utils = require "utils"

local M = {}

---@class Field
---@field required boolean
---@field validator fun(s: string): boolean
local Field = {}

local function heightValidator(s)
	-- Parse first
	local _, _, vs, uom = string.find(s, "^(%d+)%s*(%l%l)$")

	-- Cast number
	local v = tonumber(vs)

	-- Validate result
	if uom == "cm" then
		if v < 150 or v > 193 then
			return false
		end
		return true
	end
	if uom == "in" then
		if v < 59 or v > 76 then
			return false
		end
		return true
	end
	return false
end
M.heightValidator = heightValidator


local function yearValidator(s, min, max)
	-- Parse
	local y_str = string.match(s, "^%d%d%d%d$")
	local year = tonumber(y_str)
	if year == nil then
		return false
	end

	-- Validate
	if year < min or year > max then
		return false
	end
	return true
end
M.yearValidator = yearValidator


local function hairColorValidator(s)
	local i, _ = string.match(s, "^#" .. string.rep("%w", 6) .. "$")
	if i then return true end
	return false
end
M.hairColorValidator = hairColorValidator


local function eyeColorValidator(s)
	local colors = {
		["amb"] = 1,
		["blu"] = 2,
		["brn"] = 3,
		["gry"] = 4,
		["grn"] = 5,
		["hzl"] = 6,
		["oth"] = 7,
	}
	local _, _, color = string.find(s, "^(%l%l%l)$")
	if colors[color] then
		return true
	end
	return false
end
M.eyeColorValidator = eyeColorValidator


---@type { [string]: Field }
local schema = {
	byr = {
		required = true,
		validator = function(s)
			return yearValidator(s, 1920, 2002)
		end,
	},
	iyr = {
		required = true,
		validator = function(s)
			return yearValidator(s, 2010, 2020)
		end,
	},
	eyr = {
		required = true,
		validator = function(s)
			return yearValidator(s, 2020, 2030)
		end,
	},
	hgt = {
		required = true,
		validator = heightValidator,
	},
	hcl = {
		required = true,
		validator = hairColorValidator,
	},
	ecl = {
		required = true,
		validator = eyeColorValidator,
	},
	pid = {
		required = true,
		validator = function(s)
			local i = string.match(s, "^" .. string.rep("%d", 9) .. "$")
			if i then
				return true
			end
			return false
		end
	},
	cid = {
		required = false,
		validator = function(_)
			return true
		end
	},
}


---Passport class
---@class Passport
---@field byr string
---@field iyr string
---@field eyr string
---@field hgt string
---@field hcl string
---@field ecl string
---@field pid string
---@field cid string
local Passport = {}


---Replaces non space whitespace with space, multiple
---spaces with a single space and removes spaces from
---ends
---@param s string
---@return string
local function trim(s)
	local doubles = string.gsub(s, "%s+", " ")
	local ends = string.gsub(doubles, "^ ", "")
	local starts = string.gsub(ends, " $", "")
	return starts
end
M.trim = trim


local function extractPassport(s)
	---@type Passport
	local passport = {}
	for mtch in string.gmatch(s, "%w%w%w:%S+") do
		local c_index = string.find(mtch, ":")
		local field = string.sub(mtch, 1, c_index - 1)
		local value = string.sub(mtch, c_index + 1)
		passport[field] = value
	end
	return passport
end
M.extractPassport = extractPassport


---Takes input lines and extracts passports
---@param lines string[]
---@return Passport[]
local function getPassports(lines)
	---@type Passport[]
	local passports = {}
	local l_buf = ""
	local function insertPassport()
		local tmmd = trim(l_buf)
		table.insert(passports, extractPassport(tmmd))
		l_buf = ""
	end
	for _, l in ipairs(lines) do
		if trim(l) == "" then
			insertPassport()
		else
			l_buf = l_buf .. " " .. l
		end
	end
	insertPassport()
	return passports
end
M.getPassports = getPassports


---Determines if passsport is valid
---@param passport Passport
---@return boolean
local function allRequiredFields(passport)
	for k, v in pairs(schema) do
		if passport[k] == nil and v.required then
			return false
		end
	end
	return true
end
M.validate = allRequiredFields


---Performs validation on values provided in passport.
---@param passport Passport
---@return boolean
local function allValidValues(passport)
	for k, v in pairs(schema) do
		local _, result = pcall(v.validator, passport[k])
		if not result then
			return false
		end
	end
	return true
end


---Performs all operations necessary to complete part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local passports = getPassports(lines)
	local total = 0
	for _, p in ipairs(passports) do
		if allRequiredFields(p) then
			total = total + 1
		end
	end
	return total
end
M.part1 = part1


---Performs all operations necessary to complete part2
---@param filename string
---@return integer
local function part2(filename)
	local lines = utils.ingest(filename)
	local passports = getPassports(lines)
	local total = 0
	for _, p in ipairs(passports) do
		if allRequiredFields(p) and allValidValues(p) then
			total = total + 1
		end
	end
	return total
end
M.part2 = part2


return M
