local assets =
{
    Asset("ANIM", "anim/prayer_symbol.zip"),
    Asset("ATLAS", "images/prayer_symbol.xml"),
}

--使用祈运符函数
local function OnPray(inst, prayers)
	if prayers:HasTag("player") and TUNING.GAME_LEVEL>0 then
		prayers.components.lucky:DoDelta(10)
		prayers.components.sanity:DoDelta(-10)
	end
end

--祈运符燃烧函数
local function onburnt(inst)
	local ash = SpawnPrefab("lucky_ash")
    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

    if inst.components.stackable ~= nil then
        ash.components.stackable.stacksize = math.min(ash.components.stackable.maxsize, inst.components.stackable.stacksize)
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("prayer_symbol")
    inst.AnimState:SetBuild("prayer_symbol")
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
	inst.components.inventoryitem.imagename = "prayer_symbol"
	inst.components.inventoryitem.atlasname = "images/prayer_symbol.xml"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	inst.components.burnable:SetOnBurntFn(onburnt)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    --inst.OnBuiltFn = OnBuilt

    return inst
end

return Prefab("prayer_symbol", fn, assets)
