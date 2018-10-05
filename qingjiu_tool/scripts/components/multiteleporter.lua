local MultiTeleporter = Class(function(self, inst)
    self.inst = inst
    self.inst.components.teleporter = self
    self.targetTeleporters = {}
    self.onActivate = nil
    self.playersSources = {}
    self.owner = nil
    self.isroot = false
    self.playersActivationSequence = {}
    self.playersResetActivationSequenceTask = {}
    self.offset = 2
    self.lastDayUsed = nil
    self.unbindDays = nil
    inst:ListenForEvent("onremove", function(inst)
        inst.components.multiteleporter:RemoveAllTargets()
    end)
end,
nil,
{
    isroot = function(self, isroot)
        if isroot then
            self.inst:AddTag("multiteleporter_root")
        else
            self.inst:RemoveTag("multiteleporter_root")
        end
    end
})

function MultiTeleporter:OnRemoveFromEntity()
    self.inst:RemoveTag("multiteleporter")
end

function MultiTeleporter:HasTargetTeleporters()
    return (next(self.targetTeleporters) and true or false)
end

function MultiTeleporter:IsActive()
    return self:HasTargetTeleporters()
end

function MultiTeleporter:IsBusy()
    return false
end

function MultiTeleporter:RegisterTeleportee(doer)
end

function MultiTeleporter:UnregisterTeleportee(doer)
end

function MultiTeleporter:IsAllowed(doer)
    return self:HasTargetTeleporters() and (
      self.isroot or
      self:GetRootTeleport().components.multiteleporter.owner == doer.userid or
      TheWorld.components.shared_islands:IsAllowed(doer, self:GetRootTeleport()))
end

function MultiTeleporter:Activate(doer)
    local doerid = doer.userid
    local targetTeleport
    if not self:IsAllowed(doer) then
        targetTeleport = self.inst
    else
        targetTeleport = self.playersSources[doerid]
        if targetTeleport == nil or math.random() > 0.5 then
            targetTeleport = self:GetRandomTeleport()
        end
        targetTeleport.components.multiteleporter.playersSources[doerid] = self.inst
    end

    if self.onActivate ~= nil then
        self.onActivate(self.inst, doer, targetTeleport)
    end

    self:Teleport(doer, targetTeleport)

    if doer.components.leader ~= nil then
        for follower, v in pairs(doer.components.leader.followers) do
            self:Teleport(follower, targetTeleport)
        end
    end

    --special case for the chester_eyebone: look for inventory items with followers
    if doer.components.inventory ~= nil then
        for k, item in pairs(doer.components.inventory.itemslots) do
            if item.components.leader ~= nil then
                for follower, v in pairs(item.components.leader.followers) do
                    self:Teleport(follower, targetTeleport)
                end
            end
        end
        -- special special case, look inside equipped containers
        for k, equipped in pairs(doer.components.inventory.equipslots) do
            if equipped.components.container ~= nil then
                for j, item in pairs(equipped.components.container.slots) do
                    if item.components.leader ~= nil then
                        for follower, v in pairs(item.components.leader.followers) do
                            self:Teleport(follower, targetTeleport)
                        end
                    end
                end
            end
        end
    end
end

function MultiTeleporter:Teleport(obj, targetTeleporter)
    if targetTeleporter ~= nil then
        local target_x, target_y, target_z = targetTeleporter.Transform:GetWorldPosition()
        if self.offset ~= 0 then
            local angle = math.random() * 2 * PI
            target_x = target_x + math.cos(angle) * self.offset
            target_z = target_z - math.sin(angle) * self.offset
        end
        if obj.Physics ~= nil then
            obj.Physics:Teleport(target_x, target_y, target_z)
        elseif obj.Transform ~= nil then
            obj.Transform:SetPosition(target_x, target_y, target_z)
        end

        local root = self:GetRootTeleport()
        if root ~= nil then
            root.components.multiteleporter.lastDayUsed = TheWorld.state.cycles
        end
    end
end

function MultiTeleporter:SetOwner(owner)
    if owner:HasTag("player") then
        self.owner = owner.userid
        self.lastDayUsed = TheWorld.state.cycles
    end
end

function MultiTeleporter:GetTargetTeleports()
    local teleports = {}
    for t, _ in pairs(self.targetTeleporters) do
        table.insert(teleports, t)
    end
    return teleports
end

function MultiTeleporter:GetRootTeleport()
    if self.isroot then
        return self.inst
    elseif self:HasTargetTeleporters() then
        local rootTeleport, _ = next(self.targetTeleporters)
        return rootTeleport
    end

    return nil
end

function MultiTeleporter:GetRandomTeleport()
    local teleports = self:GetTargetTeleports()
    return teleports[math.random(#teleports)]
end

function MultiTeleporter:Target(otherMultiTeleporter)
    if otherMultiTeleporter == nil -- target doesn't exist
        or otherMultiTeleporter.components == nil or otherMultiTeleporter.components.multiteleporter == nil -- target has no multiteleport component
        or otherMultiTeleporter == self.inst or self.targetTeleporters[otherMultiTeleporter] ~= nil then -- target is self or already linked
        --or otherMultiTeleporter.components.multiteleporter.isroot == self.isroot then -- both root or no root
            return
    end

    if not self:HasTargetTeleporters() then
        self.inst:AddTag("multiteleporter")
    end

    if self.isroot then
        self.targetTeleporters[otherMultiTeleporter] = true
    else
        self.playersSources = {}
        self.targetTeleporters = { [ otherMultiTeleporter ] = true }
    end
end

function MultiTeleporter:RemoveTarget(otherMultiTeleporter)
    if otherMultiTeleporter == nil then
        return
    end

    if self.isroot then
        for p, t in pairs(self.playersSources) do
            if t == otherMultiTeleporter then
                self.playersSources[p] = nil
            end
        end
    end

    if self.targetTeleporters[otherMultiTeleporter] ~= nil then
        self.targetTeleporters[otherMultiTeleporter] = nil
        otherMultiTeleporter.components.multiteleporter:RemoveTarget(self.inst)

        if not self:HasTargetTeleporters() then
            self.inst:RemoveTag("multiteleporter")
            if self.isroot then
                TheWorld.components.shared_islands:Reset(self.inst)
            end
        end
    end
end

function MultiTeleporter:RemoveAllTargets()
    for target, _ in pairs(self.targetTeleporters) do
        target.components.multiteleporter:RemoveTarget(self.inst)
    end
    self.playersSources = {}
    self.targetTeleporters = {}
    self.inst:RemoveTag("multiteleporter")
end

function MultiTeleporter:SequenceAddItem(doer, item)
    local doerid = doer.userid
    local done = false

    local resetActivationSequenceTask = self.playersResetActivationSequenceTask[doerid]
    if resetActivationSequenceTask ~= nil then
        resetActivationSequenceTask:Cancel()
        resetActivationSequenceTask = nil
    end

    local activationSequence = self.playersActivationSequence[doerid]
    if activationSequence == nil then
        activationSequence = {}
        self.playersActivationSequence[doerid] = activationSequence
    end

    if #activationSequence == 3 then
        table.remove(activationSequence, 1)
    end
    table.insert(activationSequence, item.prefab)
    --print("Sequence for " .. doer.name .. ": #" .. tostring(#activationSequence) .. " is " .. item.prefab)

    if #activationSequence == 3 then
        local passphrase = activationSequence[1]
        for i = 2, 3 do
            passphrase = passphrase .. ", " .. activationSequence[i]
        end

        if self:HasTargetTeleporters() then
            local rootTeleport = self:GetRootTeleport()
            if rootTeleport.components.multiteleporter.owner == doerid then
                -- Change island passhprase
                done = TheWorld.components.shared_islands:Set(rootTeleport, passphrase)
                -- if done then
                    -- print("Activation sequence changed")
                -- end
                self.playersActivationSequence[doerid] = nil
            elseif TheWorld.components.shared_islands:Get(passphrase) == rootTeleport then
                TheWorld.components.shared_islands:Allow(doer, rootTeleport)
                --print("Activation sequence guessed by " .. doer.name)
                self.playersActivationSequence[doerid] = nil
                done = true
            --else
            --    print("Activation sequence not guessed by " .. doer.name)
            end
        else
            -- Search island matching this sequence
            -- ore create a new one, if possible
            local rootTeleport = TheWorld.components.shared_islands:Get(passphrase)
            if rootTeleport ~= nil then
                self:Target(rootTeleport)
                rootTeleport.components.multiteleporter:Target(self.inst)
                done = true
            else
                rootTeleport = TheWorld.components.shared_islands:New(passphrase)
                if rootTeleport ~= nil then
                    self:Target(rootTeleport)
                    rootTeleport.components.multiteleporter:Target(self.inst)
                    rootTeleport.components.multiteleporter:SetOwner(doer)
                    done = true
                --else
                --    print("Cannot bind new island for " .. doer.name)
                end
            end

            self.playersActivationSequence[doerid] = nil
        end
    end

    if self.playersActivationSequence[doerid] ~= nil then
        resetActivationSequenceTask = self.inst:DoTaskInTime(30, function ()
            self.playersActivationSequence[doerid] = nil
            self.playersResetActivationSequenceTask[doerid] = nil
            --print("Sequence reset expired for " .. tostring(doerid))
        end)
    end

    self.playersResetActivationSequenceTask[doerid] = resetActivationSequenceTask
    return done
end

function MultiTeleporter:OnSave()
    if not TheWorld.ismastersim then
        return
    end

    local refs = {}
    local targetTeleporters = {}
    for t, _ in pairs(self.targetTeleporters) do
        table.insert(targetTeleporters, t.GUID)
        refs[t.GUID] = true
    end

    local playersSources = {}
    for p, t in pairs(self.playersSources) do
        playersSources[p] = t.GUID
        refs[t.GUID] = true
    end

    local references = {}
    for ref, _ in pairs(refs) do
        table.insert(references, ref)
    end

    return {
        targetTeleporters = targetTeleporters,
        playersSources = playersSources,
        owner = self.owner,
        isroot = self.isroot,
        unbindDays = self.unbindDays,
        lastDayUsed = self.lastDayUsed
    }, references
end

function MultiTeleporter:LoadPostPass(newents, savedata)
    if not TheWorld.ismastersim or savedata == nil then
        return
    end

    self.owner = savedata.owner
    self.isroot = savedata.isroot or false
    self.unbindDays = savedata.unbindDays
    self.lastDayUsed = savedata.lastDayUsed

    for _, guid in ipairs(savedata.targetTeleporters) do
        local d = newents[guid]
        if d ~= nil then
            self:Target(d.entity)
        end
    end

    for player_guid, teleport_guid in ipairs(savedata.playersSources) do
        local p = newents[player_guid]
        local t = newents[teleport_guid]
        if p ~= nil and t ~= nil and t.entity ~= nil then
            self.playersSources[p] = t.entity
        end
    end
end

return MultiTeleporter
