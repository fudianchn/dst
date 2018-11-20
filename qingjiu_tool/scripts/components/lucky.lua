--更新网络变量
local function oncurrent(self,current)
	if self.inst.replica.lucky then
		self.inst.replica.lucky.currentLucky:set(current)
	end
end
local function onfirst(self,firstpickup)
	if self.inst.replica.lucky then
		self.inst.replica.lucky.isFirstPickup:set(firstpickup)
	end
end
local function onaura(self,luckyaura)
	if self.inst.replica.lucky then
		self.inst.replica.lucky.currentAura:set(luckyaura)
	end
end

--定义幸运值
local Lucky = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = 50
	self.firstpickup=1
	self.luckyaura=0
end,
nil,
{
    current = oncurrent,
	firstpickup=onfirst,
	luckyaura=onaura
})
--查看幸运值
function Lucky:getLucky()
	return self.inst.replica.lucky.currentLucky:value() or self.current
end
--判断是否是第一次开风滚草
function Lucky:isFirst()
	return self.inst.replica.lucky.isFirstPickup:value() or self.firstpickup
end
--查看幸运光环增值
function Lucky:getAura()
	return self.inst.replica.lucky.currentAura:value() or self.luckyaura
end
--保存幸运值
function Lucky:OnSave()
    local data = {
        current = self.current,
		firstpickup=self.firstpickup,
    }
    return data
end
--加载幸运值
function Lucky:OnLoad(data)
    self.current = data.current or 50
	self.firstpickup=data.firstpickup or 1
	self:DoDelta(0)
end
--计算幸运值
function Lucky:DoDelta(delta)
    self.current = math.clamp(self.current + delta, 0, self.max)
    return self.current
end
--设置幸运值
function Lucky:SetLucky(delta)
	self.current=math.clamp(delta, 0, self.max)
	return self.current
end
--开风滚草时扣除幸运值
function Lucky:DoMinus(delta)
    self.current = math.clamp(self.current + delta, 0, self.max)
	self.inst:PushEvent("luckyminus")
    return self.current
end
--第一次开启风滚草后进行标记
function Lucky:DoFirst()
	self.firstpickup=0
	return self.firstpickup
end
--计算幸运光环增值
function Lucky:DoAuraDelta(delta)
    self.luckyaura = self.luckyaura + delta
	self.inst:PushEvent("luckyaurachange")
    return self.luckyaura
end
--获取幸运光环
function Lucky:GetLuckyAura()
	local luckyGrowthValue=self.luckyaura--每秒增加的幸运值
	self.addTask = self.inst:DoPeriodicTask(1,function()
        self:DoDelta(luckyGrowthValue)
    end)
	return true
end
--取消幸运光环
function Lucky:RemoveLuckyAura()
	if self.addTask then
        self.addTask:Cancel()
        self.addTask=nil
    end
end
--幸运光环监控
function Lucky:auraListen()
	self.inst:ListenForEvent("luckyaurachange", function()
		if self.luckyaura ~= 0 then
			self:RemoveLuckyAura()
			self:GetLuckyAura()
		else
			self:RemoveLuckyAura()
		end
	end)
end

return Lucky