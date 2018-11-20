local assets =
{
    Asset("ANIM", "anim/seeds.zip"),
    Asset("ATLAS", "images/lucky_seed.xml"),
}
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.entity:AddNetwork()
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end


    inst.AnimState:SetBank("seeds")
    inst.AnimState:SetBuild("seeds")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.SEEDS
	inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
	
	inst:AddComponent("cookable")
    inst.components.cookable.product = "seeds_cooked"

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)--40天
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_seed"
    inst.components.inventoryitem.atlasname = "images/lucky_seed.xml"

    inst:AddComponent("plantable")
    inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.plantable.product = "lucky_fruit"

    return inst
end

return Prefab( "lucky_fruit_seeds", fn, assets)

