local Prayable = Class(function(self, inst) 
    self.inst = inst
    self.prayfn = nil
end)

--注入祈祷函数
function Prayable:SetPrayFn(fn)
    self.prayfn = fn
end

--开始祈祷
function Prayable:BeginPray(inst,prayers)
	if self.prayfn~=nil then
		self.prayfn(self.inst,prayers)
	end
	--消耗符文
	if inst.components.stackable ~= nil then
		inst.components.stackable:Get():Remove()
	else
		inst:Remove()
	end
end

return Prayable