local utils = require("utils")
local lu = require("luaunit")

local M = {}

---@class CoordRange
---@field min integer
---@field max integer

---@class CoordinateRanges
---@field x CoordRange
---@field y CoordRange
---@field z CoordRange
---@field w CoordRange?

---@enum Direction
local Direction = {
	negx = -1,
	negy = -2,
	negz = -3,
	negw = -4,
	posx = 1,
	posy = 2,
	posz = 3,
	posw = 4,
}
M.Direction = Direction

---@class Coordinates
---@field x integer
---@field y integer
---@field z integer
local Coordinates = {}
M.Coordinates = Coordinates

---Constructor for a Coordinates
---@param coords Coordinates
---@return Coordinates
function Coordinates:new(coords)
	local o = setmetatable({}, { __index = self })
	o.x = coords.x
	o.y = coords.y
	o.z = coords.z
	return o
end

---Serializes coordinates to a key
---@return string
function Coordinates:asKey()
	return self.x .. "|" .. self.y .. "|" .. self.z
end

---Creates coordinates from key
---@param key string
---@return Coordinates
function Coordinates:fromKey(key)
	---@type integer[]
	local coords = {}
	for scoord in string.gmatch(key, "-?%d+") do
		local coord = tonumber(scoord)
		if not coord then
			error("failed to parse number " .. scoord)
		end
		table.insert(coords, coord)
	end
	local o = setmetatable({}, { __index = self })
	o.x = coords[1]
	o.y = coords[2]
	o.z = coords[3]
	return o
end

---Returns max value for each dimension
---@param coords Coordinates
---@return Coordinates
function Coordinates:max(coords)
	return Coordinates:new {
		x = math.max(self.x, coords.x),
		y = math.max(self.y, coords.y),
		z = math.max(self.z, coords.z),
	}
end

---Returns min value for each dimension
---@param coords Coordinates
---@return Coordinates
function Coordinates:min(coords)
	return Coordinates:new {
		x = math.min(self.x, coords.x),
		y = math.min(self.y, coords.y),
		z = math.min(self.z, coords.z),
	}
end

---@class Coordinates4D:Coordinates
---@field w integer
local Coordinates4D = utils.inheritsFrom(Coordinates)
M.Coordinates4D = Coordinates4D

---Returns max value for each dimension
---@param coords Coordinates4D
---@return Coordinates4D
function Coordinates4D:max(coords)
	return Coordinates4D:new {
		x = math.max(self.x, coords.x),
		y = math.max(self.y, coords.y),
		z = math.max(self.z, coords.z),
		w = math.max(self.w, coords.w),
	}
end

---Returns min value for each dimension
---@param coords Coordinates4D
---@return Coordinates4D
function Coordinates4D:min(coords)
	return Coordinates4D:new {
		x = math.min(self.x, coords.x),
		y = math.min(self.y, coords.y),
		z = math.min(self.z, coords.z),
		w = math.min(self.w, coords.w),
	}
end

---Constructor for 4D coordinates
---@param coords Coordinates4D
---@return table|Coordinates4D
function Coordinates4D:new(coords)
	local o = setmetatable({}, { __index = self })
	o.x = coords.x
	o.y = coords.y
	o.z = coords.z
	o.w = coords.w
	return o
end

---Serializes coordinates to a key
---@return string
function Coordinates4D:asKey()
	return self.x .. "|" .. self.y .. "|" .. self.z .. "|" .. self.w
end

---Creates a 4D coordinates from a string
---@param key string
---@return Coordinates4D
function Coordinates4D:fromKey(key)
	---@type integer[]
	local coords = {}
	for scoord in string.gmatch(key, "-?%d+") do
		local coord = tonumber(scoord)
		if not coord then
			error("failed to parse number " .. scoord)
		end
		table.insert(coords, coord)
	end
	local o = setmetatable({}, { __index = self })
	o.x = coords[1]
	o.y = coords[2]
	o.z = coords[3]
	o.w = coords[4]
	return o
end


---@class Cube
---@field active boolean
---@field nextState boolean
---@field coords Coordinates
---@field neighbours {[string]: Cube} Coordinates as key
local Cube = {}
M.Cube = Cube

---Constructor of a cube
---@param coords Coordinates
---@param active boolean? default is false
function Cube:new(coords, active)
	local o = setmetatable({}, { __index = self })
	if active == nil then
		o.active = false
	else
		o.active = active
	end
	o.coords = coords
	o.neighbours = {}
	return o
end

---Applies the state change rules, determines and assigns
---the next state
function Cube:assessState()
	local activeCount = 0
	self.nextState = self.active
	for _, cube in pairs(self.neighbours) do
		if cube.active then
			activeCount = activeCount + 1
		end
	end
	if self.active then
		if activeCount < 2 or activeCount > 3 then
			self.nextState = false
		end
	else
		if activeCount == 3 then
			self.nextState = true
		end
	end
end

---Adds a neighbour to the cube
---@param neighbour Cube
function Cube:addNeighbour(neighbour)
	if self.neighbours[neighbour.coords] then
		error("neighbour " .. lu.prettystr(neighbour.coords) .. " already added to cube " .. lu.prettystr(self.coords))
	end
	self.neighbours[neighbour.coords:asKey()] = neighbour
	if not neighbour.neighbours[self.coords:asKey()] then
		neighbour.neighbours[self.coords:asKey()] = self
	end
end

---Provide initial cube setup
---@param lines string[]
---@param is4d boolean?
---@return {[string]: Cube}
local function initCubes(lines, is4d)
	---@type {[string]: Cube}
	local cubes = {}
	for i, line in ipairs(lines) do
		local y = i - 1
		for j = 1, string.len(line) do
			local x = j - 1
			---@type Coordinates
			local coords = {}
			if is4d then
				coords = Coordinates4D:new { x = x, y = y, z = 0, w = 0 }
			else
				coords = Coordinates:new { x = x, y = y, z = 0 }
			end
			local active = false
			if string.sub(line, j, j) == "#" then
				active = true
			end
			cubes[coords:asKey()] = Cube:new(coords, active)
		end
	end
	return cubes
end
M.initCubes = initCubes

---Gets the neighbouring coordinates for the given coords
---@param coords Coordinates|Coordinates4D
---@return Coordinates[]
local function getCoordinateNeighbours(coords)
	---@type Coordinates[]
	local neighbours = {}
	for x = coords.x - 1, coords.x + 1 do
		for y = coords.y - 1, coords.y + 1 do
			for z = coords.z - 1, coords.z + 1 do
				if not coords.w and not (x == coords.x and y == coords.y and z == coords.z) then
					table.insert(neighbours, Coordinates:new { x = x, y = y, z = z })
				elseif coords.w then
					-- 4D coordinates in use
					for w = coords.w - 1, coords.w + 1 do
						if not (x == coords.x and y == coords.y and z == coords.z and w == coords.w) then
							table.insert(neighbours, Coordinates4D:new { x = x, y = y, z = z, w = w })
						end
					end
				end
			end
		end
	end
	return neighbours
end
M.getCoordinateNeighbours = getCoordinateNeighbours

---@class Space
---@field cubes {[string]: Cube}
local Space = {}
M.Space = Space

---Constructor for the initial space
---@param lines string[]
---@return Space
function Space:new(lines)
	local o = setmetatable({}, { __index = self })
	o.cubes = initCubes(lines)
	o:initNeighbours()
	return o
end

function Space:initNeighbours()
	local newCubes = {}
	for coordKey, cube in pairs(self.cubes) do
		local coords = Coordinates:fromKey(coordKey)
		local neighbours = getCoordinateNeighbours(coords)
		for _, ncoords in ipairs(neighbours) do
			if not self.cubes[ncoords:asKey()] then
				local newCube = Cube:new(ncoords, false)
				newCubes[ncoords:asKey()] = newCube
			else
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end
	for key, cube in pairs(newCubes) do
		self.cubes[key] = cube
		for _, ncoords in ipairs(getCoordinateNeighbours(cube.coords)) do
			if self.cubes[ncoords:asKey()] then
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end
end

---Take a snapshot of the current state
---@return {[string]: boolean}
function Space:snapshot()
	local states = {}
	for key, cube in pairs(self.cubes) do
		states[key] = cube.active
	end
	return states
end

---Cycles through the states
function Space:cycle()
	local prevStates = self:snapshot()
	---@type {[string]: boolean}
	for _, cube in pairs(self.cubes) do
		cube:assessState()
	end
	for _, key in ipairs(utils.keysToArray(self.cubes)) do
		local cube = self.cubes[key]
		cube.active = cube.nextState
		if cube.active and prevStates[key] == false then
			for _, direction in ipairs(self:onBoundary(cube)) do
				local ncs = self:extend(direction)
				for _, nc in pairs(ncs) do
					nc:assessState()
				end
			end
		end
	end
end

---String representation of the space
---@return string[]
function Space:prettystr()
	--Indices are zyx
	---@type {[integer]: {[integer]: {[integer]: string}}}
	local chars = {}
	for _, cube in pairs(self.cubes) do
		local x = cube.coords.x
		local y = cube.coords.y
		local z = cube.coords.z
		if not chars[z] then
			chars[z] = {}
		end
		if not chars[z][y] then
			chars[z][y] = {}
		end
		if cube.active then
			chars[z][y][x] = "#"
		elseif cube.active == false then
			chars[z][y][x] = "."
		else
			chars[z][y][x] = "n"
		end
	end
	local lines = {}
	local dimensions = self:getDimensions()
	for z, ys in pairs(chars) do
		if not lines[z] then
			lines[z] = {}
			local numline = { "." }
			for x = dimensions.x.min, dimensions.x.max do
				table.insert(numline, x)
			end
			lines[z][dimensions.y.min - 1] = table.concat(numline)
		end
		for y, xs in pairs(ys) do
			local xarr = { y }
			table.move(xs, dimensions.x.min, dimensions.x.max, 2, xarr)
			lines[z][y] = table.concat(xarr)
		end
	end
	local planes = {}
	for z, ys in pairs(lines) do
		local yarr = {}
		table.move(ys, dimensions.y.min - 1, dimensions.y.max, 1, yarr)
		planes[z] = table.concat(yarr, "\n")
	end
	return planes
end

---Returns the direction of boundaries that the cube lies on
---if any
---@param cube any
---@return Direction[]
function Space:onBoundary(cube)
	local dims = self:getDimensions()
	---@type Direction[]
	local directions = {}
	if cube.coords.x == dims.x.min then
		table.insert(directions, Direction.negx)
	end
	if cube.coords.x == dims.x.max then
		table.insert(directions, Direction.posx)
	end
	if cube.coords.y == dims.y.min then
		table.insert(directions, Direction.negy)
	end
	if cube.coords.y == dims.y.max then
		table.insert(directions, Direction.posy)
	end
	if cube.coords.z == dims.z.min then
		table.insert(directions, Direction.negz)
	end
	if cube.coords.z == dims.z.max then
		table.insert(directions, Direction.posz)
	end
	if cube.coords.w and cube.coords.w == dims.w.min then
		table.insert(directions, Direction.negw)
	end
	if cube.coords.w and cube.coords.w == dims.w.max then
		table.insert(directions, Direction.posw)
	end

	return directions
end

---Returns the current count of cubes that are active
---@return integer
function Space:activeCount()
	local count = 0
	for _, cube in pairs(self.cubes) do
		if cube.active then
			count = count + 1
		end
	end
	return count
end

---Gets the outer bounds of space under consideration
---@return CoordinateRanges
function Space:getDimensions()
	local _, firstcube = next(self.cubes)
	local maxs = firstcube.coords
	local mins = firstcube.coords
	for _, cube in pairs(self.cubes) do
		maxs = maxs:max(cube.coords)
		mins = mins:min(cube.coords)
	end
	local result = {
		x = {
			min = mins.x,
			max = maxs.x,
		},
		y = {
			min = mins.y,
			max = maxs.y,
		},
		z = {
			min = mins.z,
			max = maxs.z,
		},
	}
	if maxs.w and mins.w then
		result.w = { min = mins.w, max = maxs.w }
	end
	return result
end

---Extend the space dimensions on one axis
---@param direction Direction
---@return {[string]: Cube}
function Space:extend(direction)
	local boundary = self:getDimensions()
	local addXPlane = function(newx)
		local newCubes = {}
		for y = boundary.y.min, boundary.y.max do
			for z = boundary.z.min, boundary.z.max do
				local coords = Coordinates:new { x = newx, y = y, z = z }
				newCubes[coords:asKey()] = Cube:new(coords, false)
			end
		end
		return newCubes
	end
	local addYPlane = function(newy)
		local newCubes = {}
		for x = boundary.x.min, boundary.x.max do
			for z = boundary.z.min, boundary.z.max do
				local coords = Coordinates:new { x = x, y = newy, z = z }
				newCubes[coords:asKey()] = Cube:new(coords, false)
			end
		end
		return newCubes
	end
	local addZPlane = function(newz)
		local newCubes = {}
		for x = boundary.x.min, boundary.x.max do
			for y = boundary.y.min, boundary.y.max do
				local coords = Coordinates:new { x = x, y = y, z = newz }
				newCubes[coords:asKey()] = Cube:new(coords, false)
			end
		end
		return newCubes
	end

	local newCubes = {}
	if direction == Direction.posx then
		local newx = boundary.x.max + 1
		newCubes = addXPlane(newx)
	elseif direction == Direction.negx then
		local newx = boundary.x.min - 1
		newCubes = addXPlane(newx)
	elseif direction == Direction.posy then
		local newy = boundary.y.max + 1
		newCubes = addYPlane(newy)
	elseif direction == Direction.negy then
		local newy = boundary.y.min - 1
		newCubes = addYPlane(newy)
	elseif direction == Direction.posz then
		local newz = boundary.z.max + 1
		newCubes = addZPlane(newz)
	elseif direction == Direction.negz then
		local newz = boundary.z.min - 1
		newCubes = addZPlane(newz)
	end

	--Add the new cubes to the space
	for key, cube in pairs(newCubes) do
		self.cubes[key] = cube
	end

	-- Setup the neighbour relationship
	for _, cube in pairs(newCubes) do
		local neighbours = getCoordinateNeighbours(cube.coords)
		for _, ncoords in ipairs(neighbours) do
			if self.cubes[ncoords:asKey()] then
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end

	-- Return the newcubes
	return newCubes
end

---@class Space4D:Space
local Space4D = utils.inheritsFrom(Space)
M.Space4D = Space4D

---Creates a 4D space
---@param lines string[]
---@return Space4D
function Space4D:new(lines)
	local o = setmetatable({}, { __index = self })
	o.cubes = initCubes(lines, true)
	o:initNeighbours()
	return o
end

---comment
---@param cube Cube
---@return {[string]: Cube}
function Space4D:addNeighbours(cube)
	local ncoords = getCoordinateNeighbours(cube.coords)
	local newCubes = {}
	for _, ncoord in ipairs(ncoords) do
		local k = ncoord:asKey()
		if not self.cubes[k] then
			newCubes[k] = Cube:new(ncoord, false)
			self.cubes[k] = newCubes[k]
		end
	end
	-- Setup the neighbour relationship
	for _, ncube in pairs(newCubes) do
		local neighbours = getCoordinateNeighbours(ncube.coords)
		for _, ncoord in ipairs(neighbours) do
			local k = ncoord:asKey()
			if self.cubes[k] then
				self.cubes[k]:addNeighbour(ncube)
			end
		end
	end
	return newCubes
end

---Cycles through the states
function Space4D:cycle()
	local prevStates = self:snapshot()
	---@type {[string]: boolean}
	for _, cube in pairs(self.cubes) do
		cube:assessState()
	end
	for _, key in ipairs(utils.keysToArray(self.cubes)) do
		local cube = self.cubes[key]
		cube.active = cube.nextState
		if cube.active and prevStates[key] == false then
			local ncs = self:addNeighbours(cube)
			for _, nc in pairs(ncs) do
				nc:assessState()
			end
		end
	end
end

---Extend the space dimensions on one axis
---@param direction Direction
---@return {[string]: Cube}
function Space4D:extend(direction)
	local boundary = self:getDimensions()
	local addXPlane = function(newx)
		local newCubes = {}
		for y = boundary.y.min, boundary.y.max do
			for z = boundary.z.min, boundary.z.max do
				for w = boundary.w.min, boundary.w.max do
					local coords = Coordinates4D:new { x = newx, y = y, z = z, w = w}
					newCubes[coords:asKey()] = Cube:new(coords, false)
				end
			end
		end
		return newCubes
	end
	local addYPlane = function(newy)
		local newCubes = {}
		for x = boundary.x.min, boundary.x.max do
			for z = boundary.z.min, boundary.z.max do
				for w = boundary.w.min, boundary.w.max do
					local coords = Coordinates4D:new { x = x, y = newy, z = z, w = w}
					newCubes[coords:asKey()] = Cube:new(coords, false)
				end
			end
		end
		return newCubes
	end
	local addZPlane = function(newz)
		local newCubes = {}
		for x = boundary.x.min, boundary.x.max do
			for y = boundary.y.min, boundary.y.max do
				for w = boundary.w.min, boundary.w.max do
					local coords = Coordinates4D:new { x = x, y = y, z = newz, w = w}
					newCubes[coords:asKey()] = Cube:new(coords, false)
				end
			end
		end
		return newCubes
	end
	local addWPlane = function(neww)
		local newCubes = {}
		for x = boundary.x.min, boundary.x.max do
			for y = boundary.y.min, boundary.y.max do
				for z = boundary.z.min, boundary.z.max do
					local coords = Coordinates4D:new {x=x,y=y,z=z,w=neww}
					newCubes[coords:asKey()] = Cube:new(coords, false)
				end
			end
		end
		return newCubes
	end

	local newCubes = {}
	if direction == Direction.posx then
		local newx = boundary.x.max + 1
		newCubes = addXPlane(newx)
	elseif direction == Direction.negx then
		local newx = boundary.x.min - 1
		newCubes = addXPlane(newx)
	elseif direction == Direction.posy then
		local newy = boundary.y.max + 1
		newCubes = addYPlane(newy)
	elseif direction == Direction.negy then
		local newy = boundary.y.min - 1
		newCubes = addYPlane(newy)
	elseif direction == Direction.posz then
		local newz = boundary.z.max + 1
		newCubes = addZPlane(newz)
	elseif direction == Direction.negz then
		local newz = boundary.z.min - 1
		newCubes = addZPlane(newz)
	elseif direction == Direction.posw then
		local neww = boundary.w.max + 1
		newCubes = addWPlane(neww)
	elseif direction == Direction.negw then
		local neww = boundary.w.min - 1
		newCubes = addWPlane(neww)
	end

	--Add the new cubes to the space
	for key, cube in pairs(newCubes) do
		self.cubes[key] = cube
	end

	-- Setup the neighbour relationship
	for _, cube in pairs(newCubes) do
		local neighbours = getCoordinateNeighbours(cube.coords)
		for _, ncoords in ipairs(neighbours) do
			if self.cubes[ncoords:asKey()] then
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end

	-- Return the newcubes
	return newCubes
end
---Initialize neighbours for a 4D space
function Space4D:initNeighbours()
	-- Holds new cubes to be added to the space
	local newCubes = {}
	for coordKey, cube in pairs(self.cubes) do
		local coords = Coordinates4D:fromKey(coordKey)
		local neighbours = getCoordinateNeighbours(coords)
		for _, ncoords in ipairs(neighbours) do
			if not self.cubes[ncoords:asKey()] then
				local newCube = Cube:new(ncoords, false)
				newCubes[ncoords:asKey()] = newCube
			else
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end
	-- Add the new cubes to the space
	for key, cube in pairs(newCubes) do
		self.cubes[key] = cube
		for _, ncoords in ipairs(getCoordinateNeighbours(cube.coords)) do
			if self.cubes[ncoords:asKey()] then
				self.cubes[ncoords:asKey()]:addNeighbour(cube)
			end
		end
	end
end

---Takes two states and determines if difference exists
---@param s1 {[string]: boolean}
---@param s2 {[string]: boolean}
---@return boolean
local function stateDifference(s1, s2)
	for k, v in pairs(s1) do
		if s2[k] ~= v then
			return true
		end
	end
	return false
end
M.stateDifference = stateDifference

---Performs all necessary operations for part1
---@param filename string
---@return integer
local function part1(filename)
	local lines = utils.ingest(filename)
	local space = Space:new(lines)
	for _ = 1, 6 do
		space:cycle()
	end
	return space:activeCount()
end
M.part1 = part1

local function part2(filename)
	local lines = utils.ingest(filename)
	local space = Space4D:new(lines)
	for _ = 1,6 do
		space:cycle()
	end
	return space:activeCount()
end
M.part2 = part2


return M
