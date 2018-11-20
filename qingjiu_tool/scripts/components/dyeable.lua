local Dyeable = Class(function(self, inst) 
    self.inst = inst
    self.dyefn = nil
end)

--注入染色函数
function Dyeable:SetDyeFn(fn)
    self.dyefn = fn
end

--开始染色
function Dyeable:BeginDye(inst,dyer)
	if self.dyefn~=nil then
		self.dyefn(self.inst,dyer)
	end
	dyer.components.inventory:GiveItem(SpawnPrefab("feather_crow"))
	--消耗羽毛
	if inst.components.stackable ~= nil then
		inst.components.stackable:Get():Remove()
	else
		inst:Remove()
	end
end

return Dyeable