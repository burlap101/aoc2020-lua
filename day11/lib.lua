local utils = require("utils")
local lu = require("luaunit")
local M = {}

---@class Seat
---@field occupied boolean
---@field location string
---@field tolerance integer
---@field adjacent {[string]: Seat}
---@field states boolean[]
---@field stateCounter integer
local Seat = {}
M.Seat = Seat

---Constructor for Seat
---@param occupied boolean
---@param location string
---@param tolerance integer?
---@return table|Seat
function Seat:new(occupied, location, tolerance)
	local o = setmetatable({}, { __index = self })
	o.tolerance = tolerance or 4
	o.occupied = occupied
	o.location = location
	o.adjacent = {}
	o.states = { occupied }
	o.stateCounter = 1
	return o
end

---Adds an adjacent seat for the seat
---@param seat Seat
function Seat:addAdjacent(seat)
	self.adjacent[seat.location] = seat
	if not seat.adjacent[self.location] then
		seat:addAdjacent(self)
	end
end

---Finds adjacent seats as per part2 spec
---@param seats {[string]: Seat}
---@return {[string]: Seat}
function Seat:findAdjacents(seats)
	-- Get all diagonals, verticals and horizontals
	local diagonals = {}
	local verticals = {}
	local horizontals = {}
	local row = tonumber(string.match(self.location, "(%d+)-"))
	local col = tonumber(string.match(self.location, "-(%d+)"))
	-- Iterate through the whole seat map 
	-- and allocate matching seats for each
	local maxRow = 0
	local maxCol = 0
	for loc in pairs(seats) do
		if loc == self.location then
			goto continue
		end
		local m = tonumber(string.match(loc, "(%d+)-"))
		local n = tonumber(string.match(loc, "-(%d+)"))
		maxRow = math.max(m or maxRow, maxRow)
		maxCol = math.max(n or maxCol, maxCol)
		if m == row then
			table.insert(horizontals, n)
		elseif n == col then
			table.insert(verticals, m)
		elseif math.abs(row - m) == math.abs(col - n) then
			table.insert(diagonals, {m, n})
		end
		::continue::
	end

	---@type string[]
	local locs = {}
	local left = 0
	local right = maxCol+1
	for _, n in ipairs(horizontals) do
		if n < col then
			left = math.max(n, left)
		elseif n > col then
			right = math.min(n, right)
		end
	end
	if left >= 1 then
		table.insert(locs, row .. "-" .. left)
	end
	if right <= maxCol then
		table.insert(locs, row .. "-" .. right)
	end

	local up = 0
	local down = maxRow + 1
	for _, m in ipairs(verticals) do
		if m < row then
			up = math.max(m, up)
		elseif m > row then
			down = math.min(m, down)
		end
	end
	if up >= 1 then
		table.insert(locs, up .. "-" .. col)
	end
	if down <= maxRow then
		table.insert(locs, down .. "-" .. col)
	end

	local norwest = {0, 0}
	local noreast = {0, maxCol + 1}
	local soueast = {maxRow + 1, maxCol + 1}
	local souwest = {maxRow + 1, 0}

	for _, coords in ipairs(diagonals) do
		local m = coords[1]
		local n = coords[2]
		if m < row and n < col then
			norwest = {math.max(m, norwest[1]), math.max(n, norwest[2])}
		elseif m < row and n > col then
			noreast = {math.max(m, noreast[1]), math.min(n, noreast[2])}
		elseif m > row and n > col then
			soueast = {math.min(m, soueast[1]), math.min(n, soueast[2])}
		elseif m > row and n < col then
			souwest = {math.min(m, souwest[1]), math.max(n, souwest[2])}
		end
	end
	if norwest[1] >= 1 and norwest[2] >= 1 then
		table.insert(locs, norwest[1] .. "-" .. norwest[2])
	end
	if noreast[1] >= 1 and noreast[2] <= maxCol then
		table.insert(locs, noreast[1] .. "-" .. noreast[2])
	end
	if soueast[1] <= maxRow and soueast[2] <= maxCol then
		table.insert(locs, soueast[1] .. "-" .. soueast[2])
	end
	if souwest[1] <= maxRow and souwest[2] >= 1 then
		table.insert(locs, souwest[1] .. "-" .. souwest[2])
	end

	local adjacents = {}
	for _, loc in ipairs(locs) do
		adjacents[loc] = seats[loc]
	end

	return adjacents
end

---Populates the state buffer with the next state
---@return boolean nextState
function Seat:determineNextState()
	local numOccupied = 0
	local totalSeats = 0
	for _, seat in pairs(self.adjacent) do
		totalSeats = totalSeats + 1
		if seat.occupied then
			numOccupied = numOccupied + 1
		end
	end
	if self.occupied and numOccupied >= self.tolerance then
		table.insert(self.states, false)
	elseif not self.occupied and numOccupied == 0 then
		table.insert(self.states, true)
	end
	return self.states[#self.states]
end

---Takes the seat to the next state of occupation.
---@return boolean oldState
---@return boolean newState
function Seat:gotoNextState()
	local oldState = self.occupied
	self.occupied = self.states[#self.states]
	self.stateCounter = self.stateCounter + 1
	return oldState, self.occupied
end

---Determines all possible surrounding locations
---for a given location
---@param location string
---@param rows integer aka height
---@param columns integer aka width
---@return string[]
local function surroundingLocations(location, rows, columns)
	local m = string.match(location, "(%d+)-")
	local n = string.match(location, "-(%d+)")
	---@type string[]
	local locs = {}
	for i = math.max(m - 1, 1), math.min(m + 1, rows) do
		for j = math.max(n - 1, 1), math.min(n + 1, columns) do
			local loc = i .. "-" .. j
			if loc ~= location then
				table.insert(locs, loc)
			end
		end
	end
	return locs
end
M.surroundingLocations = surroundingLocations


---Creates representation of all seats in
---waiting area.
---@param lines string[]
---@return {[string]: Seat}
local function createLayout(lines)
	local layout = {}
	for i, l in ipairs(lines) do
		for j = 1, string.len(l) do
			if string.sub(l, j, j) == "L" then
				local loc = i .. "-" .. j
				layout[loc] = Seat:new(false, loc)
			end
		end
	end
	local nRows = #lines
	local nCols = string.len(lines[1])
	for loc, seat in pairs(layout) do
		local sLocs = surroundingLocations(loc, nRows, nCols)
		for _, sLoc in ipairs(sLocs) do
			if layout[sLoc] then
				seat:addAdjacent(layout[sLoc])
			end
		end
	end
	return layout
end


---@class WaitingArea
---@field seats {[string]: Seat}
---@field states {[string]: boolean}[]
---@field rows integer
---@field cols integer
---@field counter integer
local WaitingArea = {}
M.WaitingArea = WaitingArea

function WaitingArea:new(lines)
	local o = setmetatable({}, { __index = self })
	o.seats = createLayout(lines)
	o.rows = #lines
	o.cols = string.len(lines[1])
	o.states = {}
	o.counter = 1
	return o
end

local function createLayoutPart2(lines)
	local layout = {}
	for i, l in ipairs(lines) do
		for j = 1, string.len(l) do
			if string.sub(l, j, j) == "L" then
				local loc = i .. "-" .. j
				layout[loc] = Seat:new(false, loc, 5)
			end
		end
	end
	for _, seat in pairs(layout) do
		for _, adj in pairs(seat:findAdjacents(layout)) do
			seat:addAdjacent(adj)
		end
	end
	return layout
end
M.createLayoutPart2 = createLayoutPart2

local WaitingArea2 = {}
M.WaitingArea2 = WaitingArea2

function WaitingArea2:new(lines)
	local o = setmetatable({}, { __index = WaitingArea })
	o.seats = createLayoutPart2(lines)
	o.rows = #lines
	o.cols = string.len(lines[1])
	o.states = {}
	o.counter = 1
	return o
end

---Provides a representation of the state of
---the waiting area
---@return string[]
function WaitingArea:serialize()
	---@type string[]
	local lines = {}
	for i=1,self.rows do
		lines[i] = ""
		for j=1,self.cols do
			local loc = i .. "-" .. j
			if self.seats[loc] == nil then
				lines[i] = lines[i] .. "."
			elseif self.seats[loc].occupied then
				lines[i] = lines[i] .. "#"
			else
				lines[i] = lines[i] .. "L"
			end
		end
	end
	return lines
end

---Takes a snapshot of the current state of all the seats
---@return {[string]: boolean} previous
---@return {[string]: boolean} current
function WaitingArea:snapShot()
	if self.states[self.counter] then
		error("snapshot already exists for counter")
	end
	if #self.states ~= self.counter - 1 then
		error("snapshot " .. (self.counter - 1) .. " is missing")
	end
	---@type {[string]: boolean}
	local state = {}
	for loc, seat in pairs(self.seats) do
		state[loc] = seat.occupied
	end
	table.insert(self.states, state)
	return self.states[#self.states - 1], state
end


---Performs toggling of the state of the seats.
---@return boolean
function WaitingArea:toggle()
	-- Calculate next states of all seats
	for _, seat in pairs(self.seats) do
		seat:determineNextState()
	end

	-- Set each seat into new state
	for _, seat in pairs(self.seats) do
		seat:gotoNextState()
	end

	-- Record state of all seats
	local prev, curr = self:snapShot()

	-- Counter ++
	self.counter = self.counter + 1

	-- Return whether there was no 
	-- change in seats
	if prev == nil then
		return false
	end
	for i in pairs(curr) do
		if prev[i] ~= curr[i] then
			return false
		end
	end
	return true
end

---Gets count of seats currently occupied
---@return integer
function WaitingArea:occupiedCount()
	local total = 0
	for _, seat in pairs(self.seats) do
		if seat.occupied then
			total = total + 1
		end
	end
	return total
end

local function part1(filename)
	local lines = utils.ingest(filename)
	local wa = WaitingArea:new(lines)
	local statesEqual = false
	while not statesEqual do
		statesEqual = wa:toggle()
	end
	return wa:occupiedCount()
end
M.part1 = part1

local function part2(filename)
	local lines = utils.ingest(filename)
	local wa = WaitingArea2:new(lines)
	local statesEqual = false
	while not statesEqual do
		statesEqual = wa:toggle()
	end
	return wa:occupiedCount()
end
M.part2 = part2

return M
