assets =
{
    Asset("ANIM", "anim/lucky_hat.zip"),
    Asset("IMAGE", "images/lucky_hat.tex"),
    Asset("ATLAS", "images/lucky_hat.xml")
}
prefabs =
{
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "lucky_hat", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
	if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
	if owner.components then
		if owner.components.lucky then
			owner.components.lucky:DoAuraDelta(0.05)--添加幸运光环
		end
	end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
	if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
	if owner.components then
		if owner.components.lucky then
			owner.components.lucky:DoAuraDelta(-0.05)--除去幸运光环
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)


    inst.AnimState:SetBank("lucky_hat")
    inst.AnimState:SetBuild("lucky_hat")
    inst.AnimState:PlayAnimation("anim")


    inst.entity:AddNetwork()
    inst.entity:SetPristine()
	
	inst:AddTag("lucky_hat")
	
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_hat"
    inst.components.inventoryitem.atlasname = "images/lucky_hat.xml"

	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE--回脑残
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

	--保暖240秒
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(240)
	
	--10天耐久
	inst:AddComponent("fueled")
    --inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME*10)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	
	--inst:AddComponent("repairable")


    return inst
end


return Prefab( "lucky_hat", fn, assets, prefabs)