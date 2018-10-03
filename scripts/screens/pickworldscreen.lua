local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

local function onclose(inst)
    if not inst.isopen then
        return
    end
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
    inst.owner.HUD:CloseWorldPickerScreen()
end

local function onaccept(inst)
    SendModRPCToServer(MOD_RPC["multiworldpicker"]["worldpickermigrateRPC"])
    onclose(inst)
end

local function onnextdest(inst)
    SendModRPCToServer(MOD_RPC["multiworldpicker"]["worldpickerdestRPC"])
end

local function onprevdest(inst)
    SendModRPCToServer(MOD_RPC["multiworldpicker"]["worldpickerdestRPC"], true)
end

local function activateImgBtn(btn, down)
    if down then
        if not btn.down then
            if btn.has_image_down then
                btn.image:SetTexture(btn.atlas, btn.image_down)

                if btn.size_x and btn.size_y then
                    btn.image:ScaleToSize(btn.size_x, btn.size_y)
                end
            end
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            btn.o_pos = btn:GetLocalPosition()
            if btn.move_on_click then
                btn:SetPosition(btn.o_pos + btn.clickoffset)
            end
            btn.down = true
            if btn.whiledown then
                btn:StartUpdating()
            end
            if btn.ondown then
                btn.ondown()
            end
        end
    else
        if btn.down then
            if btn.has_image_down then
                btn.image:SetTexture(btn.atlas, btn.image_focus)

                if btn.size_x and btn.size_y then
                    btn.image:ScaleToSize(btn.size_x, btn.size_y)
                end
            end
            btn.down = false
            btn:ResetPreClickPosition()
            if btn.onclick then
                btn.onclick()
            end
            btn:OnLoseFocus()
            btn:StopUpdating()
        end
    end
end

local PickWorldScreen =
Class(Screen,
    function(self, owner, str_dest, str_count)
        Screen._ctor(self, "WorldPicker")
        self.owner = owner
        self.isopen = false
        self.controller_mode = TheInput:ControllerAttached()
        self._scrnw, self._scrnh = TheSim:GetScreenSize()
        self:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self:SetMaxPropUpscale(MAX_HUD_SCALE)
        self:SetPosition(0, 0, 0)
        self:SetVAnchor(ANCHOR_MIDDLE)
        self:SetHAnchor(ANCHOR_MIDDLE)
        self.scalingroot = self:AddChild(Widget("worldpickerscalingroot"))
        self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
        self.inst:ListenForEvent("continuefrompause",
            function()
                if self.isopen then
                    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
                end
            end,
            TheWorld)
        self.inst:ListenForEvent("refreshhudsize",
            function(hud, scale)
                if self.isopen then
                    self.scalingroot:SetScale(scale)
                end
            end,
            owner.HUD.inst)

        self.root = self.scalingroot:AddChild(Widget("worldpickerroot"))
        self.root:SetScale(1, 1, 1)
        self.root:SetPosition(0, 180, 0)

        --屏幕填充
        self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
        self.black:SetVRegPoint(ANCHOR_MIDDLE)
        self.black:SetHRegPoint(ANCHOR_MIDDLE)
        self.black:SetVAnchor(ANCHOR_MIDDLE)
        self.black:SetHAnchor(ANCHOR_MIDDLE)
        self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
        self.black:SetTint(0, 0, 0, 0)
        self.black.OnMouseButton = function()
            onclose(self)
            -- return true
        end

        self.bg = self.root:AddChild(Image("images/wpicker.xml", "wpicker_bg_board.tex"))
        self.bg:SetScale(1, 1, 1)

        self.title = self.root:AddChild(Text(HEADERFONT, 28, STRINGS.MWP.SELECT_WORLD))
        self.title:SetPosition(0, 70, 0)

        self.dest = self.root:AddChild(Text(NEWFONT_OUTLINE, 35, ""))
        self.dest:SetPosition(0, 24, 0)

        self.btn_prev =
        self.root:AddChild(ImageButton("images/global_redux.xml",
            "arrow2_left.tex",
            "arrow2_left_over.tex",
            nil,
            "arrow2_left_down.tex",
            nil,
            { 1, 1 },
            { 0, 55 }))
        self.btn_prev:SetTextSize(28)
        if self.controller_mode then
            self.btn_prev:SetText(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SCROLLBACK), false)
        end
        self.btn_prev:SetScale(0.65, 0.65, 0.65)
        self.btn_prev:SetPosition(-155, -15, 0)
        self.btn_prev:SetOnClick(function()
            onprevdest(self)
        end)

        self.btn_next =
        self.root:AddChild(ImageButton("images/global_redux.xml",
            "arrow2_right.tex",
            "arrow2_right_over.tex",
            nil,
            "arrow2_right_down.tex",
            nil,
            { 1, 1 },
            { 0, 55 }))
        self.btn_next:SetTextSize(28)
        if self.controller_mode then
            self.btn_next:SetText(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SCROLLFWD), false)
        end
        self.btn_next:SetScale(0.65, 0.65, 0.65)
        self.btn_next:SetPosition(155, -15, 0)
        self.btn_next:SetOnClick(function()
            onnextdest(self)
        end)

        self.count = self.root:AddChild(Text(NEWFONT_OUTLINE, 23, ""))
        self.count:SetPosition(0, -20, 0)

        self.btn_go =
        self.root:AddChild(ImageButton("images/wpicker.xml",
            "wpicker-button-area.tex",
            "wpicker-button-area-hover.tex",
            nil,
            "wpicker-button-area-pressed.tex",
            nil,
            { 1, 1 },
            { 0, -3 }))
        self.btn_go:SetTextColour(UICOLOURS.GOLD)
        self.btn_go:SetTextFocusColour(PORTAL_TEXT_COLOUR)
        self.btn_go:SetFont(NEWFONT_OUTLINE)
        self.btn_go:SetDisabledFont(NEWFONT_OUTLINE)
        self.btn_go:SetTextDisabledColour(UICOLOURS.GOLD)
        self.btn_go:SetTextSize(28)
        local text_btn_go = STRINGS.MWP.LEAVE_FOR
        if self.controller_mode then
            text_btn_go =
            TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ACCEPT) .. "  " .. text_btn_go
            self.btn_go:SetTextSize(20)
        end
        self.btn_go:SetText(text_btn_go, true)
        self.btn_go:SetScale(1.2, 1.2, 1.2)
        self.btn_go:SetPosition(0, -78, 0)
        self.btn_go:SetOnClick(function()
            onaccept(self)
        end)

        self:SetDest(str_dest)
        self:SetCount(str_count)

        self.isopen = true
        self:Show()
    end)


function PickWorldScreen:SetDest(dest)
    if dest == nil then
        return
    end
    self.dest:SetString(dest)
end

function PickWorldScreen:SetCount(str_count)
    if str_count == nil or str_count == "" then
        self.count:SetString("")
    else
        self.count:SetString(STRINGS.MWP.PLAYER_COUNT .. str_count)
    end
end

function PickWorldScreen:Close()
    if self.isopen then
        self.black:Kill()
        self.isopen = false
        TheFrontEnd:PopScreen(self)
    end
end

function PickWorldScreen:OnRawKey(key, down)

    if key == KEY_RIGHT or key == KEY_DOWN then
        activateImgBtn(self.btn_next, down)
        return true
    end
    if key == KEY_SPACE then
        activateImgBtn(self.btn_go, down)
        return true
    end
    if key == KEY_LEFT or key == KEY_UP then
        activateImgBtn(self.btn_prev, down)
        return true
    end
end

function PickWorldScreen:OnControl(control, down)
    if PickWorldScreen._base.OnControl(self, control, down) then
        return true
    end


    if self.controller_mode then
        if control == CONTROL_SCROLLFWD then
            activateImgBtn(self.btn_next, down)
            return true
        end
        if control == CONTROL_ACCEPT then
            activateImgBtn(self.btn_go, down)
            return true
        end
        if control == CONTROL_SCROLLBACK then
            activateImgBtn(self.btn_prev, down)
            return true
        end
    end

    if not down and (control == CONTROL_CANCEL or control == CONTROL_OPEN_DEBUG_CONSOLE) then
        onclose(self)
        return true
    end
end

return PickWorldScreen
