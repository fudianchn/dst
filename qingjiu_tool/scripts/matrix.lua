-- 17-oct-2015
-- Goat <goat@ridiculousglitch.com>
-- Matrix class with basic algebraic operations

require('math')

local Matrix = { }
local MatrixMt = { __index = Matrix }

local function allocate_rows(rows, t)
    local m = t or { }
    for i = 1, rows do
        m[i] = { }
    end
    return m
end

local function map1(m, fn)
    local result = allocate_rows(m.rows)
    for i = 1, m.rows do
        for j = 1, m.cols do
            result[i][j] = fn(m[i][j])
        end
    end
    return Matrix(result)
end

local function map2(m1, m2, fn)
    local result = { }
    if m1.rows == m2.rows and m1.cols == m2.cols then
        allocate_rows(m1.rows, result)
        for i = 1, m1.rows do
            for j = 1, m1.cols do
                result[i][j] = fn(m1[i][j], m2[i][j])
            end
        end
    end
    return Matrix(result)
end

function Matrix.random(n, m, seed)
    local result = allocate_rows(n)
    if seed ~= nil then
        math.randomseed(seed)
    end
    for i = 1, n do
        for j = 1, m do
            result[i][j] = math.random()
        end
    end
    return Matrix(result)
end

function Matrix:unpack()
    local t = { }
    for i = 1, self.rows do
        for j = 1, self.cols do
            table.insert(t, self[i][j])
        end
    end
    return unpack(t)
end

function Matrix:empty()
    return (self.rows == 0)
end

function Matrix:transposed()
    local m = allocate_rows(self.cols)
    for i = 1, self.rows do
        for j = 1, self.cols do
            m[j][i] = self[i][j]
        end
    end    
    return Matrix(m)
end

function Matrix:hconcat(m)
    local result = { }
    if self.rows == m.rows then
        allocate_rows(self.rows, result)
        for i = 1, self.rows do
            for j = 1, self.cols do
                result[i][j] = self[i][j]
            end
            for j = 1, m.cols do
                result[i][j + self.cols] = m[i][j]
            end
        end
    end
    return Matrix(result)
end

function Matrix:vconcat(m)
    local result = { }
    if self.cols == m.cols then
        allocate_rows(self.rows + m.rows, result)
        for j = 1, self.cols do
            for i = 1, self.rows do
                result[i][j] = self[i][j]
            end
            for i = 1, m.rows do
                result[i + self.rows][j] = m[i][j]
            end
        end
    end
    return Matrix(result)
end

--[[
function Matrix:norm(axis)
    local cols = (axis == 1 and self.cols or (axis == 2 and self.rows or 1))
    local s = Matrix(1, cols, 0)
    for i = 1, self.rows do
        for j = 1, self.cols do
            local k = (axis == 1 and j or (axis == 2 and i or 1))
            s[1][k] = s[1][k] + self[i][j]^2
        end
    end
    
    for k = 1, cols do
        s[1][k] = math.sqrt(s[1][k])
    end

    if axis == nil then
        return s:unpack()
    else
        return s
    end
end
--]]

function Matrix:norm()
    local s = 0
    for i = 1, self.rows do
        for j = 1, self.cols do
            s = s + self[i][j]^2
        end
    end    
    return math.sqrt(s)
end

function Matrix:normalized()
    return self / self:norm()
end

function Matrix:dot(m)
    local out = { }
    if self.rows > 0 and m.rows > 0 or self.cols == m.rows then
        for i = 1, self.rows do
            out[i] = { }
        end
        
        for i = 1, self.rows do
            for j = 1, m.cols do
                local s = 0
                for k = 1, self.cols do
                    s = s + self[i][k] * m[k][j]
                end
                out[i][j] = s
            end
        end
    end
    
    return Matrix(out)
end

function MatrixMt:__tostring()
    local function mat_tostring_row(row)
        local s = tostring(row[1])
        for j = 2, #row do
            s = s .. ', ' .. tostring(row[j])
        end
        return s
    end
    
    local n = self.rows
    if n == 0 then
        return '[ ]'
    end
    
    local s = '[ ' .. mat_tostring_row(self[1])
    for i = 2, n do
        s = s .. ',\n  ' .. mat_tostring_row(self[i])
    end    
    return s .. ' ]'
end

function MatrixMt:__unm()
    return map1(self, function(v) return -v end)
end

function MatrixMt:__add(x)
    if type(self) == 'number' then
        self, x = x, self
    end
    if type(x) == 'number' then
        return map1(self, function(v) return v + x end)
    else
        return map2(self, x, function(v1, v2) return v1 + v2 end)
    end
end

function MatrixMt:__sub(x)
    if type(self) == 'number' then
        return map1(x, function(v) return self - v end)
    elseif type(x) == 'number' then
        return map1(self, function(v) return v - x end)
    else
        return map2(self, x, function(v1, v2) return v1 - v2 end)
    end
end

function MatrixMt:__mul(x)
    if type(self) == 'number' then
        self, x = x, self
    end
    if type(x) == 'number' then
        return map1(self, function(v) return v * x end)
    else
        return map2(self, x, function(v1, v2) return v1 + v2 end)
    end
end

function MatrixMt:__div(x)
    if type(self) == 'number' then
        return map1(x, function(v) return self / v end)
    elseif type(x) == 'number' then
        return map1(self, function(v) return v / x end)
    else
        return map2(self, x, function(v1, v2) return v1 / v2 end)
    end
end

function MatrixMt:__eq(m)
    if self.rows ~= m.rows or self.cols ~= m.cols then
        return false
    end
    for i = 1, self.rows do
        for j = 1, self.cols do
            if self[i][j] ~= m[i][j] then
                return false
            end
        end
    end
    return true
end

function MatrixMt:__len()
    return self.rows
end

local function MatrixNew(_, n, m, v)
    if v == nil then
        v = 0
    end
    
    local mat
    if m == nil and type(n) == 'table' then
        local rows = #n
        local cols = n[1] and #n[1] or 0
        mat = n
        mat.rows = rows
        mat.cols = cols
    else
        local rows = n
        local cols = m
        if rows == 0 or cols == nil then
            cols = 0
        end
        mat = { rows=rows, cols=cols }
        for i = 1, n do
            mat[i] = { }
            for j = 1, m do
                mat[i][j] = v
            end
        end
    end
    
    return setmetatable(mat, MatrixMt)
end

return setmetatable(Matrix, { __call = MatrixNew })

--[[
-- local Matrix = require('matrix')

local a = Matrix({
    { 1, 2 },
    { 3, 4 },
    { 5, 6 } 
})

local b = Matrix({
    { 1, 1 },
    { 2, 1 },
    { 3, 1 } 
})

print('a = \n' .. tostring(a))
print('\nb = \n' .. tostring(b))
print('\nT[b] = \n' .. tostring(b:transposed()))
print('\na x T[b] = \n' .. tostring(a:dot(b:transposed())))
print('\n0.5 * a = \n' .. tostring(0.5 * b))
print('\na + b = \n' .. tostring(a + b))
print('\na - b = \n' .. tostring(a - b))
print('\nb - 1 = \n' .. tostring(b - 1))
print('\n1 - b = \n' .. tostring(1 - b))
print('\na * b = \n' .. tostring(a * b))
print('\nrandom 3x3 [-100, +100] (with seed=42) = \n' .. tostring(200 * Matrix.random(3, 3, 0) - 100))
print('\n||a|| = ' .. tostring(a:norm()))
--print('||a||_1 = ' .. tostring(a:norm(1)))
--print('||a||_2 = ' .. tostring(a:norm(2)))
print()

local v1 = Matrix({{ 1, 2 }})
local v2 = Matrix({{ 3, 4 }})

print('v1 = ' .. tostring(v1), 'v2 = ' .. tostring(v2))
print('\nv1 + v2 = ' .. tostring(v1 + v2))
print('v1 + v2 = -(-v2 - v1) is ' .. tostring((v1 + v2) == -(-v2 - v1)))
print('v1 x v2 = ' .. tostring(v1:dot(v2:transposed()):unpack()))
--]]
