local assets =
{
    Asset("ANIM", "anim/transport_pill.zip"),
    Asset("ATLAS", "images/transport_pill.xml"),
}

--使用转运丸函数
local function OnPray(inst, prayers)
	if prayers:HasTag("player") and TUNING.GAME_LEVEL>0 then
		prayers.components.lucky:SetLucky(math.random(0, 100))
		prayers.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("transport_pill")
    inst.AnimState:SetBuild("transport_pill")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("symbol")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("inspectable")
	--添加可祈祷组件
	inst:AddComponent("prayable")
    inst.components.prayable:SetPrayFn(OnPray)

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "transport_pill"
	inst.components.inventoryitem.atlasname = "images/transport_pill.xml"

    MakeHauntableLaunch(inst)

    --inst.OnBuiltFn = OnBuilt

    return inst
end

return Prefab("transport_pill", fn, assets)
