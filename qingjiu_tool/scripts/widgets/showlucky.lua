local Widget = require "widgets/widget" --Widget，所有widget的祖先类
local Text = require "widgets/text" --Text类，文本处理
local ShowLucky = Class(Widget, function(self,owner)
    Widget._ctor(self, "ShowLucky")
	self.owner = owner
	self.lucky = 50
	self.text = self:AddChild(Text(BODYTEXTFONT, 30,"幸运值："..self.lucky))
	self:StartUpdating()
end)

--数据更新
function ShowLucky:OnUpdate(dt)
	local ownerName=self.owner:GetDisplayName()
	local ownerLucky=self.owner.replica.lucky.currentLucky:value()
	self.text:SetString(string.format("%s的幸运值：%d",ownerName,ownerLucky))
end

return ShowLucky