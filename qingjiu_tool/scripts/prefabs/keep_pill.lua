local assets =
{
    Asset("ANIM", "anim/keep_pill.zip"),
    Asset("ATLAS", "images/keep_pill.xml"),
}

--使用保运丸函数
local function OnPray(inst, prayers)
	if prayers:HasTag("player") then
		prayers.components.lucky:SetLucky(50)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("keep_pill")
    inst.AnimState:SetBuild("keep_pill")
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
	inst.components.inventoryitem.imagename = "keep_pill"
	inst.components.inventoryitem.atlasname = "images/keep_pill.xml"

    MakeHauntableLaunch(inst)

    --inst.OnBuiltFn = OnBuilt

    return inst
end

return Prefab("keep_pill", fn, assets)
