local unpack = GLOBAL.unpack
local require = GLOBAL.require
local TILE_SCALE = GLOBAL.TILE_SCALE
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local Ingredient = GLOBAL.Ingredient
local TheWorld, TheSim, SpawnPrefab

local perlin_island = require("perlin_island")

GLOBAL.STRINGS.NAMES.GRABOID = "梦乡"
GLOBAL.STRINGS.NAMES.DYNAMITE = "梦乡烟花"
GLOBAL.STRINGS.RECIPE_DESC.DYNAMITE = "记住并按固定顺序喂我三样物品做钥匙."

PrefabFiles = {
    "graboid",
    "dynamite"
}

Assets = {
    Asset("ANIM", "anim/graboid.zip"),
    Asset("ANIM", "anim/dynamite.zip"),
    Asset("ATLAS", "images/shared_islands_inventory.xml"),
    Asset("IMAGE", "images/shared_islands_inventory.tex"),
    Asset("ATLAS", "minimap/shared_islands_minimap.xml"),
    Asset("IMAGE", "minimap/shared_islands_minimap.tex"),
    Asset("SOUNDPACKAGE", "sound/graboid.fev"),
    Asset("SOUND", "sound/graboid.fsb")
}

AddMinimapAtlas("minimap/shared_islands_minimap.xml")
--炸药配方8个火药8个红宝石2个绳索
local dynamiteRecipe = { { "gunpowder", 8 }, { "redgem", 8 }, { "rope", 2 } }
local ingredients = {}
for i = 1, #dynamiteRecipe do
    ingredients[#ingredients + 1] = Ingredient(dynamiteRecipe[i][1], dynamiteRecipe[i][2])
end
local dynamite = AddRecipe("dynamite", ingredients, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO)
dynamite.atlas = "images/shared_islands_inventory.xml"

AddComponentAction("SCENE", "multiteleporter",
    function(inst, doer, actions)
        if inst:HasTag("multiteleporter") then
            table.insert(actions, GLOBAL.ACTIONS.JUMPIN)
        end
    end,
    "shared_islands"
)

AddPrefabPostInit("world", function(inst)
    if inst.ismastersim then
        inst:AddComponent("shared_islands")
    end
end)

local function check_line(y, x0, x1)
    local size_x, size_y = TheWorld.Map:GetSize()
    if x0 < 1 or x0 > size_x or y < 0 or y > size_y then
        return false
    end
    for x = x0, x1 do
        if TheWorld.Map:GetTile(x, y) ~= GLOBAL.GROUND.IMPASSABLE then
            return false
        end
    end
    return true
end

local function find_place(lines, margin)
    local size_x, size_y = TheWorld.Map:GetSize()

    for i = 1, 1000 do
        local tx = math.floor(size_x * math.random())
        local ty = math.floor(size_y * math.random())

        local found = true

        for j = 1, margin do
            local x0, x1 = unpack(lines[1])
            found = check_line(ty - j, tx + x0 - margin, tx + x1 + margin)
            x0, x1 = unpack(lines[#lines])
            found = found and check_line(ty + #lines + j, tx + x0 - margin, tx + x1 + margin)

            if not found then
                break
            end
        end

        if found then
            for y, line in ipairs(lines) do
                local x0, x1 = unpack(line)
                if not check_line(ty + y, tx + x0 - margin, tx + x1 + margin) then
                    found = false
                    break
                end
            end

            if found then
                return tx, ty
            end
        end
    end
end

local function set_tile(x, y, t)
    local map = TheWorld.Map
    local tile = map:GetTile(x, y)

    map:SetTile(x, y, t)
    map:RebuildLayer(tile, x, y)
    map:RebuildLayer(t, x, y)
end

local function get_tile_pos(x, y)
    local x0, y0 = TheWorld.Map:GetTileCoordsAtPoint(0, 0, 0)
    return (x - x0) * TILE_SCALE, 0, (y - y0) * TILE_SCALE
end

local function gen_island()
    --岛屿尺寸为15左右
    local centroid_x, centroid_y, lines = perlin_island(math.floor(15 * (0.85 + 0.3 * math.random())), { { 0.5, 1 }, { 0.35, 4 } })
    local tx, ty = find_place(lines, 12)
    local terrains = {
        GLOBAL.GROUND.MARSH,
        GLOBAL.GROUND.ROCKY,
        GLOBAL.GROUND.SAVANNA,
        GLOBAL.GROUND.FOREST,
        GLOBAL.GROUND.GRASS,
        GLOBAL.GROUND.DIRT
    }
    local terrain = terrains[ 1 + math.floor(math.random() * #terrains) ]

    if tx == nil or ty == nil then
        return nil
    end

    for y, line in ipairs(lines) do
        local x0, x1 = unpack(line)
        for x = x0, x1 do
            set_tile(tx + x, ty + y, terrain)
        end
    end

    local graboid = SpawnPrefab("graboid")
    graboid.components.multiteleporter.isroot = true
    graboid.components.multiteleporter.unbindDays = 384
    graboid.Transform:SetPosition(get_tile_pos(tx + centroid_x, ty + centroid_y))
    return graboid
end

AddSimPostInit(function()
    TheWorld = GLOBAL.TheWorld
    TheSim = GLOBAL.TheSim
    SpawnPrefab = GLOBAL.SpawnPrefab

    if TheWorld.ismastersim then
        local shared_island_hub = TheSim:FindFirstEntityWithTag("multiteleporter_root")

        if shared_island_hub == nil then
            --最大20个岛屿
            local n = 10
            for i = 1, n do
                local hub = gen_island()
                if hub ~= nil then
                    TheWorld.components.shared_islands:AddHub(hub)
                else
                    n = i - 1
                end
            end

            if n <= 0 then
                print('WARNING: no islands can be generated!')
            else
                print(tostring(n) .. ' islands generated. Resetting...')

                TheWorld:DoTaskInTime(1, function()
                    for i, v in ipairs(GLOBAL.AllPlayers) do
                        v:OnDespawn()
                    end
                    GLOBAL.TheSystemService:EnableStorage(true)
                    GLOBAL.SaveGameIndex:SaveCurrent(function()
                        GLOBAL.StartNextInstance({
                            reset_action = GLOBAL.RESET_ACTION.LOAD_SLOT,
                            save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()
                        })
                    end, true)
                end)
            end
        else
            --跳世界不掉san
            TheWorld.components.shared_islands.sanityDrop = 0

            TheWorld:ListenForEvent("cycleschanged", function(inst)
                for _, hub in pairs(inst.components.shared_islands.hubs) do
                    local hubmt = hub.components.multiteleporter
                    if hubmt.unbindDays ~= nil and hubmt.unbindDays ~= 0 and hubmt.lastDayUsed ~= nil and (inst.state.cycles - hubmt.lastDayUsed) >= hubmt.unbindDays then
                        -- Unbind
                        local oldTargets = {}
                        for target, _ in pairs(hubmt.targetTeleporters) do
                            oldTargets[#oldTargets + 1 ] = target
                        end

                        for _, target in pairs(oldTargets) do
                                target:Remove()
                        end
                    end
                end
            end)
        end
    end
end)





--fr榜文告示
local function WelcomeMessageInit(inst)
	inst:AddComponent("message")
	inst.components.message:SetTitle("榜文告示")
	inst.components.message:SetMessage("作为一名饥荒玩家,你要学会自己生存\n1.点击城门选择城堡\n2.时间季节异步执行\n其他详情参见Q群\n868423108")
end

AddPrefabPostInit("world", WelcomeMessageInit)