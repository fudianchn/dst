require "prefabutil"

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function makeobstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local anims = {


    { threshold = 0, anim = "broken" },
    { threshold = 0.4, anim = "onequarter" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "threequarter" },
    { threshold = 1, anim = {"fullA", "fullB", "fullC"} },
}

local function resolveanimtoplay(inst, percent)
    for i,v in ipairs(anims) do
        if percent <= v.threshold then
            if type(v.anim) == "table" then
                -- get a stable animation, by basing it on world position
                local x,y,z = inst.Transform:GetWorldPosition()
                local x = math.floor(x)
                local z = math.floor(z)


                local t = ( ((x%4)*(x+3)%7) + ((z%4)*(z+3)%7) )% #v.anim + 1
                return v.anim[t]
            else
                return v.anim
            end
        end
    end
end

local function onhealthchange(inst, old_percent, new_percent)
    if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
    if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

    local anim_to_play = resolveanimtoplay(inst, new_percent)
    if new_percent > 0 then



        inst.AnimState:PlayAnimation(anim_to_play.."_hit")      
        inst.AnimState:PushAnimation(anim_to_play, false)       
    else



        inst.AnimState:PlayAnimation(anim_to_play)      
    end
end





local function onload(inst)
    --print("walls - onload")
    if inst.components.health:IsDead() then
        clearobstacle(inst)
    end
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

function MakeLivingWallType(data)


    local assets =
    {
        Asset("ANIM", "anim/wall.zip"),
        Asset("ANIM", "anim/wall_".. data.name..".zip"),
    }

    local prefabs =
    {
        "collapse_small",

    }

    local function ondeploywall(inst, pt, deployer)
        --inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
        local livingwall = SpawnPrefab("wall_"..data.name) 
        if livingwall ~= nil then 
            pt = Vector3(math.floor(pt.x) + .5, 0, math.floor(pt.z) + .5)


            livingwall.Physics:SetCollides(false)
            livingwall.Physics:Teleport(pt:Get())
            livingwall.Physics:SetCollides(true)
            inst.components.stackable:Get():Remove()

            TheWorld.Pathfinder:AddWall(pt:Get())
        end
    end

    local function onhammered(inst, worker)
        if data.maxloots and data.loot then
            local num_loots = math.max(1, math.floor(data.maxloots*inst.components.health:GetPercent()))
            for k = 1, num_loots do
                inst.components.lootdropper:SpawnLootPrefab(data.loot)
            end
        end

        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

        if data.destroysound then
            inst.SoundEmitter:PlaySound(data.destroysound)




        end

        inst:Remove()
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag("wallbuilder")

        inst.AnimState:SetBank("wall")
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("idle")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
		
		inst.components.inventoryitem.imagename = "wall_"..data.name.."_item"
		inst.components.inventoryitem.atlasname = "images/wall_"..data.name.."_item.xml"
		
        inst:AddComponent("repairer")

        if data.name == "living" then
		    inst.components.repairer.repairmaterial = MATERIALS.THULECITE
        else
		    inst.components.repairer.repairmaterial = data.name
        end











        if data.paintable then
            --inst:AddComponent("paintable")
        end

        inst.components.repairer.healthrepairvalue = data.maxhealth / 6











        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploywall
        inst.components.deployable:SetDeployMode(DEPLOYMODE.WALL)
		
        MakeHauntableLaunch(inst)

        return inst
    end

    local function onhit(inst)
        if data.destroysound then

            inst.SoundEmitter:PlaySound(data.destroysound)
        end

        local healthpercent = inst.components.health:GetPercent()
        local anim_to_play = resolveanimtoplay(inst, healthpercent)
        if healthpercent > 0 then

            inst.AnimState:PlayAnimation(anim_to_play.."_hit")
            inst.AnimState:PushAnimation(anim_to_play, false)
        end
    end

    local function onrepaired(inst)
        if data.buildsound then
            inst.SoundEmitter:PlaySound(data.buildsound)
        end
        makeobstacle(inst)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

        MakeObstaclePhysics(inst, .5)
        inst.Physics:SetDontRemoveOnSleep(true)

        --inst.Transform:SetScale(1.3,1.3,1.3)

        inst:AddTag("wall")


        inst.AnimState:SetBank("wall")
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("fullA", false)

        for i, v in ipairs(data.tags) do
            inst:AddTag(v)
        end

        MakeSnowCoveredPristine(inst)
		inst:AddTag("scarytoprey")

        inst._pfpos = nil
        inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
        makeobstacle(inst)
        --Delay this because makeobstacle sets pathfinding on by default
        --but we don't to handle it until after our position is set
        inst:DoTaskInTime(0, InitializePathFinding)

        inst.OnRemoveEntity = onremove

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("repairable")
        if data.name == "living" then
		    inst.components.repairable.repairmaterial = MATERIALS.THULECITE		-- Same hax as above
        else
		    inst.components.repairable.repairmaterial = data.name
        end









        inst.components.repairable.onrepaired = onrepaired

        inst:AddComponent("combat")

        inst.components.combat.onhitfn = onhit

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.maxhealth)
        inst.components.health:SetCurrentHealth(data.maxhealth / 2)
        inst.components.health.ondelta = onhealthchange
        inst.components.health.nofadeout = true
        inst.components.health.canheal = false
        inst:AddTag("noauradamage")
		inst.components.health.fire_damage_scale = 0




        if data.buildsound then
            inst.SoundEmitter:PlaySound(data.buildsound)        







        end




        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit) 

        MakeHauntableWork(inst)

        inst.OnLoad = onload

        inst:DoTaskInTime(0, function()
            inst.AnimState:PlayAnimation(resolveanimtoplay(inst, inst.components.health:GetPercent()))
        end)

        MakeSnowCovered(inst)

        return inst
    end

    return Prefab("common/wall_"..data.name, fn, assets, prefabs),
           Prefab("common/wall_"..data.name.."_item", itemfn, assets, {"wall_"..data.name, "wall_"..data.name.."_item_placer", "collapse_small"}),
           MakePlacer("common/wall_"..data.name.."_item_placer", "wall", "wall_"..data.name, "half", false, false, true, nil, nil, "eight")
end

local livingwallprefabs = {}

local livingwalldata =
{
	{name = "living", tags={"living", "tentacle"}, loot = "tentaclespots", maxloots = 2, maxhealth=700, buildsound="dontstarve/common/place_structure_wood", destroysound="dontstarve/common/destroy_wood"}
}

for k,v in pairs(livingwalldata) do
    local livingwall, item, placer = MakeLivingWallType(v)
    table.insert(livingwallprefabs, livingwall)
    table.insert(livingwallprefabs, item)
    table.insert(livingwallprefabs, placer)
end

return unpack(livingwallprefabs)
