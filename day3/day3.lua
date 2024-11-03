local utils = require "utils"
local lib = require "day3.lib"


local lines = utils.ingest("day3/input.txt")
local map = lib.createMap(lines)
local cnt = lib.treeCount(map, 3, 1)

print("Part1:", cnt)

local mresult = lib.multiplyScenarios(map, lib.scenarios)

print("Part2:", mresult)
