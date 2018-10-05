require "prefabutil"

local assets = {
    Asset("ANIM", "anim/dynamite.zip"),
    --Asset("SOUND", "sound/spider.fsb"),
    Asset("ATLAS", "images/shared_islands_inventory.xml"),
    Asset("IMAGE", "images/shared_islands_inventory.tex")
}

local deps = {
    "graboid",
    "explode_small"
}

--local function OnIgniteFn(inst)
--    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
--end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    local graboid = SpawnPrefab("graboid")
    if graboid ~= nil then
        graboid.Transform:SetPosition(inst.Transform:GetWorldPosition())
        graboid.sg:GoToState("emerge")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(0.85, 0.85, 0.85)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dynamite")
    inst.AnimState:SetBuild("dynamite")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, 3 + math.random() * 3)
    MakeSmallPropagator(inst)
    --V2C: Remove default OnBurnt handler, as it conflicts with
    --explosive component's OnBurnt handler for removing itself
    inst.components.burnable:SetOnBurntFn(nil)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    --inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dynamite"
    inst.components.inventoryitem.atlasname = "images/shared_islands_inventory.xml"
    inst.components.inventoryitem:SetOnDroppedFn(function (inst)
        local tile_x, tile_y = TheWorld.Map:GetTileCoordsAtPoint(inst.Transform:GetWorldPosition())

        -- Is near water?
        for x = tile_x - 1, tile_x + 1 do
            for y = tile_y - 1, tile_y + 1 do
                if TheWorld.Map:GetTile(x, y) == GROUND.IMPASSABLE then
                    inst:AddTag("fireimmune")
                    return
                end
            end
        end

        if inst:HasTag("fireimmune") then
            inst:RemoveTag("fireimmune")
        end
    end)

    --MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("dynamite", fn, assets, deps)
