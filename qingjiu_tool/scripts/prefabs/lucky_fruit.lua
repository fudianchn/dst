local assets =
{
    Asset("ANIM", "anim/lucky_fruit.zip"),
    Asset("ATLAS", "images/lucky_fruit.xml"),
}
local function eatfn(inst,eater)
	if eater:HasTag("player") and TUNING.GAME_LEVEL>0 then
		if eater.components~=nil and eater.components.lucky~=nil  then
			eater.components.lucky:DoDelta(-5)
		end
	end
end

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


    inst.AnimState:SetBank("lucky_fruit")
    inst.AnimState:SetBuild("lucky_fruit")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
	inst.components.edible.healthvalue = 20
	inst.components.edible.sanityvalue = -10
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible:SetOnEatenFn(eatfn)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)--20天
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_fruit"
    inst.components.inventoryitem.atlasname = "images/lucky_fruit.xml"

    return inst
end

return Prefab( "lucky_fruit", fn, assets)

