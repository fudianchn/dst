-- 17-oct-2015
-- Goat <goat@ridiculousglitch.com>
-- Generate island based on circles and Perlin noise

require('math')
local Matrix = require('matrix')

-- randtable size is 2 * n
local RANDTABLE_N = 4096

local function ease(a, b, t)
    local t0 = 6 * t^5 - 15 * t^4 + 10 * t^3
    return a * (1 - t0) + b * t0
end

local function perlin(x, y, randtable)
    local y0 = math.floor(y)
    local y1 = y0 + 1    
    local v = y - y0

    --[[
    local grad = Matrix({randdir(randtable, x0, y0), randdir(randtable, x0, y1), randdir(randtable, x1, y0), randdir(randtable, x1, y1) })
    local dist = Matrix({ { u, v }, { u - 1, v }, { u, v - 1 }, { u - 1, v - 1 } })
    --local g1, g2, g3, g4 = (0.5 * (1 + (grad:dot(dist:transposed())))):unpack()
    local g1, g2, g3, g4 = grad:dot(dist:transposed()):unpack()
    return ease(ease(g1, g2, u), ease(g3, g4, u), v)
    --]]
    
    local g1 = randtable[y0 % RANDTABLE_N + 1][x]
    local g2 = randtable[y1 % RANDTABLE_N + 1][x]
    return ease(g1, g2, v)
end

local function perlin_point(r, i, j, params, randtable)
    local y = 0.5 * (1 + i / r)
    local x = j > 0 and 1 or 2
    local d = 0
    for _, param in ipairs(params) do
        local a, f = unpack(param)
        d = d + a * perlin(x, y * f, randtable)
    end
    return math.floor(j + r * d)
end

local function perlin_segment(r, i, j, params, randtable)
    return perlin_point(r, i, -j, params, randtable), perlin_point(r, i, j, params, randtable)
end

local function perlin_island(r, params, seed)
    local randtable = Matrix.random(RANDTABLE_N, 2, seed)    
    local lines = { }
    local min_x = r
    for ci = 0, math.floor(r / math.sqrt(2)) do
        local cj = math.floor(math.sqrt(r^2 - ci^2))
        for s = -1, 1, 2 do
            for _, ij in ipairs({ { ci, cj }, { cj, ci } }) do
                local i, j = unpack(ij)
                local x0, x1 = perlin_segment(r, s * i, j, params, randtable)
                if x0 < min_x then
                    min_x = x0
                end
                local l = r + s * i + 1
                if lines[l] == nil then
                    lines[l] = { x0, x1 }
                else
                    if x0 < lines[l][1] then
                        lines[l][1] = x0
                    end
                    if x1 > lines[l][2] then
                        lines[l][2] = x1
                    end
                end
            end
        end
    end

    -- Remove outliers
    table.remove(lines, 1)
    table.remove(lines, #lines)
    
    -- Postprocess (offset and centroid)
    local centroid_x = 0
    local centroid_y = r
    for i = 1, #lines do
        local x0, x1 = unpack(lines[i])
        x0 = x0 - min_x + 1
        x1 = x1 - min_x + 1
        centroid_x = centroid_x + x0 + x1
        lines[i] = { x0, x1 }
    end
    centroid_x = math.floor(.5 * centroid_x / #lines)
    
    return centroid_x, centroid_y, lines
end

return perlin_island

--[[
require('os')

local r = 20
local params = { { 10, 1 }, { 2, 4 } } -- [ (amp_i, freq_i) ]
local seed = os.time()
local centroid_x, centroid_y, lines = perlin_island(r, params, seed)

print(seed)
print(r)
print(centroid_x - 1, centroid_y - 1)
for i = 1, #lines do
    local x0, x1 = unpack(lines[i])
    print(i - 1, x0 - 1, x1 - 1)
end
--]]
