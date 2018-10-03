--fr汉化
local _G = GLOBAL

LoadPOFile("guido.po", "chs")

if _G.debug.getupvalue(string.match, 1) == nil then
    -- 修复因游戏原因无法正确匹配中文
    local oldmatch = string.match
    function string.match(str, pattern, index)
        return oldmatch(str, pattern:gsub("%%w", "[%%w一-鿕]"), index)
    end
end





--fr大陆基础设置
local STRINGS = _G.STRINGS
--关闭自动分流
local auto_balancing = false == true
--防止洞口生成蝙蝠
local no_bat = true == true
--提示大陆名称
local world_prompt = true == true
--绚丽之门作为洞口
local migration_postern = true == true
--id为2,3,4,5,6的世界不参与分流
local ignore_sinkholes = { "2", "3", "4", "5", "6" } == true
local _config = {}
--各大陆的名称
_config.world_name = {
    ["1"] = "维斯特洛大陆",
    ["2"] = "临冬城",
    ["3"] = "高庭城",
    ["4"] = "君临城",
    ["5"] = "幻想乡",
    ["6"] = "河间地"
} or {}
--各大陆人数上限
_config.population_limit = { ["_other"] = 8 } or {}
_config.extra_worlds = {}
for i, v in ipairs(GetModConfigData("extra_worlds") or {}) do
    _config.extra_worlds[v] = true
end

local PickWorldScreen = _G.require "screens/pickworldscreen"

Assets = {
    Asset("ATLAS", "images/wpicker.xml"),
    Asset("IMAGE", "images/wpicker.tex")
}

--大陆设置
local strings = {}
strings.WORLD = "清酒大陆"
strings.WHERE_TO_GO = "去向何处？"
strings.HERE_IS = "这里是 "
strings.WORLD_FULL = "那座城堡已经满人了"
strings.WORLD_INVALID = "该城不可达"
strings.SELECT_WORLD = "选择城堡"
strings.PLAYER_COUNT = "人数 "
strings.LEAVE_FOR = "前往"

GLOBAL.STRINGS.MWP = strings

AddModRPCHandler("multiworldpicker",
    "worldpickervisibleRPC",
    function(player)
        player.player_classified.worldpickervisible:set_local(false)
        player.player_classified._worldpickerportalid = nil
        player.player_classified._worldpickercurrentdest = nil
    end)
AddModRPCHandler("multiworldpicker",
    "worldpickerdestRPC",
    function(player, prev)
        if player.player_classified.worldpickervisible:value() and
                player.player_classified._worldpickercurrentindex ~= nil then
            local i = player.player_classified._worldpickercurrentindex + (prev == true and -1 or 1)
            local len = #_G.TheWorld.ShardList
            i = (len + i - 1) % len + 1
            local dest = _G.TheWorld.ShardList[i]
            local count = _G.TheWorld.ShardPlayerCounts[dest]
            if dest and count then
                player.player_classified._worldpickercurrentindex = i
                player.player_classified._worldpickercurrentdest = dest
                local max =
                _G.tonumber(_config.population_limit[dest]) or _G.tonumber(_config.population_limit._other) or 0
                player.player_classified.worldpickeronline:set(max > 0 and count .. "/" .. max or "" .. count)
                local name = _config.world_name[dest] or STRINGS.MWP.WORLD .. dest
                player.player_classified.worldpickerdest:set(name)
            end
        end
    end)
AddModRPCHandler("multiworldpicker",
    "worldpickermigrateRPC",
    function(player)
        player.player_classified.worldpickervisible:set_local(false)

        local portalId = player.player_classified._worldpickerportalid
        local dest = player.player_classified._worldpickercurrentdest
        local count = _G.TheWorld.ShardPlayerCounts[dest]
        if portalId and _G.tonumber(dest) and count then
            local max = _G.tonumber(_config.population_limit[dest]) or _G.tonumber(_config.population_limit._other) or 0
            if max > 0 and count >= max then
                if player.components and player.components.talker then
                    player.components.talker:Say(STRINGS.MWP.WORLD_FULL)
                end
                return
            end

            local paras = { player = player, portalid = portalId, worldid = _G.tonumber(dest) }
            _G.TheWorld:DoTaskInTime(0.1,
                function(world)
                    world:PushEvent("ms_playerdespawnandmigrate", paras)
                end)
            return
        end
        if player.components and player.components.talker then
            player.components.talker:Say(STRINGS.MWP.WORLD_INVALID)
        end
    end)

local function addWorldPicker(inst)
    function inst:OpenWorldPickerScreen(dest, count)

        if inst.pickworldscreen ~= nil then
            return inst.pickworldscreen
        end
        inst.pickworldscreen = PickWorldScreen(inst.owner, dest, count)
        inst:OpenScreenUnderPause(self.pickworldscreen)
        _G.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
        return inst.pickworldscreen
    end

    function inst:CloseWorldPickerScreen()
        if inst.pickworldscreen then
            inst.pickworldscreen:Close()
            inst.pickworldscreen = nil
        end
        inst.owner.player_classified.worldpickervisible:set_local(false)
        SendModRPCToServer(MOD_RPC["multiworldpicker"]["worldpickervisibleRPC"])
    end
end

AddClassPostConstruct("screens/playerhud", addWorldPicker)


local function migrator(inst)
    function inst:IsDestinationForPortal(_, otherPortal)
        return self.receivedPortal == otherPortal
    end

    inst._oldActivate = inst.Activate
    function inst:Activate(doer)
        if doer == nil then
            return false
        end

        if ignore_sinkholes and self.inst.prefab == "cave_entrance_open" then
            return self:_oldActivate(doer)
        end

        if _G.TheWorld.ShardList == nil or #_G.TheWorld.ShardList < 2 then
            return self:_oldActivate(doer)
        end

        if doer.mwp_last_show_wp == nil or (_G.os.time() - doer.mwp_last_show_wp) > 2 then
            doer.mwp_last_show_wp = _G.os.time()
            doer.player_classified:ShowWorldPickerPopup(true, self.id)
        elseif doer.components and doer.components.talker then
            doer.components.talker:Say(STRINGS.MWP.WHERE_TO_GO)
        end
        return true
    end
end

AddComponentPostInit("worldmigrator", migrator)


local function OnWorldPickerVisibleDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if not inst.worldpickervisible:value() then
            inst._parent.HUD:CloseWorldPickerScreen()
        else
            inst._parent.HUD:OpenWorldPickerScreen(inst.worldpickerdest:value(), inst.worldpickeronline:value())
        end
    end
end

local function OnWorldPickerDestDirty(inst)
    if inst._parent ~= nil and inst._parent.HUD ~= nil then
        if not inst.worldpickervisible:value() then
            inst._parent.HUD:CloseWorldPickerScreen()
        elseif inst._parent.HUD.pickworldscreen ~= nil then
            inst._parent.HUD.pickworldscreen:SetDest(inst.worldpickerdest:value())
            inst._parent.HUD.pickworldscreen:SetCount(inst.worldpickeronline:value())
        end
    end
end


local function addtoplayerclassified(inst)
    inst.worldpickervisible = _G.net_bool(inst.GUID, "worldpicker.worldpickervisible", "worldpickervisibledirty")
    inst.worldpickerdest = _G.net_string(inst.GUID, "worldpicker.worldpickerdest", "worldpickerdestdirty")
    inst.worldpickeronline = _G.net_string(inst.GUID, "worldpicker.worldpickeronline", "worldpickercountdirty")
    inst:DoTaskInTime(0,
        function(obj)
            if _G.TheWorld.ismastersim then
            else
                obj:ListenForEvent("worldpickervisibledirty", OnWorldPickerVisibleDirty)
                obj:ListenForEvent("worldpickerdestdirty", OnWorldPickerDestDirty)
            end
        end)
    if not _G.TheWorld.ismastersim then
        return
    end
    function inst:ShowWorldPickerPopup(show, portalid)
        if show then
            self._worldpickerportalid = portalid or 0
            self._worldpickercurrentindex = self._worldpickercurrentindex or 1
            self._worldpickercurrentdest = _G.TheWorld.ShardList[self._worldpickercurrentindex]

            local destname =
            _config.world_name[self._worldpickercurrentdest] or STRINGS.MWP.WORLD .. self._worldpickercurrentdest
            local count = _G.TheWorld.ShardPlayerCounts[self._worldpickercurrentdest]
            local max =
            _G.tonumber(_config.population_limit[self._worldpickercurrentdest]) or
                    _G.tonumber(_config.population_limit._other) or
                    0
            self.worldpickeronline:set(max > 0 and count .. "/" .. max or "" .. count)
            self.worldpickerdest:set(destname)
        end
        self.worldpickervisible:set(show)
        OnWorldPickerVisibleDirty(self)
        OnWorldPickerDestDirty(self)
    end
end

AddPrefabPostInit("player_classified", addtoplayerclassified)

AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.MIGRATE, "doshortaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.MIGRATE, "doshortaction"))
AddStategraphActionHandler("wilsonghost", _G.ActionHandler(_G.ACTIONS.MIGRATE, "haunt_pre"))
AddStategraphActionHandler("wilsonghost_client", _G.ActionHandler(_G.ACTIONS.MIGRATE, "haunt_pre"))

local _oldNetworking_SystemMessage = _G.Networking_SystemMessage
_G.Networking_SystemMessage = function(message)
    if string.sub(message, 1, 3) == "`s~" and _G.TheWorld ~= nil then
        if _G.TheWorld.ismastersim and _G.TheWorld.ShardPlayerCounts ~= nil then
            local msg = string.sub(message, 4)
            if msg then
                local pos = string.find(msg, ":")
                if pos and pos > 1 then
                    local id = string.sub(msg, 1, pos - 1)
                    if _G.tonumber(id) == nil then
                        return
                    end
                    local count = string.sub(msg, pos + 1, string.len(msg))
                    _G.TheWorld.ShardPlayerCounts[id] = _G.tonumber(count) or 0
                end
            end
        end
    else
        _oldNetworking_SystemMessage(message)
    end
end

if migration_postern then
    AddComponentAction("SCENE",
        "worldmigrator",
        function(inst, doer, actions, right)
            if inst:HasTag("resurrector") and doer:HasTag("playerghost") then
                local i = 1
                while i <= #actions do
                    if actions[i] == _G.ACTIONS.MIGRATE then
                        table.remove(actions, i)
                        break
                    else
                        i = i + 1
                    end
                end
            end
        end)
    if _G.TheNet:GetIsServer() then
        AddPrefabPostInit("multiplayer_portal",
            function(inst)
                inst:AddComponent("worldmigrator")
                inst.components.worldmigrator:SetID(0)
            end)
    end
end

if _G.TheNet:GetIsServer() then
    if auto_balancing then
        local function has_vacancy(world_id)
            local max =
            _G.tonumber(_config.population_limit[world_id]) or _G.tonumber(_config.population_limit._other) or 0
            if max < 1 then
                return true
            end
            local v =
            max - (_G.TheWorld.ShardPlayerCounts and _G.tonumber(_G.TheWorld.ShardPlayerCounts[world_id]) or 0)
            return v > 0
        end

        local function getTargetWorld()
            if #_G.AllPlayers > 1 and _G.TheWorld.ShardPlayerCounts then
                local id = _G.TheShard:GetShardId()
                for i, v in ipairs(_G.TheWorld.ShardList) do
                    if _config.extra_worlds[v] ~= true then
                        if _G.TheWorld.ShardPlayerCounts[v] == 0 then
                            id = v
                            break
                        elseif _G.TheWorld.ShardPlayerCounts[v] < _G.TheWorld.ShardPlayerCounts[id] and has_vacancy(v) then
                            id = v
                        end
                    end
                end
                return _G.tonumber(id ~= _G.TheShard:GetShardId() and id)
            end
            return nil
        end

        local _oldSpawnNewPlayerOnServerFromSim = _G.SpawnNewPlayerOnServerFromSim
        _G.SpawnNewPlayerOnServerFromSim = function(player_guid,
        skin_base,
        clothing_body,
        clothing_hand,
        clothing_legs,
        clothing_feet)
            local player = _G.Ents[player_guid]
            if player ~= nil then
                local worldId = getTargetWorld()
                if worldId ~= nil then
                    player:DoTaskInTime(0,
                        function(player)
                            _G.TheWorld:PushEvent("ms_playerdespawnandmigrate",
                                { player = player, portalid = 0, worldid = worldId })
                        end)
                end
            end
            _oldSpawnNewPlayerOnServerFromSim(player_guid,
                skin_base,
                clothing_body,
                clothing_hand,
                clothing_legs,
                clothing_feet)
        end
    end

    local _oldShard_UpdateWorldState = _G.Shard_UpdateWorldState
    _G.Shard_UpdateWorldState = function(world_id, state, tags, world_data)
        _oldShard_UpdateWorldState(world_id, state, tags, world_data)

        if _G.TheWorld == nil then
            return
        end

        local ready = state == _G.REMOTESHARDSTATE.READY

        if not ready or _G.TheWorld.ShardList == nil then
            _G.TheWorld.ShardList = {}
            for k, _ in pairs(_G.Shard_GetConnectedShards()) do
                table.insert(_G.TheWorld.ShardList, k)
            end
        else
            table.insert(_G.TheWorld.ShardList, world_id)
        end

        if _G.TheWorld.ShardPlayerCounts == nil then
            _G.TheWorld.ShardPlayerCounts = {}
            _G.TheWorld.ShardPlayerCounts[_G.TheShard:GetShardId()] = #_G.AllPlayers
            for _, v in ipairs(_G.TheWorld.ShardList) do
                _G.TheWorld.ShardPlayerCounts[v] = 0
            end
        else
            if ready then
                _G.TheWorld.ShardPlayerCounts[world_id] = 0
            else
                _G.TheWorld.ShardPlayerCounts[world_id] = nil
            end
        end
        if not ready and #_G.TheWorld.ShardList > 0 then
            for k, v in pairs(_G.ShardPortals) do
                if (v.components.worldmigrator.linkedWorld == nil or v.components.worldmigrator.auto == true) then
                    _G.c_reregisterportals()
                    break
                end
            end
        end
    end

    if no_bat then
        AddPrefabPostInit("cave_entrance_open",
            function(inst)
                if inst.components.childspawner ~= nil then
                    inst.components.childspawner:SetMaxChildren(0)
                end
            end)
    end

    if world_prompt then
        AddSimPostInit(function()
            local function prompt(src, player)
                if player ~= nil then
                    player:DoTaskInTime(1,
                        function(doer)
                            if doer and doer.components and doer.components.talker then
                                local worldname =
                                _config.world_name[_G.TheShard:GetShardId()] or
                                        STRINGS.MWP.WORLD .. _G.TheShard:GetShardId()
                                doer.components.talker:Say(STRINGS.MWP.HERE_IS .. worldname)
                            end
                        end)
                end
            end

            _G.TheWorld:ListenForEvent("ms_playerspawn", prompt)
        end)
    end

    AddSimPostInit(function()
        local shardId = _G.TheShard:GetShardId()
        local function SendCountMsg()
            local msg = "`s~" .. shardId .. ":" .. #_G.AllPlayers
            _G.TheNet:SystemMessage(msg)
        end

        _G.TheWorld:ListenForEvent("ms_playerspawn", SendCountMsg)
        --玩家离开世界不提示
        --_G.TheWorld:ListenForEvent("ms_playerleft", SendCountMsg)
    end)

    _G.mwp_shards = function()
        local name
        for i, v in ipairs(_G.TheWorld.ShardList) do
            name = _config.world_name[v] or STRINGS.MWP.WORLD .. v
        end
    end

    _G.mwp_counts = function()
        local max, name
        for k, v in pairs(_G.TheWorld.ShardPlayerCounts) do
            max = _G.tonumber(_config.population_limit[k]) or _G.tonumber(_config.population_limit._other) or 0
            name = _config.world_name[k] or STRINGS.MWP.WORLD .. k
        end
    end
end





--fr与主世界时间不同步
local require = GLOBAL.require
--关闭时间同步
local SYNC_CYCLES = false

local function RetrieveLastEventListener(source, event, inst)
    local temp
    for i, v in ipairs(source.event_listeners[event][inst]) do
        temp = v
    end
    return temp
end

local function getval(fn, path)
    local val = fn
    for entry in path:gmatch("[^%.]+") do
        local i = 1
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    return val
end

local function setval(fn, path, new)
    local val = fn
    local prev = nil
    local i
    for entry in path:gmatch("[^%.]+") do
        i = 1
        prev = val
        while true do
            local name, value = GLOBAL.debug.getupvalue(val, i)
            if name == entry then
                val = value
                break
            elseif name == nil then
                return
            end
            i = i + 1
        end
    end
    GLOBAL.debug.setupvalue(prev, i, new)
end

local function isslave()
    return GLOBAL.TheWorld.ismastersim and not GLOBAL.TheWorld.ismastershard
end

local function ClockConverter(self)
    local world = GLOBAL.TheWorld
    if isslave() then
        local _segs = getval(self.OnUpdate, "_segs")
        local OldOnClockUpdate = RetrieveLastEventListener(world, "slave_clockupdate", self.inst)
        self.inst:RemoveEventCallback("slave_clockupdate", OldOnClockUpdate, world)

        local function OnClockUpdate(src, data)
            if SYNC_CYCLES then
                local totalsegs = 0
                local remainsegs = 0

                for i, v in ipairs(data.segs) do
                    if i < data.phase then totalsegs = totalsegs + v end
                end
                totalsegs = totalsegs + (data.totaltimeinphase - data.remainingtimeinphase) / TUNING.SEG_TIME

                for i, v in ipairs(_segs) do
                    data.segs[i] = v:value()
                    totalsegs = totalsegs - v:value()
                    if totalsegs < 0 then
                        data.phase = i
                        remainsegs = -totalsegs
                    end
                end

                data.totaltimeinphase = _segs[data.phase]:value() * TUNING.SEG_TIME
                data.remainingtimeinphase = remainsegs * TUNING.SEG_TIME
                OldOnClockUpdate(src, data)
            end
        end

        self.inst:ListenForEvent("slave_clockupdate", OnClockUpdate, world)
        setval(self.OnUpdate, "_ismastershard", true)
    end
end

AddComponentPostInit("clock", ClockConverter)

local function SeasonsConverter(self)
    local world = GLOBAL.TheWorld
    if isslave() then
        local PushSeasonClockSegs = getval(self.OnLoad, "PushSeasonClockSegs")
        setval(PushSeasonClockSegs, "_ismastershard", true)

        local DEFAULT_CLOCK_SEGS = getval(self.OnLoad, "DEFAULT_CLOCK_SEGS")
        local SEASON_NAMES = getval(self.OnLoad, "SEASON_NAMES")
        local _segs = getval(self.OnLoad, "_segs")

        local function OnSetSeasonClockSegs(src, segs)
            local default = nil
            for k, v in pairs(segs) do
                default = v
                break
            end

            if default == nil then
                if segs ~= DEFAULT_CLOCK_SEGS then
                    OnSetSeasonClockSegs(DEFAULT_CLOCK_SEGS)
                end
                return
            end

            for i, v in ipairs(SEASON_NAMES) do
                _segs[i] = segs[v] or default
            end

            PushSeasonClockSegs()
        end

        local function OnSetSeasonSegModifier(src, mod)
            setval(PushSeasonClockSegs, "_segmod", mod)
            PushSeasonClockSegs()
        end

        self.inst:ListenForEvent("ms_setseasonclocksegs", OnSetSeasonClockSegs, world)
        self.inst:ListenForEvent("ms_setseasonsegmodifier", OnSetSeasonSegModifier, world)

        local OnSeasonDirty = RetrieveLastEventListener(self.inst, "seasondirty", self.inst)
        local OnLengthsDirty = RetrieveLastEventListener(self.inst, "lengthsdirty", self.inst)
        setval(OnSeasonDirty, "PushMasterSeasonData", function() end)
        setval(OnLengthsDirty, "PushMasterSeasonData", function() end)

        local OnSeasonsUpdate = RetrieveLastEventListener(world, "slave_seasonsupdate", self.inst)
        self.inst:RemoveEventCallback("slave_seasonsupdate", OnSeasonsUpdate, world)
    end
end

AddComponentPostInit("seasons", SeasonsConverter)