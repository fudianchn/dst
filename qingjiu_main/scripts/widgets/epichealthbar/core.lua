local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local theme = require "widgets/epichealthbar/theme"

local ProgressBar = Class(Widget, function(self, font, font_size)
    Widget._ctor(self, "ProgressBar")
    self.owner = ThePlayer

    self.scale = 0.94
    self.flick_scale = self.scale + 0.05
    self:SetScale(self.scale)

    self:SetPosition(0, 39.5 * self.scale, 0)
    self:SetClickable(false)

    --------------------------------------------------------------------------

    self.width = 475
    self.height = 28

    self.blood_bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    self.blood_bg:ScaleToSize(self.width, self.height)
    self.blood_bg:SetTint(1, 1, 1, 0.55)
    self.blood_bg:SetBlendMode(1)

    self.blood = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    self.blood:ScaleToSize(self.width, self.height)
    self.blood:SetBlendMode(1)

    self.flames = self:AddChild(Widget("flames"))
    for k = 1, 4 do
        local flame = self.flames:AddChild(UIAnim())
        flame:SetScale(0.11)
        flame:SetPosition(180 + -101 * k, 58, 0)

        local anim = flame:GetAnimState()
        anim:SetBank("fire_over")
        anim:SetBuild("fire_over")
        anim:OverrideSymbol("fire_over01", "fire_over", "dummy")
        anim:PlayAnimation("anim", true)
        anim:SetMultColour(0, 0, 0, 0.25)
    end
    self.flames:Hide()

    self.blood_empty = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    self.blood_empty:ScaleToSize(self.width, self.height)
    self.blood_empty:SetTint(1, 1, 1, 0.55)
    self.blood_empty:SetBlendMode(1)

    self.frame = self:AddChild(Image("images/ui/boss_hb.xml", "boss_hb.tex"))
    self.frame:SetPosition(-1, -8.2, 0)

    --------------------------------------------------------------------------

    self.name = self:AddChild(Text(font, font_size, ""))
    self.name:SetHAlign(ANCHOR_MIDDLE)

    self.percent = self:AddChild(Text(font, font_size - 8, ""))
    self.percent:SetHAlign(ANCHOR_MIDDLE)
    self.percent:SetPosition(0, -font_size, 0)

    self.hp_act = self:AddChild(Text(font, font_size - 8, ""))
    self.hp_act:SetHAlign(ANCHOR_LEFT)
    self.hp_act:SetPosition(-231.2, -1.2, 0)
    self.hp_act.pt = self.hp_act:GetPosition()

    self.hp_max = self:AddChild(Text(font, font_size - 8, ""))
    self.hp_max:SetHAlign(ANCHOR_RIGHT)
    self.hp_max:SetPosition(232.6, -1.2, 0)
    self.hp_max.pt = self.hp_max:GetPosition()
end)

--------------------------------------------------------------------------
function ProgressBar:UpdateBlood(percent)
    local width = self.width * percent
    for _, v in pairs({ "blood_bg", "blood" }) do
        self[v]:ScaleToSize(width, self.height)
        self[v]:SetPosition((width - self.width) / 2, 0, 0)
    end

    width = self.width * (1 - percent)
    self.blood_empty:ScaleToSize(width, self.height)
    self.blood_empty:SetPosition((self.width - width) / 2, 0, 0)
end

function ProgressBar:SetHealth(value, left)
    local hp = "hp_" .. (left and "act" or "max")
    self[hp]:SetString(math.floor(value + .5))
    local offset = self[hp]:GetRegionSize() * (left and 0.5 or -0.5)

    local pt = self[hp].pt
    self[hp]:SetPosition(pt.x + offset, pt.y, pt.z)
end

function ProgressBar:SetPercent(percent)
    self.percent:SetString(subfmt("[{percent}%]", { percent = math.floor(percent * 100 + 0.5) }))
end

function ProgressBar:UpdateValues(act, max)
    local percent = act / max
    self:UpdateBlood(percent)

    self:SetHealth(act, true)
    self:SetHealth(max)
    self:SetPercent(percent)
end

function ProgressBar:SetTheme(color)
    self.blood:SetTint(color.r, color.g, color.b, 0.8)
end

function ProgressBar:SetName(text)
    self.name:SetString(text)
end

function ProgressBar:PushFlames(value)
    if value >= 10000 then
        self.flames:Show()
    else
        self.flames:Hide()
    end
end

function ProgressBar:SetData(ent, hp)
    self:UpdateValues(hp.act, hp.max)

    local t = IsAnySpecialEventActive() and theme[WORLD_SPECIAL_EVENT]
    self:SetTheme(t and t[ent.prefab]
            or theme.none[ent.prefab]
            or theme.none.generic)

    self:SetName(ent:GetBasicDisplayName())
    self:PushFlames(hp.max)
end

local function PullEventAnnouncer(val)
    if ThePlayer ~= nil and ThePlayer.HUD ~= nil and ThePlayer.HUD.eventannouncer ~= nil then
        local announcer = ThePlayer.HUD.eventannouncer
        announcer:MoveTo(announcer:GetPosition(), { x = 0, y = val or 0, z = 0 }, 0.5)
    end
end

function ProgressBar:Appear()
    if self.expanded then return end
    self.expanded = true

    self:Show()
    self:MoveTo(self:GetPosition(), { x = 0, y = -35.5 * self.scale, z = 0 }, 0.5)
    PullEventAnnouncer(-55)
end

function ProgressBar:Disappear()
    if not self.expanded then return end
    self.expanded = false

    self:MoveTo(self:GetPosition(), { x = 0, y = 39.5 * self.scale, z = 0 }, 0.5, function() if not self.expanded then self:Hide() end end)
    PullEventAnnouncer()
end

function ProgressBar:DoFlick()
    if not self.expanded then return end

    self:ScaleTo(self.scale, self.flick_scale, 0.1, function() self:ScaleTo(self.flick_scale, self.scale, 0.1) end)
end

function ProgressBar:OnHide()
    self:StopUpdating()
end

return ProgressBar