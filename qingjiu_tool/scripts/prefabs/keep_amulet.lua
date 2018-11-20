local assets =
{
    Asset("ANIM", "anim/keep_amulet.zip"),
    Asset("ANIM", "anim/torso_keep_amulet.zip"),
	Asset("ATLAS", "images/keep_amulet.xml"),
}

--装备保运护符函数
local function onequip_keep(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_keep_amulet", "keep_amulet")
    inst.onitembuild = function()
		local rest_use=inst.components.finiteuses:GetUses()--剩余使用次数
		local offset_lucky=TUNING.GAME_LEVEL--抵消幸运值
		if TUNING.GAME_LEVEL>rest_use then
			offset_lucky=rest_use
		end
		owner.components.lucky:DoDelta(offset_lucky)--抵消扣除的幸运值
        inst.components.finiteuses:Use(TUNING.GAME_LEVEL)
    end
    inst:ListenForEvent("luckyminus", inst.onitembuild, owner)
	--owner.components.lucky:DoAuraDelta(0.05)--添加精神光环
end

--卸下保运护符函数
local function onunequip_keep(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("luckyminus", inst.onitembuild, owner)
	--owner.components.lucky:DoAuraDelta(-0.05)--添加精神光环
end

--初始化
local function commonfn(anim, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("keep_amulet")
    inst.AnimState:SetBuild("keep_amulet")
    inst.AnimState:PlayAnimation(anim)

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.foleysound = "dontstarve/movement/foley/jewlery"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "keep_amulet"
	inst.components.inventoryitem.atlasname = "images/keep_amulet.xml"

    return inst
end

--定义保运护符
local function keep()
    local inst = commonfn("keep_amulet")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(onequip_keep)
    inst.components.equippable:SetOnUnequip(onunequip_keep)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("keep_amulet", keep, assets)
