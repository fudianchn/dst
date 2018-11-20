local assets =
{
    Asset("ANIM", "anim/lucky_juice.zip"),
    Asset("ATLAS", "images/lucky_juice.xml"),
}

local prefabs = 
{
	"lucky_ash",
}

local function eatfn(inst,eater)
	if eater:HasTag("player") and TUNING.GAME_LEVEL>0 then
		if eater.components~=nil and eater.components.lucky~=nil  then
			eater.components.lucky:DoDelta(15)
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

	inst:AddTag("preparedfood")
	
    inst.entity:AddNetwork()
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end


    inst.AnimState:SetBank("lucky_juice")
    inst.AnimState:SetBuild("lucky_juice")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
	inst.components.edible.healthvalue = 5
	inst.components.edible.sanityvalue = 30
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
	inst.components.edible:SetOnEatenFn(eatfn)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_TWO_DAY)--2天
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "lucky_ash"

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "lucky_juice"
    inst.components.inventoryitem.atlasname = "images/lucky_juice.xml"

    return inst
end

return Prefab( "lucky_juice", fn, assets, prefabs)

