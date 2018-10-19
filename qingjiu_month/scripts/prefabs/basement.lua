require "prefabutil"

local assets =
{
    hatch =
    {
        Asset("ANIM", "anim/basement_hatch.zip"),
        Asset("SOUNDPACKAGE", "sound/hatch.fev"),
        Asset("SOUND", "sound/hatch_bank00.fsb"),
    },
    stairs = { Asset("ANIM", "anim/basement_exit.zip") },
    --elevator = { Asset("ANIM", "anim/basement_elevator.zip") },
    tile = { Asset("ANIM", "anim/basement_floor.zip") },
    voidtile = { Asset("ANIM", "anim/basement_voidtile.zip") },
}

local prefabs =
{
    hatch = { "lavaarena_creature_teleport_medium_fx" },
}

local BASEMENT_SHADE = 0.5
local CEILING_HEIGHT = 6
local SAFE_PLACEMENT_DIST = 150
local ENVIRONMENT_ACTIVE = false
local DEFAULT_TILEDATA =
[[
	0_12/4_-12/-4_4/4_12/0_-12/12_4/-8_0/4_-4/-12_0/-4_0/8_-4/12_0/8_12/12_12/-4_-4/0_4/0_-4/-8_-12/-12_12/8_4/4_4/8_0/-4_12/-4_-8/12_-12/-8_-4/-4_-12/8_-12/-8_-8/-12_-4/4_8/-8_12/8_8/-12_-12/0_8/-8_4/12_-8/4_0/8_-8/12_-4/-8_8/-12_8/4_-8/-4_8/-12_-8/0_0/0_-8/-12_4/12_8
]]
--local BASEMENT_COUNT = 0

local BLOCKED =
{
    TAGS =
    {
        SnowCovered =
        {
            function(inst)
                inst.AnimState:Hide("snow")
            end,
            MakeSnowCovered,
        },
        lightningrod = true,
    },
    RECIPES =
    {
        pighouse = true,
        rabbithouse = true,
    },
    EFFECTS =
    {
        rain = true,
        caverain = true,
        snow = true,
        pollen = true,
    },
}

local TEMPERATURE_MULT =
{
    autumn = 0.5,
    winter = 0.25,
    spring = 0.5,
    summer = 1,
}

local COLOURCUBE_PHASEFN =
{
    blendtime = 1,
    events = {},
    fn = function() return "night" end,
}

local DSP =
{
    lowdsp =
    {
        ["set_ambience"] = 750,
        ["set_sfx/set_ambience"] = 750,
    },
    highdsp =
    {
        ["set_music"] = 750,
        ["set_sfx/movement"] = 750,
        ["set_sfx/creature"] = 750,
        ["set_sfx/player"] = 750,
        ["set_sfx/voice"] = 500,
        ["set_sfx/sfx"] = 750,
    },
    duration = 0.5,
}

local function GetConvert(fn, var)
    local mem = Waffles.Memory.Load("Basement.Override", fn, var)
    if mem then
        return mem
    else
        local fn_convert = nil

        if var ~= nil then
            function fn_convert(self, val)
                Waffles.PushBasementWorldState()
                fn(self, TheWorld.state[var])
                Waffles.PopBasementWorldState()
            end
        else
            function fn_convert(...)
                Waffles.PushBasementWorldState()
                local ret = { fn(...) }
                Waffles.PopBasementWorldState()
                return unpack(ret)
            end
        end

        Waffles.Memory.Save(fn_convert, "Basement.Override", fn, var)
        Waffles.Memory.Save(fn, "Basement.Original", fn_convert, var)

        return fn --fn_convert
    end
end

local CommonReplacements =
{
    None = function() end,
    Zero = function() return 0 end,
    Builder = function(self, recname, ...)
        if recname ~= nil then
            if BLOCKED.RECIPES[recname] then
                return false, "LOWCEILING"
            else
                return self:__DoBuild(recname, ...)
            end
        end
    end,
}

--------------------------------------------------------------------------
--[[ Basement Walls ]]
--------------------------------------------------------------------------
local function UpdatePathFinding(inst, enable)
    if inst:IsValid() and enable then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition(true)
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function OnMouseOverWall(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tilekey = Waffles.GetInteriorTileKey(x, y, z)
    inst.highlightchildren = {}
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 6, { "basement_part", "wall" })) do
        if v ~= inst and Waffles.GetInteriorTileKey(v.Transform:GetWorldPosition()) == tilekey then
            table.insert(inst.highlightchildren, v)
        end
    end
end

local function IsTileExtendable(x, z)
    for i, v in ipairs({ x, z }) do
        if v > 0 then
            if v >= 46 then
                return false
            end
        elseif v <= -46 then
            return false
        end
    end
    return true
end

local function OnWorkedWall(inst, worker, workleft)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local x, y, z = inst.parent.Transform:GetWorldPosition()
    local tx, tz = ix - x, iz - z

    if (not Waffles.Valid(worker) or not worker:HasTag("player"))
            or not IsTileExtendable(tx, tz) then
        inst.components.workable:SetWorkLeft(TUNING.CAVEIN_BOULDER_MINE)
        if worker:HasTag("player") then
            ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.5, 0.01, 0.1, worker, 20)
            for i, v in ipairs(TheSim:FindEntities(ix, iy, iz, 8, { "basement_part", "wall" })) do
                v:DoTaskInTime(Waffles.GetDistanceDelay(v, inst, 0, 3, 0, 0.2), Waffles.DoHauntFlick, 0.2)
            end
        else
            Waffles.NegateWorkableFX(inst)
        end
    else
        if workleft <= 0 then
            inst.parent:SetBasementTile(tx, tz, true, worker)
        end
    end
end

local function OnCollideRubble(inst)
    inst.AnimState:PlayAnimation("broken")
    inst.AnimState:SetHaunted(false)

    inst:DowngradeRubble()
end

local downgradeanims =
{
    fullA = "threequarter_hit",
    fullB = "threequarter_hit",
    fullC = "threequarter_hit",
    threequarter_hit = "half_hit",
    half_hit = "onequarter_hit",
    onequarter_hit = "broken",
}

local function DowngradeRubble(inst)
    for current, next in pairs(downgradeanims) do
        if inst.AnimState:IsCurrentAnimation(current) then
            inst.AnimState:PlayAnimation(next, true)

            Waffles.DoHauntFlick(inst, 0.15)

            return
        end
    end

    if not inst.destroyed then
        inst.destroyed = true

        inst.Physics:SetCapsule(0, 0)

        inst:CancelAllPendingTasks()

        ErodeAway(inst)
    end
end

local function GetWallPosition(inst, imnotarobot)
    if imnotarobot then
        return inst:__GetPosition()
    else
        local entrance = Waffles.Return(inst, "parent/basement/entrance")
        local offset = Point(math.random() * 6, 0, math.random() * 6)
        return Waffles.Valid(entrance) and (entrance:GetPosition() + offset) or offset
    end
end

local function wall_common(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst:AddTag("blocker")
    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetCollisionGroup(COLLISION.WORLD)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCapsule(0.5, 50)

    inst.AnimState:SetBank("wall")
    inst.AnimState:SetBuild(build)
    inst.AnimState:OverrideShade(BASEMENT_SHADE)

    inst:AddTag("wall")
    inst:AddTag("basement_part")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:DoTaskInTime(0, UpdatePathFinding, true)
    inst:ListenForEvent("onremove", UpdatePathFinding)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("mouseover", OnMouseOverWall)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.CAVEIN_BOULDER_MINE * 1.5)
    inst.components.workable:SetOnWorkCallback(OnWorkedWall)

    --hacks to trick the weather component
    inst:AddTag("lightningrod")
    Waffles.Replace(inst, "GetPosition", GetWallPosition)

    inst.persists = false

    return inst
end

local function wall1()
    return wall_common("wall_stone")
end

local function wall2()
    return wall_common("wall_wood")
end

local function wall_rubble()
    local inst = wall_common("wall_stone")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollideRubble)

    inst.DowngradeRubble = DowngradeRubble

    inst.components.workable:SetWorkable(false)

    return inst
end

local function wall_void()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    if TheNet:GetIsClient() then
        inst.entity:AddClientSleepable()
    end

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("wall")
    inst.AnimState:SetBuild("wall_stone")
    inst.AnimState:OverrideMultColour(0, 0, 0, 1)
    inst.AnimState:SetScale(1.08, 0.82 + math.random() * 0.04)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")
    inst:AddTag("basement_part")

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Entrance ]]
--------------------------------------------------------------------------
local function CanBuildBasementAtPoint(x, y, z)
    return #TheSim:FindEntities(x, 0, z, SAFE_PLACEMENT_DIST --[[, { "basement_core" }]]) == 0
end

local function OnMouseOverEntrance(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.highlightchildren = TheSim:FindEntities(x, y, z, 0, { "DECOR" })
end

local function Shine(inst)
    if inst:IsAsleep() then
        return
    end

    local x, y = math.random(-160, 130), math.random(-40, 50)
    y = ((x == 0 and 1) or (x < 0 and x * -1) or x) / 200 * y
    SpawnPrefab("sparkle_fx"):Hook(inst.GUID, "bottom", x, y, 0)

    inst:DoTaskInTime(math.random(3, 15), Shine)
end

local function GetStatus(inst)
    return inst.sg.currentstate.name ~= "idle" and "OPEN" or nil
end

local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
    else
        inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
    end
end

local function OnActivateByOther(inst, source, doer)
    if not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
    if doer ~= nil and doer.Physics ~= nil then
        doer.Physics:CollidesWith(COLLISION.WORLD)
    end
end

local function OnNearEntrance(inst, player)
    if inst.components.teleporter:IsActive() and not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function OnFarEntrance(inst, player)
    if not inst.components.teleporter:IsBusy() and inst.sg:HasStateTag("open") then
        inst.sg:GoToState("closing")
    end
end

local function TargetModeTeleporter(inst, prox)
    local pairinst = inst.components.teleporter.targetTeleporter

    if not Waffles.Valid(pairinst)
        --[[or inst.components.teleporter:IsBusy()
        or inst.components.teleporter:IsTargetBusy()]] then
        return --don't update during teleportation sequence
    end

    local player = Waffles.FindAnyPlayerInRange(inst, prox.isclose and prox.far or prox.near)
    prox.isslave = player == nil

    local pairprox = pairinst.components.playerprox

    if not prox.isclose then
        if not prox.isslave then
            --we should trigger the pair's callback first due to restrictions
            --with the same SoundEmitter events firing at a time
            pairprox.isclose = true
            if pairprox.onnear ~= nil then
                pairprox.onnear(pairinst, player)
            end

            prox.isclose = true
            if prox.onnear ~= nil then
                prox.onnear(inst, player)
            end

            pairprox.targetmode(pairinst, pairprox)
        end
    elseif prox.isslave and pairprox.isslave then
        pairprox.isclose = false
        if pairprox.onfar ~= nil then
            pairprox.onfar(pairinst)
        end

        prox.isclose = false
        if prox.onfar ~= nil then
            prox.onfar(inst)
        end

        pairprox.targetmode(pairinst, pairprox)
    end
end

--[[local function PlayerProxGetDebugString(playerprox, islinked)
	local str = string.format("isclose: %s, isslave: %s", tostring(playerprox.isclose or false), tostring(playerprox.isslave or false))
	if not islinked then
		str = str .. " [" .. playerprox.inst.components.teleporter.targetTeleporter.components.playerprox:GetDebugString(true) .. "]"
	end
	return str
end]]

local function OnAccept(inst, giver, item)
    inst.components.inventory:DropItem(item)
    inst.components.teleporter:Activate(item)
end

local function PlayTravelSound(inst, doer)
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_down")
end

local function DoShineFlick(inst)
    Waffles.DoHauntFlick(inst, math.random() * 0.65)
    inst:DoTaskInTime(math.random(3), DoShineFlick)
end

local function entrance()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    MakeObstaclePhysics(inst, 0.65)

    inst.AnimState:SetBank("basement_entrance")
    inst.AnimState:SetBuild("basement_hatch")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("basement.tex")

    inst:AddTag("basement_part")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:SetDeployExtraSpacing(2.5)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("mouseover", OnMouseOverEntrance)
        DoShineFlick(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --the hatch don't need to be on background layer, so it's a separate entity
    inst.hatch = SpawnPrefab("basement_entrance_hatch")
    inst.hatch.entity:SetParent(inst.entity)

    inst:SetStateGraph("SGbasement_entrance")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("teleporter")
    inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.onActivateByOther = OnActivateByOther
    inst.components.teleporter.offset = 0
    inst.components.teleporter.travelcameratime = 3 * FRAMES
    inst.components.teleporter.travelarrivetime = 12 * FRAMES

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 5)
    inst.components.playerprox.onnear = OnNearEntrance
    inst.components.playerprox.onfar = OnFarEntrance
    inst.components.playerprox:SetTargetMode(TargetModeTeleporter, nil, true)
    --inst.components.playerprox.GetDebugString = PlayerProxGetDebugString

    inst:AddComponent("inventory")

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = OnAccept
    inst.components.trader.deleteitemonaccept = false

    inst:ListenForEvent("starttravelsound", PlayTravelSound)

    inst.OnEntityWake = Shine

    return inst
end

local function entrance_hatch()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("basement_hatch")
    inst.AnimState:SetBuild("basement_hatch")
    inst.AnimState:PlayAnimation("idle_closed")

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    if not TheNet:IsDedicated() then
        DoShineFlick(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetEventShare("animover", true)
    inst:SetEventShare("animqueueover", true)

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Builder ]]
--------------------------------------------------------------------------
local function DoBuildingFX(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local scorch = SpawnPrefab("burntground")
    scorch.persists = false
    scorch.Transform:SetPosition(x, y - 0.1, z)
    scorch.AnimState:SetScale(3, 3)
    scorch:DoTaskInTime(5, ErodeAway)

    local explode = SpawnPrefab("lavaarena_creature_teleport_medium_fx")
    explode.Transform:SetPosition(x, y + 0.1, z)

    local explode_rain = SpawnPrefab("explode_rain")
    explode_rain.Transform:SetPosition(x, y, z)

    for i, v in ipairs(AllPlayers) do
        local distSq = v:GetDistanceSqToInst(inst)
        local k = math.max(0, math.min(1, distSq / 1600))
        local intensity = k * (k - 2) + 1
        if intensity > 0 then
            v:ScreenFlash(intensity)
            v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 2)
        end
    end
end

local function IsSerializableEntity(ent)
    return Waffles.Valid(ent) and not Waffles.Valid(ent.entity:GetParent())
            --and TheWorld.Map:IsBasementAtPoint(ent.Transform:GetWorldPosition())
            and ent.persists and ent.prefab and ent.Transform
end

local function GetPotentialSymbolFollowers(ent)
    local x, y, z = ent.Transform:GetWorldPosition()
    return table.invert(TheSim:FindEntities(x, y, z, 0, { "FX" }))
end

local function SortPotentialSymbolFollowers(ent, lastfollowers)
    local x, y, z = ent.Transform:GetWorldPosition()
    local sortedfollowers = {}
    for i, v in ipairs(GetPotentialSymbolFollowers(ent)) do
        if lastfollowers[v] then
            table.insert(sortedfollowers, v)
        end
    end
    return sortedfollowers
end

local function DestroyOrBuryEntity(ent)
    if ent.components.workable ~= nil
            and ent.components.workable:CanBeWorked()
            and ent.components.workable.action ~= ACTIONS.NET then
        ent.components.workable:Destroy(ent)
    elseif ent.components.health ~= nil then
        if ent.components.burnable ~= nil then
            ent.components.burnable:Ignite()
        end
        ent.components.health:Kill()
        if ent.AnimState ~= nil then
            ent.AnimState:SetTime(math.random() + 0.5)
        end
    elseif not ent:HasTag("irreplaceable") and not ent:HasTag("_inventoryitem") then
        return IsSerializableEntity(ent), ent:Remove()
    end
end

local function SpeedUpSinkhole(sinkhole)
    if sinkhole.components.timer ~= nil then
        sinkhole.components.timer:LongUpdate(math.huge)
    end
end

local function IsBasementCorrupted(inst)
    if type(inst.basement) ~= "table" then
        return true
    end
    for part in string.gmatch([[core, exit, entrance]], "([%w_]+)") do
        if not Waffles.Valid(inst.basement[part]) then
            return true
        end
    end
end

local function DespawnBasement(inst)
    if not Waffles.Valid(inst) then
        return
    end

    if IsBasementCorrupted(inst) then
        return Waffles.Replace(inst, "Remove"), inst:Remove()
    end

    if not inst.basement.core:IsAsleep() then
        inst:RemoveEventCallback("entitysleep", DespawnBasement)
        inst:ListenForEvent("entitysleep", DespawnBasement)
        return
    end

    if inst.basement.entrance.components.teleporter:IsBusy() then
        inst.basement.entrance.components.teleporter:SetEnabled(false)
        inst.basement.core:DoTaskInTime(1 + math.random() * 0.2, DespawnBasement)
        return
    end

    local bx, by, bz = inst.basement.core.Transform:GetWorldPosition()
    local ex, ey, ez = inst.basement.entrance.Transform:GetWorldPosition()

    local removed_ents = {}
    for i, v in ipairs(TheSim:FindEntities(bx, 0, bz, 70, nil, { "basement_part", "INLIMBO" })) do
        if v:HasTag("irreplaceable") or (not v.entity:GetParent() and not Waffles.Valid(v.parent)) then
            --need this to properly remove campfire fires or other entities following an AnimState symbol
            local followers = GetPotentialSymbolFollowers(v)

            v.Transform:SetPosition(ex, 0, ez)

            for i, v in ipairs(SortPotentialSymbolFollowers(v, followers)) do
                DestroyOrBuryEntity(v)
            end

            if DestroyOrBuryEntity(v) then
                local name = v:GetBasicDisplayName()
                if name ~= nil and #name > 0 then
                    table.insert(removed_ents, name)
                end
            end
        end
    end
    if #removed_ents > 0 then
        Waffles.Announce(string.format(STRINGS.HUD.BASEMENT.ANNOUNCE_LOST_ENTITIES, table.concat(removed_ents, ", ")))
    end

    for name, entity in pairs(inst.basement) do
        Waffles.Replace(entity, "Remove")
        if name == "entrance" then
            Waffles.NegateWorkableFX(entity)
            DoBuildingFX(entity)
            Waffles.DespawnRecipe(entity, (GetModConfigData("loot_percent", "workshop-1349799880") or 0.75))
        else
            entity:Remove()
        end
    end

    Waffles.StackEntities(Waffles.FindNewEntities(ex, 0, ez, 3, { "_stackable" }))

    local dust = SpawnPrefab("cavein_dust_low")
    dust.Transform:SetPosition(ex, ey + 0.1, ez)

    local sinkhole = SpawnPrefab("antlion_sinkhole")
    sinkhole.persists = false
    sinkhole:SetPrefabNameOverride("basement_upgrade_gunpowder")
    sinkhole.Transform:SetPosition(ex, ey, ez)
    sinkhole:PushEvent("startcollapse")
    sinkhole:DoPeriodicTask(5, SpeedUpSinkhole)

    local debug = SpawnPrefab("basement_debugpoint")
    debug.entrance_pos = { ex, 0, ez }
    debug.Transform:SetPosition(bx, by, bz)
    debug.components.timer:StartTimer("erodeaway", 96000)
end

local function FindValidInteriorPosition()
    local tries = 0
    local map_width, map_height = TheWorld.Map:GetSize()
    local min_x, min_z = map_width * 2 + 70, map_height * 2 + 70
    local max_x, max_z = min_x + 130, min_z + 130
    while true do
        local x = math.random(min_x, max_x) * (math.random() < 0.5 and 1 or -1) + 0.5
        local z = math.random(min_z, max_z) * (math.random() < 0.5 and 1 or -1) + 0.5
        if CanBuildBasementAtPoint(x, 0, z) then
            return TheWorld.Map:GetTileCenterPoint(x, 0, z)
        else
            tries = tries + 1
            if tries > 200 then
                return
            end
        end
    end
end

local function BuildBasement(builder)
    local x, y, z = builder.Transform:GetWorldPosition()
    local owner = Waffles.Return(TheSim:FindEntities(x, y, z, 69, { "player" }), "1/userid")

    local basement = {}

    basement.entrance = SpawnPrefab("basement_entrance")
    basement.entrance.Transform:SetPosition(x, 0, z)

    --[[if BASEMENT_COUNT >= TheConfiguration.recipe_limit then
        TheNet:Announce("Reached limit for amount of basements.\n The limit can be increased in 'Basements' mod configuration.")
        Waffles.DespawnRecipe(basement.entrance, true)
        return
    end]]

    local x, y, z = FindValidInteriorPosition()
    if x == nil then
        TheNet:Announce(STRINGS.HUD.BASEMENT.ANNOUNCE_INVALID_POSITION)
        Waffles.DespawnRecipe(basement.entrance)
        return
    end

    for i, v in ipairs(TheSim:FindEntities(x, y, z, SAFE_PLACEMENT_DIST, { "basement_debugpoint" })) do --remove debug leftovers
        v:Remove()
    end

    basement.exit = SpawnPrefab("basement_exit")
    basement.exit.Transform:SetPosition(x - 11, y, z - 11)

    basement.entrance.components.teleporter.targetTeleporter = basement.exit
    basement.exit.components.teleporter.targetTeleporter = basement.entrance

    basement.core = SpawnPrefab("basement")
    basement.core.Transform:SetPosition(x, y, z)
    basement.core.owner = owner

    for i, v in ipairs(Waffles.CreatePositions.Rectangle("26x26", true, true, 4)) do
        basement.core:SetBasementTile(v.x, v.z, true)
    end

    for name, entity in pairs(basement) do
        Waffles.Replace(entity, "Remove", DespawnBasement)
        entity.basement = basement
    end

    DoBuildingFX(builder)

    builder:Remove()
end

local function builder()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")

    --[[Non-networked entity]]
    inst.persists = false

    --Auto-remove if not spawned by builder
    inst:DoTaskInTime(0, inst.Remove)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnBuiltFn = BuildBasement

    return inst
end

local function placerdecor(parent)
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("basement_hatch")
    inst.AnimState:SetBuild("basement_hatch")
    inst.AnimState:PlayAnimation("idle_closed")
    inst.AnimState:SetLightOverride(1)

    inst.entity:SetParent(parent.entity)
    parent.components.placer:LinkEntity(inst)
end

--------------------------------------------------------------------------
--[[ Basement Exit ]]
--------------------------------------------------------------------------
local function OnCollideStairs(inst, collider)
    if Waffles.Valid(collider) then
        local colliderpos = collider:GetPosition()
        if colliderpos == inst:GetPosition() then
            local x, y, z = colliderpos:Get()
            local angle = math.random() * 2 * PI
            local radius = inst:GetPhysicsRadius(0) + math.random() * 0.33
            collider.Physics:Teleport(x + math.cos(angle) * radius, 0, z - math.sin(angle) * radius)
        end
    end
end

local function ExitOnActivateByOther(inst, other, doer)
    if doer ~= nil
            and doer.sg ~= nil and not doer:HasTag("playerghost") then
        doer.sg.statemem.teleportarrivestate = "jumpout_ceiling"
    end
end

local function ReceiveItem(teleporter, item)
    if item.Transform ~= nil then
        local x, y, z = teleporter.inst.Transform:GetWorldPosition()
        local angle = math.random() * 2 * PI

        if item.Physics ~= nil then
            item.Physics:Stop()
            if teleporter.inst:IsAsleep() then
                local radius = teleporter.inst:GetPhysicsRadius(0) + math.random()
                item.Physics:Teleport(x + math.cos(angle) * radius, 0, z - math.sin(angle) * radius)
            else
                TemporarilyRemovePhysics(item, 1)
                local speed = 2 + math.random() + teleporter.inst:GetPhysicsRadius(0)
                item.Physics:Teleport(x, 5, z)
                item.Physics:SetVel(speed * math.cos(angle), -1.5, speed * math.sin(angle))
            end
        else
            local radius = 2 + math.random()
            item.Transform:SetPosition(x + math.cos(angle) * radius, 0, z - math.sin(angle) * radius)
        end
    end
end

local function LightToggle(light, value)
    light.level = (light.level or 0) + value
    if (value > 0 and light.level <= 1) or (value < 0 and light.level > 0) then
        light.Light:SetRadius(light.level)
        light.lighttoggle = light:DoTaskInTime(2 * FRAMES, LightToggle, value)
    elseif value < 0 then
        light.Light:Enable(false)
        light:Hide()
    end
    light.AnimState:SetScale(light.level, 1)
end

local function TakeLightSteps(light, value)
    if light.lighttoggle ~= nil then
        light.lighttoggle:Cancel()
    end
    light.lighttoggle = light:DoTaskInTime(2 * FRAMES, LightToggle, value)
end

local function OnNearExit(inst, player)
    if not inst.hatchlight.Light:IsEnabled() then
        inst.hatchlight.Light:Enable(true)
        inst.hatchlight:Show()

        TakeLightSteps(inst.hatchlight, 0.2)

        if not inst:IsAsleep() then
            inst.SoundEmitter:PlaySound("hatch/common/hatch/open_muffled")
        end
    end
end

local function OnFarExit(inst, player)
    if inst.hatchlight.Light:IsEnabled() then
        TakeLightSteps(inst.hatchlight, -0.2)

        if not inst:IsAsleep() then
            inst.SoundEmitter:PlaySound("hatch/common/hatch/close_muffled")
        end
    end
end

local function exit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()
    inst.Transform:SetRotation(-45)

    MakeObstaclePhysics(inst, 1.5)

    inst.AnimState:SetBank("basement_exit")
    inst.AnimState:SetBuild("basement_exit")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideShade(BASEMENT_SHADE)

    inst:AddTag("stairs")
    inst:AddTag("basement_part")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:SetDeployExtraSpacing(2.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollideStairs)

    inst.hatchlight = inst:SpawnChild("basement_exit_light")
    inst.hatchlight.Light:Enable(false)
    inst.hatchlight:Hide()

    inst:AddComponent("inspectable")

    inst:AddComponent("teleporter")
    --inst.components.teleporter.onActivate = OnStartTeleporting
    inst.components.teleporter.onActivateByOther = ExitOnActivateByOther
    inst.components.teleporter.offset = 0
    inst.components.teleporter.travelcameratime = 3 * FRAMES
    inst.components.teleporter.travelarrivetime = 29 * FRAMES
    inst.components.teleporter.ReceiveItem = ReceiveItem

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2, 4)
    inst.components.playerprox.onnear = OnNearExit
    inst.components.playerprox.onfar = OnFarExit
    inst.components.playerprox:SetTargetMode(TargetModeTeleporter, nil, true)
    --inst.components.playerprox.GetDebugString = PlayerProxGetDebugString

    return inst
end

local HATCH_LIGHT_COLOURS =
{
    day = { light = { 0.7, 0.75, 0.67 }, anim = { 0.35, 0.38, 0.33, 0 }, time = 4 },
    dusk = { light = { 0.7, 0.75, 0.67 }, anim = { 0.35, 0.38, 0.33, 0 }, time = 6 },
    night = { light = { 0, 0, 0 }, anim = { 0, 0, 0, 0 }, time = 8 },
}

local function UpdateHatchLight(inst, phase)
    local data = HATCH_LIGHT_COLOURS[phase]
    if data ~= nil then
        inst.Light:SetColour(unpack(data.light))
        inst.AnimState:SetMultColour(unpack(data.anim))
    end
end

local function exit_light()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetRadius(1)
    inst.Light:SetIntensity(0.85)
    inst.Light:SetFalloff(0.3)
    inst.Light:SetColour(0.7, 0.75, 0.67)
    --inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(0.35, 0.38, 0.33, 0)
    inst.AnimState:SetLightOverride(1)

    inst.Transform:SetScale(1.5, 0.4, 1)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("daylight")
    inst:AddTag("basement_part")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:WatchWorldState("phase", UpdateHatchLight)
    UpdateHatchLight(inst, TheWorld.state.phase)

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Interior ]]
--------------------------------------------------------------------------

local TOFLOOR = { "rocky", "wood", "checker" }

local function OnFloorType(inst)
    inst.foleyground = GROUND[inst.state.isrocky:value() and "CHECKER" or "WOODFLOOR"]

    if not TheNet:IsDedicated() and inst.tiles ~= nil then
        local anim = TOFLOOR[inst.state.flooring:value()] or "rocky"
        for i, v in ipairs(inst.tiles) do
            v.AnimState:PlayAnimation(anim)
        end
        if inst.currentfloor ~= anim then
            inst.currentfloor = anim
            for i, v in ipairs(inst.tiles) do
                Waffles.DoHauntFlick(v, 0.3)
            end
        end
    end
end

local function PushDebugPlayerLights()
    if TheWorld.state.phase == "night" then
        return
    end

    for i, ent in ipairs(AllPlayers) do
        if not Waffles.Valid(ent._debuglight) and not ent:IsInBasement() then
            ent._debuglight = ent:SpawnChild("basement_debuglight")
        end
    end
end

local function PopDebugPlayerLights()
    for i, ent in ipairs(AllPlayers) do
        if Waffles.Valid(ent._debuglight) then
            ent._debuglight:Remove()
        end
    end
end

local function OverrideAmientLighting(source, nightvision_enabled, darkness_enabled)
    local override = (darkness_enabled or source) and (not nightvision_enabled and Point(0, 0, 0)) or nil

    if TheWorld.ismastersim then
        if TheWorld.basement_lighting_task ~= nil then
            TheWorld.basement_lighting_task:Cancel()
            TheWorld.basement_lighting_task = nil
        end
        if override ~= nil then
            TheWorld.basement_lighting_task = TheWorld:DoPeriodicTask(0.1, PushDebugPlayerLights)
            PushDebugPlayerLights()
        else
            PopDebugPlayerLights()
        end
    end

    TheWorld:PushEvent("overrideambientlighting", override)
end

local function OverrideColourCube(enable)
    ThePlayer:SetEventMute("ccphasefn", false)
    ThePlayer:RemoveEventCallback("ccoverrides", OverrideColourCube)
    if enable then
        ThePlayer:PushEvent("ccphasefn", COLOURCUBE_PHASEFN)
        ThePlayer:SetEventMute("ccphasefn", true)
        ThePlayer:ListenForEvent("ccoverrides", OverrideColourCube)
    else
        ThePlayer:PushEvent("ccphasefn", Waffles.Return(ThePlayer, "components/playervision/currentccphasefn"))
    end
end

local function EnableBasementLighting(enable)
    OverrideAmientLighting(nil, Waffles.Return(ThePlayer, "components/playervision/nightvision"), enable)
    OverrideColourCube(enable)

    ThePlayer:RemoveEventCallback("nightvision", OverrideAmientLighting)
    if enable then
        ThePlayer:ListenForEvent("nightvision", OverrideAmientLighting)
    end

    local clouds = Waffles.Return(ThePlayer, "HUD/clouds")
    if clouds ~= nil then
        Waffles.Replace(clouds, "cloudcolour", enable and { 0, 0, 0 } or nil)
    end

    TheWorld:SetEventMute("screenflash", enable)
end

local terrors = { "attack", "attack_grunt", "die", "hit_response", "idle", "taunt", "appear", "dissappear" }

local function PlayTerrorSound(proxy)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:SetParent(proxy.entity)

    local theta = math.random() * 2 * PI
    inst.Transform:SetPosition(5 * math.cos(theta), 0, 5 * math.sin(theta))
    inst.SoundEmitter:PlaySound(string.format("dontstarve/sanity/creature%s/%s", math.random(2), Waffles.GetRandom(terrors)),
        nil,
        math.random())

    inst:Remove()

    proxy.basement_terror_task = proxy:DoTaskInTime(math.random(5, 40), PlayTerrorSound)
end

local function EnableBasementAmbient(enable)
    TheSim:SetReverbPreset((enable or TheWorld:HasTag("cave")) and "cave" or "default")

    ThePlayer:PushEvent("popdsp", DSP)
    if enable then
        ThePlayer:PushEvent("pushdsp", DSP)
    end

    if Waffles.Valid(TheFocalPoint) then
        if TheFocalPoint.basement_terror_task ~= nil then
            TheFocalPoint.basement_terror_task:Cancel()
            TheFocalPoint.basement_terror_task = nil
        end

        if enable then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/cave/caveAMB", "basementAMB")
            TheFocalPoint.basement_terror_task = TheFocalPoint:DoTaskInTime(math.random(10, 40), PlayTerrorSound)
        else
            TheFocalPoint.SoundEmitter:KillSound("basementAMB")
        end
    end
end

local function gettiles(inst)
    local tiles = {}
    for sub in inst.state.tiledata:value():gmatch("([^/]+)") do
        tiles[sub] = true
    end
    if not TheNet:IsDedicated() then
        local mistpos = { x = {}, z = {} }
        for tile in pairs(tiles) do
            local x, z = string.match(tile, "([^_]+)_([^_]+)")
            table.insert(mistpos.x, tonumber(x))
            table.insert(mistpos.z, tonumber(z))
        end
        inst.mistpos = mistpos
    end
    return tiles
end

local function RemoveEnts(t)
    if t ~= nil then
        for i, v in ipairs(t) do
            if v:IsValid() then
                v:Remove()
            end
        end
    end
end

local function GetNearestChunk(x, z)
    return math.floor((x + 2) / 28) * 28, math.floor((z + 2) / 28) * 28
end

local function RebuildBasementClient(inst)
    if not Waffles.Valid(ThePlayer) or not ThePlayer:IsNear(inst, 70) then
        return
    end

    RemoveEnts(inst.tiles)
    inst.tiles = {}

    --reuse previously spawned entities for optimization
    local oldvoid = {}
    if inst.void ~= nil then
        for i, v in ipairs(inst.void) do
            if v:IsValid() then
                table.insert(oldvoid, v)
            end
        end
    end
    inst.void = {}

    local pos = {}

    local ix, iy, iz = TheWorld.Map:GetTileCenterPoint(inst.Transform:GetWorldPosition())

    --master sim does that initially
    if not TheWorld.ismastersim then
        Waffles.Map.ClearSyntTiles()
        for sub in inst.state.tiledata:value():gmatch("([^/]+)") do
            local x, z = string.match(sub, "([^_]+)_([^_]+)")
            x = tonumber(x)
            z = tonumber(z)
            Waffles.Map.AddSyntTile(x + ix, 0, z + iz, inst)
        end
    end

    local tilegrid = Waffles.CreatePositions.Rectangle("8x8", true)
    local voidgrid = Waffles.CreatePositions.Rectangle("3x3", true, true)

    for tile in pairs(gettiles(inst)) do
        local x, z = string.match(tile, "([^_]+)_([^_]+)")
        x = tonumber(x) + 0.5
        z = tonumber(z) + 0.5

        for _, v in ipairs(tilegrid) do
            local isvalidpos = true
            for _, t in ipairs(voidgrid) do
                if TheWorld.Map:IsBasementAtPoint(ix + v.x + x + t.x, 0, iz + v.z + z + t.z) then
                    isvalidpos = false
                    break
                end
            end
            if isvalidpos then
                pos[(x + v.x) .. "_" .. (z + v.z)] = true
            end
        end
    end

    for key, score in pairs(pos) do
        local x, z = string.match(key, "([^_]+)_([^_]+)")
        x = tonumber(x)
        z = tonumber(z)

        local wall = table.remove(oldvoid) or SpawnPrefab("wall_basement_void")
        wall.Transform:SetPosition(ix + x, 0, iz + z)
        Waffles.AnimState.PlayWallAnimation(wall)
        Waffles.AddChild(inst, wall)
        table.insert(inst.void, wall)
    end

    local chunkgrid = Waffles.CreatePositions.Rectangle("28x28", true, true, 4)

    for i, v in ipairs(Waffles.CreatePositions.Rectangle("168x168", true, true, 28)) do
        local ix, iz = GetNearestChunk(ix + v.x, iz + v.z)
        local novoid = {}
        for _i, _v in ipairs(chunkgrid) do
            novoid[Waffles.GetInteriorTileKey(ix + _v.x, 0, iz + _v.z)] = TheWorld.Map:IsBasementAtPoint(ix + _v.x, 0, iz + _v.z) and true or nil
        end
        if next(novoid) ~= nil then
            local chunk = SpawnPrefab("basement_tile")
            chunk.Transform:SetPosition(ix, 0, iz)
            Waffles.AddChild(inst, chunk)
            table.insert(inst.tiles, chunk)
            chunk.AnimState:PlayAnimation("rocky")

            for x = -3, 3 do
                for z = -3, 3 do
                    if TheWorld.Map:IsBasementAtPoint(ix + x * 4, 0, iz + z * 4) then
                        chunk.void.AnimState:HideSymbol(x .. "_" .. z)
                    end
                end
            end
        end
    end

    RemoveEnts(oldvoid)

    OnFloorType(inst)
end

local ShelteredEnts = {}
setmetatable(ShelteredEnts, { __mode = "k" })

local function OverrideShade(ent)
    if ent.AnimState ~= nil then
        local shade = BASEMENT_SHADE --1
        local pos = ent:GetPosition()
        --shade = min(1, Remap(TheSim:GetLightAtPoint(x, y, z) * shade, 0, 1, shade, 1))
        if ent.Light ~= nil and ent.Light:IsEnabled() then
            shade = shade + 0.25
        end
        shade = math.min(shade, Remap(pos.y, CEILING_HEIGHT * 0.5, CEILING_HEIGHT * 0.7, shade, 0))
        ent.AnimState:OverrideShade(shade)
        return true
    end
end

local function PushBasementShades(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 70, nil, { "basement_part" })) do
        if not ShelteredEnts[v] then
            if BLOCKED.EFFECTS[v.prefab] then
                ShelteredEnts[v] = v.entity:GetParent()
                v.entity:SetParent(nil)
            elseif OverrideShade(v) then
                ShelteredEnts[v] = true
            end
        else
            OverrideShade(v)
        end
    end

    if not TheWorld.ismastersim and TheWorld.state.iswet then
        TheWorld.state.iswet = false
    end

    if Waffles.Valid(ThePlayer) and not ThePlayer:HasTag("playerghost")
            and ThePlayer.components.locomotor ~= nil
        --[[and	ThePlayer:GetDistanceSqToPoint(x, 0, z) < 400]] then
        ThePlayer.components.locomotor:PushTempGroundSpeedMultiplier(1, inst.foleyground)
    end
end

local function PopBasementShades(inst)
    for k, v in pairs(ShelteredEnts) do
        if k:IsValid() then
            if BLOCKED.EFFECTS[k.prefab] then
                k.entity:SetParent(v.entity)
            end
            if k.AnimState ~= nil then
                k.AnimState:OverrideShade(1)
            end
        end
    end

    ShelteredEnts = {}
    setmetatable(ShelteredEnts, { __mode = "k" })
end

local function DisableShaderTest(basement)
    if TheWorld.ismastersim then
        return basement:IsAsleep()
    else
        return not basement:IsValid()
    end
end

local function BasementShader(basement)
    repeat
        PushBasementShades(basement)
        Yield()
    until DisableShaderTest(basement)

    PopBasementShades(basement)
end

local function EnableAreaAwareComponent(ent, enable)
    local areaaware = ent.components.areaaware
    if areaaware ~= nil then
        if enable then
            ent:StopUpdatingComponent(areaaware)
            if areaaware.current_area_data ~= nil then
                areaaware.current_area_data.tags = {} --"Nightmare"
                ent:PushEvent("changearea", areaaware:GetCurrentArea())
            end
        else
            areaaware.current_area = nil
            ent:StartUpdatingComponent(areaaware)
        end
    end
end

local function OnPlayerRemoved()
    ENVIRONMENT_ACTIVE = false
end

local function EnableBasementEnvironment(inst, enable)
    if ENVIRONMENT_ACTIVE == enable then
        return
    end
    ENVIRONMENT_ACTIVE = enable

    if enable then
        RebuildBasementClient(inst)
    else
        for i, v in ipairs({ "void", "tiles" }) do
            RemoveEnts(inst[v])
            inst[v] = {}
        end

        if not TheWorld.ismastersim then
            TheWorld.state.iswet = inst.state.iswet:value()
        end
    end

    EnableBasementLighting(enable)
    EnableBasementAmbient(enable)

    if Waffles.Valid(ThePlayer) then
        EnableAreaAwareComponent(ThePlayer, not enable)

        ThePlayer:RemoveEventCallback("onremove", OnPlayerRemoved)
        if enable then
            ThePlayer:ListenForEvent("onremove", OnPlayerRemoved)
            StartThread(BasementShader, ThePlayer.GUID, inst)
        end
    end
end

local function OnEntityWakeClient(inst)
    if not Waffles.Valid(ThePlayer) or ThePlayer:GetTimeAlive() <= 0.5 then
        inst:DoTaskInTime(0.1, OnEntityWakeClient)
        return
    end

    EnableBasementEnvironment(inst, true)
end

local function OnEntitySleepClient(inst)
    if not Waffles.Valid(ThePlayer) or ThePlayer:GetTimeAlive() <= 0.5 then
        inst:DoTaskInTime(0.1, OnEntitySleepClient)
        return
    end

    EnableBasementEnvironment(inst, false)
end

local function UpdateBasementInsulation(inst, season)
    inst.insulation = (GetModConfigData("temperature", "workshop-1349799880") or -25) * (TEMPERATURE_MULT[season] or 1)

    if inst.allplayers ~= nil then
        for ent in pairs(inst.allplayers) do
            if ent.components.temperature ~= nil then
                ent.components.temperature:SetModifier("basement", inst.insulation)
            end
        end
    end
end

local function AdjustTentTag(ent, phase)
    if phase == "day" then
        ent:AddTag("siestahut")
    else
        ent:RemoveTag("siestahut")
    end
end

local function OnNewPhase(inst, phase)
    if inst.allobjects ~= nil then
        for ent in pairs(inst.allobjects) do
            if ent:IsValid() and ent:HasTag("tent") then
                AdjustTentTag(ent, phase)
            end
        end
    end
end

local function OnWet(inst, iswet)
    inst.state.iswet:set(iswet)
end

local function ForceUpdateState(inst)
    inst.state.iswet:set(TheWorld.state.iswet)
end

local function ReplaceWatcher(data, var)
    local callback, target = unpack(data)
    target:StopWatchingWorldState(var, callback)
    target:WatchWorldState(var, GetConvert(callback, var))
end

local function RetrieveWatcher(data, var)
    local callback, target = unpack(data)
    local fn = Waffles.Memory.Load("Basement.Original", callback, var)
    if fn ~= nil then
        target:StopWatchingWorldState(var, callback)
        target:WatchWorldState(var, fn)
        if TheWorld.state[var] ~= Waffles.BasementWorldState.DATA[var] then
            fn(target, TheWorld.state[var])
        end
    end
end

local WorldStateOverriders =
{
    WatchWorldState = function(self, var, fn)
        self:__WatchWorldState(var, GetConvert(fn, var))
    end,
    StopWatchingWorldState = function(self, var, fn)
        for i, v in ipairs({ Waffles.Memory.Load("Basement.Original", fn, var), fn }) do
            self:__StopWatchingWorldState(var, v)
        end
    end,
    DoTaskInTime = function(self, time, fn, ...)
        return self:__DoTaskInTime(time, GetConvert(fn), ...)
    end,
    DoPeriodicTask = function(self, time, fn, ...)
        return self:__DoPeriodicTask(time, GetConvert(fn), ...)
    end,
}

local function SwitchEntityWorldState(ent)
    if not ent.spawnedinbasement
            and TheWorld.state ~= Waffles.BasementWorldState.LAST
            and next(Waffles.GetWorldStateWatchers(ent)) ~= nil then
        Waffles.PushBasementWorldState()
        ent = Waffles.Reset(ent)
        Waffles.PopBasementWorldState()
    end
    return ent
end

local function PushBasementWorldStateForEntity(ent)
    for var, group in pairs(Waffles.GetWorldStateWatchers(ent)) do
        for i, data in ipairs(group) do
            ReplaceWatcher(data, var)
        end
    end

    for cmp, self in pairs(ent.components) do
        for k, v in pairs(shallowcopy(self)) do
            if type(v) == "function" then
                if WorldStateOverriders[k] ~= nil then
                    Waffles.Replace(self, k, WorldStateOverriders[k])
                elseif k:sub(1, 2) ~= "__" then
                    Waffles.Replace(self, k, GetConvert(v))
                end
            end
        end
    end

    if ent.pendingtasks ~= nil then
        for periodic in pairs(ent.pendingtasks) do
            if periodic.fn ~= nil then
                periodic.fn = GetConvert(periodic.fn)
            end
        end
    end

    for k, fn in pairs(WorldStateOverriders) do
        Waffles.Replace(ent, k, fn)
    end
end

local function PopBasementWorldStateForEntity(ent, data)
    for k in pairs(WorldStateOverriders) do
        Waffles.Replace(ent, k)
    end

    for var, group in pairs(Waffles.GetWorldStateWatchers(ent)) do
        for i, data in ipairs(group) do
            RetrieveWatcher(data, var)
        end
    end

    for cmp, self in pairs(ent.components) do
        for k, v in pairs(shallowcopy(self)) do
            if type(v) == "function" then
                if WorldStateOverriders[k] ~= nil or k:sub(1, 2) ~= "__" then
                    Waffles.Replace(self, k)
                end
            end
        end
    end

    if ent.pendingtasks ~= nil then
        for periodic in pairs(ent.pendingtasks) do
            if periodic.fn ~= nil then
                local fn = Waffles.Memory.Load("Basement.Original", periodic.fn)
                if fn ~= nil then
                    periodic.fn = fn
                end
            end
        end
    end
end

local function AddBasementObjectBenefits(inst, ent)
    local data = {}

    if ent.components.burnable ~= nil and not ent:HasTag("wildfireprotected") then
        data.wildfireprotected = true
        ent:AddTag("wildfireprotected")
    end
    if ent.components.container ~= nil and not ent:HasTag("fridge") then
        data.fridge = true
        ent:AddTag("fridge")
        ent:AddTag("nocool")
    end
    if ent.components.sleepingbag ~= nil and ent:HasTag("tent") then
        data.tent = ent:HasTag("siestahut")
        AdjustTentTag(ent, TheWorld.state.phase)
    end
    if ent.components.inventoryitemmoisture ~= nil then
        data.moisture = true
        Waffles.Replace(ent.components.inventoryitemmoisture, "GetTargetMoisture", CommonReplacements.Zero)
    end
    if ent.components.grower ~= nil then
        data.grower = ent.components.grower.growrate
        ent.components.grower.growrate = 0.5
    end
    if ent.components.growable ~= nil and ent.components.growable.stages ~= nil then
        data.growable = {}
        for k = #ent.components.growable.stages, 3, -1 do
            table.insert(data.growable, table.remove(ent.components.growable.stages, k))
        end
    end

    for tag, info in pairs(BLOCKED.TAGS) do
        if ent:HasTag(tag) then
            Waffles.GetPath(data, "tags")[tag] = info
            ent:RemoveTag(tag)
            if type(info) == "table" then
                info[1](ent)
            end
        end
    end

    PushBasementWorldStateForEntity(ent)

    return next(data) ~= nil and data or true
end

local function RemoveBasementObjectBenefits(inst, ent, data)
    if not Waffles.Valid(ent) or type(data) ~= "table" then
        return
    end

    if data.wildfireprotected ~= nil then
        ent:RemoveTag("wildfireprotected")
    end
    if data.fridge ~= nil then
        ent:RemoveTag("fridge")
        ent:RemoveTag("nocool")
    end
    if data.tent ~= nil then
        AdjustTentTag(ent, data.tent and "day" or "night")
    end
    if data.moisture ~= nil and ent.components.inventoryitemmoisture ~= nil then
        Waffles.Replace(ent.components.inventoryitemmoisture, "GetTargetMoisture")
    end
    if data.grower ~= nil and ent.components.grower ~= nil then
        ent.components.grower.growrate = data.grower
    end
    if data.growable ~= nil and ent.components.growable ~= nil and ent.components.growable.stages ~= nil then
        for k = 3, 3 + #data.growable do
            ent.components.growable.stages[k] = table.remove(data.growable)
        end
    end

    if data.tags ~= nil then
        for tag, info in pairs(data.tags) do
            ent:AddTag(tag)
            if type(info) == "table" then
                info[2](ent)
            end
        end
    end

    PopBasementWorldStateForEntity(ent)

    ent.persists = true
end

local function ValidatePosition(ent)
    if not ent:IsInBasement() and ent:GetTimeAlive() >= 2 then
        local x, y, z = ent.Transform:GetWorldPosition()
        local closestdist = math.huge
        local ox, oz
        for i, v in ipairs(Waffles.CreatePositions.Rectangle("8x8", true, true)) do
            local x, y, z = x + v.x, 0, z + v.z
            if TheWorld.Map:IsBasementAtPoint(x, y, z) then
                local dist = ent:GetDistanceSqToPoint(x, y, z)
                if dist < closestdist then
                    closestdist = dist
                    ox, oz = x, z
                end
            end
        end
        if ox then
            ent.Transform:SetPosition(ox, 0, oz)
        end
        if not ent:HasTag("player")
                and ent.components.workable ~= nil
                and ent.components.workable:CanBeWorked()
                and ent.components.workable.action ~= ACTIONS.NET then
            ent.components.workable:Destroy(ent)
        end
    end
end

local function TrackBasementObjects(inst)
    if not inst:IsValid() then
        return
    end

    if inst.allobjects == nil then
        inst.allobjects = {}
        setmetatable(inst.allobjects, { __mode = "k" })
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local objects = table.invert(TheSim:FindEntities(x, y, z, 70, nil, { "INLIMBO", "basement_part", "player" }))

    for ent in pairs(objects) do
        if not inst.allobjects[ent] and IsSerializableEntity(ent) then
            ent = SwitchEntityWorldState(ent)
            inst.allobjects[ent] = AddBasementObjectBenefits(inst, ent)
            objects[ent] = true
        end
    end

    for ent in pairs(inst.allobjects) do
        if objects[ent] then
            ValidatePosition(ent)
        else
            RemoveBasementObjectBenefits(inst, ent, inst.allobjects[ent])
            inst.allobjects[ent] = nil
        end
    end
end

local function SetLightWatcherAdditiveThresh(ent, thresh)
    thresh = thresh or 0
    ent.LightWatcher:SetLightThresh(0.075 + thresh)
    ent.LightWatcher:SetDarkThresh(0.05 + thresh)
end

local function UpdateLightWatchers(inst)
    if inst.allplayers ~= nil then
        local thresh = TheSim:GetLightAtPoint(10000, 10000, 10000)
        for ent in pairs(inst.allplayers) do
            if ent.LightWatcher ~= nil then
                SetLightWatcherAdditiveThresh(ent, thresh)
            end
        end
    end
end

local function SetBasementBuilder(inst, ent, enable)
    if enable then
        if ent.userid == inst.owner or Waffles.Return(TheNet:GetClientTableForUser(ent.userid), "admin") then
            ent:AddTag("basement_upgradeuser_owner")
        end
        ent:AddTag("basement_upgradeuser")
    else
        ent:RemoveTag("basement_upgradeuser_owner")
        ent:RemoveTag("basement_upgradeuser")
    end
end

local function OnBuilderPrototyperChanged(self, machine)
    local enable = self.freebuildmode or (machine == nil or machine:HasTag("basement_part"))
    local isbuilder = self.inst:HasTag("basement_upgradeuser_owner")
    if enable ~= isbuilder then
        SetBasementBuilder(self.inst.basement, self.inst, enable)
    end
end

local function ForceUpdateObjectTracker(ent)
    if Waffles.Valid(ent.basement) then
        StartThread(TrackBasementObjects, ent.basement.GUID, ent.basement)
    end
end

local function SimulateSpawnerEventsForPlayer(ent, event)
    local t = Waffles.Return(TheWorld, "event_listening/" .. event)
    if type(t) == "table" and type(t[TheWorld]) == "table" then
        for i, v in ipairs(t[TheWorld]) do
            local activeplayers = Waffles.UpvalueHacker.GetUpvalue(v, "_activeplayers")
            if activeplayers ~= nil then
                v(TheWorld, ent)
            end
        end
    end
end

local function AddBasementPlayerBenefits(inst, ent)
    ForceUpdateState(inst)

    ent.basement = inst

    if ent.components.sanity ~= nil then
        ent.components.sanity.externalmodifiers:SetModifier(inst, (GetModConfigData("sanity", "workshop-1349799880") or -5) / 60)
    end
    if ent.components.temperature ~= nil then
        ent.components.temperature:SetModifier("basement", inst.insulation)
    end
    if ent.components.moisture ~= nil then
        Waffles.Replace(ent.components.moisture, "GetMoistureRate", CommonReplacements.Zero)
    end
    if ent.components.playerlightningtarget ~= nil then
        Waffles.Replace(ent.components.playerlightningtarget, "GetHitChance", CommonReplacements.Zero)
    end
    if ent.components.builder ~= nil then
        Waffles.Replace(ent.components.builder, "DoBuild", CommonReplacements.Builder)

        SetBasementBuilder(inst, ent, true)

        Waffles.ForceUpdateTabs(ent)

        addsetter(ent.components.builder, "current_prototyper", OnBuilderPrototyperChanged)
    end
    if ent.components.beaverness ~= nil then
        Waffles.Replace(ent.components.beaverness, "SetPercent", CommonReplacements.None)
    end

    EnableAreaAwareComponent(ent, true)

    --PushBasementWorldStateForEntity(ent)

    SimulateSpawnerEventsForPlayer(ent, "ms_playerleft")

    ent:ListenForEvent("performaction", ForceUpdateObjectTracker)

    if ThePlayer == ent then
        OnEntityWakeClient(inst)
    end
end

local function RemoveBasementPlayerBenefits(inst, ent)
    if not Waffles.Valid(ent) then
        return
    end

    ForceUpdateState(inst)

    ent.basement = nil

    if ent.components.sanity ~= nil then
        ent.components.sanity.externalmodifiers:RemoveModifier(inst)
    end
    if ent.components.temperature ~= nil then
        ent.components.temperature:RemoveModifier("basement")
    end
    if ent.components.moisture ~= nil then
        Waffles.Replace(ent.components.moisture, "GetMoistureRate")
    end
    if ent.components.playerlightningtarget ~= nil then
        Waffles.Replace(ent.components.playerlightningtarget, "GetHitChance")
    end
    if ent.components.builder ~= nil then
        Waffles.Replace(ent.components.builder, "DoBuild")

        SetBasementBuilder(inst, ent, false)

        Waffles.ForceUpdateTabs(ent)

        removesetter(ent.components.builder, "current_prototyper")
    end
    if ent.components.beaverness ~= nil then
        Waffles.Replace(ent.components.beaverness, "SetPercent")

        if TheWorld.state.moonphase == "full" then
            local fn = Waffles.Return(ent, "worldstatewatching/isfullmoon/1")
            if fn ~= nil then
                fn(ent, true)
            end
        end
    end
    if ent.LightWatcher ~= nil then
        SetLightWatcherAdditiveThresh(ent)
    end

    EnableAreaAwareComponent(ent, false)

    --PopBasementWorldStateForEntity(ent)

    SimulateSpawnerEventsForPlayer(ent, "ms_playerjoined")

    ent:RemoveEventCallback("performaction", ForceUpdateObjectTracker)

    if ThePlayer == ent then
        OnEntitySleepClient(inst)
    end
end

local function TrackBasementPlayers(inst)
    if inst.allplayers == nil then
        inst.allplayers = {}
        setmetatable(inst.allplayers, { __mode = "k" })
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = table.invert(TheSim:FindEntities(x, y, z, 70, { "player" }))
    for ent in pairs(players) do
        if not inst.allplayers[ent] then
            AddBasementPlayerBenefits(inst, ent)
            inst.allplayers[ent] = true
        end
    end
    for ent in pairs(inst.allplayers) do
        if players[ent] then
            ValidatePosition(ent)
            if ent.components.locomotor ~= nil then
                ent.components.locomotor:PushTempGroundSpeedMultiplier(1, inst.foleyground)
            end
        else
            RemoveBasementPlayerBenefits(inst, ent)
            inst.allplayers[ent] = nil
        end
    end
end

local function OnScreenFlash(inst)
    if inst.tracker ~= nil then
        if inst.tracker.lighting ~= nil then
            inst.tracker.lighting:Cancel()
        end
        inst.tracker.lighting = inst:DoPeriodicTask(2, UpdateLightWatchers, 0)
    end
end

local function RebuildWalls(inst)
    local pos = {}

    --reuse previously spawned entities for optimization
    local oldwalls = {}
    if inst.walls ~= nil then
        for i, v in ipairs(inst.walls) do
            if v:IsValid() then
                table.insert(oldwalls, v)
            end
        end
    end
    inst.walls = {}

    local ix, iy, iz = TheWorld.Map:GetTileCenterPoint(inst.Transform:GetWorldPosition())

    for tile in pairs(gettiles(inst)) do
        local x, z = string.match(tile, "([^_]+)_([^_]+)")
        x = tonumber(x) + 0.5
        z = tonumber(z) + 0.5

        for i, v in ipairs(Waffles.CreatePositions.Rectangle("6x6", true)) do
            if not TheWorld.Map:IsBasementAtPoint(ix + v.x + x, 0, iz + v.z + z) then
                pos[(x + v.x) .. "_" .. (z + v.z)] = true
            end
        end
    end

    for key, score in pairs(pos) do
        local x, z = string.match(key, "([^_]+)_([^_]+)")
        x = tonumber(x)
        z = tonumber(z)

        local wall = table.remove(oldwalls) or SpawnPrefab("wall_basement_1")
        wall.Transform:SetPosition(ix + x, 0, iz + z)
        Waffles.AnimState.PlayWallAnimation(wall)
        Waffles.AddChild(inst, wall)
        table.insert(inst.walls, wall)
    end

    RemoveEnts(oldwalls)
end

local function OnEntityWake(inst)
    TrackBasementObjects(inst)

    inst.tracker =
    {
        lighting = inst:DoPeriodicTask(2, UpdateLightWatchers, 1),
        players = inst:DoPeriodicTask(0.1, TrackBasementPlayers),
        objects = inst:DoPeriodicTask(5, TrackBasementObjects),
    }

    inst.OnScreenFlash = function() OnScreenFlash(inst) end
    inst:ListenForEvent("screenflash", inst.OnScreenFlash, TheWorld)

    inst:WatchWorldState("phase", OnNewPhase)
    inst:WatchWorldState("iswet", OnWet)
    inst:WatchWorldState("season", UpdateBasementInsulation)
    UpdateBasementInsulation(inst, TheWorld.state.season)

    RebuildWalls(inst)

    inst.ceiling = inst:SpawnChild("basement_ceiling")
end

local function OnEntitySleep(inst)
    if inst.tracker ~= nil then
        for name, task in pairs(inst.tracker) do
            task:Cancel()
        end
        inst.tracker = nil
    end

    if inst.allplayers ~= nil then
        for ent in pairs(inst.allplayers) do
            RemoveBasementPlayerBenefits(inst, ent)
        end
        inst.allplayers = nil
    end

    if inst.OnScreenFlash ~= nil then
        inst:RemoveEventCallback("screenflash", inst.OnScreenFlash, TheWorld)
        inst.OnScreenFlash = nil
    end

    inst:StopAllWatchingWorldStates()

    RemoveEnts(inst.walls)

    if Waffles.Valid(inst.ceiling) then
        inst.ceiling:Remove()
    end
    inst.ceiling = nil
end

local function OnSave(inst, data)
    data.owner = inst.owner

    data.isrocky = inst.state.isrocky:value()
    data.flooring = inst.state.flooring:value()

    local tiledata = inst.state.tiledata:value()
    if tiledata ~= DEFAULT_TILEDATA then
        data.tiledata = tiledata
    end

    if inst.basement ~= nil then
        data.basement = {}
        local references = {}
        for name, entity in pairs(inst.basement) do
            data.basement[name] = entity.GUID
            table.insert(references, entity.GUID)
        end
        return references
    end
end

local function RetransformBasement(inst)
    local x, y, z = FindValidInteriorPosition()
    if x ~= nil then
        local ix, iy, iz = inst.Transform:GetWorldPosition()

        --[[local debug = SpawnPrefab("basement_debugpoint")
        debug.entrance_pos = { x, y, z }
        debug.Transform:SetPosition(ix, iy, iz)
        debug.components.timer:StartTimer("erodeaway", 96000)]]

        local offset = Point(x, y, z) - Point(ix, iy, iz)
        for i, v in ipairs(TheSim:FindEntities(ix, iy, iz, 100)) do
            if not v.entity:GetParent() then
                v.Transform:SetPosition((Point(v.Transform:GetWorldPosition()) + offset):Get())
            end
        end
    end
end

local function OnLoad(inst, data, newents)
    if data ~= nil then
        inst.owner = data.owner

        if data.isrocky ~= nil then
            inst.state.isrocky:set(data.isrocky)
        end
        if data.flooring ~= nil then
            inst.state.flooring:set(data.flooring)
        end

        if data.basement ~= nil then
            local basement = {}
            for name, GUID in pairs(data.basement) do
                basement[name] = newents[GUID]
            end
            for name, entity in pairs(basement) do
                Waffles.Replace(entity, "Remove", DespawnBasement)
                entity.basement = basement
            end
        end
    end

    --print(data.tiledata)
    inst.state.tiledata:set((data ~= nil and data.tiledata ~= nil and #data.tiledata > 0 and data.tiledata) or DEFAULT_TILEDATA)
    inst:SetBasementTile(9001, 9001)

    --support for legacy basements
    if TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition()) ~= GROUND.INVALID then
        inst:DoTaskInTime(0, RetransformBasement)
    end
end

local function SpawnRubble(worker, x, y, z)
    local wx, wy, wz = worker.Transform:GetWorldPosition()
    for i, v in ipairs(Waffles.CreatePositions.Rectangle("4x4", true, true)) do
        local wall = SpawnPrefab("wall_basement_rubble")
        wall.Transform:SetPosition(v.x + x + 0.5, 0, v.z + z + 0.5)
        Waffles.AnimState.PlayWallAnimation(wall)
        wall:DoPeriodicTask(0.2, wall.DowngradeRubble, math.sqrt(distsq(v.x + x, v.z + z, wx, wz)) * 0.2)
    end

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("stone")
end

local function SetBasementTile(inst, x, z, istile, worker, docheck)
    local tiles = {}
    local ix, iy, iz = TheWorld.Map:GetTileCenterPoint(inst.Transform:GetWorldPosition())

    for sub in inst.state.tiledata:value():gmatch("([^/]+)") do
        local x, z = string.match(sub, "([^_]+)_([^_]+)")
        x = tonumber(x)
        z = tonumber(z)
        Waffles.Map.RemoveSyntTile(x + ix, 0, z + iz)

        tiles[Waffles.GetInteriorTileKey(x, 0, z)] = true
    end
    tiles[Waffles.GetInteriorTileKey(x, 0, z)] = istile and true or nil

    local tiledata = ""
    for tilestr in pairs(tiles) do
        tiledata = tiledata .. tilestr .. "/"

        local x, z = string.match(tilestr, "([^_]+)_([^_]+)")
        x = tonumber(x)
        z = tonumber(z)
        Waffles.Map.AddSyntTile(x + ix, 0, z + iz, inst)
    end

    inst.state.tiledata:set(tiledata)

    if istile and worker then
        SpawnRubble(worker, TheWorld.Map:GetTileCenterPoint(x + ix, 0, z + iz))
    end

    if docheck and inst.allplayers ~= nil then
        for ent in pairs(inst.allplayers) do
            ValidatePosition(ent)
        end
    end
end

local function OnUpgrade(inst, data)
    data.cb(inst, data.source, unpack(data.arg))
end

local function OnInit(inst)
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("ontilechanged", RebuildBasementClient)
        RebuildBasementClient(inst)
    end

    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("ontilechanged", RebuildWalls)
    RebuildWalls(inst)

    TrackBasementObjects(inst)

    if not IsBasementCorrupted(inst) then
        return
    end

    local basement = { core = inst }

    local x, y, z = TheWorld.Map:GetTileCenterPoint(inst.Transform:GetWorldPosition())
    local exit = TheSim:FindEntities(x, 0, z, 70, { "basement_part", "stairs" })[1]
    if exit ~= nil then
        basement.exit = exit
        if exit.components.teleporter ~= nil then
            basement.entrance = exit.components.teleporter.targetTeleporter
        end
        exit.Transform:SetPosition(x - 11, y, z - 11)
    end

    for name, entity in pairs(basement) do
        Waffles.Replace(entity, "Remove", DespawnBasement)
        entity.basement = basement
    end
end

local function GetNormalPosition(inst, pt)
    if not IsBasementCorrupted(inst) then
        local offset = pt - inst.basement.exit:GetPosition()
        local convert = inst.basement.entrance:GetPosition() + offset
        return convert
    end
    return pt
end

local function base()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("basement_core")
    inst:AddTag("basement_part")

    inst.state =
    {
        iswet = net_bool(inst.GUID, "basement.iswet"),
        isrocky = net_bool(inst.GUID, "basement.isrocky"),
        flooring = net_tinybyte(inst.GUID, "basement.floorID", "onfloorchanged"),
        tiledata = net_string(inst.GUID, "basement.tiles", "ontilechanged")
    }

    inst:ListenForEvent("onfloorchanged", OnFloorType)

    inst.foleyground = GROUND.CHECKER

    if not TheNet:IsDedicated() then
        local mist = SpawnPrefab("mist")
        mist.entity:SetParent(inst.entity)
        inst.mistpos = { x = { 0 }, z = { 0 } }
        mist.components.emitter.area_emitter = function()
            return Waffles.GetRandom(inst.mistpos.x) + math.random(-2, 2),
            Waffles.GetRandom(inst.mistpos.z) + math.random(-2, 2)
        end

        mist.entity:SetAABB(14, 2)
        mist.components.emitter.density_factor = GetModConfigData("mist", "workshop-1349799880") or 1
        mist.components.emitter:Emit()
    end

    inst:DoTaskInTime(0, OnInit)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityWake = OnEntityWakeClient
        inst:ListenForEvent("onremove", OnEntitySleepClient)

        return inst
    end

    inst.GetNormalPosition = GetNormalPosition
    inst.SetBasementTile = SetBasementTile
    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("onupgrade", OnUpgrade)

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Flooring ]]
--------------------------------------------------------------------------
local function tile_common(build, anim, shade, scale)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank(build)
    inst.AnimState:SetBuild(build)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(5)
    if shade and shade > 0 then
        inst.AnimState:OverrideShade(shade)
    end
    inst.AnimState:SetScale(scale, scale)
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")
    inst:AddTag("basement_part")

    inst.persists = false

    return inst
end

local function tile()
    local inst = tile_common("basement_floor", "rocky", BASEMENT_SHADE, 8.205)

    inst.void = inst:SpawnChild("basement_voidtile")

    return inst
end

local function tile_background()
    local inst = tile_common("basement_voidtile", "idle", 0, 37.5, true)

    inst.Transform:SetRotation(90)
    inst.Transform:SetScale(1.0015, 1.0015, -1.0015)

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Ceiling (Physics) ]]
--------------------------------------------------------------------------
local function OnCollideCeiling(inst, collider)
    if Waffles.Valid(collider)
            and collider.Transform ~= nil then
        local cy, cx, cz = collider.Transform:GetWorldPosition()

        --a bird dropped by player
        if cx < 10 then
            if collider:HasTag("bird") then
                if collider.components.lootdropper ~= nil then
                    collider.components.lootdropper:SetLoot({})
                end
                if collider.components.combat ~= nil then
                    collider.components.combat:GetAttacked(inst, 5)
                end
                collider:PushEvent("gotosleep")
            end
            --an entity spawned by birdspawner, frograin, quaker, etc
            --this is no longer needed, since players entering an interior
            --are no longer tracked by these components
        else
            if not Waffles.Valid(inst.parent) then
                return
            end
            collider.Physics:Teleport(inst.parent:GetNormalPosition(collider:GetPosition()):Get()) --teleport to normal playzone
        end
    end
end

local function ceiling()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetCollisionGroup(COLLISION.WORLD)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCylinder(70, 70)
    phys:SetCollisionCallback(OnCollideCeiling)

    inst:DoTaskInTime(0, function()
        local x, y, z = (inst.parent or inst).Transform:GetWorldPosition()
        inst.Transform:SetPosition(x, CEILING_HEIGHT, z)
    end)

    inst:AddTag("basement_part")

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------
--[[ Basement Debugpoint (Rescue Players) ]]
--------------------------------------------------------------------------
local function ReportEntities(inst, fntype)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 70, nil, { "CLASSIFIED" })
    if #ents > 0 then
        print(string.format("[BASEMENT debug point (%s, %s, %s)] %s found entities nearby:", x, y, z, fntype))
        for i, v in ipairs(ents) do
            print(v.entity:GetDebugString())
        end
    end
end

local function OnSaveDebugPoint(inst, data)
    data.entrance_pos = inst.entrance_pos
    --ReportEntities(inst, "OnSave")
end

local function OnLoadDebugPoint(inst, data)
    inst.entrance_pos = data and data.entrance_pos
    ReportEntities(inst, "OnLoad")
end

local function ReturnPlayersToLand(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local pos = inst.entrance_pos or { 0, 0, 0 }
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 70, { "player" })) do
        if TheWorld.Map:IsPassableAtPoint(v.Transform:GetWorldPosition()) then
            print("[Basement Debug Point] Removing itself because a new basement is built nearby.")
            inst:Remove()
            return
        else
            Waffles.Announce(string.format(STRINGS.HUD.BASEMENT.ANNOUNCE_PLAYER_RETURNED_TO_LAND, v:GetDisplayName()))
            v.Transform:SetPosition(unpack(pos))
        end
    end
end

local function debug1()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("basement_debugpoint")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", inst.Remove)

    inst.OnSave = OnSaveDebugPoint
    inst.OnLoad = OnLoadDebugPoint
    inst.OnEntityWake = ReturnPlayersToLand

    return inst
end

local function UpdateDebugLight(inst, phase)
    if phase == "night" then
        inst:DoTaskInTime(3, inst.Remove)
    else
        local parent = inst.entity:GetParent()
        if TheWorld.basement_lighting_task == nil
                or parent and parent:IsInBasement() then
            inst:Remove()
        end
    end
end

local function ClearTrace(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent._debuglight = nil
    end
end

local function debug2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()

    inst.Light:SetRadius(0.5)
    inst.Light:SetIntensity(1)
    inst.Light:SetFalloff(1)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)

    inst:AddTag("CLASSIFIED")

    inst.persists = false

    inst:WatchWorldState("phase", UpdateDebugLight)
    inst:DoPeriodicTask(0, UpdateDebugLight)
    inst:ListenForEvent("onremove", ClearTrace)

    return inst
end

return Prefab("wall_basement_1", wall1),
Prefab("wall_basement_2", wall2),
Prefab("wall_basement_rubble", wall_rubble),
Prefab("wall_basement_void", wall_void),
Prefab("basement_entrance", entrance, assets.hatch, prefabs.hatch),
Prefab("basement_entrance_hatch", entrance_hatch, assets.hatch, prefabs.hatch),
Prefab("basement_entrance_builder", builder),
MakePlacer("basement_entrance_placer", "basement_entrance", "basement_hatch", "idle", nil, nil, nil, nil, nil, nil, placerdecor),
Prefab("basement_exit", exit, assets.stairs),
--Prefab("basement_elevator_cage", lift, assets.elevator),
--Prefab("basement_elevator_shield", lift_shield, assets.elevator),
Prefab("basement_exit_light", exit_light),
Prefab("basement", base),
Prefab("basement_tile", tile, assets.tile),
Prefab("basement_voidtile", tile_background, assets.voidtile),
Prefab("basement_ceiling", ceiling),
Prefab("basement_debugpoint", debug1),
Prefab("basement_debuglight", debug2)