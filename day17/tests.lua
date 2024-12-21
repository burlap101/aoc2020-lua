local utils = require("utils")
local lib = require("day17.lib")
local lu = require("luaunit")

function TestGetCoordinateNeighbours()
	local point = lib.Coordinates:new{x=1,y=1,z=1}
	local neighbours = lib.getCoordinateNeighbours(point)
	lu.assertEquals(#neighbours, 26)

	--Make sure the given point isn't in the neighbour list
	---@type string[]
	local keys = {}
	for _, coord in ipairs(neighbours) do
		table.insert(keys, coord:asKey())
	end
	lu.assertNotTableContains(keys, point:asKey())

	--Make sure sample points are in the table
	lu.assertTableContains(keys, lib.Coordinates:new{x=2,y=2,z=2}:asKey())
	lu.assertTableContains(keys, lib.Coordinates:new{x=2,y=1,z=2}:asKey())
	lu.assertTableContains(keys, lib.Coordinates:new{x=2,y=2,z=0}:asKey())
end

function TestCubeNew()
	local coords = lib.Coordinates:new{x = 1, y = 2, z = 3}
	local cube = lib.Cube:new(coords)
	coords = lib.Coordinates:new{x = 0, y = 0, z = 0}
	lu.assertEquals(cube.coords:asKey(), lib.Coordinates:new{x = 1, y = 2, z = 3}:asKey())
	lu.assertIsFalse(cube.active)
end

function TestSpaceNew()
	local lines = {"#"}
	local space = lib.Space:new(lines)
	lu.assertEquals(#utils.keysToArray(space.cubes), 27)
	lu.assertTableContains(utils.keysToArray(space.cubes), lib.Coordinates:new{x=-1,y=-1,z=0}:asKey())
	lu.assertEquals(#utils.keysToArray(space.cubes["0|0|-1"].neighbours), 17)
	for key, cube in pairs(space.cubes) do
		lu.assertEquals(cube.coords:asKey(), key)
	end
end

function TestSpace4DNew()
	local lines = {"#"}
	local space = lib.Space4D:new(lines)
	lu.assertEquals(#utils.keysToArray(space.cubes), 81)
end

function TestCoordinatesMax()
	local coords = lib.Coordinates:new{x=1, y=2, z=3}
	local ncoords = lib.Coordinates:new{x=2, y=1, z=3}
	lu.assertEquals(coords:max(ncoords), {x=2, y=2, z=3})
end

function TestInitCubes()
	local lines = {"#"}
	local cubes = lib.initCubes(lines)
	for key, cube in pairs(cubes) do
		lu.assertEquals(cube.coords:asKey(), key)
	end
end

function TestSpaceDimensions()
	local lines = {"#"}
	local space = lib.Space:new(lines)
	---@type CoordinateRanges
	local expected = {
		x = {
			min = -1,
			max = 1,
		},
		y = {
			min = -1,
			max = 1
		},
		z = {
			min = -1,
			max = 1
		}
	}
	lu.assertEquals(space:getDimensions(), expected)
end

function TestSpaceExtend()
	local lines = {"#"}
	local space = lib.Space:new(lines)
	space:extend(lib.Direction.posx)
	lu.assertEquals(#utils.keysToArray(space.cubes), 36)
	for key, cube in pairs(space.cubes) do
		lu.assertNotEquals(cube.active, nil, key..": active is nil")
	end
end

function TestSpaceCycle()
	local lines = utils.ingest("day17/test.txt")
	local space = lib.Space:new(lines)
	local dims = space:getDimensions()
	lu.assertEquals(space:activeCount(), 5)
	lu.assertTableContains(utils.keysToArray(space.cubes), "2|2|-1")
	space:cycle()
	dims = space:getDimensions()
	lu.assertEquals(dims, {x={max=3, min=-1}, y={max=4, min=-1}, z={max=2, min=-2}})
	lu.assertTableContains(utils.keysToArray(space.cubes), "2|2|-1")
	for key, cube in pairs(space.cubes) do
		if key == "2|2|-1" then
			lu.assertNotIsNil(cube.active, key..": "..lu.prettystr(cube.coords))
		end
		if #space:onBoundary(cube) == 0 then
			lu.assertEquals(#utils.keysToArray(cube.neighbours), 26)
		elseif #space:onBoundary(cube) == 1 then
			lu.assertEquals(#utils.keysToArray(cube.neighbours), 17)
		elseif #space:onBoundary(cube) == 2 then
			lu.assertEquals(#utils.keysToArray(cube.neighbours), 11)
		elseif #space:onBoundary(cube) == 3 then
			lu.assertEquals(#utils.keysToArray(cube.neighbours), 7)
		else
			error("another boundary situation came up"..lu.prettystr(space:onBoundary(cube)))
		end
	end
	lu.assertEquals(space:activeCount(), 11)
	space:cycle()

end

function TestPart1()
	lu.assertEquals(lib.part1("day17/test.txt"), 112)
end

os.exit(lu.LuaUnit.run())
