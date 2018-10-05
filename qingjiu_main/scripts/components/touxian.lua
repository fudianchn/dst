return Class(function(self, inst)

    self.inst = inst

    self.deathnum = 0

    function self:Init()
        if self.deathnum then
            self.inst:ListenForEvent("death", function()
                self.deathnum = self.deathnum + 1
            end)
        end
    end

    function self:OnSave()
        return { deathnum = self.deathnum }
    end

    function self:OnLoad(data)
        self.deathnum = data and data.deathnum
    end
end)