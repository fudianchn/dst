local unpack = GLOBAL.unpack
local require = GLOBAL.require
local TILE_SCALE = GLOBAL.TILE_SCALE
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local Ingredient = GLOBAL.Ingredient
local TheWorld, TheSim, SpawnPrefab

local perlin_island = require("perlin_island")

GLOBAL.STRINGS.NAMES.GRABOID = "梦岛"
GLOBAL.STRINGS.NAMES.DYNAMITE = "梦岛烟花"
GLOBAL.STRINGS.RECIPE_DESC.DYNAMITE = "每座城堡只有一座岛屿"

PrefabFiles = {
    "graboid",
    "dynamite",
    "seffc",
    "klaussack_placer",
    "achivbooks",
    "expbean",
    "opalamulet",
    "mudwall.lua",
    "reedwall.lua",
    "bonewall.lua",
    "hedgewall.lua",
    "livingwall.lua",
    "carrot_planted_placer.lua",
    "cave_fern_placer.lua",
    "mandrake_planted_placer.lua",
    "marbletree_placer.lua",
    "marblepillar_placer.lua",
    "succulent_placer.lua",
    "cave_banana_placer",
    "cactus_placer",
    "statuemaxwell_placer",
    "pigtorch_placer",
    "rose_placer",
    "pumpkin_planted.lua",
    "pumpkin_planted_placer.lua",
}

Assets = {
    Asset("ANIM", "anim/graboid.zip"),
    Asset("ANIM", "anim/dynamite.zip"),
    Asset("ATLAS", "images/shared_islands_inventory.xml"),
    Asset("IMAGE", "images/shared_islands_inventory.tex"),
    Asset("ATLAS", "minimap/shared_islands_minimap.xml"),
    Asset("IMAGE", "minimap/shared_islands_minimap.tex"),
    Asset("SOUNDPACKAGE", "sound/graboid.fev"),
    Asset("SOUND", "sound/graboid.fsb"),

    Asset("ATLAS", "images/inventoryimages/expbean.xml"),
    Asset("IMAGE", "images/inventoryimages/expbean.tex"),

    Asset("ATLAS", "images/inventoryimages/klaussack.xml"),
    Asset("IMAGE", "images/inventoryimages/klaussack.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_birds.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_birds.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_brimstone.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_brimstone.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_gardening.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_gardening.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_sleep.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_sleep.tex"),

    Asset("ATLAS", "images/inventoryimages/achivbook_tentacles.xml"),
    Asset("IMAGE", "images/inventoryimages/achivbook_tentacles.tex"),

    Asset("ATLAS", "images/hud/bigtitle_cn.xml"),
    Asset("IMAGE", "images/hud/bigtitle_cn.tex"),

    Asset("ATLAS", "images/hud/bigtitle_en.xml"),
    Asset("IMAGE", "images/hud/bigtitle_en.tex"),

    Asset("ATLAS", "images/hud/achivbg_act.xml"),
    Asset("IMAGE", "images/hud/achivbg_act.tex"),
    Asset("ATLAS", "images/hud/achivbg_dact.xml"),
    Asset("IMAGE", "images/hud/achivbg_dact.tex"),

    Asset("ATLAS", "images/button/last_act.xml"),
    Asset("IMAGE", "images/button/last_act.tex"),
    Asset("ATLAS", "images/button/last_dact.xml"),
    Asset("IMAGE", "images/button/last_dact.tex"),

    Asset("ATLAS", "images/button/next_act.xml"),
    Asset("IMAGE", "images/button/next_act.tex"),
    Asset("ATLAS", "images/button/next_dact.xml"),
    Asset("IMAGE", "images/button/next_dact.tex"),

    Asset("ATLAS", "images/button/close.xml"),
    Asset("IMAGE", "images/button/close.tex"),

    Asset("ATLAS", "images/button/infobutton.xml"),
    Asset("IMAGE", "images/button/infobutton.tex"),

    Asset("ATLAS", "images/button/info_cn.xml"),
    Asset("IMAGE", "images/button/info_cn.tex"),

    Asset("ATLAS", "images/button/info_en.xml"),
    Asset("IMAGE", "images/button/info_en.tex"),

    Asset("ATLAS", "images/button/checkbutton.xml"),
    Asset("IMAGE", "images/button/checkbutton.tex"),

    Asset("ATLAS", "images/button/checkbuttonglow.xml"),
    Asset("IMAGE", "images/button/checkbuttonglow.tex"),

    Asset("ATLAS", "images/button/coinbutton.xml"),
    Asset("IMAGE", "images/button/coinbutton.tex"),

    Asset("ATLAS", "images/button/coinbuttonglow.xml"),
    Asset("IMAGE", "images/button/coinbuttonglow.tex"),

    Asset("ATLAS", "images/button/config_act.xml"),
    Asset("IMAGE", "images/button/config_act.tex"),

    Asset("ATLAS", "images/button/config_dact.xml"),
    Asset("IMAGE", "images/button/config_dact.tex"),

    Asset("ATLAS", "images/button/config_bg.xml"),
    Asset("IMAGE", "images/button/config_bg.tex"),

    Asset("ATLAS", "images/button/config_bigger.xml"),
    Asset("IMAGE", "images/button/config_bigger.tex"),

    Asset("ATLAS", "images/button/config_smaller.xml"),
    Asset("IMAGE", "images/button/config_smaller.tex"),

    Asset("ATLAS", "images/button/config_drag.xml"),
    Asset("IMAGE", "images/button/config_drag.tex"),

    Asset("ATLAS", "images/button/config_remove.xml"),
    Asset("IMAGE", "images/button/config_remove.tex"),

    Asset("ATLAS", "images/button/remove_info_cn.xml"),
    Asset("IMAGE", "images/button/remove_info_cn.tex"),

    Asset("ATLAS", "images/button/remove_info_en.xml"),
    Asset("IMAGE", "images/button/remove_info_en.tex"),

    Asset("ATLAS", "images/button/remove_yes.xml"),
    Asset("IMAGE", "images/button/remove_yes.tex"),

    Asset("ATLAS", "images/button/remove_no.xml"),
    Asset("IMAGE", "images/button/remove_no.tex"),

    Asset("ATLAS", "images/mark_1.xml"),
    Asset("ATLAS", "images/mark_2.xml"),
    Asset("ATLAS", "images/mark_3.xml"),
    Asset("ATLAS", "images/mark_4.xml"),
    Asset("ATLAS", "images/mark_5.xml"),
    Asset("ATLAS", "images/mark_6.xml"),
    Asset("ATLAS", "images/mark_7.xml"),
    Asset("ATLAS", "images/mark_8.xml"),
    Asset("ATLAS", "images/mark_9.xml"),
    Asset("ATLAS", "images/mark_10.xml"),
    Asset("ATLAS", "images/mark_11.xml"),
    Asset("ATLAS", "images/mark_12.xml"),
    Asset("ATLAS", "images/mark_13.xml"),
    Asset("ATLAS", "images/mark_14.xml"),
    Asset("ATLAS", "images/mark_15.xml"),
    Asset("ATLAS", "images/mark_16.xml"),
    Asset("ATLAS", "images/mark_17.xml"),
    Asset("ATLAS", "images/mark_18.xml"),
    Asset("ATLAS", "images/mark_19.xml"),
    Asset("ATLAS", "images/mark_20.xml"),
    Asset("ATLAS", "images/mark_21.xml"),
    Asset("ATLAS", "images/mark_22.xml"),

    Asset("ANIM", "anim/swap_book_maxwell.zip"),

    Asset("ANIM", "anim/wall_mud.zip"), --This is the animation for your item while it is on the ground
    Asset("ANIM", "anim/wall_reed.zip"),
    Asset("ANIM", "anim/wall_bone.zip"),
    Asset("ANIM", "anim/wall_hedge.zip"),
    Asset("ANIM", "anim/wall_living.zip"),
    Asset("ATLAS", "images/wall_mud_item.xml"),
    Asset("ATLAS", "images/wall_reed_item.xml"),
    Asset("ATLAS", "images/wall_bone_item.xml"),
    Asset("ATLAS", "images/wall_hedge_item.xml"),
    Asset("ATLAS", "images/wall_living_item.xml"),
    Asset("IMAGE", "images/wall_mud_item.tex"),
    Asset("IMAGE", "images/wall_reed_item.tex"),
    Asset("IMAGE", "images/wall_bone_item.tex"),
    Asset("IMAGE", "images/wall_hedge_item.tex"),
    Asset("IMAGE", "images/wall_living_item.tex"),
    Asset("ATLAS", "images/inventoryimages/mandrake_planted.xml"), -- Mandrakes Info
    Asset("IMAGE", "images/inventoryimages/mandrake_planted.tex"), -- Mandrakes Texture
    Asset("ATLAS", "images/inventoryimages/carrot_planted.xml"), -- Carrots Info
    Asset("IMAGE", "images/inventoryimages/carrot_planted.tex"), -- Carrots Texture
    Asset("ATLAS", "images/inventoryimages/succulent_planted.xml"), -- Succulents Info
    Asset("IMAGE", "images/inventoryimages/succulent_planted.tex"), -- Succulents Texture
    Asset("ATLAS", "images/inventoryimages/cave_fern_planted.xml"), -- Ferns Info
    Asset("IMAGE", "images/inventoryimages/cave_fern_planted.tex"), -- Ferns Texture
    Asset("ATLAS", "images/inventoryimages/marbletree.xml"), -- Marble Trees Info
    Asset("IMAGE", "images/inventoryimages/marbletree.tex"), -- Marble Trees Texture
    Asset("ATLAS", "images/inventoryimages/marblepillar.xml"), -- Marble Pillars Info
    Asset("IMAGE", "images/inventoryimages/marblepillar.tex"), -- Marble Pillars Texture
    Asset("ATLAS", "images/inventoryimages/bananatree.xml"), -- Banana Tree Info
    Asset("IMAGE", "images/inventoryimages/bananatree.tex"), -- Banana Tree Texture
    Asset("ATLAS", "images/inventoryimages/cacti.xml"), -- Cactus Info
    Asset("IMAGE", "images/inventoryimages/cacti.tex"), -- Cactus Texture
    Asset("ATLAS", "images/inventoryimages/statuemaxwell.xml"), -- Maxwell Statue Info
    Asset("IMAGE", "images/inventoryimages/statuemaxwell.tex"), -- Maxwell Statue Texture
    Asset("ATLAS", "images/inventoryimages/pigtorch.xml"), -- Pig Torch Info
    Asset("IMAGE", "images/inventoryimages/pigtorch.tex"), -- Pig Torch Texture
    Asset("ATLAS", "images/inventoryimages/rose.xml"), -- Rose Flower Info
    Asset("IMAGE", "images/inventoryimages/rose.tex"), -- Rose Flower Texture
    Asset("ATLAS", "images/inventoryimages/pumpkin.xml"), -- Planted Pumpkin
    Asset("IMAGE", "images/inventoryimages/pumpkin.tex"), -- Planted Pumpkin
    Asset("IMAGE", "images/container.tex"),
    Asset("ATLAS", "images/container.xml"),
    Asset("IMAGE", "images/container_x20.tex"),
    Asset("ATLAS", "images/container_x20.xml"),
    Asset("IMAGE", "images/krampus_sack_bg.tex"),
    Asset("ATLAS", "images/krampus_sack_bg.xml"),
}

AddMinimapAtlas("minimap/shared_islands_minimap.xml")
--炸药配方12个紫宝石68个绳索20个火药
local dynamiteRecipe = { { "purplegem", 12 }, { "rope", 68 }, { "gunpowder", 20 } }
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
    "shared_islands")

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
    local terrain = terrains[1 + math.floor(math.random() * #terrains)]

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
            --最大1个岛屿
            local n = 1
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
                            oldTargets[#oldTargets + 1] = target
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





--fr任务系统
local _G = GLOBAL
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH
local TheInput = GLOBAL.TheInput
require 'AllAchiv/allachivbalance'
require 'AllAchiv/strings_acm_c'
TUNING.AllAchivLan = "cn"

require "AllAchiv/allachivrpc"


STRINGS.NAMES.EXPBEAN = "经验豆"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.EXPBEAN = "增加2000经验!"


local namelist = {
    "intogame",
    "firsteat",
    "supereat",
    "danding",
    "a_6",
    "messiah",
    "walkalot",
    "stopalot",
    "tooyoung",
    "evil",
    "snake",

    "deathalot",
    "nosanity",
    "sick",
    "coldblood",
    "burn",
    "freeze",
    "goodman",
    "brother",
    "a_7",
    "a_8",
    "fishmaster",
    "pickmaster",
    "chopmaster",
    "cookmaster",
    "buildmaster",
    "longage",
    "noob",
    "luck",
    "black",
    "tank",
    "angry",
    "icebody",
    "firebody",
    "moistbody",

    --================================
    "a_yingguai",
    "a_worm",
    "a_monkey",
    "a_buzzard",
    "a_lightninggoat",
    "a_spiderqueen",
    "a_spider",
    "a_spider_warrior",
    "a_spider_dropper",
    "a_spider_hider",
    "a_spider_spitter",
    "a_warg",
    "a_hound",
    "a_firehound",
    "a_icehound",
    "a_koalefant_summer",
    "a_koalefant_winter",
    "a_catcoon",
    "a_bunnyman",
    "a_leif",
    "a_slurtle",
    "a_tallbird",
    "a_walrus",
    "a_bat",
    "a_butterfly",
    "a_killerbee",
    "a_deer",
    "a_mole",
    "a_mosquito",
    "a_penguin",
    "a_merm",
    "a_frog",
    "a_beefalo",
    "a_perd",
    "a_krampus",
    "a_robin_crow",
    "a_robin_robin",
    "a_robin_winter",
    "a_robin_canary",
    "a_pigman",
    "a_shadow_knight",
    "a_shadow_bishop",
    "a_shadow_rook",
    "a_moose",
    "a_dragonfly",
    "a_bearger",
    "a_deerclops",
    "a_stalker_forest",
    "a_stalker",
    "a_stalker_atrium",
    "a_klaus",
    "a_antlion",
    "a_minotaur",
    "a_beequeen",
    "a_toadstool",
    "a_toadstool_dark",

    "a_9",
    "a_10",
    "a_11",
    "a_12",


    "a_tallbirdegg",
    "a_frogglebunwich",
    "a_baconeggs",
    "a_bonestew",
    "a_fishtacos",
    "a_turkeydinner",
    "a_fishsticks",
    "a_meatballs",
    "a_perogies",
    "a_bisque",
    "a_surfnturf",
    "a_tigershark",
    "a_twister",
    "a_snake",
    "a_snake_poison",
    "a_crocodog",
    "a_poisoncrocodog",
    "a_watercrocodog",
    "a_coffee",
    "a_a5",
    "a_a6",
    "a_a7",
    "a_a8",


    "a_a9", --击杀6只秃鹫      死亡聚集地
    "a_a10", --击杀11只缀食者     吃豆豆
    "a_a11", --装备缀食者800秒       撑得慌
    "a_a12", --装备独奏乐器800秒    一个人的乐队
    "a_a13", --制作22个大理石盔甲    不痛不痒
    "a_a14", --制作33个铥矿皇冠     远古三件套 Ⅰ
    "a_a15", --制作33个铥矿盔甲     远古三件套 Ⅱ
    "a_a16", --制作33个铥矿棒       远古三件套 Ⅲ
    "a_a17", --制作200个火药           一硫二硝三木炭
    "a_a18", --制作80个噩梦燃料     黑燃料
    "a_a19", --制作6个南瓜灯    万圣节
    "a_a20", --制作88个治疗药膏   小伤无碍
    "a_a21", --制作66个蜂蜜药膏  甜蜜绷带
    "a_a22", --采集88次仙人掌   扎手手







    --================================
    "all",
}

for k, v in pairs(namelist) do
    table.insert(Assets, Asset("ATLAS", "images/hud/achivtile_act_" .. TUNING.AllAchivLan .. "_" .. v .. ".xml"))
    table.insert(Assets, Asset("IMAGE", "images/hud/achivtile_act_" .. TUNING.AllAchivLan .. "_" .. v .. ".tex"))
    table.insert(Assets, Asset("ATLAS", "images/hud/achivtile_dact_" .. TUNING.AllAchivLan .. "_" .. v .. ".xml"))
    table.insert(Assets, Asset("IMAGE", "images/hud/achivtile_dact_" .. TUNING.AllAchivLan .. "_" .. v .. ".tex"))
end

local coinlist = {
    "hungerup",
    "sanityup",
    "healthup",
    "hungerrateup",
    "healthregen",
    "sanityregen",
    "speedup",
    "damageup",
    "absorbup",
    "crit",
    "fireflylight",
    "nomoist",
    "doubledrop",
    "goodman",
    "fishmaster",
    "pickmaster",
    "chopmaster",
    "cookmaster",
    "buildmaster",
    "refresh",
    "icebody",
    "firebody",
    "supply",
    "reader",
    "jump",
    "level",
    "fastpicker",
}

for k, v in pairs(coinlist) do
    table.insert(Assets, Asset("ATLAS", "images/coin_" .. TUNING.AllAchivLan .. "/" .. v .. ".xml"))
    table.insert(Assets, Asset("IMAGE", "images/coin_" .. TUNING.AllAchivLan .. "/" .. v .. ".tex"))
end

--独立同名书本，解决与可做书人物冲突的问题
AddRecipe("achivbook_birds", { Ingredient("papyrus", 2), Ingredient("bird_egg", 2) },
    RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder",
    "images/inventoryimages.xml", "book_birds.tex")

AddRecipe("achivbook_gardening", { GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("seeds", 1), GLOBAL.Ingredient("poop", 1) },
    RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder",
    "images/inventoryimages.xml", "book_gardening.tex")

AddRecipe("achivbook_sleep", { GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("nightmarefuel", 2) },
    RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder",
    "images/inventoryimages.xml", "book_sleep.tex")

AddRecipe("achivbook_brimstone", { GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("redgem", 1) },
    RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder",
    "images/inventoryimages.xml", "book_brimstone.tex")

AddRecipe("achivbook_tentacles", { GLOBAL.Ingredient("papyrus", 2), GLOBAL.Ingredient("tentaclespots", 1) },
    RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "achivbookbuilder",
    "images/inventoryimages.xml", "book_tentacles.tex")

--添加克劳斯背包建造
AddRecipe("klaus_sack", { Ingredient("redmooneye", 1), Ingredient("bluemooneye", 1), Ingredient("silk", 8) }, RECIPETABS.MAGIC, TECH.NONE,
    "klaussack_placer", --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    "achiveking", -- builder_tag
    "images/inventoryimages/klaussack.xml", -- atlas
    "klaussack.tex") -- image

--添加克劳斯背包钥匙建造
AddRecipe("deer_antler1", { Ingredient("boneshard", 2), Ingredient("twigs", 1) }, RECIPETABS.MAGIC, TECH.NONE,
    nil, --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    "achiveking", -- builder_tag
    "images/inventoryimages.xml", -- atlas
    "deer_antler1.tex") -- image

--预运行
AddPlayerPostInit(function(inst)
    inst.checkintogame = GLOBAL.net_shortint(inst.GUID, "checkintogame")
    inst.checkfirsteat = GLOBAL.net_shortint(inst.GUID, "checkfirsteat")
    inst.checksupereat = GLOBAL.net_shortint(inst.GUID, "checksupereat")
    inst.checkdanding = GLOBAL.net_shortint(inst.GUID, "checkdanding")
    inst.checkmessiah = GLOBAL.net_shortint(inst.GUID, "checkmessiah")
    inst.checkwalkalot = GLOBAL.net_shortint(inst.GUID, "checkwalkalot")
    inst.checkstopalot = GLOBAL.net_shortint(inst.GUID, "checkstopalot")
    inst.checktooyoung = GLOBAL.net_shortint(inst.GUID, "checktooyoung")
    inst.checkevil = GLOBAL.net_shortint(inst.GUID, "checkevil")
    inst.checksnake = GLOBAL.net_shortint(inst.GUID, "checksnake")

    inst.checkdeathalot = GLOBAL.net_shortint(inst.GUID, "checkdeathalot")
    inst.checknosanity = GLOBAL.net_shortint(inst.GUID, "checknosanity")
    inst.checksick = GLOBAL.net_shortint(inst.GUID, "checksick")
    inst.checkcoldblood = GLOBAL.net_shortint(inst.GUID, "checkcoldblood")
    inst.checkburn = GLOBAL.net_shortint(inst.GUID, "checkburn")
    inst.checkfreeze = GLOBAL.net_shortint(inst.GUID, "checkfreeze")
    inst.checkgoodman = GLOBAL.net_shortint(inst.GUID, "checkgoodman")
    inst.checkbrother = GLOBAL.net_shortint(inst.GUID, "checkbrother")
    inst.checkfishmaster = GLOBAL.net_shortint(inst.GUID, "checkfishmaster")
    inst.checkpickmaster = GLOBAL.net_shortint(inst.GUID, "checkpickmaster")
    inst.checkchopmaster = GLOBAL.net_shortint(inst.GUID, "checkchopmaster")
    inst.checknoob = GLOBAL.net_shortint(inst.GUID, "checknoob")
    inst.checkcookmaster = GLOBAL.net_shortint(inst.GUID, "checkcookmaster")
    inst.checklongage = GLOBAL.net_shortint(inst.GUID, "checklongage")
    inst.checkluck = GLOBAL.net_shortint(inst.GUID, "checkluck")
    inst.checkblack = GLOBAL.net_shortint(inst.GUID, "checkblack")
    inst.checkbuildmaster = GLOBAL.net_shortint(inst.GUID, "checkbuildmaster")
    inst.checktank = GLOBAL.net_shortint(inst.GUID, "checktank")
    inst.checkangry = GLOBAL.net_shortint(inst.GUID, "checkangry")
    inst.checkicebody = GLOBAL.net_shortint(inst.GUID, "checkicebody")
    inst.checkfirebody = GLOBAL.net_shortint(inst.GUID, "checkfirebody")
    inst.checkmoistbody = GLOBAL.net_shortint(inst.GUID, "checkmoistbody")



    --==========================================================================================
    inst.checka_yingguai = GLOBAL.net_shortint(inst.GUID, "checka_yingguai")
    inst.checka_worm = GLOBAL.net_shortint(inst.GUID, "checka_worm")
    inst.checka_monkey = GLOBAL.net_shortint(inst.GUID, "checka_monkey")
    inst.checka_buzzard = GLOBAL.net_shortint(inst.GUID, "checka_buzzard")
    inst.checka_lightninggoat = GLOBAL.net_shortint(inst.GUID, "checka_lightninggoat")
    inst.checka_spiderqueen = GLOBAL.net_shortint(inst.GUID, "checka_spiderqueen")
    inst.checka_spider = GLOBAL.net_shortint(inst.GUID, "checka_spider")
    inst.checka_spider_warrior = GLOBAL.net_shortint(inst.GUID, "checka_spider_warrior")
    inst.checka_spider_dropper = GLOBAL.net_shortint(inst.GUID, "checka_spider_dropper")
    inst.checka_spider_hider = GLOBAL.net_shortint(inst.GUID, "checka_spider_hider")
    inst.checka_spider_spitter = GLOBAL.net_shortint(inst.GUID, "checka_spider_spitter")
    inst.checka_warg = GLOBAL.net_shortint(inst.GUID, "checka_warg")
    inst.checka_hound = GLOBAL.net_shortint(inst.GUID, "checka_hound")
    inst.checka_firehound = GLOBAL.net_shortint(inst.GUID, "checka_firehound")
    inst.checka_icehound = GLOBAL.net_shortint(inst.GUID, "checka_icehound")
    inst.checka_koalefant_summer = GLOBAL.net_shortint(inst.GUID, "checka_koalefant_summer")
    inst.checka_koalefant_winter = GLOBAL.net_shortint(inst.GUID, "checka_koalefant_winter")
    inst.checka_catcoon = GLOBAL.net_shortint(inst.GUID, "checka_catcoon")
    inst.checka_bunnyman = GLOBAL.net_shortint(inst.GUID, "checka_bunnyman")
    inst.checka_leif = GLOBAL.net_shortint(inst.GUID, "checka_leif")
    inst.checka_slurtle = GLOBAL.net_shortint(inst.GUID, "checka_slurtle")
    inst.checka_tallbird = GLOBAL.net_shortint(inst.GUID, "checka_tallbird")
    inst.checka_walrus = GLOBAL.net_shortint(inst.GUID, "checka_walrus")
    inst.checka_bat = GLOBAL.net_shortint(inst.GUID, "checka_bat")
    inst.checka_butterfly = GLOBAL.net_shortint(inst.GUID, "checka_butterfly")
    inst.checka_killerbee = GLOBAL.net_shortint(inst.GUID, "checka_killerbee")
    inst.checka_deer = GLOBAL.net_shortint(inst.GUID, "checka_deer")
    inst.checka_mole = GLOBAL.net_shortint(inst.GUID, "checka_mole")
    inst.checka_mosquito = GLOBAL.net_shortint(inst.GUID, "checka_mosquito")
    inst.checka_penguin = GLOBAL.net_shortint(inst.GUID, "checka_penguin")
    inst.checka_merm = GLOBAL.net_shortint(inst.GUID, "checka_merm")
    inst.checka_frog = GLOBAL.net_shortint(inst.GUID, "checka_frog")
    inst.checka_beefalo = GLOBAL.net_shortint(inst.GUID, "checka_beefalo")
    inst.checka_perd = GLOBAL.net_shortint(inst.GUID, "checka_perd")
    inst.checka_krampus = GLOBAL.net_shortint(inst.GUID, "checka_krampus")
    inst.checka_robin_crow = GLOBAL.net_shortint(inst.GUID, "checka_robin_crow")
    inst.checka_robin_robin = GLOBAL.net_shortint(inst.GUID, "checka_robin_robin")
    inst.checka_robin_winter = GLOBAL.net_shortint(inst.GUID, "checka_robin_winter")
    inst.checka_robin_canary = GLOBAL.net_shortint(inst.GUID, "checka_robin_canary")
    inst.checka_pigman = GLOBAL.net_shortint(inst.GUID, "checka_pigman")
    inst.checka_shadow_knight = GLOBAL.net_shortint(inst.GUID, "checka_shadow_knight")
    inst.checka_shadow_bishop = GLOBAL.net_shortint(inst.GUID, "checka_shadow_bishop")
    inst.checka_shadow_rook = GLOBAL.net_shortint(inst.GUID, "checka_shadow_rook")
    inst.checka_moose = GLOBAL.net_shortint(inst.GUID, "checka_moose")
    inst.checka_dragonfly = GLOBAL.net_shortint(inst.GUID, "checka_dragonfly")
    inst.checka_bearger = GLOBAL.net_shortint(inst.GUID, "checka_bearger")
    inst.checka_deerclops = GLOBAL.net_shortint(inst.GUID, "checka_deerclops")
    inst.checka_stalker_forest = GLOBAL.net_shortint(inst.GUID, "checka_stalker_forest")
    inst.checka_stalker = GLOBAL.net_shortint(inst.GUID, "checka_stalker")
    inst.checka_stalker_atrium = GLOBAL.net_shortint(inst.GUID, "checka_stalker_atrium")
    inst.checka_klaus = GLOBAL.net_shortint(inst.GUID, "checka_klaus")
    inst.checka_antlion = GLOBAL.net_shortint(inst.GUID, "checka_antlion")
    inst.checka_minotaur = GLOBAL.net_shortint(inst.GUID, "checka_minotaur")
    inst.checka_beequeen = GLOBAL.net_shortint(inst.GUID, "checka_beequeen")
    inst.checka_toadstool = GLOBAL.net_shortint(inst.GUID, "checka_toadstool")
    inst.checka_toadstool_dark = GLOBAL.net_shortint(inst.GUID, "checka_toadstool_dark")


    inst.checka_1 = GLOBAL.net_shortint(inst.GUID, "checka_1")
    inst.checka_2 = GLOBAL.net_shortint(inst.GUID, "checka_2")
    inst.checka_3 = GLOBAL.net_shortint(inst.GUID, "checka_3")
    inst.checka_4 = GLOBAL.net_shortint(inst.GUID, "checka_4")
    inst.checka_5 = GLOBAL.net_shortint(inst.GUID, "checka_5")
    inst.checka_6 = GLOBAL.net_shortint(inst.GUID, "checka_6")
    inst.checka_7 = GLOBAL.net_shortint(inst.GUID, "checka_7")
    inst.checka_8 = GLOBAL.net_shortint(inst.GUID, "checka_8")
    inst.checka_9 = GLOBAL.net_shortint(inst.GUID, "checka_9")
    inst.checka_10 = GLOBAL.net_shortint(inst.GUID, "checka_10")
    inst.checka_11 = GLOBAL.net_shortint(inst.GUID, "checka_11")
    inst.checka_12 = GLOBAL.net_shortint(inst.GUID, "checka_12")
    inst.checka_13 = GLOBAL.net_shortint(inst.GUID, "checka_13")
    inst.checka_14 = GLOBAL.net_shortint(inst.GUID, "checka_14")
    inst.checka_15 = GLOBAL.net_shortint(inst.GUID, "checka_15")

    inst.checka_tallbirdegg = GLOBAL.net_shortint(inst.GUID, "checka_tallbirdegg")
    inst.checka_frogglebunwich = GLOBAL.net_shortint(inst.GUID, "checka_frogglebunwich")
    inst.checka_baconeggs = GLOBAL.net_shortint(inst.GUID, "checka_baconeggs")
    inst.checka_bonestew = GLOBAL.net_shortint(inst.GUID, "checka_bonestew")
    inst.checka_fishtacos = GLOBAL.net_shortint(inst.GUID, "checka_fishtacos")
    inst.checka_turkeydinner = GLOBAL.net_shortint(inst.GUID, "checka_turkeydinner")
    inst.checka_fishsticks = GLOBAL.net_shortint(inst.GUID, "checka_fishsticks")
    inst.checka_meatballs = GLOBAL.net_shortint(inst.GUID, "checka_meatballs")
    inst.checka_perogies = GLOBAL.net_shortint(inst.GUID, "checka_perogies")

    inst.checka_bisque = GLOBAL.net_shortint(inst.GUID, "checka_bisque")
    inst.checka_surfnturf = GLOBAL.net_shortint(inst.GUID, "checka_surfnturf")
    inst.checka_tigershark = GLOBAL.net_shortint(inst.GUID, "checka_tigershark")
    inst.checka_twister = GLOBAL.net_shortint(inst.GUID, "checka_twister")
    inst.checka_snake = GLOBAL.net_shortint(inst.GUID, "checka_snake")
    inst.checka_snake_poison = GLOBAL.net_shortint(inst.GUID, "checka_snake_poison")
    inst.checka_crocodog = GLOBAL.net_shortint(inst.GUID, "checka_crocodog")
    inst.checka_poisoncrocodog = GLOBAL.net_shortint(inst.GUID, "checka_poisoncrocodog")
    inst.checka_watercrocodog = GLOBAL.net_shortint(inst.GUID, "checka_watercrocodog")
    inst.checka_coffee = GLOBAL.net_shortint(inst.GUID, "checka_coffee")

    inst.checka_a1 = GLOBAL.net_shortint(inst.GUID, "checka_a1")
    inst.checka_a2 = GLOBAL.net_shortint(inst.GUID, "checka_a2")
    inst.checka_a3 = GLOBAL.net_shortint(inst.GUID, "checka_a3")
    inst.checka_a4 = GLOBAL.net_shortint(inst.GUID, "checka_a4")
    inst.checka_a5 = GLOBAL.net_shortint(inst.GUID, "checka_a5")
    inst.checka_a6 = GLOBAL.net_shortint(inst.GUID, "checka_a6")
    inst.checka_a7 = GLOBAL.net_shortint(inst.GUID, "checka_a7")
    inst.checka_a8 = GLOBAL.net_shortint(inst.GUID, "checka_a8")
    inst.checka_a9 = GLOBAL.net_shortint(inst.GUID, "checka_a9")
    inst.checka_a10 = GLOBAL.net_shortint(inst.GUID, "checka_a10")
    inst.checka_a11 = GLOBAL.net_shortint(inst.GUID, "checka_a11")
    inst.checka_a12 = GLOBAL.net_shortint(inst.GUID, "checka_a12")
    inst.checka_a13 = GLOBAL.net_shortint(inst.GUID, "checka_a13")
    inst.checka_a14 = GLOBAL.net_shortint(inst.GUID, "checka_a14")
    inst.checka_a15 = GLOBAL.net_shortint(inst.GUID, "checka_a15")
    inst.checka_a16 = GLOBAL.net_shortint(inst.GUID, "checka_a16")
    inst.checka_a17 = GLOBAL.net_shortint(inst.GUID, "checka_a17")
    inst.checka_a18 = GLOBAL.net_shortint(inst.GUID, "checka_a18")
    inst.checka_a19 = GLOBAL.net_shortint(inst.GUID, "checka_a19")
    inst.checka_a20 = GLOBAL.net_shortint(inst.GUID, "checka_a20")
    inst.checka_a21 = GLOBAL.net_shortint(inst.GUID, "checka_a21")
    inst.checka_a22 = GLOBAL.net_shortint(inst.GUID, "checka_a22")
    inst.checka_a23 = GLOBAL.net_shortint(inst.GUID, "checka_a23")
    inst.checka_a24 = GLOBAL.net_shortint(inst.GUID, "checka_a24")
    inst.checka_a25 = GLOBAL.net_shortint(inst.GUID, "checka_a25")
    inst.checka_a26 = GLOBAL.net_shortint(inst.GUID, "checka_a26")
    inst.checka_a27 = GLOBAL.net_shortint(inst.GUID, "checka_a27")
    inst.checka_a28 = GLOBAL.net_shortint(inst.GUID, "checka_a28")
    inst.checka_a29 = GLOBAL.net_shortint(inst.GUID, "checka_a29")
    inst.checka_a30 = GLOBAL.net_shortint(inst.GUID, "checka_a30")
    inst.checka_a31 = GLOBAL.net_shortint(inst.GUID, "checka_a31")
    inst.checka_a32 = GLOBAL.net_shortint(inst.GUID, "checka_a32")
    inst.checka_a33 = GLOBAL.net_shortint(inst.GUID, "checka_a33")
    inst.checka_a34 = GLOBAL.net_shortint(inst.GUID, "checka_a34")
    inst.checka_a35 = GLOBAL.net_shortint(inst.GUID, "checka_a35")
    inst.checka_a36 = GLOBAL.net_shortint(inst.GUID, "checka_a36")
    inst.checka_a37 = GLOBAL.net_shortint(inst.GUID, "checka_a37")
    inst.checka_a38 = GLOBAL.net_shortint(inst.GUID, "checka_a38")
    inst.checka_a39 = GLOBAL.net_shortint(inst.GUID, "checka_a39")
    inst.checka_a40 = GLOBAL.net_shortint(inst.GUID, "checka_a40")

    --==========================================================================================




    inst.checkall = GLOBAL.net_shortint(inst.GUID, "checkall")





    inst.currenteatamount = GLOBAL.net_shortint(inst.GUID, "currenteatamount")
    inst.currenteatmonsterlasagna = GLOBAL.net_shortint(inst.GUID, "currenteatmonsterlasagna")
    inst.currentrespawnamount = GLOBAL.net_shortint(inst.GUID, "currentrespawnamount")
    inst.currentwalktime = GLOBAL.net_shortint(inst.GUID, "currentwalktime")
    inst.currentstoptime = GLOBAL.net_shortint(inst.GUID, "currentstoptime")
    inst.currentevilamount = GLOBAL.net_shortint(inst.GUID, "currentevilamount")
    inst.currentdeathamouth = GLOBAL.net_shortint(inst.GUID, "currentdeathamouth")
    inst.currentnosanitytime = GLOBAL.net_shortint(inst.GUID, "currentnosanitytime")
    inst.currentsnakeamount = GLOBAL.net_shortint(inst.GUID, "currentsnakeamount")
    inst.currentfriendpig = GLOBAL.net_shortint(inst.GUID, "currentfriendpig")
    inst.currentfriendbunny = GLOBAL.net_shortint(inst.GUID, "currentfriendbunny")
    inst.currentfishamount = GLOBAL.net_shortint(inst.GUID, "currentfishamount")
    inst.currentpickamount = GLOBAL.net_shortint(inst.GUID, "currentpickamount")
    inst.currentchopamount = GLOBAL.net_shortint(inst.GUID, "currentchopamount")
    inst.currentcookamount = GLOBAL.net_shortint(inst.GUID, "currentcookamount")
    inst.currentbuildamount = GLOBAL.net_shortint(inst.GUID, "currentbuildamount")
    inst.currentattackeddamage = GLOBAL.net_shortint(inst.GUID, "currentattackeddamage")
    inst.currentonhitdamage = GLOBAL.net_int(inst.GUID, "currentonhitdamage")
    inst.currenticetime = GLOBAL.net_shortint(inst.GUID, "currenticetime")
    inst.currentfiretime = GLOBAL.net_shortint(inst.GUID, "currentfiretime")
    inst.currentmoisttime = GLOBAL.net_shortint(inst.GUID, "currentmoisttime")
    inst.currentage = GLOBAL.net_shortint(inst.GUID, "currentage")



    inst.currentcoinamount = GLOBAL.net_shortint(inst.GUID, "currentcoinamount")

    inst.currenthungerup = GLOBAL.net_shortint(inst.GUID, "currenthungerup")
    inst.currentsanityup = GLOBAL.net_shortint(inst.GUID, "currentsanityup")
    inst.currenthealthup = GLOBAL.net_shortint(inst.GUID, "currenthealthup")
    inst.currenthealthregen = GLOBAL.net_shortint(inst.GUID, "currenthealthregen")
    inst.currentsanityregen = GLOBAL.net_shortint(inst.GUID, "currentsanityregen")
    inst.currenthungerrateup = GLOBAL.net_shortint(inst.GUID, "currenthungerrateup")
    inst.currentspeedup = GLOBAL.net_shortint(inst.GUID, "currentspeedup")
    inst.currentabsorbup = GLOBAL.net_shortint(inst.GUID, "currentabsorbup")
    inst.currentdamageup = GLOBAL.net_shortint(inst.GUID, "currentdamageup")
    inst.currentcrit = GLOBAL.net_shortint(inst.GUID, "currentcrit")

    inst.currentdoubledrop = GLOBAL.net_shortint(inst.GUID, "currentdoubledrop")
    inst.currentfireflylight = GLOBAL.net_shortint(inst.GUID, "currentfireflylight")
    inst.currentnomoist = GLOBAL.net_shortint(inst.GUID, "currentnomoist")
    inst.currentgoodman = GLOBAL.net_shortint(inst.GUID, "currentgoodman")
    inst.currentrefresh = GLOBAL.net_shortint(inst.GUID, "currentrefresh")
    inst.currentfishmaster = GLOBAL.net_shortint(inst.GUID, "currentfishmaster")
    inst.currentcookmaster = GLOBAL.net_shortint(inst.GUID, "currentcookmaster")
    inst.currentchopmaster = GLOBAL.net_shortint(inst.GUID, "currentchopmaster")
    inst.currentpickmaster = GLOBAL.net_shortint(inst.GUID, "currentpickmaster")
    inst.currentbuildmaster = GLOBAL.net_shortint(inst.GUID, "currentbuildmaster")
    inst.currenticebody = GLOBAL.net_shortint(inst.GUID, "currenticebody")
    inst.currentfirebody = GLOBAL.net_shortint(inst.GUID, "currentfirebody")
    inst.currentsupply = GLOBAL.net_shortint(inst.GUID, "currentsupply")
    inst.currentreader = GLOBAL.net_shortint(inst.GUID, "currentreader")

    inst.currentjump = GLOBAL.net_shortint(inst.GUID, "currentjump")
    inst.currentlevel = GLOBAL.net_shortint(inst.GUID, "currentlevel")
    inst.currentfastpicker = GLOBAL.net_shortint(inst.GUID, "currentfastpicker")

    --==========================================================================================
    inst.currenta_yingguaiamount = GLOBAL.net_shortint(inst.GUID, "currenta_yingguaiamount")
    inst.currenta_wormamount = GLOBAL.net_shortint(inst.GUID, "currenta_wormamount")
    inst.currenta_monkeyamount = GLOBAL.net_shortint(inst.GUID, "currenta_monkeyamount")
    inst.currenta_buzzardamount = GLOBAL.net_shortint(inst.GUID, "currenta_buzzardamount")
    inst.currenta_lightninggoatamount = GLOBAL.net_shortint(inst.GUID, "currenta_lightninggoatamount")
    inst.currenta_spiderqueenamount = GLOBAL.net_shortint(inst.GUID, "currenta_spiderqueenamount")
    inst.currenta_spideramount = GLOBAL.net_shortint(inst.GUID, "currenta_spideramount")
    inst.currenta_spider_warrioramount = GLOBAL.net_shortint(inst.GUID, "currenta_spider_warrioramount")
    inst.currenta_spider_dropperamount = GLOBAL.net_shortint(inst.GUID, "currenta_spider_dropperamount")
    inst.currenta_spider_hideramount = GLOBAL.net_shortint(inst.GUID, "currenta_spider_hideramount")
    inst.currenta_spider_spitteramount = GLOBAL.net_shortint(inst.GUID, "currenta_spider_spitteramount")
    inst.currenta_wargamount = GLOBAL.net_shortint(inst.GUID, "currenta_wargamount")
    inst.currenta_houndamount = GLOBAL.net_shortint(inst.GUID, "currenta_houndamount")
    inst.currenta_firehoundamount = GLOBAL.net_shortint(inst.GUID, "currenta_firehoundamount")
    inst.currenta_icehoundamount = GLOBAL.net_shortint(inst.GUID, "currenta_icehoundamount")
    inst.currenta_koalefant_summeramount = GLOBAL.net_shortint(inst.GUID, "currenta_koalefant_summeramount")
    inst.currenta_koalefant_winteramount = GLOBAL.net_shortint(inst.GUID, "currenta_koalefant_winteramount")
    inst.currenta_catcoonamount = GLOBAL.net_shortint(inst.GUID, "currenta_catcoonamount")
    inst.currenta_bunnymanamount = GLOBAL.net_shortint(inst.GUID, "currenta_bunnymanamount")
    inst.currenta_leifamount = GLOBAL.net_shortint(inst.GUID, "currenta_leifamount")
    inst.currenta_slurtleamount = GLOBAL.net_shortint(inst.GUID, "currenta_slurtleamount")
    inst.currenta_tallbirdamount = GLOBAL.net_shortint(inst.GUID, "currenta_tallbirdamount")
    inst.currenta_walrusamount = GLOBAL.net_shortint(inst.GUID, "currenta_walrusamount")
    inst.currenta_batamount = GLOBAL.net_shortint(inst.GUID, "currenta_batamount")
    inst.currenta_butterflyamount = GLOBAL.net_shortint(inst.GUID, "currenta_butterflyamount")
    inst.currenta_killerbeeamount = GLOBAL.net_shortint(inst.GUID, "currenta_killerbeeamount")
    inst.currenta_deeramount = GLOBAL.net_shortint(inst.GUID, "currenta_deeramount")
    inst.currenta_moleamount = GLOBAL.net_shortint(inst.GUID, "currenta_moleamount")
    inst.currenta_mosquitoamount = GLOBAL.net_shortint(inst.GUID, "currenta_mosquitoamount")
    inst.currenta_penguinamount = GLOBAL.net_shortint(inst.GUID, "currenta_penguinamount")
    inst.currenta_mermamount = GLOBAL.net_shortint(inst.GUID, "currenta_mermamount")
    inst.currenta_frogamount = GLOBAL.net_shortint(inst.GUID, "currenta_frogamount")
    inst.currenta_beefaloamount = GLOBAL.net_shortint(inst.GUID, "currenta_beefaloamount")
    inst.currenta_perdamount = GLOBAL.net_shortint(inst.GUID, "currenta_perdamount")
    inst.currenta_krampusamount = GLOBAL.net_shortint(inst.GUID, "currenta_krampusamount")
    inst.currenta_robin_crowamount = GLOBAL.net_shortint(inst.GUID, "currenta_robin_crowamount")
    inst.currenta_robin_robinamount = GLOBAL.net_shortint(inst.GUID, "currenta_robin_robinamount")
    inst.currenta_robin_winteramount = GLOBAL.net_shortint(inst.GUID, "currenta_robin_winteramount")
    inst.currenta_robin_canaryamount = GLOBAL.net_shortint(inst.GUID, "currenta_robin_canaryamount")
    inst.currenta_pigmanamount = GLOBAL.net_shortint(inst.GUID, "currenta_pigmanamount")

    inst.currenta_1amount = GLOBAL.net_shortint(inst.GUID, "currenta_1amount")
    inst.currenta_2amount = GLOBAL.net_shortint(inst.GUID, "currenta_2amount")
    inst.currenta_3amount = GLOBAL.net_shortint(inst.GUID, "currenta_3amount")
    inst.currenta_4amount = GLOBAL.net_shortint(inst.GUID, "currenta_4amount")
    inst.currenta_5amount = GLOBAL.net_shortint(inst.GUID, "currenta_5amount")
    inst.currenta_6amount = GLOBAL.net_shortint(inst.GUID, "currenta_6amount")
    inst.currenta_7amount = GLOBAL.net_shortint(inst.GUID, "currenta_7amount")
    inst.currenta_8amount = GLOBAL.net_shortint(inst.GUID, "currenta_8amount")
    inst.currenta_9amount = GLOBAL.net_shortint(inst.GUID, "currenta_9amount")
    inst.currenta_10amount = GLOBAL.net_shortint(inst.GUID, "currenta_10amount")
    inst.currenta_11amount = GLOBAL.net_shortint(inst.GUID, "currenta_11amount")
    inst.currenta_12amount = GLOBAL.net_shortint(inst.GUID, "currenta_12amount")
    inst.currenta_13amount = GLOBAL.net_shortint(inst.GUID, "currenta_13amount")
    inst.currenta_14amount = GLOBAL.net_shortint(inst.GUID, "currenta_14amount")
    inst.currenta_15amount = GLOBAL.net_shortint(inst.GUID, "currenta_15amount")


    inst.currenta_tallbirdeggamount = GLOBAL.net_shortint(inst.GUID, "currenta_tallbirdeggamount")
    inst.currenta_frogglebunwichamount = GLOBAL.net_shortint(inst.GUID, "currenta_frogglebunwichamount")
    inst.currenta_baconeggsamount = GLOBAL.net_shortint(inst.GUID, "currenta_baconeggsamount")
    inst.currenta_bonestewamount = GLOBAL.net_shortint(inst.GUID, "currenta_bonestewamount")
    inst.currenta_fishtacosamount = GLOBAL.net_shortint(inst.GUID, "currenta_fishtacosamount")
    inst.currenta_turkeydinneramount = GLOBAL.net_shortint(inst.GUID, "currenta_turkeydinneramount")
    inst.currenta_fishsticksamount = GLOBAL.net_shortint(inst.GUID, "currenta_fishsticksamount")
    inst.currenta_meatballsamount = GLOBAL.net_shortint(inst.GUID, "currenta_meatballsamount")
    inst.currenta_perogiesamount = GLOBAL.net_shortint(inst.GUID, "currenta_perogiesamount")

    inst.currenta_bisqueamount = GLOBAL.net_shortint(inst.GUID, "currenta_bisqueamount")
    inst.currenta_surfnturfamount = GLOBAL.net_shortint(inst.GUID, "currenta_surfnturfamount")
    inst.currenta_tigersharkamount = GLOBAL.net_shortint(inst.GUID, "currenta_tigersharkamount")
    inst.currenta_twisteramount = GLOBAL.net_shortint(inst.GUID, "currenta_twisteramount")
    inst.currenta_snakeamount = GLOBAL.net_shortint(inst.GUID, "currenta_snakeamount")
    inst.currenta_snake_poisonamount = GLOBAL.net_shortint(inst.GUID, "currenta_snake_poisonamount")
    inst.currenta_crocodogamount = GLOBAL.net_shortint(inst.GUID, "currenta_crocodogamount")
    inst.currenta_poisoncrocodogamount = GLOBAL.net_shortint(inst.GUID, "currenta_poisoncrocodogamount")
    inst.currenta_watercrocodogamount = GLOBAL.net_shortint(inst.GUID, "currenta_watercrocodogamount")
    inst.currenta_coffeeamount = GLOBAL.net_shortint(inst.GUID, "currenta_coffeeamount")


    inst.currenta_a1amount = GLOBAL.net_shortint(inst.GUID, "currenta_a1amount")
    inst.currenta_a2amount = GLOBAL.net_shortint(inst.GUID, "currenta_a2amount")
    inst.currenta_a3amount = GLOBAL.net_shortint(inst.GUID, "currenta_a3amount")
    inst.currenta_a4amount = GLOBAL.net_shortint(inst.GUID, "currenta_a4amount")
    inst.currenta_a5amount = GLOBAL.net_shortint(inst.GUID, "currenta_a5amount")
    inst.currenta_a6amount = GLOBAL.net_shortint(inst.GUID, "currenta_a6amount")
    inst.currenta_a7amount = GLOBAL.net_shortint(inst.GUID, "currenta_a7amount")
    inst.currenta_a8amount = GLOBAL.net_shortint(inst.GUID, "currenta_a8amount")
    inst.currenta_a9amount = GLOBAL.net_shortint(inst.GUID, "currenta_a9amount")
    inst.currenta_a10amount = GLOBAL.net_shortint(inst.GUID, "currenta_a10amount")


    inst.currenta_a11amount = GLOBAL.net_shortint(inst.GUID, "currenta_a11amount")
    inst.currenta_a12amount = GLOBAL.net_shortint(inst.GUID, "currenta_a12amount")
    inst.currenta_a13amount = GLOBAL.net_shortint(inst.GUID, "currenta_a13amount")
    inst.currenta_a14amount = GLOBAL.net_shortint(inst.GUID, "currenta_a14amount")
    inst.currenta_a15amount = GLOBAL.net_shortint(inst.GUID, "currenta_a15amount")
    inst.currenta_a16amount = GLOBAL.net_shortint(inst.GUID, "currenta_a16amount")
    inst.currenta_a17amount = GLOBAL.net_shortint(inst.GUID, "currenta_a17amount")
    inst.currenta_a18amount = GLOBAL.net_shortint(inst.GUID, "currenta_a18amount")
    inst.currenta_a19amount = GLOBAL.net_shortint(inst.GUID, "currenta_a19amount")
    inst.currenta_a20amount = GLOBAL.net_shortint(inst.GUID, "currenta_a20amount")
    inst.currenta_a21amount = GLOBAL.net_shortint(inst.GUID, "currenta_a21amount")
    inst.currenta_a22amount = GLOBAL.net_shortint(inst.GUID, "currenta_a22amount")
    inst.currenta_a23amount = GLOBAL.net_shortint(inst.GUID, "currenta_a23amount")
    inst.currenta_a24amount = GLOBAL.net_shortint(inst.GUID, "currenta_a24amount")
    inst.currenta_a25amount = GLOBAL.net_shortint(inst.GUID, "currenta_a25amount")
    inst.currenta_a26amount = GLOBAL.net_shortint(inst.GUID, "currenta_a26amount")
    inst.currenta_a27amount = GLOBAL.net_shortint(inst.GUID, "currenta_a27amount")
    inst.currenta_a28amount = GLOBAL.net_shortint(inst.GUID, "currenta_a28amount")
    inst.currenta_a29amount = GLOBAL.net_shortint(inst.GUID, "currenta_a29amount")
    inst.currenta_a30amount = GLOBAL.net_shortint(inst.GUID, "currenta_a30amount")
    inst.currenta_a31amount = GLOBAL.net_shortint(inst.GUID, "currenta_a31amount")
    inst.currenta_a32amount = GLOBAL.net_shortint(inst.GUID, "currenta_a32amount")
    inst.currenta_a33amount = GLOBAL.net_shortint(inst.GUID, "currenta_a33amount")
    inst.currenta_a34amount = GLOBAL.net_shortint(inst.GUID, "currenta_a34amount")
    inst.currenta_a35amount = GLOBAL.net_shortint(inst.GUID, "currenta_a35amount")
    inst.currenta_a36amount = GLOBAL.net_shortint(inst.GUID, "currenta_a36amount")
    inst.currenta_a37amount = GLOBAL.net_shortint(inst.GUID, "currenta_a37amount")
    inst.currenta_a38amount = GLOBAL.net_shortint(inst.GUID, "currenta_a38amount")
    inst.currenta_a39amount = GLOBAL.net_shortint(inst.GUID, "currenta_a39amount")
    inst.currenta_a40amount = GLOBAL.net_shortint(inst.GUID, "currenta_a40amount")


    --==========================================================================================



    inst:AddComponent("allachivevent_c")
    inst:AddComponent("allachivcoin")
    inst.components.allachivevent_c.a_a1 = false

    inst:AddComponent("allachivevent")

    if not GLOBAL.TheNet:GetIsClient() then
        inst.components.allachivevent_c:Init(inst)
        inst.components.allachivevent:Init(inst)
        inst.components.allachivcoin:Init(inst)
    end
end)

--UI尺寸
local function PositionUI(self, screensize)
    local hudscale = self.top_root:GetScale()
    self.uiachievement:SetScale(.72 * hudscale.x, .72 * hudscale.y, 1)
    --self.uiachievement.mainbutton.hudscale = self.top_root:GetScale()
end


--UI

local uiachievement = require("widgets/uiachievement")
local function Adduiachievement(self)
    self.uiachievement = self.top_root:AddChild(uiachievement(self.owner))
    local screensize = { GLOBAL.TheSim:GetScreenSize() }
    PositionUI(self, screensize)
    self.uiachievement:SetHAnchor(0)
    self.uiachievement:SetVAnchor(0)
    --H: 0=中间 1=左端 2=右端
    --V: 0=中间 1=顶端 2=底端
    self.uiachievement:MoveToFront()
    local OnUpdate_base = self.OnUpdate
    self.OnUpdate = function(self, dt)
        OnUpdate_base(self, dt)
        local curscreensize = { GLOBAL.TheSim:GetScreenSize() }
        if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
            PositionUI(self, curscreensize)
            screensize = curscreensize
        end
    end
end

AddClassPostConstruct("widgets/controls", Adduiachievement)



--欧皇检测
AddPrefabPostInit("krampus_sack", function(inst)
    inst:AddComponent("ksmark")
end)





--fr彩色虫洞
AddMinimapAtlas("images/mark_1.xml")
AddMinimapAtlas("images/mark_2.xml")
AddMinimapAtlas("images/mark_3.xml")
AddMinimapAtlas("images/mark_4.xml")
AddMinimapAtlas("images/mark_5.xml")
AddMinimapAtlas("images/mark_6.xml")
AddMinimapAtlas("images/mark_7.xml")
AddMinimapAtlas("images/mark_8.xml")
AddMinimapAtlas("images/mark_9.xml")
AddMinimapAtlas("images/mark_10.xml")
AddMinimapAtlas("images/mark_11.xml")
AddMinimapAtlas("images/mark_12.xml")
AddMinimapAtlas("images/mark_13.xml")
AddMinimapAtlas("images/mark_14.xml")
AddMinimapAtlas("images/mark_15.xml")
AddMinimapAtlas("images/mark_16.xml")
AddMinimapAtlas("images/mark_17.xml")
AddMinimapAtlas("images/mark_18.xml")
AddMinimapAtlas("images/mark_19.xml")
AddMinimapAtlas("images/mark_20.xml")
AddMinimapAtlas("images/mark_21.xml")
AddMinimapAtlas("images/mark_22.xml")

local function Mark(inst)
    if not inst.components.wormhole_marks:CheckMark() then
        inst.components.wormhole_marks:MarkEntrance()
    end

    local other = inst.components.teleporter.targetTeleporter
    if not other.components.wormhole_marks:CheckMark() then
        other.components.wormhole_marks:MarkExit()
    end
end

function WormholePrefabPostInit(inst)
    if not inst.components.wormhole_marks then
        inst:AddComponent("wormhole_marks")
    end
    inst:ListenForEvent("starttravelsound", Mark)
end

AddPrefabPostInit("wormhole", WormholePrefabPostInit)

function WorldPrefabPostInit(inst)
    if inst:HasTag("forest") then
        inst:AddComponent("wormhole_counter")
    end
end

if GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated() then
    AddPrefabPostInit("world", WorldPrefabPostInit)
end





--fr齿轮可制造
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

STRINGS.RECIPE_DESC.GEARS = "应该是个有用的东西..."

Recipe("gears", { Ingredient("cutstone", 4), Ingredient("twigs", 6), Ingredient("goldnugget", 4), Ingredient("flint", 6) }, RECIPETABS.REFINE, TECH.SCIENCE_TWO)






--fr月光护符
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
Recipe = GLOBAL.Recipe
TUNING = GLOBAL.TUNING

--prefabs names and descriptions
STRINGS.NAMES.OPALAMULET = "月光护符"
modimport("init/init_descriptions")

local require = GLOBAL.require
local AllRecipes = GLOBAL.AllRecipes
local GetValidRecipe = GLOBAL.GetValidRecipe
local RECIPETABS = GLOBAL.RECIPETABS
local CHARACTER_INGREDIENT = GLOBAL.CHARACTER_INGREDIENT

--crafting
AddRecipe("opalamulet",
    { Ingredient("opalpreciousgem", 1), Ingredient("moonrocknugget", 6), Ingredient("yellowamulet", 1) },
    RECIPETABS.MAGIC, TECH.LOST, nil, nil, nil, nil, nil, "images/inventoryimages/opalamulet.xml", "opalamulet.tex")

--tuning月光护符爆率1%
TUNING.OPALAMULETBLUEPRINT_DROPRARE = 0.01

local function opalamuletblueprint_gargoyle(inst)
    if (inst.components.lootdropper) then
        inst.components.lootdropper:AddChanceLoot("opalamulet_blueprint", TUNING.OPALAMULETBLUEPRINT_DROPRARE)
    end
end

AddPrefabPostInit("gargoyle_houndatk", opalamuletblueprint_gargoyle)
AddPrefabPostInit("gargoyle_hounddeath", opalamuletblueprint_gargoyle)
AddPrefabPostInit("gargoyle_werepigatk", opalamuletblueprint_gargoyle)
AddPrefabPostInit("gargoyle_werepigdeath", opalamuletblueprint_gargoyle)
AddPrefabPostInit("gargoyle_werepighowl", opalamuletblueprint_gargoyle)





--fr更多的墙
KnownModIndex = GLOBAL.KnownModIndex

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

--RECIPE STRINGS
STRINGS.NAMES.WALL_MUD_ITEM = "泥巴墙"
STRINGS.NAMES.WALL_MUD = "泥巴墙"
STRINGS.RECIPE_DESC.WALL_MUD_ITEM = "便宜又实用,虽然看起来有些薄弱."
STRINGS.NAMES.WALL_REED_ITEM = "芦苇墙"
STRINGS.NAMES.WALL_REED = "芦苇墙"
STRINGS.RECIPE_DESC.WALL_REED_ITEM = "用干芦苇铸成的城墙."
STRINGS.NAMES.WALL_BONE_ITEM = "碎骨墙"
STRINGS.NAMES.WALL_BONE = "碎骨墙"
STRINGS.RECIPE_DESC.WALL_BONE_ITEM = "用敌军的尸骨筑起的城墙."
STRINGS.NAMES.WALL_HEDGE_ITEM = "树篱墙"
STRINGS.NAMES.WALL_HEDGE = "树篱墙"
STRINGS.RECIPE_DESC.WALL_HEDGE_ITEM = "守护你的花园."
STRINGS.NAMES.WALL_LIVING_ITEM = "触手墙"
STRINGS.NAMES.WALL_LIVING = "触手墙"
STRINGS.RECIPE_DESC.WALL_LIVING_ITEM = "不要靠的太近哦."

--CHARACTER STRINGS

--MUD WALL STRINGS
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_MUD = "闻起来真糟糕."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_MUD_ITEM = "我可以从中创造一些东西."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_MUD = "太湿了,没有一点火星."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_MUD_ITEM = "我不想要这个."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_MUD = "生命的产物，现在保护着生命."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_MUD_ITEM = "我应该把它处理掉."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_MUD = "很粗糙,但在绝望的时候..."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_MUD_ITEM = "我应该以此为基础."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUD = "这冒犯了我所有的感官."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUD_ITEM = "我要把这个从我的视线里移开!"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_MUD = "恶心又羸弱"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_MUD_ITEM = "运行构建协议"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_MUD = "这不仅仅是泥巴,是吗?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_MUD_ITEM = "我可以用它做点什么."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_MUD = "一股恶臭扑面而来!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_MUD_ITEM = "我来构建它."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_MUD = "闻起来好难闻."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_MUD_ITEM = "到处都是!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_MUD = "我们的防御能力可能会更好."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_MUD_ITEM = "我要做些什么."
--REED WALL STRINGS
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_REED = "它们在微风中沙沙作响."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_REED_ITEM = "我是种植物吗?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_REED = "他们会烧得很旺..."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_REED_ITEM = "我应该玩这些."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_REED = "在奥菲莉娅的水坑边."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_REED_ITEM = "我应该把这些放下."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_REED = "一种古老的纤维粘合技术."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_REED_ITEM = "我可以用这些做点什么."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.REED = "毫无价值的建筑."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.REED_ITEM = "我对体力劳动不感兴趣."
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_REED = "一个干燥的路障"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_REED_ITEM = "一些装配要求"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_REED = "你能听到他们唱歌吗?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_REED_ITEM = "我能做点什么,嗯?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_REED = "它在唱歌!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_REED_ITEM = "我可以!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_REED = "现在青蛙住在哪里?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_REED_ITEM = "我可以做一堵墙."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_REED = "香蒲与芦苇."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_REED_ITEM = "我可以用它来做点什么."
--BONE WALL STRINGS
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_BONE = "这有点令人毛骨悚然."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_BONE_ITEM = "这看起来相当安全."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_BONE = "我不能在这些骨头里生火吗?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_BONE_ITEM = "我应该把这些放在某处."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_BONE = "生亦何欢,死亦何苦,就像我妹妹一样保护我."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_BONE_ITEM = "我应该建造这个."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_BONE = "一个可怕的构造."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_BONE_ITEM = "我应该建造这个."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BONE = "它传递了一个信息,你能感受到吗."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BONE_ITEM = "我想我可以建这个."
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_BONE = "有机的"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_BONE_ITEM = "建设系统,正在启动"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_BONE = "没有什么是浪费的."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_BONE_ITEM = "我可以做这个."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_BONE = "我可以做这个!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_BONE_ITEM = "我能行."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_BONE = "我们害怕..."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_BONE_ITEM = "我不想建造它."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_BONE = "一堵用敌人碎骨筑起来的墙!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_BONE_ITEM = "我可以用这个做一堵墙."
--HEDGE WALL STRINGS
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_HEDGE = "我不想在这里迷路."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_HEDGE_ITEM = "从中心开始锻造."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_HEDGE = "对于一个燃烧的死亡迷宫来说是完美的."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_HEDGE_ITEM = "我应该制定一个计划."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_HEDGE = "它们不需要很长时间就会长出来."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_HEDGE_ITEM = "我应该种植这些."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_HEDGE = "当然,这不是一堵真正的墙."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_HEDGE_ITEM = "我应该把它们放在这里."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.HEDGE = "我的园丁在哪里?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.HEDGE_ITEM = "我能制作这东西..."
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_HEDGE = "运行文件 好玩的嫂子.avi"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_HEDGE_ITEM = "警告 警告 错误"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_HEDGE = "回归自然."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_HEDGE_ITEM = "我应该把这些放下."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_HEDGE = "这让沃尔夫冈有点懵比."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_HEDGE_ITEM = "让我来制作它!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_HEDGE = "蜜蜂和蝴蝶住在这里吗?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_HEDGE_ITEM = "我能做点什么!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_HEDGE = "我能创造出一个千古谜题!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_HEDGE_ITEM = "我应该建造这个."
--LIVING WALL STRINGS
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_LIVING = "我应该保持距离."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_LIVING_ITEM = "我应该尽快把它处理掉."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_LIVING = "它在盯着我?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WALL_LIVING_ITEM = "我有充足的制作时间."
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_LIVING = "它在凝视我吗?"
STRINGS.CHARACTERS.WENDY.DESCRIBE.WALL_LIVING_ITEM = "我可以建造它."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_LIVING = "这是对当地植物的另一种用途."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WALL_LIVING_ITEM = "我应该做这个."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.LIVING = "哦，像这样."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.LIVING_ITEM = "似乎很强大."
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_LIVING = "小心，粘液虫和机械装置"
STRINGS.CHARACTERS.WX78.DESCRIBE.WALL_LIVING_ITEM = "请输入建造指令"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_LIVING = "有些事情应该保持平静,是吗?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WALL_LIVING_ITEM = "我应该把它放在这里."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_LIVING = "很丑但很强大!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WALL_LIVING_ITEM = "我来建造!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_LIVING = "我不喜欢它."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WALL_LIVING_ITEM = "这真可怕..."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_LIVING = "真是一堵神奇的墙壁."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WALL_LIVING_ITEM = "当你需要一些建筑材料时,它在哪里?"

--RECIPES
AddRecipe("wall_mud_item",
    {
        Ingredient("poop", 6)
    },
    RECIPETABS.TOWN, TECH.NONE, nil, nil, nil, 6, nil, "images/wall_mud_item.xml", "wall_mud_item.tex")

AddRecipe("wall_reed_item",
    {
        Ingredient("cutreeds", 4),
        Ingredient("rope", 1)
    },
    RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil, nil, nil, 6, nil, "images/wall_reed_item.xml", "wall_reed_item.tex")

AddRecipe("wall_bone_item",
    {
        Ingredient("boneshard", 12)
    },
    RECIPETABS.TOWN, TECH.SCIENCE_TWO, nil, nil, nil, 6, nil, "images/wall_bone_item.xml", "wall_bone_item.tex")

AddRecipe("wall_hedge_item",
    {
        Ingredient("pinecone", 6),
        Ingredient("livinglog", 4)
    },
    RECIPETABS.TOWN, TECH.SCIENCE_TWO, nil, nil, nil, 6, nil, "images/wall_hedge_item.xml", "wall_hedge_item.tex")

AddRecipe("wall_living_item",
    {
        Ingredient("tentaclespots", 6),
        Ingredient("cutstone", 6)
    },
    RECIPETABS.TOWN, TECH.MAGIC_TWO, nil, nil, nil, 6, nil, "images/wall_living_item.xml", "wall_living_item.tex")





--fr曼德拉草可制作
local require = GLOBAL.require
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local STRINGS = GLOBAL.STRINGS
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local GROUND = GLOBAL.GROUND
local DEPLOYMODE = GLOBAL.DEPLOYMODE
local SpawnPrefab = GLOBAL.SpawnPrefab

-- Gears Recipe
local MandrakeIngredientCarrot = 10
local MandrakeIngredientMonsterMeat = 8
local MandrakeIngredientPetals = 15
-- Recipe Description
STRINGS.RECIPE_DESC.MANDRAKE = "一种有生命的植物,也许曾经有生命?"

--(name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image)

AddRecipe("mandrake", { Ingredient("carrot", 10), Ingredient("monstermeat", 8), Ingredient("petals", 15) }, RECIPETABS.FARM, TECH.SCIENCE_ONE)





--fr曼德拉可种植
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH
local STRINGS = GLOBAL.STRINGS

STRINGS.NAMES.FLOWER_ROSE = "玫瑰花"
STRINGS.NAMES.PUMPKIN_PLANTED = "南瓜"

STRINGS.RECIPE_DESC.MANDRAKE_PLANTED = "把曼德拉草种在地里."
STRINGS.RECIPE_DESC.CARROT_PLANTED = "把胡萝卜种在地里."
STRINGS.RECIPE_DESC.SUCCULENT_PLANT = "在地上种植多肉植物."
STRINGS.RECIPE_DESC.CAVE_FERN = "在地上种蕨类植物."
STRINGS.RECIPE_DESC.MARBLETREE = "把这些大理石树栽下去."
STRINGS.RECIPE_DESC.MARBLEPILLAR = "把这些大理石柱子建起来."
STRINGS.RECIPE_DESC.CAVE_BANANA_TREE = "种植香蕉树!"
STRINGS.RECIPE_DESC.CACTUS = "种植仙人掌."
STRINGS.RECIPE_DESC.STATUEMAXWELL = "把这些漂亮的雕像种下去."
STRINGS.RECIPE_DESC.PIGTORCH = "造些奇怪的火把."
STRINGS.RECIPE_DESC.FLOWER_ROSE = "种些奇怪的花."
STRINGS.RECIPE_DESC.PUMPKIN_PLANTED = "可爱的南瓜."

--不可部署
local DEPLOYABLE = false
if not DEPLOYABLE then
    AddRecipe("mandrake_planted", { Ingredient("mandrake", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "mandrake_planted_placer", -- placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/mandrake_planted.xml", -- atlas
        "mandrake_planted.tex") -- image

    AddRecipe("pumpkin_planted", { Ingredient("pumpkin", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "pumpkin_planted_placer",
        1,
        nil,
        1,
        nil,
        "images/inventoryimages/pumpkin.xml",
        "pumpkin.tex")

    AddRecipe("carrot_planted", { Ingredient("carrot_seeds", 1), Ingredient("poop", 2) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "carrot_planted_placer", --placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/carrot_planted.xml", -- atlas
        "carrot_planted.tex") -- image

    AddRecipe("succulent_plant", { Ingredient("succulent_picked", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "succulent_placer", --placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/succulent_planted.xml", -- atlas
        "succulent_planted.tex") -- image

    AddRecipe("cave_fern", { Ingredient("foliage", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "cave_fern_placer", --placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/cave_fern_planted.xml", -- atlas
        "cave_fern_planted.tex") -- image

    AddRecipe("marbletree", { Ingredient("marble", 6) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "marbletree_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/marbletree.xml", -- atlas
        "marbletree.tex") -- image

    AddRecipe("marblepillar", { Ingredient("marble", 6) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "marblepillar_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/marblepillar.xml", -- atlas
        "marblepillar.tex") -- image

    AddRecipe("statuemaxwell", { Ingredient("marble", 6), Ingredient("nightmarefuel", 2) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "statuemaxwell_placer", -- placer
        3, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/statuemaxwell.xml", -- atlas
        "statuemaxwell.tex") -- image

    AddRecipe("flower_rose", { Ingredient("petals", 2), Ingredient("stinger", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "rose_placer", --placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/rose.xml", -- atlas
        "rose.tex") -- image
else
    local planted_prefab = {
        carrot = "carrot_planted",
        mandrake = "mandrake_planted",
        succulent_picked = "succulent_plant",
        foliage = "cave_fern",
        pumpkin = "pumpkin",
    }

    local function postinit(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(GLOBAL.DEPLOYMODE.PLANT)
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.LESS)
        inst.components.deployable.ondeploy = function(inst, pt)
            local planted_item = GLOBAL.SpawnAt(planted_prefab[inst.prefab], pt)
            if not planted_item.SoundEmitter then
                planted_item.entity:AddSoundEmitter()
            end
            planted_item.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
        end
        return inst
    end

    AddPrefabPostInit("carrot", postinit)
    AddPrefabPostInit("mandrake", postinit)
    AddPrefabPostInit("succulent_picked", postinit)
    AddPrefabPostInit("foliage", postinit)
    AddPrefabPostInit("pumpkin", postinit)

    AddRecipe("marbletree", { Ingredient("marble", 6) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "marbletree_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/marbletree.xml", -- atlas
        "marbletree.tex") -- image

    AddRecipe("marblepillar", { Ingredient("marble", 6) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "marblepillar_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/marblepillar.xml", -- atlas
        "marblepillar.tex") -- image

    AddRecipe("statuemaxwell", { Ingredient("marble", 6), Ingredient("nightmarefuel", 2) }, RECIPETABS.TOWN, TECH.SCULPTING_ONE,
        "statuemaxwell_placer", -- placer
        3, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/statuemaxwell.xml", -- atlas
        "statuemaxwell.tex") -- image

    AddRecipe("flower_rose", { Ingredient("petals", 2), Ingredient("stinger", 1) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "rose_placer", --placer
        1, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/rose.xml", -- atlas
        "rose.tex") -- image
end
--禁止op的种植
local OPSTUFF = false
if OPSTUFF then
    AddRecipe("cave_banana_tree", { Ingredient("cave_banana", 4), Ingredient("poop", 3), Ingredient("twigs", 2) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "cave_banana_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/bananatree.xml", -- atlas
        "bananatree.tex") -- image

    AddRecipe("cactus", { Ingredient("cactus_meat", 5), Ingredient("poop", 4) }, RECIPETABS.FARM, TECH.SCIENCE_ONE,
        "cactus_placer", --placer
        2, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/cacti.xml", -- atlas
        "cacti.tex") -- image

    AddRecipe("pigtorch", { Ingredient("log", 6), Ingredient("pigskin", 4) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE,
        "pigtorch_placer", -- placer
        3, -- min_spacing
        nil, -- nounlock
        nil, -- numtogive
        nil, -- builder_tag
        "images/inventoryimages/pigtorch.xml", -- atlas
        "pigtorch.tex") -- image
end
--种植的南瓜易腐烂
local PERISH = true
if not PERISH then
    AddPrefabPostInit("pumpkin", function(inst)
        if inst.components.perishable ~= nil then
            inst.components.perishable:SetPerishTime(999999999999)
        end
    end)
end





--fr更多的背包
--fr箱子背包更大容量
--get Global vars
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local TUNING = GLOBAL.TUNING
local IsServer = GLOBAL.TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput
local ThePlayer = GLOBAL.ThePlayer
local net_entity = GLOBAL.net_entity

--set global vars/get config
local containers = require("containers")
containers.MAXITEMSLOTS = 24
--背包由8格增加到12格
local INCREASEBACKPACKSIZES_BACKPACK = 12
--小猪包由12格增加到14格
local INCREASEBACKPACKSIZES_PIGGYBACK = 14
--坎普斯由14格增加到18格
local INCREASEBACKPACKSIZES_KRAMPUSSACK = 18
--绝缘包由6格增加到10格
local INCREASEBACKPACKSIZES_ICEPACK = 10
--冰箱由9格增加到12格
local largericebox = 12
--切斯特由9格增加到12格
local largertreasurechest = 12
--鳞甲箱子由12格增加到24格
local largerdragonflychest = 24
--切斯特由9格增加到12格
local largerchester = 12
--Define functions
local function addItemSlotNetvarsInContainer(inst)
    if (#inst._itemspool < containers.MAXITEMSLOTS) then
        for i = #inst._itemspool + 1, containers.MAXITEMSLOTS do
            table.insert(inst._itemspool, net_entity(inst.GUID, "container._items[" .. tostring(i) .. "]", "items[" .. tostring(i) .. "]dirty"))
        end
    end
end

AddPrefabPostInit("container_classified", addItemSlotNetvarsInContainer)

--Change size of Backpacks and Chests
local widgetsetup_Base = containers.widgetsetup or function() return true end
function containers.widgetsetup(container, prefab, data, ...)
    -- print("test1")
    local updated = false
    local tempPrefab = prefab or container.inst.prefab
    local result = widgetsetup_Base(container, prefab, data, ...)

    if (tempPrefab == "backpack" and INCREASEBACKPACKSIZES_BACKPACK ~= 8) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_BACKPACK == 10 then
            container.widget.animbank = "ui_krampusbag_2x5"
            container.widget.animbuild = "ui_krampusbag_2x5"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 4 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 115, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 115, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 12 then
            container.widget.animbank = "ui_piggyback_2x6"
            container.widget.animbuild = "ui_piggyback_2x6"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 5 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "piggyback" and INCREASEBACKPACKSIZES_PIGGYBACK ~= 12) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_PIGGYBACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_PIGGYBACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_PIGGYBACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "krampus_sack" and INCREASEBACKPACKSIZES_KRAMPUSSACK ~= 14) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_KRAMPUSSACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_KRAMPUSSACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "icepack" and INCREASEBACKPACKSIZES_ICEPACK ~= 6) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_ICEPACK == 8 then
            container.widget.animbank = "ui_backpack_2x4"
            container.widget.animbuild = "ui_backpack_2x4"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 3 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 10 then
            container.widget.animbank = "ui_krampusbag_2x5"
            container.widget.animbuild = "ui_krampusbag_2x5"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 4 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 115, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 115, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 12 then
            container.widget.animbank = "ui_piggyback_2x6"
            container.widget.animbuild = "ui_piggyback_2x6"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 5 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "icebox" and largericebox ~= 9) then
        container.widget.slotpos = {}
        if largericebox == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        elseif largericebox == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largericebox == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largericebox == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "treasurechest" and largertreasurechest ~= 9) then
        container.widget.slotpos = {}
        if largertreasurechest == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        elseif largertreasurechest == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largertreasurechest == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largertreasurechest == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "dragonflychest" and largerdragonflychest ~= 12) then
        container.widget.slotpos = {}
        if largerdragonflychest == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largerdragonflychest == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largerdragonflychest == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "chester" and largerchester ~= 9) then
        container.widget.slotpos = {}
        if largerchester == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        end
        updated = true
    end

    if updated then
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        --containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    end
    return result
end





--fr箱子提示
local _G = GLOBAL

local SERVER_SIDE = nil
local DEDICATED_SIDE = nil
local CLIENT_SIDE = nil
local ONLY_CLIENT_SIDE = nil
if GLOBAL.TheNet:GetIsServer() then
    SERVER_SIDE = true
    if GLOBAL.TheNet:IsDedicated() then
        DEDICATED_SIDE = true
    else
        CLIENT_SIDE = true
    end
elseif GLOBAL.TheNet:GetIsClient() then
    SERVER_SIDE = false
    CLIENT_SIDE = true
    ONLY_CLIENT_SIDE = true
end


--允许箱子高亮显示
local client_option = true

local isDST = _G.TheSim:GetGameID() == 'DST'

local Highlight = _G.require 'components/highlight'
local __Highlight_ApplyColour = Highlight.ApplyColour
local __Highlight_UnHighlight = Highlight.UnHighlight

local c = { r = 0, g = .25, b = 0 }

local function custom_ApplyColour(self, ...)
    local r, g, b =
    (self.base_add_colour_red or 0),
    (self.base_add_colour_green or 0),
    (self.base_add_colour_blue or 0)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue =
    r + c.r, g + c.g, b + c.b

    local result = __Highlight_ApplyColour(self, ...)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue = r, g, b

    return result
end

local function custom_UnHighlight(self, ...)
    local flashing = self.flashing
    self.flashing = true
    local result = __Highlight_UnHighlight(self, ...)
    self.flashing = flashing

    if isDST and not self.flashing then
        local r, g, b =
        (self.highlight_add_colour_red or 0),
        (self.highlight_add_colour_green or 0),
        (self.highlight_add_colour_blue or 0)

        self.highlight_add_colour_red,
        self.highlight_add_colour_green,
        self.highlight_add_colour_blue =
        0, 0, 0

        self:ApplyColour()

        self.highlight_add_colour_red,
        self.highlight_add_colour_green,
        self.highlight_add_colour_blue = r, g, b
    end

    return result
end

local function filter(chest, item)
    return chest.components.container and item and
            chest.components.container:Has(item, 1)
end


local function ServerRPCFunction(owner, prefab, source, unhighlighten, highlighten)
    if unhighlighten then
        local v = nil
        for i = 1, 50 do
            v = owner["mynetvarSearchedChest" .. tostring(i)]:value()
            if v ~= nil and not (not v:HasTag("HighlightSourceCraftPot") and source == "CraftPotClose") then
                v:RemoveTag("HighlightSourceCraftPot")
                owner["mynetvarSearchedChest" .. tostring(i)]:set(nil)
            end
        end
    end
    if highlighten then
        if owner and prefab then
            local x, y, z = owner.Transform:GetWorldPosition()
            local e = TheSim:FindEntities(x, y, z, 20, nil, { 'NOBLOCK', 'player', 'FX' }) or {}
            for k, v in pairs(e) do
                if v and v:IsValid() and v.entity:IsVisible() and filter(v, prefab) then
                    -- print("server highlight "..tostring(v))
                    if source == "CraftPot" then
                        v:AddTag("HighlightSourceCraftPot")
                    end
                    for i = 1, 50 do
                        if owner["mynetvarSearchedChest" .. tostring(i)]:value() == nil then
                            v.highlightsource = source
                            owner["mynetvarSearchedChest" .. tostring(i)]:set(v)
                            break
                        end
                    end
                end
            end
        end
    end
end

local function ClientUnhighlightChests(owner, prefab, source, unhighlighten, highlighten)
    if CLIENT_SIDE then
        if unhighlighten then
            for i = 1, 50 do
                local chest = owner["mynetvarSearchedChest" .. tostring(i)]:value()
                if chest and chest.components.highlight then
                    if not (not chest:HasTag("HighlightSourceCraftPot") and source == "CraftPotClose") then

                        if chest.components.highlight.ApplyColour == custom_ApplyColour then
                            chest.components.highlight.ApplyColour = nil
                        end

                        if chest.components.highlight.UnHighlight == custom_UnHighlight then
                            chest.components.highlight.UnHighlight = nil
                        end

                        chest.components.highlight:UnHighlight()
                    end
                end
            end
        end
        if SERVER_SIDE then
            ServerRPCFunction(owner, prefab, source, unhighlighten, highlighten) -- call it directly without rpc, if we are also server
        else
            local rpc = GetModRPC("FinderMod", "CheckContainersItem")
            SendModRPCToServer(rpc, prefab, source, unhighlighten, highlighten)
        end
    end
end

local function DoHighlightStuff(owner, prefab, source, unhighlighten, highlighten)
    if CLIENT_SIDE and owner == GLOBAL.ThePlayer then
        ClientUnhighlightChests(owner, prefab, source, unhighlighten, highlighten)
    end
end

local function onactiveitem(owner, data)
    local prefab = data.item and data.item.prefab or nil
    local source = "newactiveitem"
    if owner and prefab then
        DoHighlightStuff(owner, prefab, source, true, true)
    else
        DoHighlightStuff(owner, prefab, source, true, false)
    end
end

local function OnDirtyEventSearchedChest(inst, i)
    if CLIENT_SIDE and inst == GLOBAL.ThePlayer then
        if client_option then
            local chest = inst["mynetvarSearchedChest" .. tostring(i)]:value()
            if chest then
                if not chest.components.highlight then
                    chest:AddComponent('highlight')
                end

                if chest.components.highlight then
                    chest.components.highlight.ApplyColour = custom_ApplyColour
                    chest.components.highlight.UnHighlight = custom_UnHighlight
                    chest.components.highlight:Highlight(0, 0, 0)
                end
            end
        end
    end
end


local function RegisterListeners(inst)
    for i = 1, 50 do
        inst:ListenForEvent("DirtyEventSearchedChest" .. tostring(i), function(inst) inst:DoTaskInTime(0, OnDirtyEventSearchedChest(inst, i)) end)
    end
end

local function init(inst)
    if not inst then return end
    for i = 1, 50 do
        inst["mynetvarSearchedChest" .. tostring(i)] = GLOBAL.net_entity(inst.GUID, "SearchedChest" .. tostring(i) .. "NetStuff", "DirtyEventSearchedChest" .. tostring(i))
        inst["mynetvarSearchedChest" .. tostring(i)]:set(nil)
    end
    inst:DoTaskInTime(0, RegisterListeners)
    inst:ListenForEvent('newactiveitem', onactiveitem)
end

AddPlayerPostInit(function(owner)
    init(owner)
end)

AddModRPCHandler("FinderMod", "CheckContainersItem", ServerRPCFunction)

AddClassPostConstruct("widgets/ingredientui", function(self)
    local __IngredientUI_OnGainFocus = self.OnGainFocus

    function self:OnGainFocus(...)
        local tex = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
        local owner = self.parent and self.parent.parent and self.parent.parent.owner
        if tex and owner then
            DoHighlightStuff(owner, tex, "Crafting", true, true)
        end
        if __IngredientUI_OnGainFocus then
            return __IngredientUI_OnGainFocus(self, ...)
        end
    end

    local __IngredientUI_OnLoseFocus = self.OnLoseFocus
    function self:OnLoseFocus(...)
        local owner = self.parent and self.parent.parent and self.parent.parent.owner
        DoHighlightStuff(owner, nil, "Crafting", true, false)
        if __IngredientUI_OnLoseFocus then
            return __IngredientUI_OnLoseFocus(self, ...)
        end
    end
end)


local function testCraftPot()
    local FoodIngredientUI = _G.require 'widgets/foodingredientui'
end

if GLOBAL.pcall(testCraftPot) then
    local cooking = _G.require("cooking")
    local ing = cooking.ingredients

    AddClassPostConstruct("widgets/foodingredientui", function(self)
        local __FoodIngredientUI_OnGainFocus = self.OnGainFocus
        function self:OnGainFocus(...)
            local searchtag = self.prefab
            local isname = self.is_name
            local owner = self.owner
            local prefabs = {}

            if not isname then
                for prefab, xyz in pairs(ing) do
                    for tag, number in pairs(xyz.tags) do
                        if tag == searchtag then
                            table.insert(prefabs, prefab)
                        end
                    end
                end
            elseif isname and GLOBAL.PREFABDEFINITIONS[searchtag] then
                table.insert(prefabs, GLOBAL.PREFABDEFINITIONS[searchtag].name)
            end
            DoHighlightStuff(owner, nil, "CraftPot", true, false)
            for k, prefab in pairs(prefabs) do
                if prefab and owner then
                    DoHighlightStuff(owner, prefab, "CraftPot", false, true)
                end
            end
            if __FoodIngredientUI_OnGainFocus then
                return __FoodIngredientUI_OnGainFocus(self, ...)
            end
        end
    end)

    AddClassPostConstruct("widgets/foodcrafting", function(self)
        local _OnLoseFocus = self.OnLoseFocus
        self.OnLoseFocus = function(...)
            local owner = self.owner
            DoHighlightStuff(owner, nil, "CraftPot", true, false)
            if _OnLoseFocus then
                return _OnLoseFocus(self, ...)
            end
        end

        local _Close = self.Close
        self.Close = function(...)
            local owner = self.owner
            DoHighlightStuff(owner, nil, "CraftPotClose", true, false)
            if _Close then
                return _Close(self, ...)
            end
        end
    end)
end


AddClassPostConstruct("widgets/tabgroup", function(self)
    local __TabGroup_DeselectAll = self.DeselectAll
    function self:DeselectAll(...)
        DoHighlightStuff(GLOBAL.ThePlayer, nil, "CraftingClose", true, false)
        return __TabGroup_DeselectAll(self, ...)
    end
end)