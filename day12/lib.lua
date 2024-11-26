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
---@field easting integer
---@field rotate function(string, integer)
---@field moveForward function(integer)
---@field makeMove function(string)
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

---@class Waypoint: Ship
---@field northing integer
---@field easting integer
---@field ship Ship
local Waypoint = setmetatable({}, {__index=Ship})

---Constructor for the waypoint
---@return table|Waypoint
function Waypoint:new()
	local o = setmetatable({}, {__index=self})
	o.northing = 1
	o.easting = 10
	o.ship = Ship:new()
	return o
end

---Moves the ship towards the waypoint so many times
---@param value integer
function Waypoint:moveForward(value)
	local ship = self.ship
	ship.easting = ship.easting + value * self.easting
	ship.northing = ship.northing + value * self.northing
end

---Rotates the waypoint around the ship
---@param dir string
---@param value integer
function Waypoint:rotate(dir, value)
	local facing = 0
	if dir == "L" then
		facing = (facing - value) % 360
		if facing < 0 then
			facing = facing + 360
		end
	elseif dir == "R" then
		facing = (facing + value) % 360
		if facing > 360 then
			facing = facing - 360
		end
	end
	-- Set the relative position of the waypoint
	local n = self.northing
	local e = self.easting
	if facing == direction.E then
		self.northing = -e
		self.easting = n
	elseif facing == direction.S then
		self.northing = -n
		self.easting = -e
	elseif facing == direction.W then
		self.northing = e
		self.easting = -n
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

local function part2(filename)
	local lines = utils.ingest(filename)
	local waypoint = Waypoint:new()
	for _, line in ipairs(lines) do
		waypoint:makeMove(line)
	end
	local ship = waypoint.ship
	return math.abs(ship.easting) + math.abs(ship.northing)
end
M.part2 = part2

return M
