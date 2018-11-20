require "prefabutil"

local prefabs =
{
    "collapse_small",
}

local assets =
{
    Asset("ANIM", "anim/dyed_bucket.zip"),
}

local function OnHammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end

local function fn()
    local inst = CreateEntity()

	inst:AddTag("dyed_bucket")
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.1)

    inst.AnimState:SetBank("dyed_bucket")
    inst.AnimState:SetBuild("dyed_bucket")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
	inst.components.workable:SetOnWorkCallback(onhit) 

    inst:AddComponent("lootdropper")

	inst:ListenForEvent("onbuilt", OnBuilt)
	
    MakeHauntableWork(inst)

    return inst
end

return Prefab("dyed_bucket", fn, assets, prefabs),
    MakePlacer("dyed_bucket_placer", "dyed_bucket", "dyed_bucket", "idle")
