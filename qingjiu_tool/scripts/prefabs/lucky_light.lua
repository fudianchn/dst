local PULSE_SYNC_PERIOD = 30--脉冲同步周期

--Needs to save/load time alive.

local function kill_sound(inst)
    inst.SoundEmitter:KillSound("staff_star_loop")
end

local function kill_light(inst)
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover", kill_sound)
    inst:DoTaskInTime(1, inst.Remove) --originally 0.6, padded for network
    inst.persists = false
    inst._killed = true
	--熄灭后掉落幸运道具
	inst.components.lootdropper:DropLoot()
end

local function ontimer(inst, data)
    if data.name == "extinguish" then
        kill_light(inst)
    end
end

local function onpulsetimedirty(inst)
    inst._pulseoffs = inst._pulsetime:value() - inst:GetTimeAlive()
end

local function pulse_light(inst)
    local timealive = inst:GetTimeAlive()--获取存在时间

    if inst._ismastersim then--主机判断
        if timealive - inst._lastpulsesync > PULSE_SYNC_PERIOD then
            inst._pulsetime:set(timealive)
            inst._lastpulsesync = timealive
        else
            inst._pulsetime:set_local(timealive)
        end

        inst.Light:Enable(true)
    end

    --Client light modulation is enabled:

    --local s = GetSineVal(0.05, true, inst)
    local s = math.abs(math.sin(PI * (timealive + inst._pulseoffs) * 0.05))
    local rad = Lerp(11, 12, s)
    local intentsity = Lerp(0.8, 0.7, s)
    local falloff = Lerp(0.8, 0.7, s) 
    inst.Light:SetFalloff(falloff)
    inst.Light:SetIntensity(intentsity)
    inst.Light:SetRadius(rad)
end

local function onhaunt(inst)
    if inst.components.timer:TimerExists("extinguish") then
        inst.components.timer:StopTimer("extinguish")
        kill_light(inst)
    end
    return true
end

--幸运光环
local function luckyaura(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	--print("幸运之星坐标："..x..","..y..","..z)
	local ents = TheSim:FindEntities(x, y, z, 10)
	for i,v in ipairs(ents) do
		if v:HasTag("player") then
			--print(v:GetDisplayName())
			if v.components.lucky then
				local vx,vy,vz=v.Transform:GetWorldPosition()
				local auraRange=10-math.sqrt(math.pow((vx-x),2)+math.pow((vy-y),2))
				local auraWeight=(auraRange>8 and 0.2) or
								 (auraRange>4 and 0.1) or
								 (auraRange>0 and 0.05) or
								 0
				--print("增加的幸运值："..auraWeight)
				v.components.lucky:DoDelta(auraWeight)
			end
		end
	end
end

local function makestafflight(name,  anim, colour, idles)
    local assets =
    {
        Asset("ANIM", "anim/"..anim..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        inst._ismastersim = TheWorld.ismastersim
        inst._pulseoffs = 0
        inst._pulsetime = net_float(inst.GUID, "_pulsetime", "pulsetimedirty")

        inst:DoPeriodicTask(.1, pulse_light)--更新光动画

        inst.Light:SetColour(unpack(colour))--设置光的颜色
        inst.Light:Enable(false)
        inst.Light:EnableClientModulation(true)--启动客户端调制

        inst.AnimState:SetBank(anim)
        inst.AnimState:SetBuild(anim)
        inst.AnimState:PlayAnimation("appear")
        inst.AnimState:PushAnimation(idles[1], true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        --HASHEATER (from heater component) added to pristine state for optimization
        inst:AddTag("HASHEATER")
		inst:AddTag("lucky_light")
        
        MakeInventoryPhysics(inst)

        inst.no_wet_prefix = true

        inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_LP", "staff_star_loop")

        inst.entity:SetPristine()

		--如果不是主机，监听网络变量，初始化结束。
        if not inst._ismastersim then
            inst:ListenForEvent("pulsetimedirty", onpulsetimedirty)
            return inst
        end

        inst._pulsetime:set(inst:GetTimeAlive())--给网络变量赋值为存在时间
        inst._lastpulsesync = inst._pulsetime:value()--最后的脉冲同步

		--冬暖夏凉
        inst:AddComponent("heater")
        if TheWorld.state.iswinter then
            inst.components.heater.heat = 100
        elseif TheWorld.state.issummer then
            inst.components.heater.heat = -100
            inst.components.heater:SetThermics(false, true)
        end
		
		--掉落物
		inst:AddComponent("lootdropper")
		inst.components.lootdropper:AddRandomLoot("prayer_symbol", 0.2)--祈运符
		inst.components.lootdropper:AddRandomLoot("lucky_gem", 0.05)--幸运宝石
		inst.components.lootdropper:AddRandomLoot("keep_amulet", 0.02)--幸运护符
		inst.components.lootdropper:AddRandomLoot("dyed_bucket_blueprint", 0.1)--染色桶蓝图
		inst.components.lootdropper:AddRandomLoot("lucky_ash", 1)--幸运粉尘
		inst.components.lootdropper:AddRandomLoot("keep_pill", 0.1)--保运丸
		inst.components.lootdropper:AddRandomLoot("transport_pill", 0.1)--转运丸
		inst.components.lootdropper:AddRandomLoot("lucky_staff", 0.02)--幸运法杖
		inst.components.lootdropper:AddRandomLoot("lucky_hat", 0.01)--幸运帽
		inst.components.lootdropper:AddRandomLoot("lucky_fruit_seeds", 0.2)--幸运种子
		inst.components.lootdropper:AddRandomLoot("lucky_hat_blueprint", 0.05)--幸运帽蓝图
		inst.components.lootdropper:AddRandomLoot("lucky_fruit_seeds", 0.1)--幸运帽蓝图
		inst.components.lootdropper.numrandomloot = 1
		
		--幸运光环
		inst:DoPeriodicTask(1,luckyaura)

        --inst:AddComponent("sanityaura")--精神光环
        --inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL--半天回100的速度

        inst:AddComponent("inspectable")--可检查的

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
        inst.components.hauntable:SetOnHauntFn(onhaunt)

        inst:AddComponent("timer")--定时器
        inst.components.timer:StartTimer("extinguish", TUNING.TOTAL_DAY_TIME*0.5)--持续半天
        inst:ListenForEvent("timerdone", ontimer)
        inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_create")

        return inst
    end

    return Prefab(name, fn, assets)
end

return makestafflight("lucky_light", "lucky_light", { 255 / 255, 102 / 255, 102 / 255 }, { "idle_loop" })
