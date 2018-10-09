local assets =
{
    Asset("ANIM", "anim/torso_opalamulet.zip"),
    Asset("ANIM", "anim/opalamulet_ground.zip"),
    Asset("ANIM", "anim/opalamulet_fx.zip"),
    Asset("ANIM", "anim/shadow_upgrade.zip"),

    Asset("IMAGE", "images/inventoryimages/opalamulet.tex"),
    Asset("ATLAS", "images/inventoryimages/opalamulet.xml"),
}
local function turnoff_opal(inst)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
            inst._particle:Remove()
        end
        inst._light = nil
    end
end

local function getstatus(inst)
    if not inst.components.inventoryitem:IsHeld() and TheWorld.state.isfullmoon then
        return "CHARGING"
                or nil
    end
end

--Full Moon Effect---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function opal_wilson(inst, owner)
    if TheWorld.state.isfullmoon then
        owner:DoTaskInTime(0, function()
            if not owner:HasTag("opalbeard") then
                owner.AnimState:OverrideSymbol("beard", "beard", "beard_short")
                SpawnPrefab("sand_puff").Transform:SetPosition(owner.Transform:GetWorldPosition())
                owner.components.beard.bits = 1
                inst.components.fueled:DoDelta(-3)
            end
        end)
        owner:DoTaskInTime(0.5, function()
            if not owner:HasTag("opalbeard") then
                owner.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
                SpawnPrefab("sand_puff").Transform:SetPosition(owner.Transform:GetWorldPosition())
                owner.components.beard.bits = 2
                inst.components.fueled:DoDelta(-6)
            end
        end)
        owner:DoTaskInTime(1, function()
            if not owner:HasTag("opalbeard") then
                owner.AnimState:OverrideSymbol("beard", "beard", "beard_long")
                SpawnPrefab("sand_puff").Transform:SetPosition(owner.Transform:GetWorldPosition())
                owner.components.beard.bits = 3
                owner:AddTag("opalbeard")
                inst.components.fueled:DoDelta(-9)
            end
        end)
        if owner.components.beard.bits == 0 then
            owner:RemoveTag("opalbeard")
        end
    end
end

local function opal_willow(inst, owner)
    if TheWorld.state.isfullmoon then
        owner.components.health.fire_damage_scale = 0.01
        if owner.components.health.takingfiredamage then
            owner.components.health:DoDelta(5)
            inst.components.fueled:DoDelta(-1)
        end
    end
end

local function opal_wolfgang(inst, owner)
    if TheWorld.state.isfullmoon and owner.components.hunger:GetPercent() < 0.965 then
        owner.components.hunger:DoDelta(50)
    end
end

local function opal_wendy(inst, owner)
    local x, y, z = owner.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, { "abigail" }, nil)
    for i, v in ipairs(ents) do
        if TheWorld.state.isfullmoon then
            if v.components.health and not v:HasTag("opalghost") then
                inst.components.fueled:DoDelta(-75)
                v.components.combat.defaultdamage = 4 * TUNING.ABIGAIL_DAMAGE_PER_SECOND
                v:AddTag("opalghost")
            end
            if v._light == nil or not v._light:IsValid() then
                v._light = SpawnPrefab("opallight")
                v._particle = SpawnPrefab("chesterlight")
                v._light.AnimState:PlayAnimation("idle_start", true)
                v._light.AnimState:PushAnimation("idle", true)
                v._particle.AnimState:PlayAnimation("on", true)
                v._particle.AnimState:PushAnimation("idle_loop", true)
            end
            v._light.entity:SetParent(v.entity)
            v._particle.entity:SetParent(v.entity)
        else v.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND
            v:RemoveTag("opalghost")
            if v._light ~= nil then
                if v._light:IsValid() then
                    v._light:Remove()
                    v._particle:Remove()
                end
                v._light = nil
            end
        end
    end
end

local function opal_wx(inst, owner)
    if TheWorld.state.isfullmoon then
        if math.random() >= 0.7 then
            TheWorld:PushEvent("ms_sendlightningstrike", owner:GetPosition())
            inst.components.fueled:DoDelta(-50)
        end
    end
end

local function opal_wickerbottom(inst, owner)
    if TheWorld.state.isfullmoon then
        local book = owner.bufferedaction ~= nil and (owner.bufferedaction.target or owner.bufferedaction.invobject) or nil
        if book ~= nil and book.components.finiteuses then
            if book.components.finiteuses:GetUses() < 5 then
                book.components.finiteuses:SetMaxUses(5)
                book.components.finiteuses:SetUses(5)
                inst.components.fueled:DoDelta(-150)
            end
        end
    end
end

local function opal_woodie(inst, owner)
    if TheWorld.state.isfullmoon then
        owner.components.beaverness:SetPercent(.25)
    elseif owner.sg:HasStateTag("chopping") then
        owner.components.beaverness:DoDelta(2)
        inst.components.fueled:DoDelta(-0.9)
    end
end

local function opal_wes(inst, owner)
    if TheWorld.state.isfullmoon then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8, { "cattoyairborne" }, nil)
        for i, v in ipairs(ents) do
            if v.components.combat and not v:HasTag("opalballoon") then
                if v.prefab == "balloon" then
                    SpawnPrefab("attune_in_fx").Transform:SetPosition(v.Transform:GetWorldPosition())
                    v.components.combat:SetDefaultDamage(50)
                    v:AddTag("opalballoon")
                end
            end
        end
    end
end

local function opal_waxwell(inst, owner)
    if TheWorld.state.isfullmoon then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8, { "shadowminion" }, nil)
        for i, v in ipairs(ents) do
            if v.components.health and not v:HasTag("opalshadow") then
                inst.components.fueled:DoDelta(-150)
                v.components.health:SetAbsorptionAmount(0.6)
                v.components.health:SetMaxHealth(75)
                v.components.health:StartRegen(TUNING.SHADOWWAXWELL_HEALTH_REGEN, TUNING.SHADOWWAXWELL_HEALTH_REGEN_PERIOD)
                v:AddTag("opalshadow")
                SpawnPrefab("opalupgrade").Transform:SetPosition(v.Transform:GetWorldPosition())
            end
            if v._particle == nil or not v._particle:IsValid() then
                v._particle = SpawnPrefab("opalupgrade")
            end
            v._particle.entity:SetParent(v.entity)
        end
    end
end

local function opal_wathgrithr(inst, owner)
    if TheWorld.state.isfullmoon then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 10, { "_combat" })
        for k, v in pairs(ents) do
            if v.components.lootdropper ~= nil and not v:HasTag("opalloot") then
                if v:HasTag("smallcreature") then
                    v.components.lootdropper:AddChanceLoot("smallmeat", 1)
                    v.components.lootdropper:AddChanceLoot("smallmeat", 0.5)
                end
                if v:HasTag("monster") then
                    v.components.lootdropper:AddChanceLoot("monstermeat", 1)
                    v.components.lootdropper:AddChanceLoot("monstermeat", 0.5)
                end
                if v:HasTag("largecreature") then
                    v.components.lootdropper:AddChanceLoot("meat", 1)
                    v.components.lootdropper:AddChanceLoot("meat", 1)
                    v.components.lootdropper:AddChanceLoot("meat", 0.5)
                end
                if (v:HasTag("lureplant")) or (v:HasTag("leif")) then
                    v.components.lootdropper:AddChanceLoot("plantmeat", 1)
                end
                v:AddTag("opalloot")
            end
        end
    end
end

local function opal_webber(inst, owner)
    if TheWorld.state.isfullmoon then
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            local x, y, z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 20, { "spider" })
            for k, v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end
end

local function opal_winona(inst, owner)
    if TheWorld.state.isfullmoon then
        owner.components.builder.ingredientmod = 0.75
    else
        owner.components.builder.ingredientmod = 1
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_opalamulet", "opalamulet")
    inst.components.fueled:StartConsuming()
    if TheWorld.state.isfullmoon then
        --Character Powerup
        if owner.prefab == "wilson" then
            owner.components.talker:Say("什么...我的胡子怎么了?")
            inst.task = inst:DoPeriodicTask(1.5, opal_wilson, nil, owner)
        end
        if owner.prefab == "willow" then
            owner.components.talker:Say("我现在就想游到火里去!")
            inst.task = inst:DoPeriodicTask(0.25, opal_willow, nil, owner)
        end
        if owner.prefab == "wolfgang" then
            owner.components.talker:Say("只有肌肉才能让我快乐!")
            inst.task = inst:DoPeriodicTask(1, opal_wolfgang, nil, owner)
        end
        if owner.prefab == "wx78" then
            owner.components.talker:Say("暴风雨即将来临")
            inst.task = inst:DoPeriodicTask(3, opal_wx, nil, owner)
        end
        if owner.prefab == "wickerbottom" then
            owner.components.talker:Say("今晚的新闻时间到了.")
            inst.task = inst:DoPeriodicTask(1, opal_wickerbottom, nil, owner)
        end
        if owner.prefab == "waxwell" then
            owner.components.talker:Say("觉醒!")
            inst.task = inst:DoPeriodicTask(0.5, opal_waxwell, nil, owner)
        end
        if owner.prefab == "wathgrithr" then
            owner.components.talker:Say("佛祖保佑我吧!")
            inst.task = inst:DoPeriodicTask(3, opal_wathgrithr, nil, owner)
        end
        if owner.prefab == "webber" then
            owner.components.talker:Say("有人和我们一起玩吗?")
            inst.task = inst:DoPeriodicTask(3, opal_webber, nil, owner)
        end
        if owner.prefab == "winona" then
            owner.components.talker:Say("那明亮的光线... 它给了我一个主意!")
            inst.task = inst:DoPeriodicTask(0.5, opal_winona, nil, owner)
        end
        --Active light and fuel
        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("opallight")
            inst._particle = SpawnPrefab("chesterlight")
            inst._light.AnimState:PlayAnimation("idle_start", true)
            inst._light.AnimState:PushAnimation("idle", true)
            inst._particle.AnimState:PlayAnimation("on", true)
            inst._particle.AnimState:PushAnimation("idle_loop", true)
        end
        inst._light.entity:SetParent(owner.entity)
        inst._particle.entity:SetParent(owner.entity)
        inst.components.fueled.rate = 6
    end
    --Character Powerup (No Need Fullmoon)
    if owner.prefab == "wendy" then
        if TheWorld.state.isfullmoon then
            owner.components.talker:Say("是时候玩你最喜欢的游戏了.")
        end
        inst.task = inst:DoPeriodicTask(0.5, opal_wendy, nil, owner)
    end
    if owner.prefab == "woodie" then
        owner.components.talker:Say("我觉得...浑身燥热.")
        inst.task = inst:DoPeriodicTask(0.5, opal_woodie, nil, owner)
    end
    if owner.prefab == "wes" then
        inst.task = inst:DoPeriodicTask(0.5, opal_wes, nil, owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
    turnoff_opal(inst)
    --Clear Character Powerup
    if owner.prefab == "wilson" then
        owner:RemoveTag("opalbeard")
    end
    if owner.prefab == "willow" then
        owner.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE
    end
    if owner.prefab == "wendy" then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8, { "abigail" }, nil)
        for i, v in ipairs(ents) do
            v.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND
            v:RemoveTag("opalghost")
            if v._light ~= nil then
                if v._light:IsValid() then
                    v._light:Remove()
                    v._particle:Remove()
                end
                v._light = nil
            end
        end
    end
    if owner.prefab == "winona" then
        owner.components.builder.ingredientmod = 1
    end
    --Clear All Tasks
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function OnInit(inst)
    if not inst.components.inventoryitem:IsHeld() then
        if TheWorld.state.isfullmoon then
            inst.AnimState:PlayAnimation("idle_fullmoon", true)
            inst.components.fueled:StartConsuming()
            inst.components.fueled.rate = -6
            if inst._light == nil or not inst._light:IsValid() then
                inst._light = SpawnPrefab("opallight")
                inst._particle = SpawnPrefab("chesterlight")
                inst._light.AnimState:PlayAnimation("idle_start", true)
                inst._light.AnimState:PushAnimation("idle", true)
                inst._particle.AnimState:PlayAnimation("on", true)
                inst._particle.AnimState:PushAnimation("idle_loop", true)
                inst.ischarging = true
            end
            inst._light.entity:SetParent(inst.entity)
            inst._particle.entity:SetParent(inst.entity)
        end
    elseif not TheWorld.state.isfullmoon then
        inst.AnimState:PlayAnimation("idle", true)
        inst.components.fueled:StopConsuming()
        inst.components.fueled.rate = 0
        turnoff_opal(inst)
        inst.ischarging = false
    end
end

local function onbuilt(inst, builder)
    builder.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/shadow_pulse")
    builder.components.talker:Say("这些东西是从哪儿来的?!")
    local theta = math.random() * 2 * PI
    local steps = 3
    for i = 1, steps do
        local shadow = SpawnPrefab("nightmarebeak")
        local x, y, z = inst.Transform:GetWorldPosition()
        shadow.Transform:SetPosition(x + math.random(5, 7), y, z + math.random(5, 7))
        SpawnPrefab("poopcloud").Transform:SetPosition(shadow.Transform:GetWorldPosition())
        shadow.components.combat:SetTarget(builder)
        shadow.Transform:SetScale(1.5, 1.5, 1.5)
        shadow.components.health:SetMaxHealth(1000)
        shadow.components.locomotor.walkspeed = 6
        shadow.components.lootdropper:AddChanceLoot("moonrocknugget", 0.9)
        if math.random() >= 0.5 then
            shadow.sg:GoToState("appear")
        else
            shadow.sg:GoToState("taunt")
        end
    end
    theta = theta - (2 * PI / steps)
end

local function getstatus(inst)
    return inst.ischarging == true and "CHARGING" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("opalamulet_ground")
    inst.AnimState:SetBuild("opalamulet_ground")
    inst.AnimState:PlayAnimation("idle", true)

    inst.foleysound = "dontstarve/movement/foley/jewlery"

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "opalamulet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/opalamulet.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(800)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    MakeHauntableLaunch(inst)

    inst.ischarging = nil

    inst:DoPeriodicTask(1, OnInit)

    inst.OnBuiltFn = onbuilt

    return inst
end

local function opallightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("opalamulet_fx")
    inst.AnimState:SetBuild("opalamulet_fx")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:SetDeployExtraSpacing(2)

    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.65)
    inst.Light:SetColour(223 / 255, 69 / 255, 208 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function upgradefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("shadow_upgrade")
    inst.AnimState:SetBuild("shadow_upgrade")
    inst.AnimState:PlayAnimation("fx", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:SetDeployExtraSpacing(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("opalamulet", fn, assets, prefabs),
Prefab("opallight", opallightfn),
Prefab("opalupgrade", upgradefn)
