local assert = GLOBAL.assert
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local GROUND = GLOBAL.GROUND
local SpawnPrefab = GLOBAL.SpawnPrefab

--开启地毯绝缘
local InsulatingTurfs = 1
InsulatingTurfs = InsulatingTurfs == 1 or InsulatingTurfs == true or InsulatingTurfs == "true"
--保温地毯永久保温
local InsulationDuration = 99999999999999
do
    local val = GLOBAL.tonumber(InsulationDuration)
    if val == nil then
        moderror(("Value of configuration option InsulationDuration '%s' is invalid."):format(tostring(InsulationDuration)))
        val = 0
    end
    InsulationDuration = math.max(math.min(val, 99999999999999), 1)
    if InsulationDuration ~= val then
        print(("[Turfed] Value of configuration option InsulationDuration '%s' is out of limits, setting to %s."):format(tostring(val), tostring(InsulationDuration)))
    end
end
--回san地毯
local SanityTurfs = 1
SanityTurfs = SanityTurfs == 1 or SanityTurfs == true or SanityTurfs == "true"
--防雨地毯
local RainProtectingTurfs = 1
RainProtectingTurfs = RainProtectingTurfs == 1 or RainProtectingTurfs == true or RainProtectingTurfs == "true"
--加速地毯
local SpeedyTurfs = 1
SpeedyTurfs = SpeedyTurfs == 1 or SpeedyTurfs == true or SpeedyTurfs == "true"
--1.25倍回san
local SpeedyTurfSpeeds = 1.25
do
    local val = GLOBAL.tonumber(SpeedyTurfSpeeds)
    if val == nil then
        moderror(("Value of configuration option SpeedyTurfSpeeds '%s' is invalid"):format(tostring(SpeedyTurfSpeeds)))
        val = 0
    end
    SpeedyTurfSpeeds = math.max(math.min(val, 8), 0.01)
    if SpeedyTurfSpeeds ~= val then
        print(("[Turfed] Value of configuration option SpeedyTurfSpeeds '%s' is out of limits, setting to %s."):format(tostring(val), tostring(SpeedyTurfSpeeds)))
    end
end
--可塑造的地毯
local EnableGameTurfRecipes = 1
EnableGameTurfRecipes = EnableGameTurfRecipes == 1 or EnableGameTurfRecipes == true or EnableGameTurfRecipes == "true"
--可以在草皮上做地毯
local EnableTurfedTurfRecipes = 1
EnableTurfedTurfRecipes = EnableTurfedTurfRecipes == 1 or EnableTurfedTurfRecipes == true or EnableTurfedTurfRecipes == "true"
--地毯上没有移速加成
local EnableNonPlayerSpeed = false
EnableNonPlayerSpeed = EnableNonPlayerSpeed == 1 or EnableNonPlayerSpeed == true or EnableNonPlayerSpeed == "true"

--[[
local EnableFlooringPlanting = GetModConfigData("EnableFlooringPlanting")
EnableFlooringPlanting = EnableFlooringPlanting == true or EnableFlooringPlanting == "true" or EnableFlooringPlanting == 1
local EnableIndividualization = GetModConfigData("EnableIndividualization")
EnableIndividualization = EnableIndividualization == true or EnableIndividualization == "true" or EnableIndividualization == 1
print(("[Turfed] Settings: InsulatingTurfs=%s, InsulationDuration=%s, SanityTurfs=%s, RainProtectingTurfs=%s, SpeedyTurfs=%s, SpeedyTurfSpeeds=%s, EnableGameTurfRecipes=%s, EnableTurfedTurfRecipes=%s, EnableFlooringPlanting=%s, EnableIndividualization=%s, EnableNonPlayerSpeed=%s"):format(
	tostring(InsulatingTurfs), tostring(InsulationDuration), tostring(SanityTurfs), tostring(RainProtectingTurfs), tostring(SpeedyTurfs), tostring(SpeedyTurfSpeeds), tostring(EnableGameTurfRecipes), tostring(EnableTurfedTurfRecipes), tostring(EnableFlooringPlanting), tostring(EnableIndividualization), tostring(EnableNonPlayerSpeed)
))
--]]


Assets = {
    --Excuse me, are you checking out my assets?
    --Custom Assets
    --Testing Purposes
    Asset("IMAGE", "levels/textures/noise_modtest.tex"),
    Asset("IMAGE", "levels/textures/mini_noise_modtest.tex"),
    --Turfed Craft Tab
    Asset("IMAGE", "images/tabimages/turfedtab.tex"),
    Asset("ATLAS", "images/tabimages/turfedtab.xml"),
}

local turfs_assets_tbl = {
    -- Carpet
    { tiletexturename = "carpetblackfur", invname = "carpetblackfur" },
    { tiletexturename = "carpetblue", invname = "carpetblue" },
    { tiletexturename = "carpetcamo", invname = "carpetcamo" },
    { tiletexturename = "carpetfur", invname = "carpetfur" },
    { tiletexturename = "carpetpink", invname = "carpetpink" },
    { tiletexturename = "carpetpurple", invname = "carpetpurple" },
    { tiletexturename = "carpetred", invname = "carpetred" },
    { tiletexturename = "carpetred2", invname = "carpetred2" },
    { tiletexturename = "carpettd", invname = "carpettiedye" },
    { tiletexturename = "carpetwifi", invname = "carpetwifi" },
    -- Nature
    { tiletexturename = "natureastroturf", invname = "natureastroturf" },
    { tiletexturename = "naturedesert", invname = "naturedesert" },
    -- Rock
    { tiletexturename = "rockblacktop", invname = "rockblacktop" },
    { tiletexturename = "rockgiraffe", invname = "rockgiraffe" },
    { tiletexturename = "rockmoon", invname = "rockmoon" },
    { tiletexturename = "rockyellowbrick", invname = "rockyellowbrick" },
    -- Tile
    { tiletexturename = "tilecheckerboard", invname = "tilecheckerboard" },
    { tiletexturename = "tilefrosty", invname = "tilefrosty" },
    { tiletexturename = "tilesquares", invname = "tilesquares" },
    -- Wood
    { tiletexturename = "woodcherry", invname = "woodcherry" },
    { tiletexturename = "wooddark", invname = "wooddark" },
    { tiletexturename = "woodpine", invname = "woodpine" },
    -- spikes
    { tiletexturename = "spikes", invname = "spikes" },

    -- Base Game Turfs
    { invname = "Forest_Turf" },
    { invname = "Deciduous_Turf" },
    { invname = "Grass_Turf" },
    { invname = "Savanna_Turf" },
    { invname = "Desert_Turf" },
    { invname = "Marsh_Turf" },
    { invname = "Fungus_Blue_Turf" },
    { invname = "Fungus_Red_Turf" },
    { invname = "Fungus_Green_Turf" },
    { invname = "Mud_Turf" },
    { invname = "Sinkhole_Turf" },
    { invname = "Rocky_Turf" },
    { invname = "Guano_Turf" },
    { invname = "Cave_Rock_Turf" },
}

for i, data in ipairs(turfs_assets_tbl) do
    if data.tiletexturename ~= nil then
        table.insert(Assets, Asset("IMAGE", "levels/textures/noise_" .. data.tiletexturename .. ".tex"))
        table.insert(Assets, Asset("IMAGE", "levels/textures/mini_noise_" .. data.tiletexturename .. ".tex"))
    end
    if data.invname ~= nil then
        table.insert(Assets, Asset("IMAGE", "images/inventoryimages/" .. data.invname .. ".tex"))
        table.insert(Assets, Asset("ATLAS", "images/inventoryimages/" .. data.invname .. ".xml"))
    end
end

-------------------------------------------------------------------------------


PrefabFiles = {
    -- Testing Purposes
    "turf_test",
    -- Turfed Turfs
    "turfed_turfs",
}

--These generate the "table index is nil" error if there is no successful AddTile that adds MODTEST to the GROUND table <-thank you DarkXero of the klei forums
local MOD_GROUND_TURFS = {
    [GROUND.MODTEST] = "turf_test",
    [GROUND.CARPETBLACKFUR] = "turf_carpetblackfur",
    [GROUND.CARPETBLUE] = "turf_carpetblue",
    [GROUND.CARPETCAMO] = "turf_carpetcamo",
    [GROUND.CARPETFUR] = "turf_carpetfur",
    [GROUND.CARPETPINK] = "turf_carpetpink",
    [GROUND.CARPETPURPLE] = "turf_carpetpurple",
    [GROUND.CARPETRED] = "turf_carpetred",
    [GROUND.CARPETRED2] = "turf_carpetred2",
    [GROUND.CARPETTD] = "turf_carpettd",
    [GROUND.CARPETWIFI] = "turf_carpetwifi",
    [GROUND.NATUREASTROTURF] = "turf_natureastroturf",
    [GROUND.NATUREDESERT] = "turf_naturedesert",
    [GROUND.ROCKBLACKTOP] = "turf_rockblacktop",
    [GROUND.ROCKGIRAFFE] = "turf_rockgiraffe",
    [GROUND.ROCKMOON] = "turf_rockmoon",
    [GROUND.ROCKYELLOWBRICK] = "turf_rockyellowbrick",
    [GROUND.TILECHECKERBOARD] = "turf_tilecheckerboard",
    [GROUND.TILEFROSTY] = "turf_tilefrosty",
    [GROUND.TILESQUARES] = "turf_tilesquares",
    [GROUND.WOODCHERRY] = "turf_woodcherry",
    [GROUND.WOODDARK] = "turf_wooddark",
    [GROUND.WOODPINE] = "turf_woodpine",
    [GROUND.SPIKES] = "turf_spikes",
}


local function SpawnTurf(turf, pt)
    if turf ~= nil then
        local loot = SpawnPrefab(turf)

        if loot.components.inventoryitem ~= nil then
            loot.components.inventoryitem:InheritMoisture(GLOBAL.TheWorld.state.wetness, GLOBAL.TheWorld.state.iswet)
        end

        loot.Transform:SetPosition(pt:Get())

        if loot.Physics ~= nil then
            local angle = math.random() * 2 * GLOBAL.PI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
        end
    end
end

-- Not necessary for the AddComponentPostInit version
local Terraformer = require("components/terraformer")
local OldTerraform = Terraformer.Terraform or function() return false end

-- A heavily-gutted version of the original Terraform function
-- Ultimately, it checks for the turf type at the intended dig spot and will spawn it if the original function didn't
function Terraformer:Terraform(pt, spawnturf)
    local Map = GLOBAL.TheWorld.Map

    if not Map:CanTerraformAtPoint(pt:Get()) then
        return false
    end

    local original_tile_type = Map:GetTileAtPoint(pt:Get())
    --local dugSomethingUp = OldTerraform(self, pt)

    -- If the old terraform successfully dug up some turf and it's a ruins turf, spawn the item
    if OldTerraform(self, pt, spawnturf) then
        local turfPrefab = MOD_GROUND_TURFS[original_tile_type]

        if spawnturf and turfPrefab ~= nil then
            SpawnTurf(turfPrefab, pt)
        end

        return true
    end

    return false
end


-- worldtiledef's GetTileInfo replacement with better performance
-- create a hashed cache of all tile types and use it instead of GetTileInfo's iteration

local TileInfoCache = nil
local function UpdateTileInfoCache()
    TileInfoCache = {}
    local tiledefs = require 'worldtiledefs'
    for i, data in ipairs(tiledefs.ground) do
        local tileid = data[1]
        if tileid == nil then
            local s = ""
            if type(data) == "table" then
                s = GLOBAL.tabletodictstring(data)
            end
            moderror(string.format("[Turfed|UpdateTileInfoCache] worldtiledefs.ground[%d] has unsupported value %s %s", i, tostring(data), s))
        else
            TileInfoCache[tileid] = data
        end
    end
end

local function MyGetTileInfo(tile)
    if TileInfoCache == nil then
        UpdateTileInfoCache()
    end
    local res = TileInfoCache[tile]
    return res ~= nil and res[2] or nil
end

local function ReplaceGetTileInfoFunction()
    -- check if GLOBAL.GetTileInfo is the original one
    if type(GLOBAL.GetTileInfo) ~= "function" then
        moderror(("[Turfed|SimPostInit] Type of GLOBAL.GetTileInfo is %s (%s), expected function."):format(type(GLOBAL.GetTileInfo), tostring(GLOBAL.GetTileInfo)))
        return
    end
    local info = GLOBAL.debug.getinfo(GLOBAL.GetTileInfo)
    if type(info) ~= "table" then
        moderror(("[Turfed|SimPostInit] Type of GetTileInfo's debuginfo is %s (%s), expected table."):format(type(info), tostring(info)))
        return
    end
    local source = info.source or info.short_src or ""
    local source_expected = "scripts/worldtiledefs.lua"
    if source ~= source_expected then
        -- someone overwrote the function, oh well
        print(("[Turfed|SimPostInit] Source of GetTileInfo function is '%s', expected '%s'."):format(tostring(source), source_expected))
        return
    end

    -- future changes to worldtiledefs.ground table might be ignored with regards to GetTileInfo calls
    UpdateTileInfoCache()
    GLOBAL.GetTileInfo = MyGetTileInfo
end

AddSimPostInit(function()
    ReplaceGetTileInfoFunction()
end)


-- Turfs, Overheating/Freezing, and YOU!
if InsulatingTurfs then
    AddComponentPostInit("temperature", function(self)
        local _GetInsulation = self.GetInsulation
        self.GetInsulation = function(self)
            local winterInsulation, summerInsulation = _GetInsulation(self)
            local tile, data = self.inst:GetCurrentTileType()
            if data ~= nil and data.turfed ~= nil then
                local winterBonusMult = data.turfed.insulationWinterMult ~= nil and data.turfed.insulationWinterMult or 0
                local winterBonusAdd = data.turfed.insulationWinterAdd ~= nil and data.turfed.insulationWinterAdd or 0
                local summerBonusMult = data.turfed.insulationSummerMult ~= nil and data.turfed.insulationSummerMult or 0
                local summerBonusAdd = data.turfed.insulationSummerAdd ~= nil and data.turfed.insulationSummerAdd or 0
                winterInsulation = winterInsulation + InsulationDuration * winterBonusMult + winterBonusAdd
                summerInsulation = summerInsulation + InsulationDuration * summerBonusMult + summerBonusAdd
            end
            return math.max(0, winterInsulation), math.max(0, summerInsulation)
        end
    end)
end

-- Turfs, Sanity, and YOU!
if SanityTurfs then
    AddPlayerPostInit(function(inst)
        if inst.components.sanity then
            local _crfn = inst.components.sanity.custom_rate_fn
            inst.components.sanity.custom_rate_fn = function(inst)
                local ret = 0
                if _crfn then
                    ret = _crfn(inst)
                end
                local tile, data = inst:GetCurrentTileType()
                if data ~= nil and data.turfed ~= nil then
                    local sanityBonusMult = data.turfed.sanityMult ~= nil and data.turfed.sanityMult or 0
                    local sanityBonusAdd = data.turfed.sanityAdd ~= nil and data.turfed.sanityAdd or 0
                    local sanityDelta = TUNING.DAPPERNESS_MED * sanityBonusMult + sanityBonusAdd
                    ret = ret + sanityDelta
                end
                return ret
            end
        end
    end)
end

-- Turfs, Rain, and YOU!
if RainProtectingTurfs then
    AddComponentPostInit("moisture", function(self)
        local _GetMoistureRate = self.GetMoistureRate
        self.GetMoistureRate = function(self)
            local oldrate = _GetMoistureRate(self)
            local tile, data = self.inst:GetCurrentTileType()
            if data ~= nil and data.turfed ~= nil then
                local moistureMult = data.turfed.moistureMult ~= nil and data.turfed.moistureMult or 1
                local rate = oldrate * moistureMult
                return math.max(0, rate)
            end
            return oldrate
        end
    end)
end


-- Turfs, Speed, and YOU!

-- evaluates tag condition for entity
-- @param entity
-- @param condition table  {"!?tag1", "!?tag2", .. "!?tagN"}
--     tagX means the entity has the tag, !tagX means the entity does not have the tag
--     %tagX means the entity's prefab is equal to tagX, !%tagX means the entity's prefab is not equal to tagX
--     tag subexpressions are joined by conjuction (AND), i.e. all have to be true for the condition to be true; n.b.: no subexpression means true condition as well
-- @return boolean
local function EvaluateTagCondition(entity, conditions)
    if type(conditions) ~= "table" then
        moderror(("[Turfed|EvaluateTagCondition(%s,%s)] Type of conditions is %s (%s), expected table."):format(tostring(entity), tostring(condition), type(conditions), tostring(conditions)))
        return false
    end

    for i = 1, #conditions do
        local condition = conditions[i]
        local expr = condition -- leave original condition intact for debug message
        local neg = false
        if string.sub(expr, 1, 1) == "!" then
            neg = not neg
            expr = string.sub(expr, 2)
        end
        if #expr == 0 then
            moderror(("[Turfed|EvaluateTagCondition(%s,%s)] Subexpression #%d '%s' of conditions '%s' is empty."):format(tostring(entity), tostring(conditions), i, tostring(subexpr), GLOBAL.tabletoliststring(conditions)))
            return false
        end

        if string.sub(expr, 1, 1) == "%" then
            -- check prefab name equivalence
            expr = string.sub(expr, 2)
            local hasname = entity.prefab == expr
            if not ((not neg and hasname) or (neg and not hasname)) then
                -- subexpression is not true
                return false
            end
        else
            -- check tag existence
            local hastag = entity:HasTag(expr)
            if not ((not neg and hastag) or (neg and not hastag)) then
                -- subexpression is not true
                return false
            end
        end
    end

    return true
end

-- workaround due to Moderator Commands mod
-- copied definition from util.lua
local function string_split(self, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

-- cache of transformed condition strings
local conditionCache = {}

-- transform tag condition from string form into table
-- assumes no tag (in conditionStr) contains ',', '!' or '%'
-- @param conditionStr string
-- @return table
local function TransformTagCondition(conditionStr)
    if conditionCache[conditionStr] ~= nil then
        return conditionCache[conditionStr]
    end

    local conditionTbl = string_split(conditionStr, ",")
    -- go from N to 1 to make removal correct
    for i = #conditionTbl, 1, -1 do
        local condition = conditionTbl[i]
        -- trim spaces
        local condition2 = string.gsub(condition, "^%s*(.-)%s*$", "%1")
        -- normalize negations
        while string.sub(condition2, 1, 2) == "!!" do
            condition2 = string.sub(condition2, 3)
        end

        if condition2 == "" or condition2 == "!" or condition2 == "%" or condition2 == "!%" then
            moderror(("[Turfed|TransformTagCondition(%s)] Subexpression #%d of '%s' is empty."):format(tostring(conditionStr), i, condition))
            -- remove invalid condition
            table.remove(conditionTbl, i)
        else
            -- replace original condition with normalized one
            conditionTbl[i] = condition2
        end
    end

    conditionCache[conditionStr] = conditionTbl
    return conditionTbl
end

-- calculates bonus that applies for the entity
-- @param entity
-- @param bonuses table  item is {condition, bonus}
-- @return nil if no condition is true for the entity
--         sum of bonuses from applicable entries
local function GetConditionalBonus(entity, bonuses)
    if entity == nil then
        -- use if+error instead of assert for improved performance in positive case (expensive string.format is skipped)
        error(("[Turfed|GetConditionalBonus(%s,%s)] Entity is nil."):format(tostring(entity), tostring(bonuses)))
    end
    if type(bonuses) ~= "table" then
        moderror(("[Turfed|GetConditionalBonus(%s,%s)] Type of bonuses is %s (%s), expected table."):format(tostring(entity), tostring(bonuses), type(bonuses), tostring(bonuses)))
        return nil
    end

    local sum = nil
    for i = 1, #bonuses do
        local bonusdata = bonuses[i]
        if type(bonusdata) ~= "table" then
            moderror(("[Turfed|GetConditionalBonus(%s,%s)] Type of bonuses[%d] is %s (%s), expected table."):format(tostring(entity), tostring(bonuses), i, type(bonusdata), tostring(bonusdata)))
            return nil
        end
        local condition = bonusdata[1]
        local bonus = bonusdata[2]
        local conditionType = type(condition)
        if conditionType ~= "table" then
            if conditionType ~= "string" then
                moderror(("[Turfed|GetConditionalBonus(%s,%s)] Type of condition [%d] is %s (%s), expected table or string."):format(tostring(entity), tostring(bonuses), i, type(condition), tostring(condition)))
                return nil
            end
            -- first time accessing this condition, transform it to table for future faster performance
            condition = TransformTagCondition(condition)
            bonusdata[1] = condition
        end
        if type(bonus) ~= "number" then
            moderror(("[Turfed|GetConditionalBonus(%s,%s)] Type of bonus [%d] is %s (%s), expected number."):format(tostring(entity), tostring(bonuses), i, type(bonus), tostring(bonus)))
            return nil
        end
        local applies = EvaluateTagCondition(entity, condition)
        if applies then
            sum = (sum or 0) + bonus
        end
    end

    return sum
end

local function ResetSpeedMultiplier(self)
    if self.turfedfast == true then
        self:RemoveExternalSpeedMultiplier(self.inst, "TurfedSpeed")
        self.turfedfast = nil
    end
end

if SpeedyTurfs then
    AddComponentPostInit("locomotor", function(self)
        if EnableNonPlayerSpeed or self.inst:HasTag("player") then
            local _UGSM = self.UpdateGroundSpeedMultiplier
            self.UpdateGroundSpeedMultiplier = function(self)
                _UGSM(self)
                local tile, data = self.inst:GetCurrentTileType()
                if data == nil or data.turfed == nil then
                    -- no turfed data
                    ResetSpeedMultiplier(self)
                    return
                end
                if data.turfed.speedMult == nil or data.turfed.speedAdd == nil then
                    -- the turf doesn't affect speed
                    ResetSpeedMultiplier(self)
                    return
                end

                local speedMult = data.turfed.speedMult
                local speedAdd = data.turfed.speedAdd
                local speedBonuses = data.turfed.speed ~= nil and data.turfed.speed or {}
                local entityBonusAdd = GetConditionalBonus(self.inst, speedBonuses)
                if entityBonusAdd == nil then
                    -- the entity is not affected by the turf
                    ResetSpeedMultiplier(self)
                    return
                end

                local speed = ((SpeedyTurfSpeeds - 1) * speedMult + 1 + speedAdd) * (1 + entityBonusAdd)
                speed = math.clamp(speed, 0.05, 8)
                self:SetExternalSpeedMultiplier(self.inst, "TurfedSpeed", speed)
                self.turfedfast = true
            end
        end
    end)
end


--Craftables
--(name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image)

turfedtab = AddRecipeTab("地毯", 956, "images/tabimages/turfedtab.xml", "turfedtab.tex", nil)

--TURFED TURFS -yes its fun to say
STRINGS.NAMES.TURF_TEST = "一块测试用的地毯"

--Carpet
STRINGS.NAMES.TURF_CARPETBLACKFUR = "毛皮地毯"
STRINGS.RECIPE_DESC.TURF_CARPETBLACKFUR = "做一卷熊皮地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETBLACKFUR = "用怪物的皮毛做成的温暖舒适的地毯."

STRINGS.NAMES.TURF_CARPETBLUE = "蓝色地毯"
STRINGS.RECIPE_DESC.TURF_CARPETBLUE = "做一卷蓝色的地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETBLUE = "就像你一样忧郁."

STRINGS.NAMES.TURF_CARPETCAMO = "迷彩地毯"
STRINGS.RECIPE_DESC.TURF_CARPETCAMO = "做一卷迷彩地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETCAMO = "我敢说你肯定没看到这条地毯."

STRINGS.NAMES.TURF_CARPETFUR = "牛毛地毯"
STRINGS.RECIPE_DESC.TURF_CARPETFUR = "做一卷牛毛地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETFUR = "温暖,昏昏欲睡,好怪的气味..."

STRINGS.NAMES.TURF_CARPETPINK = "粉红地毯"
STRINGS.RECIPE_DESC.TURF_CARPETPINK = "做一卷粉红色的地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETPINK = "粉红色地毯?真萌!"

STRINGS.NAMES.TURF_CARPETPURPLE = "紫色地毯"
STRINGS.RECIPE_DESC.TURF_CARPETPURPLE = "做一卷紫色的地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETPURPLE = "紫色是高贵的颜色,也是这条地毯的颜色."

STRINGS.NAMES.TURF_CARPETRED = "红色地毯"
STRINGS.RECIPE_DESC.TURF_CARPETRED = "做一卷红色的地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETRED = "他们在浆果附近洗了白色的地毯,他们说,不要告诉别人..."

STRINGS.NAMES.TURF_CARPETRED2 = "钻石地毯"
STRINGS.RECIPE_DESC.TURF_CARPETRED2 = "做一卷红钻石地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETRED2 = "闪亮如血钻."

STRINGS.NAMES.TURF_CARPETTD = "漂染地毯"
STRINGS.RECIPE_DESC.TURF_CARPETTD = "做一卷漂染地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETTD = "这个地毯,好像... 哇哦..."

STRINGS.NAMES.TURF_CARPETWIFI = "Wifi地毯"
STRINGS.RECIPE_DESC.TURF_CARPETWIFI = "做一卷Wifi地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CARPETWIFI = "网络情缘一线牵,珍惜这段缘? 网络的那头有你,真好..."
--Nature
STRINGS.NAMES.TURF_NATUREASTROTURF = "阿斯特罗草皮"
STRINGS.RECIPE_DESC.TURF_NATUREASTROTURF = "做一卷阿斯特罗地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_NATUREASTROTURF = "绿色的荧光地毯!"

STRINGS.NAMES.TURF_NATUREDESERT = "沙漠地毯"
STRINGS.RECIPE_DESC.TURF_NATUREDESERT = "做一卷沙漠地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_NATUREDESERT = "你自己的这片干燥,破碎,贫瘠的土地."
--Rock
STRINGS.NAMES.TURF_ROCKBLACKTOP = "柏油路地毯"
STRINGS.RECIPE_DESC.TURF_ROCKBLACKTOP = "创造一条柏油路."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ROCKBLACKTOP = "柏油路,无尽的旅程..."

STRINGS.NAMES.TURF_ROCKGIRAFFE = "长颈鹿地毯"
STRINGS.RECIPE_DESC.TURF_ROCKGIRAFFE = "做一条长颈鹿地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ROCKGIRAFFE = "用新鲜优雅的长颈鹿做的."

STRINGS.NAMES.TURF_ROCKMOON = "月石岩地毯"
STRINGS.RECIPE_DESC.TURF_ROCKMOON = "做一条月石岩地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ROCKMOON = "给嫦娥姐姐打个电话吧."

STRINGS.NAMES.TURF_ROCKYELLOWBRICK = "黄砖地毯"
STRINGS.RECIPE_DESC.TURF_ROCKYELLOWBRICK = "做一条印着黄色砖头的地毯."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ROCKYELLOWBRICK = "跟我走吧,天亮就出发."
--Tile
STRINGS.NAMES.TURF_TILECHECKERBOARD = "棋盘瓷砖"
STRINGS.RECIPE_DESC.TURF_TILECHECKERBOARD = "制作一些棋盘瓷砖."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_TILECHECKERBOARD = "将军."

STRINGS.NAMES.TURF_TILEFROSTY = "寒冬霜瓦"
STRINGS.RECIPE_DESC.TURF_TILEFROSTY = "制作一些寒冬霜瓦."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_TILEFROSTY = "你想做些瓦片吗?"

STRINGS.NAMES.TURF_TILESQUARES = "方形瓦片"
STRINGS.RECIPE_DESC.TURF_TILESQUARES = "制作一些正方形的瓷砖e."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_TILESQUARES = "这样的瓷砖,有很多的正方形."
--Wood
STRINGS.NAMES.TURF_WOODCHERRY = "樱桃木地板"
STRINGS.RECIPE_DESC.TURF_WOODCHERRY = "制作一些樱桃木地板."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_WOODCHERRY = "你在哪儿找到的樱桃呢?"

STRINGS.NAMES.TURF_WOODDARK = "暗木地板"
STRINGS.RECIPE_DESC.TURF_WOODDARK = "制作一些深色的木地板."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_WOODDARK = "guido最喜欢的颜色."

STRINGS.NAMES.TURF_WOODPINE = "松木地板"
STRINGS.RECIPE_DESC.TURF_WOODPINE = "制作一些松木地板."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_WOODPINE = "让松果变得有用的地板."
-- Spikes
STRINGS.NAMES.TURF_SPIKES = "尖刺地板"
STRINGS.RECIPE_DESC.TURF_SPIKES = "制作一些尖刺的地板."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_SPIKES = "能让你慢下来."

---------- AddRecipe(name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image)

--Recipes

GLOBAL.Recipe("turf_carpetfloor", { Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) }, turfedtab, TECH.SCIENCE_TWO, nil, nil, nil, 4)

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetblackfur", { Ingredient("bearger_fur", 1), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/carpetblackfur.xml", "carpetblackfur.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetblue", { Ingredient("blue_cap", 3), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetblue.xml", "carpetblue.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetcamo", { Ingredient("gunpowder", 1), Ingredient("cutgrass", 2), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetcamo.xml", "carpetcamo.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetfur", { Ingredient("beefalowool", 4), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/carpetfur.xml", "carpetfur.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetpink", { Ingredient("petals", 6), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetpink.xml", "carpetpink.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetpurple", { Ingredient("purplegem", 2), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetpurple.xml", "carpetpurple.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetred", { Ingredient("berries", 10), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetred.xml", "carpetred.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetred2", { Ingredient("redgem", 1), Ingredient("beefalowool", 2), Ingredient("sewing_kit", 1) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetred2.xml", "carpetred2.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpettd", { Ingredient("blue_cap", 2), Ingredient("green_cap", 2), Ingredient("cutgrass", 3) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpettiedye.xml", "carpettiedye.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_carpetwifi", { Ingredient("trinket_6", 1), Ingredient("goldnugget", 1), Ingredient("beefalowool", 2) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/carpetwifi.xml", "carpetwifi.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_natureastroturf", { Ingredient("cutgrass", 4), Ingredient("green_cap", 2), Ingredient("honey", 2) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/natureastroturf.xml", "natureastroturf.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_naturedesert", { Ingredient("rocks", 4), Ingredient("nitre", 2), Ingredient("cutgrass", 2) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/naturedesert.xml", "naturedesert.tex")
end

GLOBAL.Recipe("turf_road", { Ingredient("turf_rocky", 1), Ingredient("boards", 2) }, turfedtab, TECH.SCIENCE_TWO, nil, nil, nil, 4)

GLOBAL.Recipe("turf_dragonfly", { Ingredient("dragon_scales", 1), Ingredient("cutstone", 2) }, turfedtab, TECH.SCIENCE_TWO, nil, nil, nil, 6)

if EnableTurfedTurfRecipes then
    AddRecipe("turf_rockblacktop", { Ingredient("rocks", 8), Ingredient("charcoal", 4), Ingredient("goldnugget", 1) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/rockblacktop.xml", "rockblacktop.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_rockgiraffe", { Ingredient("rocks", 8), Ingredient("nitre", 4), Ingredient("goldnugget", 1) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/rockgiraffe.xml", "rockgiraffe.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_rockmoon", { Ingredient("rocks", 8), Ingredient("moonrocknugget", 1) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 8, nil,
        "images/inventoryimages/rockmoon.xml", "rockmoon.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_rockyellowbrick", { Ingredient("rocks", 8), Ingredient("goldnugget", 4) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/rockyellowbrick.xml", "rockyellowbrick.tex")
end

--Recipe("wall_hay_item", {Ingredient("cutgrass", 4), Ingredient("twigs", 2) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE,nil,nil,nil,4)
GLOBAL.Recipe("turf_checkerfloor", { Ingredient("cutstone", 2), Ingredient("marble", 1) }, turfedtab, TECH.SCIENCE_TWO, nil, nil, nil, 4)

if EnableTurfedTurfRecipes then
    AddRecipe("turf_tilecheckerboard", { Ingredient("cutstone", 2), Ingredient("marble", 2) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/tilecheckerboard.xml", "tilecheckerboard.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_tilefrosty", { Ingredient("cutstone", 2), Ingredient("marble", 2), Ingredient("ice", 6) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/tilefrosty.xml", "tilefrosty.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_tilesquares", { Ingredient("cutstone", 4), Ingredient("marble", 2) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 6, nil,
        "images/inventoryimages/tilesquares.xml", "tilesquares.tex")
end

GLOBAL.Recipe("turf_woodfloor", { Ingredient("boards", 2) }, turfedtab, TECH.SCIENCE_ONE, nil, nil, nil, 4)

if EnableTurfedTurfRecipes then
    AddRecipe("turf_woodcherry", { Ingredient("boards", 2), Ingredient("charcoal", 2), Ingredient("berries", 6) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/woodcherry.xml", "woodcherry.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_wooddark", { Ingredient("boards", 2), Ingredient("charcoal", 4), Ingredient("nightmarefuel", 3) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/wooddark.xml", "wooddark.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_woodpine", { Ingredient("boards", 2), Ingredient("pinecone", 5) },
        turfedtab,
        TECH.SCIENCE_ONE,
        nil, nil, nil, 4, nil,
        "images/inventoryimages/woodpine.xml", "woodpine.tex")
end

if EnableTurfedTurfRecipes then
    AddRecipe("turf_spikes", { Ingredient("houndstooth", 2), Ingredient("stinger", 2), Ingredient("flint", 2) },
        turfedtab,
        TECH.SCIENCE_TWO,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/spikes.xml", "spikes.tex")
end

--DST TURFS
STRINGS.NAMES.TURF_FOREST = "森林地皮"
STRINGS.RECIPE_DESC.TURF_FOREST = "制作一片森林."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_FOREST = "一片森林."

STRINGS.NAMES.TURF_DECIDUOUS = "落叶地皮"
STRINGS.RECIPE_DESC.TURF_DECIDUOUS = "制作一片落叶地."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_DECIDUOUS = "一片落叶地."

STRINGS.NAMES.TURF_GRASS = "草坪"
STRINGS.RECIPE_DESC.TURF_GRASS = "制作一片草地."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_GRASS = "一片草地."

STRINGS.NAMES.TURF_SAVANNA = "草原地皮"
STRINGS.RECIPE_DESC.TURF_SAVANNA = "制作一片稀树草原."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_SAVANNA = "一片稀树草原."

STRINGS.NAMES.TURF_DESERTDIRT = "沙漠地皮"
STRINGS.RECIPE_DESC.TURF_DESERTDIRT = "制作一片沙漠."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_DESERTDIRT = "一片沙漠."

STRINGS.NAMES.TURF_MARSH = "沼泽地皮"
STRINGS.RECIPE_DESC.TURF_MARSH = "制作一片沼泽地."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_MARSH = "一片沼泽地."

STRINGS.NAMES.TURF_FUNGUS = "蓝色真菌地皮"
STRINGS.RECIPE_DESC.TURF_FUNGUS = "制作一块蓝色的真菌地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_FUNGUS = "一块蓝色的真菌地皮."

STRINGS.NAMES.TURF_FUNGUS_RED = "红色真菌地皮"
STRINGS.RECIPE_DESC.TURF_FUNGUS_RED = "制作一块红色真菌地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_FUNGUS_RED = "一块红色的真菌地皮."

STRINGS.NAMES.TURF_FUNGUS_GREEN = "绿色真菌地皮"
STRINGS.RECIPE_DESC.TURF_FUNGUS_GREEN = "制作一块绿色真菌地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_FUNGUS_GREEN = "一块绿色的真菌地皮."

STRINGS.NAMES.TURF_MUD = "泥巴地皮"
STRINGS.RECIPE_DESC.TURF_MUD = "制作一块泥巴地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_MUD = "一片泥地."

STRINGS.NAMES.TURF_SINKHOLE = "落水地皮"
STRINGS.RECIPE_DESC.TURF_SINKHOLE = "制作一块落水地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_SINKHOLE = "一块落水地皮."

STRINGS.NAMES.TURF_ROCKY = "岩石地皮"
STRINGS.RECIPE_DESC.TURF_ROCKY = "制作一块岩石地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ROCKY = "一块岩石地皮."

STRINGS.NAMES.TURF_CAVE = "鸟粪地皮"
STRINGS.RECIPE_DESC.TURF_CAVE = "做一块鸟粪地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_CAVE = "一块鸟粪地皮."

STRINGS.NAMES.TURF_UNDERROCK = "洞穴岩石地皮"
STRINGS.RECIPE_DESC.TURF_UNDERROCK = "制作一块洞穴岩石地皮."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_UNDERROCK = "一块洞穴岩石地皮."

--Recipes

-- Vanilla Edited

--GLOBAL.Recipe("turf_woodfloor", {Ingredient("log",1), Ingredient("cutgrass",1), Ingredient("twigs",1)} ,GLOBAL.RECIPETABS.LIGHT ,GLOBAL.TECH.NONE)


-- GLOBAL.Recipe("turf_road", {Ingredient("turf_rocky", 1), Ingredient("boards", 1)}, turfedtab,  TECH.SCIENCE_TWO)
-- GLOBAL.Recipe("turf_woodfloor", {Ingredient("boards", 1)}, turfedtab, TECH.SCIENCE_TWO)
-- GLOBAL.Recipe("turf_checkerfloor", {Ingredient("marble", 1)}, turfedtab, TECH.SCIENCE_TWO)
-- GLOBAL.Recipe("turf_carpetfloor", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, turfedtab, TECH.SCIENCE_TWO)
-- GLOBAL.Recipe("turf_dragonfly", {Ingredient("dragon_scales", 1), Ingredient("cutstone", 2)}, turfedtab, TECH.SCIENCE_TWO, nil, nil, nil, 6)  


--
if EnableGameTurfRecipes then
    AddRecipe("turf_forest", { Ingredient("cutgrass", 3), Ingredient("twigs", 2), Ingredient("pinecone", 2) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Forest_Turf.xml", "Forest_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_deciduous", { Ingredient("cutgrass", 3), Ingredient("red_cap", 2), Ingredient("acorn", 2) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Deciduous_Turf.xml", "Deciduous_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_grass", { Ingredient("cutgrass", 3), Ingredient("seeds", 3), Ingredient("poop", 1) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Grass_Turf.xml", "Grass_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_savanna", { Ingredient("cutgrass", 5), Ingredient("seeds", 2) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Savanna_Turf.xml", "Savanna_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_desertdirt", { Ingredient("boneshard", 2), Ingredient("rocks", 3) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Desert_Turf.xml", "Desert_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_marsh", { Ingredient("cutreeds", 2), Ingredient("spoiled_food", 3) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Marsh_Turf.xml", "Marsh_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_fungus", { Ingredient("blue_cap", 3), Ingredient("cutgrass", 5) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Fungus_Blue_Turf.xml", "Fungus_Blue_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_fungus_red", { Ingredient("red_cap", 3), Ingredient("cutgrass", 5) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Fungus_Red_Turf.xml", "Fungus_Red_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_fungus_green", { Ingredient("green_cap", 3), Ingredient("cutgrass", 5) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Fungus_Green_Turf.xml", "Fungus_Green_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_mud", { Ingredient("foliage", 2), Ingredient("poop", 3) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Mud_Turf.xml", "Mud_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_sinkhole", { Ingredient("rocks", 3), Ingredient("cutreeds", 3) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Sinkhole_Turf.xml", "Sinkhole_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_rocky", { Ingredient("flint", 2), Ingredient("rocks", 4), Ingredient("nitre", 1) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Rocky_Turf.xml", "Rocky_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_cave", { Ingredient("guano", 3), Ingredient("rocks", 2) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Guano_Turf.xml", "Guano_Turf.tex")
end

if EnableGameTurfRecipes then
    AddRecipe("turf_underrock", { Ingredient("silk", 3), Ingredient("rocks", 3) },
        turfedtab,
        TECH.NONE,
        nil, nil, nil, 2, nil,
        "images/inventoryimages/Cave_Rock_Turf.xml", "Cave_Rock_Turf.tex")
end
