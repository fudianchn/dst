local TARGET_TILE = GROUND.MODTEST


require "prefabutil"

local function ondeploy(inst, pt, deployer)
    if deployer and deployer.SoundEmitter then
        deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
    end

    local map = TheWorld.Map
    local original_tile_type = map:GetTileAtPoint(pt:Get())
    local x, y = map:GetTileCoordsAtPoint(pt:Get())
    if x and y then
        map:SetTile(x,y, inst.data.tile)
        map:RebuildLayer( original_tile_type, x, y )
        map:RebuildLayer( inst.data.tile, x, y )
    end

    local minimap = TheWorld.minimap.MiniMap
    minimap:RebuildLayer(original_tile_type, x, y)
    minimap:RebuildLayer(inst.data.tile, x, y)

    inst.components.stackable:Get():Remove()
end


local assets =
{
	Asset("ANIM", "anim/turf.zip"),
}
	
local prefabs =
{
	"gridplacer",
}


local data = {name = "turf_test", anim = "marsh", tile = TARGET_TILE}
	
local function fn(Sim)

	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst:AddTag("groundtile")
		
	inst.AnimState:SetBank("turf")
	inst.AnimState:SetBuild("turf")
	inst.AnimState:PlayAnimation(data.anim)
	
    inst:AddTag("molebait")
    MakeDragonflyBait(inst, 3)

    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
    return inst
end
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("turf_carpetfloor")
	inst.data = data
	
    inst:AddComponent("bait")
        
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)
		
        inst:AddComponent("deployable")
        --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
        inst.components.deployable.ondeploy = ondeploy
        if data.tile == "webbing" then
            inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
        else
            inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        end
        inst.components.deployable:SetUseGridPlacer(true)

	---------------------  
	return inst	  
end

return Prefab( "common/objects/turf_test", fn, assets, prefabs)
