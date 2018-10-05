local assets = {
    Asset("ANIM", "anim/graboid.zip"),
}

local function acceptItemTest(inst, item, giver)
    local teleport = inst.components.multiteleporter
    if teleport == nil then
        return false
    end

    if teleport:HasTargetTeleporters() then
        local rootTeleport = teleport:GetRootTeleport()
        if giver.userid == rootTeleport.components.multiteleporter.owner then
            return true
        end

        return not TheWorld.components.shared_islands:IsAllowed(giver, rootTeleport)
    else
        return true
    end
end

local function onGetItemFromPlayer(inst, giver, item)
    if inst.components.multiteleporter ~= nil and inst.sg:HasStateTag("open") then
        if inst.components.multiteleporter:SequenceAddItem(giver, item) then
            inst.sg:GoToState("agree")
        else
            inst.sg:GoToState("eating")
        end
    end
end

local function onCameraArrive(doer)
    doer:SnapCamera()
    doer:ScreenFade(true)
end

local function onDoerArrive(doer)
    if doer.sg.currentstate.name ~= "death" then
        if doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(-TheWorld.components.shared_islands.sanityDrop)
        end
    end
end

local function onDoneTeleporting(other)
    --if other.teleporting ~= nil then
    --    if other.teleporting > 1 then
    --        other.teleporting = other.teleporting - 1
    --    else
    --        other.teleporting = nil
    --        if not other.components.playerprox:IsPlayerClose() then
    --            other.sg:GoToState("closing")
    --        end
    --    end
    --end
end

local function onActivate(inst, doer, other)
    if doer:HasTag("player") then
        --ProfileStatsSet("wormhole_used", true)

        if other ~= nil then
            --DeleteCloseEntsWithTag("WORM_DANGER", other, 15)
            --other.teleporting = (other.teleporting or 0) + 1
            other:DoTaskInTime(3.5, onDoneTeleporting)
        end

        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end

        doer:SnapCamera()
        doer:DoTaskInTime(.5, onDoerArrive)
        --doer:DoTaskInTime(4, function() other.sg:GoToState("spit") end)
        --doer:DoTaskInTime(5, doer.PushEvent, "wormholespit") --for wisecracker
        --Sounds are triggered in player's stategraph
    --elseif inst.SoundEmitter ~= nil then
    --    inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
    end
end

local function onNear(inst)
    if not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function onFar(inst)
    if inst.sg:HasStateTag("open") then
        inst.sg:GoToState("closing")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.MiniMapEntity:SetIcon("graboid.tex")
    inst.MiniMapEntity:SetPriority(1)

    MakeObstaclePhysics(inst, 1.3, 1.3)

    inst.AnimState:SetBank("graboid")
    inst.AnimState:SetBuild("graboid")
    inst.AnimState:PlayAnimation("idle_closed", true)

    --inst.DynamicShadow:SetSize(4, 4)

    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(1.0, 1.0, 0.75)
    inst.Light:Enable(false)

    inst:ListenForEvent("phasechanged", function(world, phase)
        if (phase == "day" or phase == "dusk") and inst.Light:IsEnabled() then
            inst.Light:Enable(false)
        elseif phase == "night" and not inst.Light:IsEnabled() then
            inst.Light:Enable(true)
        end
    end, TheWorld)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGgraboid")

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 5)
    inst.components.playerprox.onnear = onNear
    inst.components.playerprox.onfar = onFar

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = onGetItemFromPlayer
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(acceptItemTest)
    --inst.components.trader.onrefuse = onRefuseItem

    inst:AddComponent("multiteleporter")
    inst.components.multiteleporter.onActivate = onActivate
    inst.components.multiteleporter.offset = 0

    inst:AddComponent("inventory")

    return inst
end

return Prefab("graboid", fn, assets)
