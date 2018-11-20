local assets =
{
    Asset("ANIM", "anim/lucky_staff.zip"),
    Asset("ANIM", "anim/swap_lucky_staff.zip"),
	Asset("ATLAS", "images/lucky_staff.xml"),
}

local prefabs =
{
    "lucky_light",
    "reticule",
}

--创造幸运之星
local function createlight(staff, target, pos)
    local light = SpawnPrefab("lucky_light")
    light.Transform:SetPosition(pos:Get())
    staff.components.finiteuses:Use(1)

    local caster = staff.components.inventoryitem.owner
    if caster ~= nil and caster.components.sanity ~= nil then
        caster.components.sanity:DoDelta(-TUNING.SANITY_LARGE)--消耗33脑残
    end
end

local function light_reticuletargetfn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
end

local function onhauntlight(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE then
        local pos = inst:GetPosition()
        local start_angle = math.random() * 2 * PI
        local offset = FindWalkableOffset(pos, start_angle, math.random(3, 12), 60, false, true, NoHoles)
        if offset ~= nil then
            createlight(inst, nil, pos + offset)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
            return true
        end
    end
    return false
end

---------COMMON FUNCTIONS---------
--法杖用完后效果
local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

--卸下法杖
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function commonfn(colour)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lucky_staff")
    inst.AnimState:SetBuild("lucky_staff")
    inst.AnimState:PlayAnimation("lucky_staff")

    inst:AddTag("nopunch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_staff"
	inst.components.inventoryitem.atlasname = "images/lucky_staff.xml"

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")

	--装备法杖
    inst.components.equippable:SetOnEquip(function(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_lucky_staff", "swap_lucky_staff")
        --owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_purplestaff")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

local function lucky_staff()
    local inst = commonfn()

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = light_reticuletargetfn
    inst.components.reticule.ease = true

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = {255/255, 102/255, 102/255}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
    inst.components.spellcaster.canuseonpoint = true

    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, onhauntlight, true, false, true)

    return inst
end


return Prefab("lucky_staff", lucky_staff, assets, prefabs)
