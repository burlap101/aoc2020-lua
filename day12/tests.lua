local lib = require("day12.lib")
local lu = require("luaunit")


function TestShipRotate()
	local ship = lib.Ship:new()
	ship:rotate("R", 90)
	lu.assertEquals(ship.facing, 180)
	ship:rotate("R", 90)
	lu.assertEquals(ship.facing, 270)
	ship:rotate("L", 90)
	lu.assertEquals(ship.facing, 180)
	ship:rotate("L", 270)
	lu.assertEquals(ship.facing, 270)
end

function TestShipMoveForward()
	local ship = lib.Ship:new()
	ship:moveForward(28)
	lu.assertEquals(ship.easting, 28)
	lu.assertEquals(ship.northing, 0)
	ship:rotate("R", 90)
	ship:moveForward(28)
	lu.assertEquals(ship.easting, 28)
	lu.assertEquals(ship.northing, -28)
	ship:rotate("R", 90)
	ship:moveForward(28)
	lu.assertEquals(ship.easting, 0)
	lu.assertEquals(ship.northing, -28)
	ship:rotate("R", 90)
	ship:moveForward(28)
	lu.assertEquals(ship.easting, 0)
	lu.assertEquals(ship.northing, 0)
end



function TestPart1()
	lu.assertEquals(lib.part1("day12/test.txt"), 25)
end

function TestPart2()
	lu.assertEquals(lib.part2("day12/test.txt"), 286)
end

os.exit(lu.LuaUnit.run())
