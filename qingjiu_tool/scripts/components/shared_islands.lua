require("math")
require("constants")

local SharedIslands = Class(function(self, inst)
    self.inst = inst
    self.passphrases = { }
    self.playersAllowed = { }
    self.hubs = { }
    self.sanityDrop = TUNING.SANITY_MED
end)

function SharedIslands:Set(teleport, passphrase)
    if self.passphrases[passphrase] ~= nil then
        --if self.passphrases[passphrase] ~= teleport then
        --    -- Cannot use this passphrase
        --end
        return false
    else
        teleport:ListenForEvent("onremove", function()
            self.passphrases[passphrase] = nil
        end)
    end

    for p, t in pairs(self.passphrases) do
        if t == teleport then
            self.passphrases[p] = nil
            break
        end
    end

    self.passphrases[passphrase] = teleport
    self.playersAllowed[teleport] = {}
    return true
end

function SharedIslands:Reset(teleport)
    for p, t in pairs(self.passphrases) do
        if t == teleport then
            self.passphrases[p] = nil
            break
        end
    end

    teleport.components.multiteleporter.owner = nil
    teleport.components.multiteleporter.lastDayUsed = nil
    self.playersAllowed[teleport] = {}
end

function SharedIslands:Get(passphrase)
    return self.passphrases[passphrase]
end

function SharedIslands:New(passphrase)
    local hub = self.passphrases[passphrase]
    if hub ~= nil then
        -- Passphrase already in use
        return nil
    end

    for _, h in ipairs(self.hubs) do
        if h.components.multiteleporter.owner == nil then
            hub = h
            break
        end
    end

    if hub ~= nil then
        self:Set(hub, passphrase)
        return hub
    end

    return nil
end

function SharedIslands:Allow(user, teleport)
    if teleport ~= nil and self.playersAllowed[teleport] ~= nil then
        self.playersAllowed[teleport][user.userid] = true
    end
end

function SharedIslands:IsAllowed(user, teleport)
    for _, v in ipairs(TheNet:GetClientTable()) do
        if user.userid == v.userid and v.admin then
            return true
        end
    end

    return (self.playersAllowed[teleport] and self.playersAllowed[teleport][user.userid])
end

function SharedIslands:AddHub(hub)
    table.insert(self.hubs, hub)
end

function SharedIslands:OnSave()
    local passphrases = {}
    local refs = {}
    for passphrase, inst in pairs(self.passphrases) do
        passphrases[passphrase] = inst.GUID
        refs[inst.GUID] = true
    end

    local playersAllowed = {}
    for t, players in pairs(self.playersAllowed) do
        local ps = {}
        for userid, _ in pairs(players) do
            table.insert(ps, userid)
        end
        playersAllowed[t.GUID] = ps
        refs[t.GUID] = true
    end

    local hubs = {}
    for _, hub in ipairs(self.hubs) do
        table.insert(hubs, hub.GUID)
        refs[hub.GUID] = true
    end

    local references = {}
    for guid, _ in pairs(refs) do
        table.insert(references, guid)
    end

    return {
        passphrases = passphrases,
        playersAllowed = playersAllowed,
        hubs = hubs
    }, references
end

function SharedIslands:LoadPostPass(newents, savedata)
    if savedata == nil or savedata.passphrases == nil then
        return
    end

    for passphrase, guid in pairs(savedata.passphrases) do
        self:Set(newents[guid] and newents[guid].entity, passphrase)
    end

    for guid, userids in pairs(savedata.playersAllowed) do
        for _, userid in pairs(userids) do
            self:Allow({ userid = userid } , newents[guid] and newents[guid].entity)
        end
    end

    for _, guid in ipairs(savedata.hubs) do
        local hub = newents[guid] and newents[guid].entity
        if hub ~= nil then
            self:AddHub(hub)
        end
    end
end

return SharedIslands
