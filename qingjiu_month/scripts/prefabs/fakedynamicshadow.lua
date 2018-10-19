local function UpdatePosition(inst)
	if inst.proxy:IsValid() and Waffles.Valid(inst.target) then
		local x, y, z = inst.target.Transform:GetWorldPosition()
		inst.Transform:SetPosition(x, 0, z)
	else
		inst:CancelAllPendingTasks()
		inst:DoTaskInTime(0, inst.Remove)
	end
end

--[[local function GetDebugString(inst)
    return string.format("Target: %s, Scale: %s, %s", tostring(inst.proxy.target:value()), inst.proxy.scale_x:value(), inst.proxy.scale_y:value())
end]]

local function HookToTarget(proxy)
    local fx = CreateEntity()

    fx:AddTag("FX")
    --[[Non-networked entity]]
    fx.persists = false
	
	fx.entity:AddTransform()
	fx.entity:AddDynamicShadow()
	
	fx.Transform:SetFromProxy(proxy.GUID)

	fx.DynamicShadow:SetSize(proxy.scale_x:value() / 10, proxy.scale_y:value() / 10)
	fx.target = proxy.target:value()
	
	fx:ListenForEvent("entitysleep", fx.Remove)
	
	fx.proxy = proxy
		
	fx:DoPeriodicTask(0, UpdatePosition)
	UpdatePosition(fx)
	
	--fx.debugstringfn = GetDebugString
	--SetDebugEntity(fx)
end

local function SetTarget(inst, target, x, y)	
	inst.scale_x:set(x * 10)
	inst.scale_y:set(y * 10)
	inst.target:set(target)
	return inst	
end

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddNetwork()
	
	inst.scale_x = net_smallbyte(inst.GUID, "DynamicShadow.scale_x")
	inst.scale_y = net_smallbyte(inst.GUID, "DynamicShadow.scale_y")
	inst.target = net_entity(inst.GUID, "DynamicShadow.target", "targetdirty")
	
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("targetdirty", HookToTarget)
	end
	
	inst:AddTag("FX")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
	
	inst.SetTarget = SetTarget
	
	return inst
end

return Prefab("fakedynamicshadow", fn)