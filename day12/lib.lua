local utils = require("utils")
local M = {}


---@enum direction
local direction = {
	E=90,
	S=180,
	W=270,
	N=0,
}

---@class Ship
---@field facing direction
---@field northing integer
---@field easintg integer
local Ship = {}
M.Ship = Ship

---Constructor for a ship
---@return Ship
function Ship:new()
	local o = setmetatable({}, { __index = self })
	o.facing = direction.E
	o.easting = 0
	o.northing = 0
	return o
end

function Ship:rotate(dir, value)
	if dir == "L" then
		self.facing = (self.facing - value) % 360
		if self.facing < 0 then
			self.facing = self.facing + 360
		end
	elseif dir == "R" then
		self.facing = (self.facing + value) % 360
		if self.facing > 360 then
			self.facing = self.facing - 360
		end
	end
end

---Moves ship forward
---@param value integer
function Ship:moveForward(value)
	if self.facing == direction.E then
		self.easting = self.easting + value
	elseif self.facing == direction.W then
		self.easting = self.easting - value
	elseif self.facing == direction.N then
		self.northing = self.northing + value
	elseif self.facing == direction.S then
		self.northing = self.northing - value
	end
end

---Makes the ship move
---@param line any
function Ship:makeMove(line)
	---@type string
	---@type integer
	local dir, val = string.match(line, "(%a)(-?%d+)")
	if dir == "L" or dir == "R" then
		self:rotate(dir, val)
	elseif dir == "F" then
		self:moveForward(val)
	elseif dir == "N" then
		self.northing = self.northing + val
	elseif dir == "S" then
		self.northing = self.northing - val
	elseif dir == "E" then
		self.easting = self.easting + val
	elseif dir == "W" then
		self.easting = self.easting - val
	end
end

local function part1(filename)
	local lines = utils.ingest(filename)
	local ship = Ship:new()
	for _, line in ipairs(lines) do
		ship:makeMove(line)
	end
	return math.abs(ship.easting) + math.abs(ship.northing)
end
M.part1 = part1

return M
