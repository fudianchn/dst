local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
		
	inst:AddTag("FX")
	
	if not TheNet:IsDedicated() then		
		inst:DoTaskInTime(0, function()
			local x, y, z = inst.Transform:GetWorldPosition()
			for k = 1, math.random(15, 25) do				
				inst:DoTaskInTime(k * math.random() * 0.02, function()
					SpawnPrefab("explode_particle"):StartFX("torchfire_rag", x, y, z)
				end)
			end
		end)
	end
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	
	inst:DoTaskInTime(5, inst.Remove)
			
	return inst
end

local function StartFX(inst, prefab, x, y, z, speedmult)
	local emitter = inst:SpawnChild(prefab)
    if emitter.SoundEmitter ~= nil then
		emitter.SoundEmitter:SetMute(true)
	end
	if emitter.Light ~= nil then
		emitter.Light:SetRadius(math.random() * 0.3)
	end
	
	local turn = math.random() > 0.5 and 1 or -1
	local rnd = math.random() * turn
	inst.Physics:Teleport(x + rnd, y + math.random(), z - rnd)

	local speed = (2 + math.random()) * math.random() * (speedmult or 6)
	local angle = math.random() * 2 * PI
	x = speed * math.cos(angle)
	y = speed * 3
	z = -speed * math.sin(angle)
	
	inst.Physics:SetVel(x, y, z)
	
	inst:DoTaskInTime(math.random() * 2, inst.Remove)
end

local function particle()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	
	local phys = inst.entity:AddPhysics()
	phys:SetMass(1)
	phys:SetFriction(.1)
	phys:SetDamping(0)
	phys:SetRestitution(.5)
	phys:SetCollisionGroup(COLLISION.ITEMS)
	phys:ClearCollisionMask()
	phys:CollidesWith(COLLISION.WORLD)
	phys:CollidesWith(COLLISION.OBSTACLES)
	phys:CollidesWith(COLLISION.SMALLOBSTACLES)
	phys:SetSphere(0)
		
	inst:AddTag("FX")
	
	inst.persists = false
	
	inst.StartFX = StartFX
	
	inst:DoTaskInTime(5, inst.Remove)
			
	return inst
end

return Prefab("explode_rain", fn),
	Prefab("explode_particle", particle)