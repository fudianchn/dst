_G = GLOBAL

LoadPOFile("guido.po", "chs")

if _G.debug.getupvalue(string.match, 1) == nil then
    -- 修复因游戏原因无法正确匹配中文
    local fr_old_match = string.match
    function string.match(str, pattern, index)
        return fr_old_match(str, pattern:gsub("%%w", "[%%w一-鿕]"), index)
    end
end