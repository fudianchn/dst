local assets =
{
    Asset("ANIM", "anim/lucky_gem.zip"),
	Asset("ATLAS", "images/lucky_gem.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lucky_gem")
    inst.AnimState:SetBuild("lucky_gem")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_gem"
	inst.components.inventoryitem.atlasname = "images/lucky_gem.xml"
	
    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("lucky_gem", fn, assets)
