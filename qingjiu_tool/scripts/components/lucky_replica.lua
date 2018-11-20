--定义幸运值
local Lucky = Class(function(self, inst)
    self.inst = inst
	self.currentLucky=net_shortint(inst.GUID,"currentLucky")
	self.isFirstPickup=net_shortint(inst.GUID,"isFirstPickup")
	self.currentAura=net_shortint(inst.GUID,"currentAura")
end)
--查看幸运值
function Lucky:getLucky()
	return self.currentLucky:value()
end
--判断是否是第一次开风滚草
function Lucky:isFirst()
	return self.isFirstPickup:value()
end
--查看幸运光环增值
function Lucky:getAura()
	return self.currentAura:value()
end

return Lucky