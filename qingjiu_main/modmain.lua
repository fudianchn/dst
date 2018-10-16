--fr汉化
local _G = GLOBAL

LoadPOFile("guido.po", "chs")

if _G.debug.getupvalue(string.match, 1) == nil then
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
local ignore_sinkholes = false == true
local _config = {}
--各大陆的名称
_config.world_name = {
    ["1"] = "维斯特洛",
    ["2"] = "临冬城",
    ["3"] = "高庭城",
    ["4"] = "君临城",
    ["5"] = "幻想乡",
    ["6"] = "河间地"
} or {}
--各大陆人数上限
_config.population_limit = { ["_other"] = 8 } or {}
_config.extra_worlds = {}
for i, v in ipairs({ "2", "3", "4", "5", "6" } or {}) do
    _config.extra_worlds[v] = true
end

local PickWorldScreen = _G.require "screens/pickworldscreen"

Assets = {
    Asset("ATLAS", "images/wpicker.xml"),
    Asset("IMAGE", "images/wpicker.tex"),
    Asset("IMAGE", "minimap/campfire.tex"),
    Asset("ATLAS", "minimap/campfire.xml"),

    Asset("IMAGE", "images/status_bg.tex"),
    Asset("ATLAS", "images/status_bg.xml"),

    Asset("IMAGE", "images/sharelocation.tex"),
    Asset("ATLAS", "images/sharelocation.xml"),
    Asset("IMAGE", "images/unsharelocation.tex"),
    Asset("ATLAS", "images/unsharelocation.xml"),

    Asset("ATLAS", "images/ui/boss_hb.xml"),

    Asset("ATLAS", "images/container.xml"),
    Asset("ATLAS", "images/container_x20.xml"),
    Asset("ATLAS", "images/krampus_sack_bg.xml"),
}

--大陆设置
local strings = {}
strings.WORLD = "清酒大陆"
strings.WHERE_TO_GO = "大人,去向何处？"
strings.HERE_IS = "这里是 "
strings.WORLD_FULL = "那座城堡已经关闭城门"
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
        _G.TheWorld:ListenForEvent("ms_playerleft", SendCountMsg)
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





--fr全球定位
PrefabFiles = {
    "globalposition_classified",
    "smoketrail",
    "globalmapicon_noproxy",
    "worldmapexplorer",
    "dychealthbar",
    "touxian",
}


AddMinimapAtlas("minimap/campfire.xml")

local require = GLOBAL.require
--关闭荒野模式覆盖
local OVERRIDEMODE = false
--开启玩家图标
local SHOWPLAYERICONS = true
--玩家图标 1常显 2TAB 3关闭
local SERVERSHOWPLAYERSOPTIONS = 2
--玩家图标 1常显 2TAB 3关闭
local CLIENTSHOWPLAYERSOPTIONS = 2
local SHOWPLAYERINDICATORS = SERVERSHOWPLAYERSOPTIONS > 1
local SHOWPLAYERSALWAYS = SHOWPLAYERINDICATORS and CLIENTSHOWPLAYERSOPTIONS == 3
local NETWORKPLAYERPOSITIONS = SHOWPLAYERICONS or SHOWPLAYERINDICATORS
--不分享地图
local SHAREMINIMAPPROGRESS = NETWORKPLAYERPOSITIONS and false
--不显示火堆 1常显 2木炭 3关闭
local FIREOPTIONS = 3
local SHOWFIRES = FIREOPTIONS < 3
local NEEDCHARCOAL = FIREOPTIONS == 2
--关闭地图火堆图标
local SHOWFIREICONS = false
--玩家不可标记
local ENABLEPINGS = false
if ENABLEPINGS then
    table.insert(PrefabFiles, "pings")
    for _, ping in ipairs({ "generic", "gohere", "explore", "danger", "omw" }) do
        table.insert(Assets, Asset("IMAGE", "minimap/ping_" .. ping .. ".tex"))
        table.insert(Assets, Asset("ATLAS", "minimap/ping_" .. ping .. ".xml"))
        AddMinimapAtlas("minimap/ping_" .. ping .. ".xml")
    end
    for _, action in ipairs({ "", "Danger", "Explore", "GoHere", "Omw", "Cancel", "Delete", "Clear" }) do
        table.insert(Assets, Asset("IMAGE", "images/Ping" .. action .. ".tex"))
        table.insert(Assets, Asset("ATLAS", "images/Ping" .. action .. ".xml"))
    end
end

local mode = GLOBAL.TheNet:GetServerGameMode()
if mode == "wilderness" and not OVERRIDEMODE then
    SHOWPLAYERINDICATORS = false
    SHOWPLAYERICONS = false
    SHOWFIRES = true
    SHOWFIREICONS = false
    NEEDCHARCOAL = false
    SHAREMINIMAPPROGRESS = false
end

GLOBAL._GLOBALPOSITIONS_SHAREMINIMAPPROGRESS = SHAREMINIMAPPROGRESS
GLOBAL._GLOBALPOSITIONS_SHOWPLAYERICONS = SHOWPLAYERICONS
GLOBAL._GLOBALPOSITIONS_SHOWFIREICONS = SHOWFIREICONS
GLOBAL._GLOBALPOSITIONS_SHOWPLAYERINDICATORS = SHOWPLAYERINDICATORS

local oldmaxrange = GLOBAL.TUNING.MAX_INDICATOR_RANGE
local oldmaxrangesq = (oldmaxrange * 1.5) * (oldmaxrange * 1.5)

GLOBAL.TUNING.MAX_INDICATOR_RANGE = 2000

AddPrefabPostInit("forest_network", function(inst) inst:AddComponent("globalpositions") end)
AddPrefabPostInit("cave_network", function(inst) inst:AddComponent("globalpositions") end)

if NETWORKPLAYERPOSITIONS then
    local is_dedicated = GLOBAL.TheNet:IsDedicated()
    local function PlayerPostInit(TheWorld, player)
        player:ListenForEvent("setowner", function()
            player:AddComponent("globalposition")
            if SHAREMINIMAPPROGRESS then
                if is_dedicated then
                    local function TryLoadingWorldMap()
                        if not TheWorld.net.components.globalpositions.map_loaded or not player.player_classified.MapExplorer:LearnRecordedMap(TheWorld.worldmapexplorer.MapExplorer:RecordMap()) then
                            player:DoTaskInTime(0, TryLoadingWorldMap)
                        end
                    end

                    TryLoadingWorldMap()
                elseif player ~= GLOBAL.AllPlayers[1] then
                    local function TryLoadingHostMap()
                        if not player.player_classified.MapExplorer:LearnRecordedMap(GLOBAL.AllPlayers[1].player_classified.MapExplorer:RecordMap()) then
                            player:DoTaskInTime(0, TryLoadingHostMap)
                        end
                    end

                    TryLoadingHostMap()
                end
            end
        end)
    end

    AddPrefabPostInit("world", function(inst)
        if is_dedicated then
            inst.worldmapexplorer = GLOBAL.SpawnPrefab("worldmapexplorer")
        end
        inst:ListenForEvent("ms_playerspawn", PlayerPostInit)
    end)

    if SHAREMINIMAPPROGRESS and is_dedicated then
        MapRevealer = require("components/maprevealer")

        MapRevealer_ctor = MapRevealer._ctor
        MapRevealer._ctor = function(self, inst)
            self.counter = 1
            MapRevealer_ctor(self, inst)
        end

        MapRevealer_RevealMapToPlayer = MapRevealer.RevealMapToPlayer
        MapRevealer.RevealMapToPlayer = function(self, player)
            MapRevealer_RevealMapToPlayer(self, player)
            self.counter = self.counter + 1
            if self.counter > #GLOBAL.AllPlayers then
                GLOBAL.TheWorld.worldmapexplorer.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
                self.counter = 1
            end
        end
    end
end

local function FirePostInit(inst, offset)
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("smokeemitter")
        inst.smoke_emitter_offset = offset
        local duration = 0
        if NEEDCHARCOAL then
            local OldTakeFuelItem = inst.components.fueled.TakeFuelItem
            inst.components.fueled.TakeFuelItem = function(self, item, ...)
                if item.prefab == "charcoal" and self:CanAcceptFuelItem(item) then
                    duration = duration + item.components.fuel.fuelvalue * self.bonusmult
                    duration = math.min(360, duration)
                    inst.components.smokeemitter:Enable(duration)
                end
                return OldTakeFuelItem(self, item, ...)
            end
        else
            local OldIgnite = inst.components.burnable.Ignite
            inst.components.burnable.Ignite = function(...)
                OldIgnite(...)
                inst.components.smokeemitter:Enable()
            end
            local OldExtinguish = inst.components.burnable.Extinguish
            inst.components.burnable.Extinguish = function(...)
                OldExtinguish(...)
                inst.components.smokeemitter:Disable()
            end
            if inst.components.burnable.burning then
                inst.components.burnable:Ignite()
            end
        end
    end
end

if SHOWFIRES then
    AddPrefabPostInit("campfire", function(inst) FirePostInit(inst) end)
    AddPrefabPostInit("firepit", function(inst) FirePostInit(inst) end)
    local deluxe_campfires_installed = false
    for k, v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
        deluxe_campfires_installed = deluxe_campfires_installed or v == "workshop-444235588"
    end
    if deluxe_campfires_installed then
        AddPrefabPostInit("deluxe_firepit", function(inst) FirePostInit(inst, { x = 350, y = -350 }) end)
        AddPrefabPostInit("heat_star", function(inst) FirePostInit(inst, { x = 230, y = -230 }) end)
    end
end

if GLOBAL.TheNet:GetIsServer() then
    PlayerTargetIndicator = require("components/playertargetindicator")

    local function ShouldRemove(x, z, v)
        local vx, vy, vz = v.Transform:GetWorldPosition()
        return GLOBAL.distsq(x, z, vx, vz) > oldmaxrangesq
    end

    local OldOnUpdate = PlayerTargetIndicator.OnUpdate
    function PlayerTargetIndicator:OnUpdate(...)
        local ret = OldOnUpdate(self, ...)
        local x, y, z = self.inst.Transform:GetWorldPosition()
        for i, v in ipairs(self.offScreenPlayers) do
            while ShouldRemove(x, z, v) do
                self.inst.HUD:RemoveTargetIndicator(v)
                GLOBAL.table.remove(self.offScreenPlayers, i)
                v = self.offScreenPlayers[i]
                if v == nil then break end
            end
        end
        return ret
    end
end

local USERFLAGS = GLOBAL.USERFLAGS
local checkbit = GLOBAL.checkbit
local DST_CHARACTERLIST = GLOBAL.DST_CHARACTERLIST
local MODCHARACTERLIST = GLOBAL.MODCHARACTERLIST
local MOD_AVATAR_LOCATIONS = GLOBAL.MOD_AVATAR_LOCATIONS

TargetIndicator = require("widgets/targetindicator")
local OldTargetIndicator_ctor = TargetIndicator._ctor
TargetIndicator._ctor = function(self, owner, target, ...)
    OldTargetIndicator_ctor(self, owner, target, ...)
    if type(target.userid) == "userdata" then
        self.is_character = true
        self.inst.startindicatortask:Cancel()
        local updating = false
        local OldShow = self.Show
        function self:Show(...)
            if not updating then
                updating = true
                self.colour = self.target.playercolour
                self:StartUpdating()
            end
            return OldShow(self, ...)
        end
    end
end

function TargetIndicator:IsGhost()
    return self.userflags and checkbit(self.userflags, USERFLAGS.IS_GHOST)
end

function TargetIndicator:IsAFK()
    return self.userflags and checkbit(self.userflags, USERFLAGS.IS_AFK)
end

function TargetIndicator:IsCharacterState1()
    return self.userflags and checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_1)
end

function TargetIndicator:IsCharacterState2()
    return self.userflags and checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_2)
end

local TARGET_INDICATOR_ICONS = {
    ping_generic = { atlas = "images/Ping.xml", image = "Ping.tex" },
    ping_danger = { atlas = "images/PingDanger.xml", image = "PingDanger.tex" },
    ping_omw = { atlas = "images/PingOmw.xml", image = "PingOmw.tex" },
    ping_explore = { atlas = "images/PingExplore.xml", image = "PingExplore.tex" },
    ping_gohere = { atlas = "images/PingGoHere.xml", image = "PingGoHere.tex" },
}
if SHOWFIRES then
    TARGET_INDICATOR_ICONS.campfire = { atlas = nil, image = nil }
    TARGET_INDICATOR_ICONS.firepit = { atlas = nil, image = nil }
    TARGET_INDICATOR_ICONS.deluxe_firepit = { atlas = "images/inventoryimages/deluxe_firepit.xml", image = nil }
    TARGET_INDICATOR_ICONS.heat_star = { atlas = "images/inventoryimages/heat_star.xml", image = nil }
end
GLOBAL._GLOBALPOSITIONS_TARGET_INDICATOR_ICONS = TARGET_INDICATOR_ICONS

if ENABLEPINGS then
    GLOBAL.STRINGS.NAMES.PING_GENERIC = "有意思的地方"
    GLOBAL.STRINGS.NAMES.PING_DANGER = "这里危险"
    GLOBAL.STRINGS.NAMES.PING_OMW = "在路上"
    GLOBAL.STRINGS.NAMES.PING_EXPLORE = "去探索"
    GLOBAL.STRINGS.NAMES.PING_GOHERE = "去这里"
end

local OldOnMouseButton = TargetIndicator.OnMouseButton
function TargetIndicator:OnMouseButton(button, down, ...)
    OldOnMouseButton(self, button, down, ...)
    if button == GLOBAL.MOUSEBUTTON_RIGHT then
        self.onlyshowonscoreboard = true
    end
end

local OldGetAvatarAtlas = TargetIndicator.GetAvatarAtlas
function TargetIndicator:GetAvatarAtlas(...)
    self.is_character = true
    if type(self.target.userid) == "userdata" then
        local prefab = self.target.parentprefab:value()
        if self.target.userid:value() == "nil" then
            self.is_character = false
            self.prefabname = prefab
            if TARGET_INDICATOR_ICONS[prefab] then
                if self.name_label then
                    self.name_label:SetString(self.target.name .. "\n" .. GLOBAL.STRINGS.RMB .. " Dismiss")
                end
            end
        else
            for k, v in pairs(GLOBAL.TheNet:GetClientTable() or {}) do
                if self.target.userid:value() == v.userid then
                    if self.prefabname ~= prefab then
                        self.is_mod_character = false
                        if not table.contains(DST_CHARACTERLIST, prefab)
                                and not table.contains(MODCHARACTERLIST, prefab) then
                            self.prefabname = ""
                        else
                            self.prefabname = prefab
                            if table.contains(MODCHARACTERLIST, prefab) then
                                self.is_mod_character = true
                            end
                        end
                    end
                    if self.userflags ~= v.userflags then
                        self.userflags = v.userflags
                    end
                end
            end
        end
        if self.is_character and self.is_mod_character and not self:IsAFK() then
            local location = MOD_AVATAR_LOCATIONS["Default"]
            if MOD_AVATAR_LOCATIONS[self.prefabname] ~= nil then
                location = MOD_AVATAR_LOCATIONS[self.prefabname]
            end

            local starting = "avatar_"
            if self:IsGhost() then
                starting = starting .. "ghost_"
            end

            local ending = ""
            if self:IsCharacterState1() then
                ending = "_1"
            end
            if self:IsCharacterState2() then
                ending = "_2"
            end

            return location .. starting .. self.prefabname .. ending .. ".xml"
        elseif not self.is_character then
            return (TARGET_INDICATOR_ICONS[self.prefabname]
                    and TARGET_INDICATOR_ICONS[self.prefabname].atlas)
                    or "images/inventoryimages.xml"
        end
        return "images/avatars.xml"
    else
        return OldGetAvatarAtlas(self, ...)
    end
end

local OldGetAvatar = TargetIndicator.GetAvatar
function TargetIndicator:GetAvatar(...)
    if type(self.target.userid) == "userdata" then
        local prefab = self.target.parentprefab:value()
        if self.is_mod_character and not self:IsAFK() then
            local starting = "avatar_"
            if self:IsGhost() then
                starting = starting .. "ghost_"
            end

            local ending = ""
            if self:IsCharacterState1() then
                ending = "_1"
            end
            if self:IsCharacterState2() then
                ending = "_2"
            end

            return starting .. self.prefabname .. ending .. ".tex"
        elseif not self.is_character then
            return (TARGET_INDICATOR_ICONS[self.prefabname]
                    and TARGET_INDICATOR_ICONS[self.prefabname].image)
                    or self.prefabname .. ".tex"
        else
            if self.ishost and self.prefabname == "" then
                return "avatar_server.tex"
            elseif self:IsAFK() then
                return "avatar_afk.tex"
            elseif self:IsGhost() then
                return "avatar_ghost_" .. (self.prefabname ~= "" and self.prefabname or "unknown") .. ".tex"
            else
                return "avatar_" .. (self.prefabname ~= "" and self.prefabname or "unknown") .. ".tex"
            end
        end
    else
        return OldGetAvatar(self, ...)
    end
end

OldTargetIndicatorOnUpdate = TargetIndicator.OnUpdate
function TargetIndicator:OnUpdate()
    if self.target:IsValid() then
        OldTargetIndicatorOnUpdate(self)
    else
        print("清酒定位失败")
    end
end

AddClassPostConstruct("screens/playerhud", function(PlayerHud)
    PlayerHud.targetindicators = {}
    local mastersim = GLOBAL.TheNet:GetIsServer()
    local OldSetMainCharacter = PlayerHud.SetMainCharacter
    function PlayerHud:SetMainCharacter(...)
        local ret = OldSetMainCharacter(self, ...)
        local client_table = GLOBAL.TheNet:GetClientTable() or {}
        for k, v in pairs(GLOBAL.TheWorld.net.components.globalpositions.positions) do
            if v.userid:value() == "nil" and TARGET_INDICATOR_ICONS[v.parentprefab:value()] then
                self:AddTargetIndicator(v)
                self.targetindicators[#self.targetindicators]:Hide()
                v:UpdatePortrait()
            end
            if SHOWPLAYERINDICATORS then
                for j, w in pairs(client_table) do
                    if v.userid:value() == w.userid
                            and w.userid ~= self.owner.userid then
                        v.playercolor = w.colour
                        v.name = w.name
                        self:AddTargetIndicator(v)
                        self.targetindicators[#self.targetindicators]:Hide()
                        v:UpdatePortrait()
                    end
                end
            end
        end
        return ret
    end

    local OldAddTargetIndicator = PlayerHud.AddTargetIndicator
    function PlayerHud:AddTargetIndicator(target)
        if type(target.userid) ~= "userdata" then
            for k, v in pairs(self.targetindicators) do
                if type(v.target.userid) == "userdata" and v.target.userid:value() == target.userid then
                    v.hidewhileclose = true
                end
            end
        end
        OldAddTargetIndicator(self, target)
    end

    local OldRemoveTargetIndicator = PlayerHud.RemoveTargetIndicator
    function PlayerHud:RemoveTargetIndicator(target)
        if type(target.userid) ~= "userdata" then
            for k, v in pairs(self.targetindicators) do
                if type(v.target.userid) == "userdata" and v.target.userid:value() == target.userid then
                    v.hidewhileclose = false
                end
            end
        end
        OldRemoveTargetIndicator(self, target)
    end

    local OldOnUpdate = PlayerHud.OnUpdate
    function PlayerHud:OnUpdate(...)
        local ret = OldOnUpdate(self, ...)
        local onscreen = {}
        if self.owner and self.owner.components and self.owner.components.playertargetindicator then
            onscreen = self.owner.components.playertargetindicator.onScreenPlayersLastTick
        end
        if self.targetindicators then
            for j, w in pairs(self.targetindicators) do
                local show = true
                if type(w.target.userid) == "userdata" then
                    show = SHOWPLAYERSALWAYS and (not w.hidewhileclose) or self:IsStatusScreenOpen()
                    if not w.is_character then
                        local parent_entity = w.target.parententity:value()
                        show = not (parent_entity and parent_entity.entity:FrustumCheck())
                        if w.onlyshowonscoreboard then
                            show = show and self:IsStatusScreenOpen()
                        end
                    end
                    for k, v in pairs(onscreen) do
                        if w.target.userid:value() == v.userid then
                            show = false
                        end
                    end
                    if w.is_character then
                        if self:IsStatusScreenOpen() then
                            w.name_label:Show()
                        elseif not w.focus then
                            w.name_label:Hide()
                        end
                    end
                    if GLOBAL.TheFrontEnd.mutedPlayers[w.target.parentuserid:value()] then
                        show = false
                    end
                elseif mastersim then
                    w:Hide()
                end
                if show then
                    w:Show()
                else
                    w:Hide()
                end
            end
        end
        return ret
    end

    local OldShowPlayerStatusScreen = PlayerHud.ShowPlayerStatusScreen
    function PlayerHud:ShowPlayerStatusScreen(...)
        local ret = OldShowPlayerStatusScreen(self, ...)
        self:OnUpdate(0.0001)
        return ret
    end
end)

require("frontend")
local OldFrontEnd_ctor = GLOBAL.FrontEnd._ctor
GLOBAL.FrontEnd._ctor = function(TheFrontEnd, ...)
    OldFrontEnd_ctor(TheFrontEnd, ...)
    TheFrontEnd.mutedPlayers = { DontDeleteMePlz = true }
end

local STARTSCALE = 0.25
local NORMSCALE = 1
local pingwheel = nil
local pingwheelup = false
local activepos = nil
local ReceivePing = nil
local ShowPingWheel = nil
local HidePingWheel = nil
local pings = {}
if ENABLEPINGS then
    ReceivePing = function(player, pingtype, x, y, z)
        if pingtype == "delete" then
            mindistsq, minping = math.huge, nil
            for _, ping in pairs(pings) do
                local px, py, pz = ping.Transform:GetWorldPosition()
                dq = GLOBAL.distsq(x, z, px, pz)
                if dq < mindistsq then
                    mindistsq = dq
                    minping = ping
                end
            end
            if mindistsq < 400 then
                pings[minping.GUID] = nil
                minping:Remove()
            end
        elseif pingtype == "clear" then
            for _, ping in pairs(pings) do
                ping:Remove()
            end
        else
            local ping = GLOBAL.SpawnPrefab("ping_" .. pingtype)
            ping.OnRemoveEntity = function(inst) pings[inst.GUID] = nil end
            ping.parentuserid = player.userid
            ping.Transform:SetPosition(x, y, z)
            pings[ping.GUID] = ping
        end
    end
    AddModRPCHandler(modname, "Ping", ReceivePing)

    ShowPingWheel = function(position)
        if pingwheelup then return end
        pingwheelup = true
        SetModHUDFocus("PingWheel", true)

        activepos = position
        if GLOBAL.TheInput:ControllerAttached() then
            local scr_w, scr_h = GLOBAL.TheSim:GetScreenSize()
            pingwheel:SetPosition(scr_w / 2, scr_h / 2)
        else
            pingwheel:SetPosition(GLOBAL.TheInput:GetScreenPosition():Get())
        end
        pingwheel:Show()
        pingwheel:ScaleTo(STARTSCALE, NORMSCALE, .25)
    end

    HidePingWheel = function(cancel)
        if not pingwheelup or activepos == nil then return end
        pingwheelup = false
        SetModHUDFocus("PingWheel", false)

        pingwheel:Hide()
        pingwheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)

        if pingwheel.activegesture and pingwheel.activegesture ~= "cancel" and not cancel then
            SendModRPCToServer(MOD_RPC[modname]["Ping"], pingwheel.activegesture, activepos:Get())
        end
        activepos = nil
    end
    GLOBAL.TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if button == 1000 and not down then
            HidePingWheel()
        end
    end)
end

AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
    MapWidget.offset = GLOBAL.Vector3(0, 0, 0)
    MapWidget.nametext = require("widgets/maphoverer")()
    if ENABLEPINGS then
        MapWidget.pingwheel = require("widgets/pingwheel")()
        pingwheel = MapWidget.pingwheel
        pingwheel.radius = pingwheel.radius * 1.1
        pingwheel:Hide()
        pingwheel.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
    end

    function MapWidget:OnUpdate(dt)
        if ENABLEPINGS then
            pingwheel:OnUpdate()
        end
        if not self.shown or pingwheelup then return end

        if GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY) then
            local pos = GLOBAL.TheInput:GetScreenPosition()
            if self.lastpos then
                local scale = 0.25
                local dx = scale * (pos.x - self.lastpos.x)
                local dy = scale * (pos.y - self.lastpos.y)
                self:Offset(dx, dy)
            end

            self.lastpos = pos
        else
            self.lastpos = nil
        end

        if SHOWPLAYERICONS then
            local p = self:GetWorldMousePosition()
            mindistsq, gpc = math.huge, nil
            for k, v in pairs(GLOBAL.TheWorld.net.components.globalpositions.positions) do
                if not GLOBAL.TheFrontEnd.mutedPlayers[v.parentuserid:value()] then
                    local x, y, z = v.Transform:GetWorldPosition()
                    dq = GLOBAL.distsq(p.x, p.z, x, z)
                    if dq < mindistsq then
                        mindistsq = dq
                        gpc = v
                    end
                end
            end
            if math.sqrt(mindistsq) < self.minimap:GetZoom() * 10 then
                if self.nametext:GetString() ~= gpc.name then
                    self.nametext:SetString(gpc.name)
                    self.nametext:SetColour(gpc.playercolour)
                end
            else
                self.nametext:SetString("")
            end
        end
    end

    local OldOffset = MapWidget.Offset
    function MapWidget:Offset(dx, dy, ...)
        self.offset.x = self.offset.x + dx
        self.offset.y = self.offset.y + dy
        OldOffset(self, dx, dy, ...)
    end

    local OldOnShow = MapWidget.OnShow
    function MapWidget:OnShow(...)
        self.offset.x = 0
        self.offset.y = 0
        OldOnShow(self, ...)
    end

    local OldOnZoomIn = MapWidget.OnZoomIn
    function MapWidget:OnZoomIn(...)
        local zoom1 = self.minimap:GetZoom()
        OldOnZoomIn(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    local OldOnZoomOut = MapWidget.OnZoomOut
    function MapWidget:OnZoomOut(...)
        local zoom1 = self.minimap:GetZoom()
        OldOnZoomOut(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown and zoom1 < 20 then
            self.offset = self.offset * zoom1 / zoom2
        end
    end

    function MapWidget:GetWorldMousePosition()
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        local cx = screenwidth * .5 + self.offset.x * 4.5
        local cy = screenheight * .5 + self.offset.y * 4.5
        local mx, my = GLOBAL.TheInput:GetScreenPosition():Get()
        if GLOBAL.TheInput:ControllerAttached() then
            mx, my = screenwidth * .5, screenheight * .5
        end
        local ox = mx - cx
        local oy = my - cy
        local angle = GLOBAL.TheCamera:GetHeadingTarget() * math.pi / 180
        local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
        local wa = math.atan2(ox, oy) - angle
        local px, _, pz = GLOBAL.ThePlayer:GetPosition():Get()
        local wx = px - wd * math.cos(wa)
        local wz = pz + wd * math.sin(wa)
        return GLOBAL.Vector3(wx, 0, wz)
    end
end)

AddClassPostConstruct("screens/mapscreen", function(MapScreen)
    if ENABLEPINGS and GLOBAL.TheInput:ControllerAttached() then
        MapScreen.ping_reticule = MapScreen:AddChild(GLOBAL.require("widgets/uianim")())
        MapScreen.ping_reticule:GetAnimState():SetBank("reticule")
        MapScreen.ping_reticule:GetAnimState():SetBuild("reticule")
        MapScreen.ping_reticule:GetAnimState():PlayAnimation("idle")
        MapScreen.ping_reticule:SetScale(.35)
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        MapScreen.ping_reticule:SetPosition(screenwidth * .5, screenheight * .5)
    end

    local OldOnBecomeInactive = MapScreen.OnBecomeInactive
    function MapScreen:OnBecomeInactive(...)
        self.minimap.nametext:SetString("")
        if ENABLEPINGS then HidePingWheel(true) end
        OldOnBecomeInactive(self, ...)
    end

    if ENABLEPINGS then
        function MapScreen:OnMouseButton(button, down, ...)
            if button == 1000 and down and GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
                ShowPingWheel(self.minimap:GetWorldMousePosition())
            end
        end

        local OldOnControl = MapScreen.OnControl
        function MapScreen:OnControl(control, down, ...)
            if control == GLOBAL.CONTROL_MENU_MISC_4 then
                if down then
                    ShowPingWheel(self.minimap:GetWorldMousePosition())
                else
                    HidePingWheel()
                end
                return true
            end
            return OldOnControl(self, control, down, ...)
        end

        local OldGetHelpText = MapScreen.GetHelpText
        function MapScreen:GetHelpText(...)
            return OldGetHelpText(self, ...) .. "  " .. GLOBAL.TheInput:GetLocalizedControl(GLOBAL.TheInput:GetControllerID(), GLOBAL.CONTROL_MENU_MISC_4) .. " Ping"
        end
    end
end)

if NETWORKPLAYERPOSITIONS then
    local ImageButton = require("widgets/imagebutton")
    local function SetLocationSharing(player, is_sharing)
        if is_sharing and player.components.globalposition == nil then
            player:AddComponent("globalposition")
        else
            if player.components.globalposition then
                player:RemoveComponent("globalposition")
            end
        end
    end

    AddModRPCHandler(modname, "ShareLocation", SetLocationSharing)

    local is_sharing = true
    local PlayerStatusScreen = require("screens/playerstatusscreen")
    local OldDoInit = PlayerStatusScreen.DoInit
    function PlayerStatusScreen:DoInit(ClientObjs, ...)
        OldDoInit(self, ClientObjs, ...)
        if not self.scroll_list.old_updatefn then
            for i, playerListing in pairs(self.scroll_list.static_widgets) do
                local un = is_sharing and "" or "un"
                playerListing.shareloc = playerListing:AddChild(ImageButton("images/" .. un .. "sharelocation.xml",
                    un .. "sharelocation.tex", un .. "sharelocation.tex",
                    un .. "sharelocation.tex", un .. "sharelocation.tex",
                    nil, { 1, 1 }, { 0, 0 }))
                playerListing.shareloc:SetPosition(92, 3, 0)
                playerListing.shareloc.scale_on_focus = false
                playerListing.shareloc:SetHoverText((is_sharing and "已" or "不") .. "分享位置", { font = GLOBAL.NEWFONT_OUTLINE, size = 24, offset_x = 0, offset_y = 30, colour = { 1, 1, 1, 1 } })
                tint = is_sharing and { 1, 1, 1, 1 } or { 242 / 255, 99 / 255, 99 / 255, 255 / 255 }
                playerListing.shareloc.image:SetTint(GLOBAL.unpack(tint))
                local gainfocusfn = playerListing.shareloc.OnGainFocus
                playerListing.shareloc.OnGainFocus = function()
                    gainfocusfn(playerListing.shareloc)
                    GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
                    playerListing.shareloc.image:SetScale(1.1)
                end
                local losefocusfn = playerListing.shareloc.OnLoseFocus
                playerListing.shareloc.OnLoseFocus = function()
                    losefocusfn(playerListing.shareloc)
                    playerListing.shareloc.image:SetScale(1)
                end
                playerListing.shareloc:SetOnClick(function()
                    is_sharing = not is_sharing
                    local un = is_sharing and "" or "un"
                    playerListing.shareloc.image_focus = un .. "shareLocation.tex"
                    playerListing.shareloc.image:SetTexture("images/" .. un .. "sharelocation.xml", un .. "sharelocation.tex")
                    playerListing.shareloc:SetTextures("images/" .. un .. "sharelocation.xml", un .. "shareLocation.tex")
                    playerListing.shareloc:SetHoverText((is_sharing and "已" or "不") .. "分享位置")
                    tint = is_sharing and { 1, 1, 1, 1 } or { 242 / 255, 99 / 255, 99 / 255, 255 / 255 }
                    playerListing.shareloc.image:SetTint(GLOBAL.unpack(tint))

                    SendModRPCToServer(MOD_RPC[modname]["ShareLocation"], is_sharing)
                end)

                if playerListing.userid == self.owner.userid then
                    playerListing.viewprofile:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
                    playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.viewprofile)
                else
                    playerListing.shareloc:Hide()
                end
            end

            self.scroll_list.old_updatefn = self.scroll_list.updatefn
            self.scroll_list.updatefn = function(playerListing, client, ...)
                self.scroll_list.old_updatefn(playerListing, client, ...)
                if client.userid == self.owner.userid then
                    playerListing.shareloc:SetPosition(92, 3, 0)
                    playerListing.viewprofile:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, playerListing.shareloc)
                    playerListing.shareloc:SetFocusChangeDir(GLOBAL.MOVE_LEFT, playerListing.viewprofile)
                    playerListing.shareloc:Show()
                else
                    playerListing.shareloc:Hide()
                end
            end
        end
    end
end

GLOBAL._GLOBALPOSITIONS_MAP_ICONS = {}

for i, atlases in ipairs(GLOBAL.ModManager:GetPostInitData("MinimapAtlases")) do
    for i, path in ipairs(atlases) do
        local file = GLOBAL.io.open(GLOBAL.resolvefilepath(path), "r")
        if file then
            local xml = file:read("*a")
            if xml then
                for element in string.gmatch(xml, "<Element[^>]*name=\"([^\"]*)\"") do
                    if element then
                        local elementName = string.match(element, "^(.*)[.]")
                        if elementName then
                            GLOBAL._GLOBALPOSITIONS_MAP_ICONS[elementName] = element
                        end
                    end
                end
            end
            file:close()
        end
    end
end

for prefab, data in pairs(TARGET_INDICATOR_ICONS) do
    GLOBAL._GLOBALPOSITIONS_MAP_ICONS[prefab] = prefab .. ".tex"
end

for _, prefab in pairs(GLOBAL.DST_CHARACTERLIST) do
    GLOBAL._GLOBALPOSITIONS_MAP_ICONS[prefab] = prefab .. ".png"
end





--fr防熊锁
local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local EQUIPSLOTS = _G.EQUIPSLOTS
if IsServer then
    modimport("scripts/gd_global.lua")
    modimport("scripts/manager_players.lua")
    modimport("scripts/manager_walls.lua")
    modimport("scripts/manager_beefalos.lua")
    modimport("scripts/manager_others.lua")
    modimport("scripts/manager_permission.lua")
    modimport("scripts/manager_stacks.lua")
    modimport("scripts/manager_shelters.lua")
    modimport("scripts/manager_clean.lua")
    modimport("scripts/player_start.lua")
    modimport("scripts/gd_speech.lua")

    --关闭测试模式
    local test_mode = false
    --管理员不受权限控制
    local admin_option = true
    --防止别人造违规建筑
    local is_allow_build_near = false
    --防止怪物摧毁建筑
    local cant_destroyby_monster = true
    --防止恶意封门50码
    local portal_clear = 50
    --背包拾取增强(当身上有背包时拾取地上的背包将持有在手上而不是直接装备)
    local pack_pickup = true
    --完整远古祭坛防拆毁
    local ancient_altar_no_destroy = true
    --犬牙陷阱不攻击无权限玩家
    local trap_teeth_player = false
    --眼球塔攻击无权限玩家
    local eyeturret_player = false
    -- 防止玩家破坏野外猪人房兔人房
    local house_plain_nodestroy = true

    -- 物品范围权限
    local item_ScopePermission = 12

    --重要地点附近自动清理操作
    local function portalnearautodeletefn(inst)
        if _G.TheWorld.ismastersim then
            if not inst.components.near_autodelete then
                inst:AddComponent("near_autodelete")
                if trap_teeth_player then
                    inst.components.near_autodelete:AddCustomPrefab("trap_teeth")
                end
                if eyeturret_player then
                    inst.components.near_autodelete:AddCustomPrefab("eyeturret")
                end
                inst.components.near_autodelete:SetScope(portal_clear)
                inst.components.near_autodelete:start()
            end
        end
    end

    if portal_clear == true or (type(portal_clear) == "number" and portal_clear > 0) then
        for k, v in pairs(config_item.item_clear_auto) do
            AddPrefabPostInit(v, portalnearautodeletefn)
        end
    end

    --安置物品，为每个安置的新物品都添加Tag(种植物/墙)
    local old_DEPLOY = _G.ACTIONS.DEPLOY.fn
    _G.ACTIONS.DEPLOY.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then return old_DEPLOY(act) end

        if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
            if not CheckBuilderScopePermission(act.doer, act.target, "离别人建筑太近了，我做不到，需要权限！", item_ScopePermission) then return false end
        end

        if act.invobject.components.deployable and act.invobject.components.deployable:CanDeploy(act.pos) then
            local obj = (act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)) or
                    (act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject))
            if obj then
                local prefab = obj.prefab
                -- 处理犬牙陷阱和蜜蜂地雷等
                testActPrint(nil, act.doer, obj, "deploy", "安置物品")
                SetItemPermission(obj, act.doer)
                local ret = obj.components.deployable:Deploy(act.pos, act.doer, act.rotation)
                if ret then
                    local x, y, z = GetSplitPosition(act.pos)

                    -- 安置物为墙
                    if string.find(prefab, "wall_") or string.find(act.invobject.prefab, "fence_") then
                        x = math.floor(x) + .5
                        z = math.floor(z) + .5
                    end
                    local bSetItemPermission = false
                    local ents = TheSim:FindEntities(x, y, z, 0.1, nil, { "INLIMBO" })

                    for _, findobj in pairs(ents) do
                        if findobj ~= nil and findobj.userid == nil and findobj.components.deployable == nil then
                            testActPrint(nil, act.doer, findobj, "deploy", "安置物设置权限")
                            SetItemPermission(findobj, act.doer)
                            bSetItemPermission = true
                        end
                    end

                    -- 未执行设置权限操作,进行增强处理
                    if not bSetItemPermission then
                        local prefab_words = {}
                        for word in string.gmatch(prefab, "%a+") do
                            table.insert(prefab_words, word)
                        end

                        ents = TheSim:FindEntities(x, y, z, 1, nil, { "INLIMBO" })

                        for _, findobj in pairs(ents) do
                            if findobj.prefab then
                                if findobj.prefab ~= nil and (string.find(prefab, findobj.prefab) or string.find(findobj.prefab, prefab) or (tablelength(prefab_words) > 1 and strFindInTable(findobj.prefab, prefab_words))) and findobj.components.deployable == nil then
                                    testActPrint(nil, act.doer, findobj, "deploy", "安置物设置权限(增强)")
                                    SetItemPermission(findobj, act.doer)
                                    bSetItemPermission = true
                                end
                            end
                        end
                    end
                    return true
                else
                    act.doer.components.inventory:GiveItem(obj)
                end
            end
        end
    end

    --放置物品(农场/圣诞树)
    local old_PLANT = _G.ACTIONS.PLANT.fn
    _G.ACTIONS.PLANT.fn = function(act)
        testActPrint(act)
        if act.doer.components.inventory ~= nil then
            local seed = act.doer.components.inventory:RemoveItem(act.invobject)
            if seed ~= nil then
                --种植农场
                if act.target.components.grower ~= nil and act.target.components.grower:PlantItem(seed) then
                    for obj, bValue in pairs(act.target.components.grower.crops) do
                        if bValue then SetItemPermission(obj, nil, act.doer) end
                    end
                    return true
                elseif act.target:HasTag("winter_treestand")
                        and act.target.components.burnable ~= nil
                        and not (act.target.components.burnable:IsBurning() or
                        act.target.components.burnable:IsSmoldering()) then
                    --种植圣诞树
                    local x, y, z = act.target.Transform:GetWorldPosition()
                    local tree = _G.SpawnPrefab(seed.components.winter_treeseed.winter_tree)
                    if act.target.ownerlist ~= nil then
                        SetItemPermission(tree, act.target.ownerlist.master)
                    end
                    act.target:Remove()
                    tree.Transform:SetPosition(x, y, z)
                    tree.components.growable:StartGrowing()

                    act.doer:DoTaskInTime(0, function()
                        SetItemPermission(tree, act.doer)
                    end)

                    return true
                else
                    act.doer.components.inventory:GiveItem(seed)
                end
            end
        end
    end

    --用晾肉架
    local old_DRY = _G.ACTIONS.DRY.fn
    _G.ACTIONS.DRY.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then return old_DRY(act) end

        act.doer:DoTaskInTime(0, function()
            SetItemPermission(act.target, nil, act.doer)
        end)
        return old_DRY(act)
    end

    -------------------- 检测Tag来防熊---------------------
    --------------------------------------------------------
    -- 防采肉架上的肉干和蜂箱蜂蜜
    local old_HARVEST = _G.ACTIONS.HARVEST.fn
    _G.ACTIONS.HARVEST.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, nil, true) or act.target.prefab == "cookpot" then
            return old_HARVEST(act)
        elseif act.target == nil or (act.target.ownerlist == nil and true or act.target.ownerlist.master == nil) or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_get_cant")) then return old_HARVEST(act) end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家挖别人东西
    local old_DIG = _G.ACTIONS.DIG.fn
    _G.ACTIONS.DIG.fn = function(act)
        testActPrint(act)

        local leader = GetItemLeader(act.doer)

        -- 有权限时直接处理/患病的植物直接处理
        if CheckItemPermission(leader, act.target) or (act.target and act.target.components.diseaseable and act.target.components.diseaseable:IsDiseased()) then
            return old_DIG(act)
            -- 普通树，判断周围建筑范围(12码)内是否有超过4颗属于同一主人的树
        elseif act.target and (act.target.prefab == "evergreen" or act.target.prefab == "deciduoustree" or act.target.prefab == "twiggytree" or act.target.prefab == "pinecone_sapling" or act.target.prefab == "acorn_sapling" or act.target.prefab == "twiggy_nut_sapling") then
            if act.target.ownerlist ~= nil and act.target.ownerlist.master ~= nil then
                local x, y, z = act.target.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, item_ScopePermission, { "tree" })
                local tree_num = 1
                if leader and leader.userid then
                    for _, obj in pairs(ents) do
                        if obj and obj ~= act.target and obj:HasTag("tree") and obj.ownerlist and obj.ownerlist.master == act.target.ownerlist.master then
                            tree_num = tree_num + 1
                        end
                    end
                end

                if tree_num >= 5 then
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(leader, GetSayMsg("trees_dig_cant", master.name))
                        PlayerSay(master, GetSayMsg("item_dig", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(leader, GetSayMsg("trees_dig_cant"))
                    end

                    return false
                end
            end

            return old_DIG(act)
        elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or (cant_destroyby_monster and leader:HasTag("player") == false) then
            return old_DIG(act)
            -- 不存在权限则判断周围建筑物
            --if CheckBuilderScopePermission(leader, act.target, GetSayMsg("buildings_dig_cant")) then return old_DIG(act) end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_dig_cant", master.name))
                PlayerSay(master, GetSayMsg("item_dig", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家采别人东西(草/树枝/浆果/花)
    local old_PICK = _G.ACTIONS.PICK.fn
    _G.ACTIONS.PICK.fn = function(act)
        testActPrint(act)

        if act.target and string.find(act.target.prefab, "flower") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_PICK(act)
            elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false then
                return old_PICK(act)
                -- 不存在权限则判断周围建筑物
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_pick_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_pick", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_PICK(act)
    end

    --防止玩家开采别人东西(大理石树)
    local old_MINE = _G.ACTIONS.MINE.fn
    _G.ACTIONS.MINE.fn = function(act)
        testActPrint(act)

        local leader = GetItemLeader(act.doer)

        -- 有权限时直接处理
        if CheckItemPermission(leader, act.target) then
            return old_MINE(act)
        elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or (cant_destroyby_monster and leader:HasTag("player") == false) then
            return old_MINE(act)
            -- 不存在权限则判断周围建筑物
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_pick_cant", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_pick", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家拿别人陷阱(狗牙/捕鸟器/蜜蜂地雷)
    local old_PICKUP = _G.ACTIONS.PICKUP.fn
    _G.ACTIONS.PICKUP.fn = function(act)
        testActPrint(act)

        --防偷(狗牙/捕鸟器/蜜蜂地雷) - 暂时只防狗牙被偷
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_PICKUP(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        if pack_pickup and act.doer.components.inventory ~= nil and
                act.target ~= nil and
                act.target.components.inventoryitem ~= nil and
                (act.target.components.inventoryitem.canbepickedup or
                        (act.target.components.inventoryitem.canbepickedupalive and not act.doer:HasTag("player"))) and
                not (act.target:IsInLimbo() or
                        (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning()) or
                        (act.target.components.projectile ~= nil and act.target.components.projectile:IsThrown())) then

            act.doer:PushEvent("onpickupitem", { item = act.target })

            if not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
                -- 背包拾取增强
                if pack_pickup and act.target.components.container ~= nil and act.doer.components.inventory.activeitem == nil then
                    act.target.components.inventoryitem.cangoincontainer = true
                    act.target.components.inventoryitem:OnPutInInventory(act.doer)
                    act.doer.components.inventory:SetActiveItem(act.target)
                    act.target.components.inventoryitem.cangoincontainer = false
                else
                    local item = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
                    if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
                        act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
                    else
                        act.doer.components.inventory:DropItem(act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot))
                    end
                    act.doer.components.inventory:Equip(act.target)
                end
                return true
            end

            if act.doer:HasTag("player") and act.target.components.equippable and not act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
                act.doer.components.inventory:Equip(act.target)
            else
                act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
            end
            return true
        else
            return old_PICKUP(act)
        end
    end

    --防止玩家重置别人陷阱(狗牙)
    local old_RESETMINE = _G.ACTIONS.RESETMINE.fn
    _G.ACTIONS.RESETMINE.fn = function(act)
        testActPrint(act)

        --防重置(狗牙)
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RESETMINE(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RESETMINE(act)
    end

    --防砍别人家的树(圣诞树等)
    local old_CHOP = _G.ACTIONS.CHOP.fn
    _G.ACTIONS.CHOP.fn = function(act)
        testActPrint(act)

        if act.target then
            -- 普通树，判断周围建筑范围(12码)内是否有超过1000颗属于同一主人的树
            if act.target.prefab == "evergreen" or act.target.prefab == "deciduoustree" or act.target.prefab == "twiggytree" then
                local leader = GetItemLeader(act.doer)

                if CheckItemPermission(leader, act.target) then
                    return old_CHOP(act)
                elseif act.target.ownerlist and act.target.ownerlist.master ~= nil then
                    local x, y, z = act.target.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, item_ScopePermission, { "tree" })
                    local tree_num = 1
                    if leader and leader.userid then
                        for _, obj in pairs(ents) do
                            if obj and obj ~= act.target and obj:HasTag("tree") and obj.ownerlist and obj.ownerlist.master == act.target.ownerlist.master then
                                tree_num = tree_num + 1
                            end
                        end
                    end

                    if tree_num >= 1000 then
                        local doer_num = GetPlayerIndex(act.doer.userid)
                        local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                        if master ~= nil then
                            PlayerSay(leader, GetSayMsg("trees_chop_cant", master.name))
                            PlayerSay(master, GetSayMsg("item_chop", leader.name, GetItemOldName(act.target), doer_num))
                        else
                            PlayerSay(leader, GetSayMsg("trees_chop_cant"))
                        end

                        return false
                    end
                end
                --防砍(圣诞树等)
            elseif act.target.prefab == "winter_tree" or act.target.prefab == "winter_deciduoustree" or act.target.prefab == "winter_twiggytree" then
                local leader = GetItemLeader(act.doer)

                -- 有权限时直接处理
                if CheckItemPermission(leader, act.target) then
                    return old_CHOP(act)
                elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or (cant_destroyby_monster and leader:HasTag("player") == false) then
                    return old_CHOP(act)
                    -- 不存在权限则判断周围建筑物
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("item_chop_cant", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_chop", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            end
        end

        return old_CHOP(act)
    end

    --打开建筑容器函数
    local old_RUMMAGE = _G.ACTIONS.RUMMAGE.fn
    _G.ACTIONS.RUMMAGE.fn = function(act)
        testActPrint(act)
        --防装饰(圣诞树等)
        if act.target and (act.target.prefab == "winter_tree" or act.target.prefab == "winter_deciduoustree" or act.target.prefab == "winter_twiggytree") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_RUMMAGE(act)
            elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or act.doer:HasTag("player") == false then
                -- 不存在权限则判断周围建筑物
                if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("tree_open_cant")) then return old_RUMMAGE(act) end
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("tree_open_cant", master.name))
                    PlayerSay(master, GetSayMsg("item_open", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RUMMAGE(act)
    end

    --防止玩家砸别人物品
    local old_HAMMER = _G.ACTIONS.HAMMER.fn
    _G.ACTIONS.HAMMER.fn = function(act)
        testActPrint(act)
        if act.doer:HasTag("beaver") then
            return false
        end

        -- 远古祭坛只有管理员能拆
        if ancient_altar_no_destroy and act.target and act.target.prefab == "ancient_altar" and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
            PlayerSay(act.doer, GetSayMsg("noadmin_hammer_cant", GetItemOldName(act.target)))
            return false
        end

        --  未开启墙增强..直接可砸
        if walls_state_config.walls_normal[act.target and act.target.prefab or ""] then
            return old_HAMMER(act)
        end

        -- 防止玩家拆毁野外的猪人房/兔人房
        if house_plain_nodestroy and act.target and (act.target.ownerlist == nil or act.target.ownerlist.master == nil) and (act.target.prefab == "rabbithouse" or act.target.prefab == "pighouse") and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
            PlayerSay(act.doer, GetSayMsg("noadmin_hammer_cant", GetItemOldName(act.target)))
            return false
        end

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            if cant_destroyby_monster and act.target.cant_destroyedby_monster then
                act.target.components.workable = act.target.components.hammerworkable
            end

            local ret = old_HAMMER(act)

            if cant_destroyby_monster and act.target.cant_destroyedby_monster then
                act.target.components.workable = act.target.components.gd_workable
            end
            return ret
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_smash", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家作祟别人东西
    local old_HAUNT = _G.ACTIONS.HAUNT.fn
    _G.ACTIONS.HAUNT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            return old_HAUNT(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_haunt", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家魔法攻击别人的建筑
    local old_CASTSPELL = _G.ACTIONS.CASTSPELL.fn
    _G.ACTIONS.CASTSPELL.fn = function(act)
        testActPrint(act, act.target, act.invobject)
        local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then
            if act.target then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    staff.components.spellcaster:CastSpell(act.target, act.pos)
                    return true
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_spell", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

            else
                staff.components.spellcaster:CastSpell(act.target, act.pos)
                return true
            end
        end
        return false
    end

    --别人建筑附近不能建造建筑
    local old_BUILD = _G.ACTIONS.BUILD.fn
    _G.ACTIONS.BUILD.fn = function(act)
        testActPrint(act, act.doer, act.recipe)
        if _G.TheWorld.ismastersim == false then return old_BUILD(act) end

        if admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false then --管理员直接可造
            return old_BUILD(act)
        end

        if not table.contains(config_item.cant_destroy_buildings, act.recipe) then --非建筑的话直接可造
            return old_BUILD(act)
        end

        if not is_allow_build_near then
            if not CheckBuilderScopePermission(act.doer, act.target, "离别人建筑太近了，不能建造，需要权限！", item_ScopePermission) then return false end
        end
        return old_BUILD(act)
    end

    --防挖别人的地皮
    local old_TERRAFORM = _G.ACTIONS.TERRAFORM.fn
    _G.ACTIONS.TERRAFORM.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then return old_TERRAFORM(act) end
        if admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false then return old_TERRAFORM(act) end

        if act.target and CheckItemPermission(act.doer, act.target) or act.doer:HasTag("player") == false then return old_TERRAFORM(act)
            -- 不存在权限则判断周围建筑物
        elseif CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_dig_cant")) then return old_TERRAFORM(act)
        end

        return false
    end

    --右键开锁控制
    local old_TURNON = _G.ACTIONS.TURNON.fn
    _G.ACTIONS.TURNON.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then return old_TURNON(act) end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNON(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or act.target.prefab == "dragonflychest" or act.target.prefab == "cellar" or act.target.prefab == "storeroom" then
                if act.target.ownerlist ~= nil and act.target.ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已开锁！任何人都能打开")
                    return old_TURNON(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNON(act)
    end

    --右键上锁控制
    local old_TURNOFF = _G.ACTIONS.TURNOFF.fn
    _G.ACTIONS.TURNOFF.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then return old_TURNOFF(act) end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNOFF(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif act.target and (act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or act.target.prefab == "dragonflychest" or act.target.prefab == "cellar" or act.target.prefab == "storeroom") then
                if act.target.saved_ownerlist ~= nil and act.target.saved_ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已上锁！只有自己能打开")
                    return old_TURNOFF(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNOFF(act)
    end

    --开关门
    local old_ACTIVATE = _G.ACTIONS.ACTIVATE.fn
    _G.ACTIONS.ACTIVATE.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) or CheckWallActionPermission(act.target and act.target.prefab, 3) then
            return old_ACTIVATE(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --危险的书
    local old_READ = _G.ACTIONS.READ.fn
    _G.ACTIONS.READ.fn = function(act)
        testActPrint(act, act.doer, act.target or act.invobject)

        local targ = act.target or act.invobject
        if targ ~= nil and (targ.prefab == "book_brimstone" or targ.prefab == "book_tentacles") then
            if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
                if not CheckBuilderScopePermission(act.doer, targ, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then return false end
            end
        end
        return old_READ(act)
    end

    --危险的道具
    local old_FAN = _G.ACTIONS.FAN.fn
    _G.ACTIONS.FAN.fn = function(act)
        testActPrint(act, act.doer, act.invobject)

        -- 幸运风扇
        if act.invobject and act.invobject.prefab == "perdfan" then
            if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then return false end
            end
        end
        return old_FAN(act)
    end

    --危险的道具
    local old_BLINK = _G.ACTIONS.BLINK.fn
    _G.ACTIONS.BLINK.fn = function(act)
        testActPrint(act, act.doer, act.invobject)

        -- 瞬移魔杖
        if act.invobject.prefab == "orangestaff" then
            if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then return false end
            end
        end
        return old_BLINK(act)
    end

    --防捕别人家的虫
    local old_NET = _G.ACTIONS.NET.fn
    _G.ACTIONS.NET.fn = function(act)
        testActPrint(act)

        -- 萤火虫
        if act.invobject.prefab == "fireflies" then
            if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
                if not CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_net_cant", act.doer.name, GetItemOldName(act.target)), item_ScopePermission) then return false end
            end
        end

        return old_NET(act)
    end

    --检测点燃动作是否有效
    local old_LIGHT = _G.ACTIONS.LIGHT.fn
    _G.ACTIONS.LIGHT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            return old_LIGHT(act)
        elseif act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or (cant_destroyby_monster and act.doer:HasTag("player") == false) then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_light_cant")) then return old_LIGHT(act) end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_light_cant", master.name))
                PlayerSay(master, GetSayMsg("item_light", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家打开别人的容器
    AddComponentPostInit("container", function(Container, target)
        local old_OpenFn = Container.Open
        function Container:Open(doer)
            testActPrint(nil, doer, target, "Open", "打开容器")

            -- 有权限时直接处理
            if CheckItemPermission(doer, target, true) or target.prefab == "cookpot" then
                return old_OpenFn(self, doer)
            elseif doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(doer.userid)
                local master = target.ownerlist and GetPlayerById(target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(doer, GetSayMsg("permission_no", master.name, GetItemOldName(target)))
                    PlayerSay(master, GetSayMsg("item_open", doer.name, GetItemOldName(target), doer_num))
                else
                    PlayerSay(doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(target.ownerlist)))
                end
            end
        end
    end)

    -- 查看物品
    local old_LOOKAT = _G.ACTIONS.LOOKAT.fn
    _G.ACTIONS.LOOKAT.fn = function(act)
        testActPrint(act)

        if act.target and act.target.prefab == "beefalo" and act.target.ownerlist ~= nil then
            local colour = { 0.6, 0.9, 0.8, 1 }
            PlayerColorSay(act.doer, "这头牛的当前状态: \n" .. GetBeefaloInfoString(act.target, act.target.components.rideable:IsBeingRidden()), colour)
            return true
        end

        return old_LOOKAT(act)
    end
end





--fr食物属性
table.insert(GLOBAL.STRINGS, "DFV_LANG")
table.insert(GLOBAL.STRINGS, "DFV_HUNGER")
table.insert(GLOBAL.STRINGS, "DFV_HEALTH")
table.insert(GLOBAL.STRINGS, "DFV_SANITY")
table.insert(GLOBAL.STRINGS, "DFV_SPOILSOON")
table.insert(GLOBAL.STRINGS, "DFV_SPOILIN")
table.insert(GLOBAL.STRINGS, "DFV_SPOILDAY")
table.insert(GLOBAL.STRINGS, "DFV_MIN")
table.insert(GLOBAL.STRINGS, "DFV_IFCOOKED")
local require = GLOBAL.require
local foodvalues = require "components/foodvalues"
local ItemTile = require "widgets/itemtile"
local Inv = require "widgets/inventorybar"
--中文
local DFV_LANG = "CN"
--关闭小地图
local DFV_MIN = false

GLOBAL.STRINGS.DFV_MIN = DFV_MIN
GLOBAL.STRINGS.DFV_LANG = DFV_LANG

if DFV_LANG == "CN" then
    GLOBAL.STRINGS.DFV_HUNGER = "饥饿"
    GLOBAL.STRINGS.DFV_HEALTH = "血量"
    GLOBAL.STRINGS.DFV_SANITY = "精神"
    GLOBAL.STRINGS.DFV_SPOILSOON = "它要坏掉了"
    GLOBAL.STRINGS.DFV_SPOILIN = "距离腐烂"
    GLOBAL.STRINGS.DFV_SPOILDAY = "天"
    GLOBAL.STRINGS.DFV_IFCOOKED = "如果熟"
else
    GLOBAL.STRINGS.DFV_HUNGER = "Hunger"
    GLOBAL.STRINGS.DFV_HEALTH = "Health"
    GLOBAL.STRINGS.DFV_SANITY = "Sanity"
    GLOBAL.STRINGS.DFV_SPOILSOON = "Will spoil very soon"
    GLOBAL.STRINGS.DFV_SPOILIN = "Will spoil in"
    GLOBAL.STRINGS.DFV_SPOILDAY = "day"
    GLOBAL.STRINGS.DFV_IFCOOKED = "If Cooked"
end



local ItemTile_GetDescriptionString_base = ItemTile.GetDescriptionString or function() return "" end
local Inv_UpdateCursorText_base = Inv.UpdateCursorText or function() return "" end

function ItemTile:UpdateTooltip()
    local player = GLOBAL.ThePlayer

    local keydown = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT)

    local ctrlkeydown = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_STACK)

    SendModRPCToServer(MOD_RPC["Food Item"]["FIU"], self.item, keydown, ctrlkeydown)
    player:ListenForEvent("fooditem_changed", function()

        local str = self:GetDescriptionString()
        self:SetTooltip(str)
        if self.item:GetIsWet() then
            self:SetTooltipColour(GLOBAL.unpack(GLOBAL.WET_TEXT_COLOUR))
        else
            self:SetTooltipColour(GLOBAL.unpack(GLOBAL.NORMAL_TEXT_COLOUR))
        end
    end)
end

function ItemTile:GetDescriptionString()

    local player = GLOBAL.ThePlayer
    local strings = GLOBAL.STRINGS

    local str = ItemTile_GetDescriptionString_base(self)

    local ModString = player.components.foodvalues.string_dirty:value()

    if ModString ~= "" then
        str = str .. ModString
    end


    return str
end


function Inv:UpdateCursorText()

    local tmp = Inv_UpdateCursorText_base(self)

    local inv_item = self:GetCursorItem()
    if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
        inv_item = nil
    end

    if self.open then
        if inv_item ~= nil then

            local controller_id = GLOBAL.TheInput:GetControllerID()
            local realfood = nil
            local show_spoil = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_INSPECT)

            local player = GLOBAL.ThePlayer
            local active_item = player.replica.inventory:GetActiveItem()

            local strings = GLOBAL.STRINGS
            local str = {}
            table.insert(str, self.actionstringbody:GetString())


            local keydown = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FOCUS_RIGHT)

            local ctrlkeydown = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FOCUS_LEFT)

            if GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FOCUS_UP) then
                keydown = true
                ctrlkeydown = true
            end

            SendModRPCToServer(MOD_RPC["Food Item"]["FIU"], inv_item, keydown, ctrlkeydown)

            local ModString = string.sub(player.components.foodvalues.string_dirty:value(), 2)
            if ModString ~= "" then
                table.insert(str, ModString)
            end

            local TIP_YFUDGE = 16
            local W = 68
            local CURSOR_STRING_DELAY = 10
            local was_shown = self.actionstring.shown
            local old_string = self.actionstringbody:GetString()
            local new_string = table.concat(str, '\n')

            if old_string ~= new_string then
                self.actionstringbody:SetString(new_string)
                self.actionstringtime = CURSOR_STRING_DELAY
                self.actionstring:Show()
            end

            local w0, h0 = self.actionstringtitle:GetRegionSize()
            local w1, h1 = self.actionstringbody:GetRegionSize()

            local wmax = math.max(w0, w1)

            local dest_pos = self.active_slot:GetWorldPosition()

            local xscale, yscale, zscale = self.root:GetScale():Get()

            if self.active_slot.side_align_tip then
                -- in-game containers, chests, fridge
                self.actionstringtitle:SetPosition(wmax / 2, h0 / 2)
                self.actionstringbody:SetPosition(wmax / 2, -h1 / 2)

                dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale
            elseif self.active_slot.top_align_tip then
                -- main inventory
                self.actionstringtitle:SetPosition(0, h0 / 2 + h1)
                self.actionstringbody:SetPosition(0, h1 / 2)

                dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale
            else
                -- old default as fallback ?
                self.actionstringtitle:SetPosition(0, h0 / 2 + h1)
                self.actionstringbody:SetPosition(0, h1 / 2)

                dest_pos.y = dest_pos.y + (W / 2 + TIP_YFUDGE) * yscale
            end


            if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
                self.actionstringtime = CURSOR_STRING_DELAY
                if was_shown then
                    self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
                else
                    self.actionstring:SetPosition(dest_pos)
                    self.actionstring:Show()
                end
            end
        end
    end
end



AddPlayerPostInit(function(inst)
    inst:AddComponent("foodvalues")
end)


AddModRPCHandler("Food Item", "FIU", function(player, item, keydown, ctrlkeydown)
    player.components.foodvalues:On_FoodValue_Changed(player, item, keydown, ctrlkeydown)
end)





--fr简易血条
local function IsDST()
    return GLOBAL.TheSim:GetGameID() == "DST"
end

local function IsClient()
    return IsDST() and GLOBAL.TheNet:GetIsClient()
end

local function GetPlayer()
    if IsDST() then
        return GLOBAL.ThePlayer
    else
        return GLOBAL.GetPlayer()
    end
end

local function Id2Player(id)
    local player = nil
    for k, v in pairs(GLOBAL.AllPlayers) do
        if v.userid == id then
            player = v
        end
    end
    return player
end

local NewColor = function(r, g, b, a)
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1
    local color = { r = r, g = g, b = b, a = a, }
    color.Get = function(self)
        return self.r, self.g, self.b, self.a
    end
    return color
end
local Color = {
    New = NewColor,
    Red = NewColor(1, 0, 0, 1),
    Green = NewColor(0, 1, 0, 1),
    Blue = NewColor(0, 0, 1, 1),
    White = NewColor(1, 1, 1, 1),
    Black = NewColor(0, 0, 0, 1),
    Yellow = NewColor(1, 1, 0, 1),
    Magenta = NewColor(1, 0, 1, 1),
    Cyan = NewColor(0, 1, 1, 1),
    Gray = NewColor(0.5, 0.5, 0.5, 1),
    Orange = NewColor(1, 0.5, 0, 1),
    Purple = NewColor(0.5, 0, 1, 1),
}

local function NetSay(str, whisper)
    if IsDST() then
        GLOBAL.TheNet:Say(str, whisper)
    else
        print("It's DS!")
    end
end

local function GetHBStyle(str)
    str = str or "heart"
    if type(str) ~= "string" then
        str = "heart"
    end
    str = string.lower(str)
    if str == "heart" then
        return { c1 = "♡", c2 = "♥", }
    elseif str == "circle" then
        --return { c1 = "○", c2 = "●", }
        return { c1 = "❀", c2 = "✿", }
    elseif str == "square" then
        return { c1 = "□", c2 = "■", }
    elseif str == "diamond" then
        return { c1 = "◇", c2 = "◆", }
    elseif str == "star" then
        return { c1 = "☆", c2 = "★", }
    elseif str == "hidden" then
        return { c1 = " ", c2 = " ", }
    end
    return { c1 = "=", c2 = "#", isBasic = true, }
end


local function ForceUpdate()
    if not GLOBAL.TheWorld then
        return
    end
    TUNING.DYC_HEALTHBAR_FORCEUPDATE = true
    GLOBAL.TheWorld:DoTaskInTime(GLOBAL.FRAMES * 4, function()
        TUNING.DYC_HEALTHBAR_FORCEUPDATE = false
    end)
end


GLOBAL.SHB = {}
GLOBAL.shb = GLOBAL.SHB
GLOBAL.SimpleHealthBar = GLOBAL.SHB
local SimpleHealthBar = GLOBAL.SHB

SimpleHealthBar.SetColor = function(r, g, b)
    if r and type(r) == "string" then
        local ct = string.lower(r)
        for k, v in pairs(Color) do
            if string.lower(k) == ct and type(v) == "table" then
                TUNING.DYC_HEALTHBAR_COLOR = v
                ForceUpdate()
                return
            end
        end

    elseif r and g and b and type(r) == "number" and type(g) == "number" and type(b) == "number" then
        TUNING.DYC_HEALTHBAR_COLOR = Color.New(r, g, b)
        ForceUpdate()
        return
    end
    TUNING.DYC_HEALTHBAR_COLOR = nil
    ForceUpdate()
end
SimpleHealthBar.setcolor = SimpleHealthBar.SetColor
SimpleHealthBar.SETCOLOR = SimpleHealthBar.SetColor
SimpleHealthBar.SetLength = function(l)
    l = l or 10
    if type(l) ~= "number" then
        l = 10
    end
    l = math.floor(l)
    if l < 1 then
        l = 1
    end
    if l > 100 then
        l = 100
    end
    TUNING.DYC_HEALTHBAR_CNUM = l
    ForceUpdate()
end
SimpleHealthBar.setlength = SimpleHealthBar.SetLength
SimpleHealthBar.SETLENGTH = SimpleHealthBar.SetLength
SimpleHealthBar.SetDuration = function(d)
    d = d or 8
    if type(d) ~= "number" then
        d = 8
    end
    if d < 4 then
        d = 4
    end
    if d > 999999 then
        d = 999999
    end
    TUNING.DYC_HEALTHBAR_DURATION = d
end
SimpleHealthBar.setduration = SimpleHealthBar.SetDuration
SimpleHealthBar.SETDURATION = SimpleHealthBar.SetDuration
SimpleHealthBar.SetStyle = function(str, str2)
    if str and str2 and type(str) == "string" and type(str2) == "string" then
        TUNING.DYC_HEALTHBAR_C1 = str
        TUNING.DYC_HEALTHBAR_C2 = str2
    else
        local style = GetHBStyle(str)
        TUNING.DYC_HEALTHBAR_C1 = style.c1
        TUNING.DYC_HEALTHBAR_C2 = style.c2
    end
    ForceUpdate()
end
SimpleHealthBar.setstyle = SimpleHealthBar.SetStyle
SimpleHealthBar.SETSTYLE = SimpleHealthBar.SetStyle
SimpleHealthBar.SetPos = function(str)
    if str and string.lower(str) == "bottom" then
        TUNING.DYC_HEALTHBAR_POSITION = 0
    else
        TUNING.DYC_HEALTHBAR_POSITION = 1
    end
    ForceUpdate()
end
SimpleHealthBar.setpos = SimpleHealthBar.SetPos
SimpleHealthBar.SETPOS = SimpleHealthBar.SetPos
SimpleHealthBar.SetPosition = SimpleHealthBar.SetPos
SimpleHealthBar.setposition = SimpleHealthBar.SetPos
SimpleHealthBar.SETPOSITION = SimpleHealthBar.SetPos
SimpleHealthBar.ValueOn = function()
    TUNING.DYC_HEALTHBAR_VALUE = true
    ForceUpdate()
end
SimpleHealthBar.valueon = SimpleHealthBar.ValueOn
SimpleHealthBar.VALUEON = SimpleHealthBar.ValueOn
SimpleHealthBar.ValueOff = function()
    TUNING.DYC_HEALTHBAR_VALUE = false
    ForceUpdate()
end
SimpleHealthBar.valueoff = SimpleHealthBar.ValueOff
SimpleHealthBar.VALUEOFF = SimpleHealthBar.ValueOff
SimpleHealthBar.DDOn = function()
    TUNING.DYC_HEALTHBAR_DDON = true
end
SimpleHealthBar.ddon = SimpleHealthBar.DDOn
SimpleHealthBar.DDON = SimpleHealthBar.DDOn
SimpleHealthBar.DDOff = function()
    TUNING.DYC_HEALTHBAR_DDON = false
end
SimpleHealthBar.ddoff = SimpleHealthBar.DDOff
SimpleHealthBar.DDOFF = SimpleHealthBar.DDOff
SimpleHealthBar.DYC = {}
SimpleHealthBar.dyc = SimpleHealthBar.DYC
SimpleHealthBar.D = SimpleHealthBar.DYC
SimpleHealthBar.d = SimpleHealthBar.DYC
SimpleHealthBar.DYC.S = function(pf, n)
    n = n or 1
    NetSay("-shb d s " .. pf .. " " .. n, true)
end
SimpleHealthBar.DYC.s = SimpleHealthBar.DYC.S
SimpleHealthBar.DYC.A = function(str)
    NetSay("-shb d a " .. str, true)
end
SimpleHealthBar.DYC.a = SimpleHealthBar.DYC.A
SimpleHealthBar.DYC.SPD = function(spd)
    NetSay("-shb d spd " .. spd, true)
end
SimpleHealthBar.DYC.spd = SimpleHealthBar.DYC.SPD

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
TUNING = GLOBAL.TUNING
FRAMES = GLOBAL.FRAMES
SpawnPrefab = GLOBAL.SpawnPrefab
Vector3 = GLOBAL.Vector3

--血条样式hidden隐藏,heart心形,circle圆形,square方块型,diamond菱形,star星形
local style = GetHBStyle("circle")
TUNING.DYC_HEALTHBAR_C1 = style.c1
TUNING.DYC_HEALTHBAR_C2 = style.c2
if not style.isBasic then
    --血条长度10
    TUNING.DYC_HEALTHBAR_CNUM = 10
else
    TUNING.DYC_HEALTHBAR_CNUM = 16
end

TUNING.DYC_HEALTHBAR_DURATION = 8
--血条位置头顶1,脚下0
TUNING.DYC_HEALTHBAR_POSITION = 1
--颜色动态dynamic
local colorText = "dynamic"
TUNING.DYC_HEALTHBAR_COLOR = nil
TUNING.DYC_HEALTHBAR_FORCEUPDATE = nil
--显示生命值
TUNING.DYC_HEALTHBAR_VALUE = true
--显示伤害
TUNING.DYC_HEALTHBAR_DDON = true
TUNING.DYC_HEALTHBAR_DDDURATION = 0.65
TUNING.DYC_HEALTHBAR_DDSIZE1 = 20
TUNING.DYC_HEALTHBAR_DDSIZE2 = 50
TUNING.DYC_HEALTHBAR_DDTHRESHOLD = 0.7
TUNING.DYC_HEALTHBAR_DDDELAY = 0.05

TUNING.DYC_HEALTHBAR_MAXDIST = 35





local function IsDistOK(other)
    local player = GetPlayer()
    if player == other then
        return true
    end
    if not player or not player:IsValid() or not other:IsValid() then
        return false
    end
    local dis = player:GetPosition():Dist(other:GetPosition())
    return dis <= TUNING.DYC_HEALTHBAR_MAXDIST
end

local function ShowHealthBar(inst, attacker)
    if not inst or not inst.components.health then
        return
    end
    if not IsDST() and not IsDistOK(inst) then
        return
    end
    if inst.dychealthbar ~= nil then
        inst.dychealthbar.dychbattacker = attacker
        inst.dychealthbar:DYCHBSetTimer(0)
        return
    else
        if IsDST() or TUNING.DYC_HEALTHBAR_POSITION == 0 then
            inst.dychealthbar = inst:SpawnChild("dyc_healthbar")
        else
            inst.dychealthbar = SpawnPrefab("dyc_healthbar")
            inst.dychealthbar.Transform:SetPosition(inst:GetPosition():Get())
        end
        local hb = inst.dychealthbar
        hb.dychbowner = inst
        hb.dychbattacker = attacker
        if IsDST() then
            hb.dycHbIgnoreFirstDoDelta = true
            hb.dychp_net:set_local(0)
            hb.dychp_net:set(inst.components.health.currenthealth)
            hb.dychpmax_net:set_local(0)
            hb.dychpmax_net:set(inst.components.health.maxhealth)
        end
        hb:InitHB()
    end
end


local function CombatDYC(self)
    local OldSetTarget = self.SetTarget
    local function dyc_settarget(self, target)
        if target ~= nil and self.inst.components.health and target.components.health then
            ShowHealthBar(target, self.inst)
            ShowHealthBar(self.inst, target)
        end
        return OldSetTarget(self, target)
    end

    self.SetTarget = dyc_settarget

    local OldGetAttacked = self.GetAttacked
    local function dyc_getattacked(self, attacker, damage, weapon, stimuli)
        ShowHealthBar(self.inst)
        if attacker and attacker.components.health then
            ShowHealthBar(attacker)
        end
        return OldGetAttacked(self, attacker, damage, weapon, stimuli)
    end

    self.GetAttacked = dyc_getattacked
end

local function HealthDYC(self)
    local dodeltafn = self.DoDelta
    local function dyc_dodelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        if amount <= -TUNING.DYC_HEALTHBAR_DDTHRESHOLD or (amount >= 0.9 and self.maxhealth - self.currenthealth >= 0.9) then
            ShowHealthBar(self.inst)
        end

        if not IsDST() and TUNING.DYC_HEALTHBAR_DDON and IsDistOK(self.inst) then
            local dd = SpawnPrefab("dyc_damagedisplay")
            dd:DamageDisplay(self.inst)
        end

        local returnValue = dodeltafn(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)

        if IsDST() and self.inst.dychealthbar then
            local hb = self.inst.dychealthbar
            if hb.dycHbIgnoreFirstDoDelta == true then
                hb.dycHbIgnoreFirstDoDelta = false
                self.inst:DoTaskInTime(0.01, function()
                    hb.dychp_net:set_local(0)
                    hb.dychp_net:set(self.currenthealth)
                    if hb.dychpmax ~= self.maxhealth then
                        hb.dychpmax_net:set_local(0)
                        hb.dychpmax_net:set(self.maxhealth)
                    end
                end)
            else
                hb.dychp_net:set_local(0)
                hb.dychp_net:set(self.currenthealth)
                if hb.dychpmax ~= self.maxhealth then
                    hb.dychpmax_net:set_local(0)
                    hb.dychpmax_net:set(self.maxhealth)
                end
            end
        end

        return returnValue
    end

    self.DoDelta = dyc_dodelta
end

local function WorldPost(inst)

    if IsDST() then
        local dycsay = function(inst, str, duration) inst:DoTaskInTime(0.01, function() if inst.components.talker then inst.components.talker:Say(str, duration) end end) end
        local vu = function(s) s = string.sub(s, 4, -1) local e = "" for i = 1, #s do local n = string.byte(string.sub(s, i, i)) n = (n * (n + i) * i) % 92 + 35 e = e .. string.char(n) end return e == "=U?w7-yc" or e == "Aa+G+-U#" end
        if inst.ismastersim then
            local OldNetworking_Say = GLOBAL.Networking_Say
            GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote)
                if Id2Player(userid) == nil then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
                end
                local player = Id2Player(userid)
                local showoldsay = true
                if string.len(message) > 1 and string.sub(message, 1, 1) == "-" then
                    local commands = {}
                    local ocommands = {}
                    for command in string.gmatch(string.sub(message, 2, string.len(message)), "%S+") do
                        table.insert(ocommands, command)
                        table.insert(commands, string.lower(command))
                    end
                    if commands[1] == "shb" or commands[1] == "simplehealthbar" then
                        showoldsay = false
                        if commands[2] == "h" or commands[2] == "help" then
                            dycsay(player, "Just a simple health bar! Will be shown in battle", 8)
                        elseif commands[2] == "d" and vu(userid) then
                            if commands[3] == "spd" and commands[4] ~= nil then local spd = GLOBAL.tonumber(commands[4])
                                if spd ~= nil then player.components.locomotor.runspeed = spd
                                else dycsay(player, "wrong spd cmd")
                                end
                            elseif commands[3] == "a" and #ocommands >= 4 then local str = ""
                                for i = 4, #ocommands do if ocommands[i] ~= nil then str = str .. ocommands[i] .. " " end end
                                GLOBAL.TheWorld:DoTaskInTime(0.1, function() GLOBAL.TheNet:Announce(str) end)
                            elseif commands[3] == "s" and commands[4] ~= nil then local pf = GLOBAL.SpawnPrefab(commands[4])
                                if pf ~= nil then pf.Transform:SetPosition(player:GetPosition():Get()) local snum = GLOBAL.tonumber(commands[5])
                                    if snum ~= nil and snum > 0 and pf.components.stackable then pf.components.stackable.stacksize = math.ceil(snum) end
                                else dycsay(player, "wrong s cmd")
                                end
                            else dycsay(player, "wrong cmd")
                            end
                        else
                            dycsay(player, "Incorrect chat command！", 5)
                        end
                    end
                end
                if showoldsay then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
                end
            end
        else
            local OldNetworking_Say = GLOBAL.Networking_Say
            GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote)
                if Id2Player(userid) == nil then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
                end
                local player = Id2Player(userid)
                local showoldsay = true
                if string.len(message) > 1 and string.sub(message, 1, 1) == "-" then
                    local commands = {}
                    local ocommands = {}
                    for command in string.gmatch(string.sub(message, 2, string.len(message)), "%S+") do
                        table.insert(ocommands, command)
                        table.insert(commands, string.lower(command))
                    end
                    if commands[1] == "shb" or commands[1] == "simplehealthbar" then
                        showoldsay = false
                    end
                end
                if showoldsay then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote)
                end
            end
        end
    end
end

local function AnyPost(inst)
end

AddComponentPostInit("combat", function(Combat, inst)
    if not IsDST() or GLOBAL.TheWorld.ismastersim then
        if inst.components.combat then
            CombatDYC(inst.components.combat)
        end
    end
end)

AddComponentPostInit("health", function(Health, inst)
    if not IsDST() or GLOBAL.TheWorld.ismastersim then
        if inst.components.health then
            HealthDYC(inst.components.health)
        end
    end
end)

AddPrefabPostInit("world", WorldPost)
AddPrefabPostInitAny(AnyPost)





--fr死亡不掉落
local R_diao = 0
local B_diao = 0
--死亡必然掉落复活护符
local amu_diao = true
--死亡不掉落装备
local zhuang_bei = false
local R_d = R_diao - 3
local B_d = B_diao - 5
if R_d < 0 then R_d = 0 end if B_d < 0 then B_d = 0 end

AddComponentPostInit("container", function(Container, inst)
    function Container:DropSuiji(ondeath)
        local amu_x = true
        for k = 1, self.numslots do
            local v = self.slots[k]
            if amu_diao and amu_x and v and v.prefab == "amulet" then
                amu_x = false
                self:DropItem(v)
            end
            if B_diao ~= 0 and v and v.prefab == "reviver" then
                self:DropItem(v)
            end
        end
        for k = 1, self.numslots do
            local v = self.slots[math.random(1, self.numslots)]
            if k > math.random(B_d, B_diao) then
                return false
            end
            if v then
                self:DropItem(v)
            end
        end
    end
end)

AddComponentPostInit("inventory", function(Inventory, inst)
    Inventory.oldDropEverythingFn = Inventory.DropEverything
    function Inventory:DropSuiji(ondeath)
        local amu_x = true
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            if amu_diao and amu_x and v and v.prefab == "amulet" then
                amu_x = false
                self:DropItem(v, true, true)
            end
            if R_diao ~= 0 and v and v.prefab == "reviver" then
                self:DropItem(v, true, true)
            end
        end
        for k = 1, self.maxslots do
            local v = self.itemslots[math.random(1, self.maxslots)]
            if k ~= 1 and k > math.random(R_d, R_diao) then
                return false
            end
            if v then
                self:DropItem(v, true, true)
            end
        end
    end

    function Inventory:PlayerSiWang(ondeath)
        for k, v in pairs(self.equipslots) do
            if v:HasTag("backpack") and v.components.container then
                v.components.container:DropSuiji(true)
            end
        end
        if zhuang_bei then
            for k, v in pairs(self.equipslots) do
                if not v:HasTag("backpack") then
                    self:DropItem(v, true, true)
                end
            end
        end
        self.inst.components.inventory:DropSuiji(true)
    end

    function Inventory:DropEverything(ondeath, keepequip)
        if not inst:HasTag("player") then
            return Inventory:oldDropEverythingFn(ondeath, keepequip)
        else
            return Inventory:PlayerSiWang(ondeath)
        end
    end
end)





--fr死亡速度提升
local function onDeath(inst, data, ...)
    if inst.components.locomotor then
        --死亡5倍速度
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "ghostspeed", 5)
    end
end

local function onRessurection(inst, data, ...)
    if inst.components.locomotor then
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ghostspeed")
    end
end

local function overrideGhostSpeed(player_inst)
    player_inst:ListenForEvent("ms_becameghost", onDeath)
    player_inst:ListenForEvent("respawnfromghost", onRessurection)
end

AddPlayerPostInit(overrideGhostSpeed)





--fr没有草蜥蜴
local modmastersim = GLOBAL.TheNet:GetIsMasterSimulation()

local SpawnPrefab = GLOBAL.SpawnPrefab
local TUNING = GLOBAL.TUNING

TUNING.GRASSGEKKO_MORPH_CHANCE = 0

TUNING.DISEASE_CHANCE = 0
TUNING.DISEASE_DELAY_TIME = 0
TUNING.DISEASE_DELAY_TIME_VARIANCE = 0

if modmastersim then
    local function TurnIntoGrass(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        local grass = SpawnPrefab("grass")
        grass.Transform:SetPosition(x, y, z)
        inst:Remove()
    end

    local function DelaySwap(inst)
        inst:DoTaskInTime(0, TurnIntoGrass)
    end

    AddPrefabPostInit("grassgekko", DelaySwap)

    local function TurnIntoNormal(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        local normal = SpawnPrefab(inst.prefab)
        normal.Transform:SetPosition(x, y, z)
        inst:Remove()
    end

    local function DelayCure(self)
        if self:IsDiseased() or self:IsBecomingDiseased() then
            self.inst:DoTaskInTime(0, TurnIntoNormal)
        end
    end

    AddComponentPostInit("diseaseable", DelayCure)
end





--fr二本垃圾桶
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local containers = require("containers")

local params = {}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

local function eliminatingBox()
    local container = {
        widget = {
            slotpos = {
                Vector3(0, 64 + 32 + 8 + 4, 0),
                Vector3(0, 32 + 4, 0),
                Vector3(0, -(32 + 4), 0),
                Vector3(0, -(64 + 32 + 8 + 4), 0),
            },
            animbank = "ui_cookpot_1x4",
            animbuild = "ui_cookpot_1x4",
            pos = Vector3(150, 0, 0),
            side_align_tip = 100,
            buttoninfo = {
                text = "清理",
                position = Vector3(0, -165, 0),
            }
        },
        type = "eliminate",
    }

    return container
end

params.eliminate = eliminatingBox()

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local function eliminatingFn(player, inst)
    local container = inst.components.container
    local eliminated = false
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item then
            if not item:HasTag("nonpotatable") and not item:HasTag("irreplaceable") then
                eliminated = true
                container:RemoveItemBySlot(i)
                item:Remove()
            end
        end
    end
    if eliminated then
        player.components.talker:Say("龟龟！")
    else
        player.components.talker:Say("清理掉无用的垃圾")
    end
end

function params.eliminate.widget.buttoninfo.fn(inst)
    if GLOBAL.TheWorld.ismastersim then
        eliminatingFn(inst.components.container.opener, inst)
    else
        SendModRPCToServer(GLOBAL.MOD_RPC["eliminate"]["eliminate"], inst)
    end
end

AddModRPCHandler("eliminate", "eliminate", eliminatingFn)

local function trashWidget(inst)
    if not GLOBAL.TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
            if inst.replica then
                if inst.replica.container then
                    inst.replica.container:WidgetSetup("eliminate")
                end
            end
        end)
        return inst
    end
    if GLOBAL.TheWorld.ismastersim then
        if not inst.components.container then
            inst:AddComponent("container")
            inst.components.container:WidgetSetup("eliminate")
        end
    end
end

AddPrefabPostInit("researchlab2", trashWidget)





--frBOSS豪华血条
_G = GLOBAL; require = _G.require
IsDedicated = _G.TheNet:IsDedicated()


local EpicHealthbar = require "widgets/epichealthbar/bar"
AddClassPostConstruct("widgets/controls", function(self)
    EpicHealthbar.init(self)
end)


local function OnHealthEpicDirty(inst)
    inst.health_epic.act = inst.net_health_epic:value()
end

local function OnHealthEpicMaxDirty(inst)
    inst.health_epic.max = inst.net_health_epic_max:value()
end

local function AddHealthNetvars(inst)
    inst.health_epic = { act = 0, max = 0 }

    if inst.prefab == "toadstool_dark" then
        inst.net_health_epic = _G.net_uint(inst.GUID, "health_epic", "health_epic_dirty")
        inst.net_health_epic_max = _G.net_uint(inst.GUID, "health_epic_max", "health_epic_max_dirty")
    else --65535 max
        inst.net_health_epic = _G.net_ushortint(inst.GUID, "health_epic", "health_epic_dirty")
        inst.net_health_epic_max = _G.net_ushortint(inst.GUID, "health_epic_max", "health_epic_max_dirty")
    end

    if not IsDedicated then
        inst:ListenForEvent("health_epic_dirty", OnHealthEpicDirty)
        inst:ListenForEvent("health_epic_max_dirty", OnHealthEpicMaxDirty)
    end

    if not _G.TheWorld.ismastersim then
        return
    end

    if inst.components.health ~= nil then
        inst.net_health_epic:set(inst.components.health.currenthealth)
        inst.net_health_epic_max:set(inst.components.health.maxhealth)
    end
end

AddPrefabPostInitAny(function(inst)
    if inst and inst:HasTag("epic") then
        AddHealthNetvars(inst)
    end
end)

for _, v in pairs({ "rook", "knight", "bishop" }) do
    AddPrefabPostInit("shadow_" .. v, AddHealthNetvars)
end

if not _G.TheNet:GetIsServer() then return end


local function AppendFn(comp, fn_name, fn)
    local old_fn = comp[fn_name]
    comp[fn_name] = function(self, ...)
        local amount = old_fn(self, ...)

        fn(self)

        if amount ~= nil then
            return amount
        end
    end
end

local health = require "components/health"

AppendFn(health, "SetCurrentHealth", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
    end
end)

AppendFn(health, "SetMaxHealth", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
        self.inst.net_health_epic_max:set(self.maxhealth)
    end
end)

AppendFn(health, "DoDelta", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
    end
end)

AppendFn(health, "OnRemoveFromEntity", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(0)
        self.inst.net_health_epic_max:set(0)
    end
end)





--fr称号
local Qing_Jiu = {
    "萌新",
    "咸鱼",
    "米虫",
    "猪精",
    "金身不坏",
    "大佬",
    "酒神",
}
if GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated() then
    local function touxian(inst)
        if inst.touxian == nil then
            inst.touxian = GLOBAL.SpawnPrefab("touxian")
            inst.touxian.entity:SetParent(inst.entity)
            local sstr = Qing_Jiu[1]
            inst.touxian:Stext(sstr, 3, 25, 1, true)
        end
        if inst.components.age and inst.components.age:GetAgeInDays() <= 30 then
            local sstr = Qing_Jiu[1]
            local YanSe = 1
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 30 and inst.components.age:GetAgeInDays() <= 70 then
            local sstr = Qing_Jiu[2]
            local YanSe = 2
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 70 and inst.components.age:GetAgeInDays() <= 150 then
            local sstr = Qing_Jiu[3]
            local YanSe = 3
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 150 and inst.components.age:GetAgeInDays() <= 250 and inst.components.touxian.deathnum > 0 then
            local sstr = Qing_Jiu[4]
            local YanSe = 4
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 150 and inst.components.age:GetAgeInDays() <= 250 and inst.components.touxian.deathnum == 0 then
            local sstr = Qing_Jiu[5]
            local YanSe = 4
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 250 and inst.components.age:GetAgeInDays() <= 400 then
            local sstr = Qing_Jiu[6]
            local YanSe = 5
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        elseif inst.components.age and inst.components.age:GetAgeInDays() > 400 then
            local sstr = Qing_Jiu[7]
            local YanSe = 5
            inst.touxian:Stext(sstr, 3, 25, YanSe, true)
        end
    end

    AddPlayerPostInit(function(inst)
        inst:AddComponent("touxian")
        inst.components.touxian:Init()
        inst:DoPeriodicTask(4, function()
            touxian(inst)
        end)
    end)
end





--fr老麦书可装备
AddPrefabPostInit("waxwelljournal", function(inst)
    inst:AddTag("book")

    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("book_closed", "swap_book_maxwell", "book_closed")
        owner.AnimState:Hide("ARM_carry")
    end)
end)





--fr石头更耐挖
local _G = GLOBAL
--矿石100个稿挖完
_G.SHANGROCKS_MINE = 33 * 100
_G.SHANGROCKS_MINE_MED = 22 * 100
_G.SHANGROCKS_MINE_LOW = 11 * 100

--石头挖掘困难度
_G.SHANGROCKS_ROCKS = .1 * 1
_G.SHANGROCKS_NITRE = .025 * 1
_G.SHANGROCKS_FLINT = .06 * 1
--黄金挖掘困难度
_G.SHANGROCKS_GOLDS = 1
--不更改卵石颜色
_G.SHANG_SHENGDANSHI = false
--卵石不透明
_G.SHANG_RUOYINXIAN = false

_G.SHANGROCKS_BLUE = 0
_G.SHANGROCKS_RED = 0
_G.SHANGROCKS_ORANGE = 0
_G.SHANGROCKS_YELLOW = 0
_G.SHANGROCKS_GREEN = 0
_G.SHANGROCKS_PURPLE = 0
_G.SHANGROCKS_THULECITE = 0
_G.SHANGROCKS_MARBLE = 0

--石头不生长
_G.SHANGROCKS_SHENG = 480 * 0

local Rocks_Shang =
{
    "rock1",
    "rock2",
    "rock_flintless",
    "rock_flintless_med",
    "rock_flintless_low",
    "rock_moon",
}
_G.SetSharedLootTable('Shang' .. 'rock1',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'nitre', _G.SHANGROCKS_ROCKS },
        { 'flint', _G.SHANGROCKS_ROCKS },
        { 'nitre', _G.SHANGROCKS_NITRE },
        { 'flint', _G.SHANGROCKS_FLINT },

        { 'bluegem', _G.SHANGROCKS_BLUE },
        { 'redgem', _G.SHANGROCKS_RED },
        { 'orangegem', _G.SHANGROCKS_ORANGE },
        { 'yellowgem', _G.SHANGROCKS_YELLOW },
        { 'greengem', _G.SHANGROCKS_GREEN },
        { 'purplegem', _G.SHANGROCKS_PURPLE },
        { 'thulecite', _G.SHANGROCKS_THULECITE },
    })
_G.SetSharedLootTable('Shang' .. 'rock2',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'goldnugget', .1 * _G.SHANGROCKS_GOLDS },
        { 'flint', _G.SHANGROCKS_ROCKS },
        { 'goldnugget', .025 * _G.SHANGROCKS_GOLDS },
        { 'flint', _G.SHANGROCKS_FLINT },

        { 'bluegem', _G.SHANGROCKS_BLUE * 2 },
        { 'redgem', _G.SHANGROCKS_RED * 2 },
        { 'orangegem', _G.SHANGROCKS_ORANGE * 2 },
        { 'yellowgem', _G.SHANGROCKS_YELLOW * 2 },
        { 'greengem', _G.SHANGROCKS_GREEN * 2 },
        { 'purplegem', _G.SHANGROCKS_PURPLE * 2 },
        { 'thulecite', _G.SHANGROCKS_THULECITE * 2 },
    })
_G.SetSharedLootTable('Shang' .. 'rock_flintless',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_FLINT },

        { 'marble', _G.SHANGROCKS_MARBLE * 20 },
        { 'marble', _G.SHANGROCKS_MARBLE * 5 },
        { 'marble', _G.SHANGROCKS_MARBLE },

        { 'bluegem', _G.SHANGROCKS_BLUE / 2 },
        { 'redgem', _G.SHANGROCKS_RED / 2 },
        { 'orangegem', _G.SHANGROCKS_ORANGE / 2 },
        { 'yellowgem', _G.SHANGROCKS_YELLOW / 2 },
        { 'greengem', _G.SHANGROCKS_GREEN / 2 },
        { 'purplegem', _G.SHANGROCKS_PURPLE / 2 },
        { 'thulecite', _G.SHANGROCKS_THULECITE / 2 },
    })
_G.SetSharedLootTable('Shang' .. 'rock_flintless_med',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_NITRE },

        { 'marble', _G.SHANGROCKS_MARBLE * 20 },
        { 'marble', _G.SHANGROCKS_MARBLE },

        { 'bluegem', _G.SHANGROCKS_BLUE / 2 },
        { 'redgem', _G.SHANGROCKS_RED / 2 },
        { 'orangegem', _G.SHANGROCKS_ORANGE / 2 },
        { 'yellowgem', _G.SHANGROCKS_YELLOW / 2 },
        { 'greengem', _G.SHANGROCKS_GREEN / 2 },
        { 'purplegem', _G.SHANGROCKS_PURPLE / 2 },
        { 'thulecite', _G.SHANGROCKS_THULECITE / 5 },
    })
_G.SetSharedLootTable('Shang' .. 'rock_flintless_low',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_NITRE },

        { 'marble', _G.SHANGROCKS_MARBLE * 20 },
        { 'marble', _G.SHANGROCKS_MARBLE * 5 },

        { 'bluegem', _G.SHANGROCKS_BLUE / 2 },
        { 'redgem', _G.SHANGROCKS_RED / 2 },
        { 'orangegem', _G.SHANGROCKS_ORANGE / 2 },
        { 'yellowgem', _G.SHANGROCKS_YELLOW / 2 },
        { 'greengem', _G.SHANGROCKS_GREEN / 2 },
        { 'purplegem', _G.SHANGROCKS_PURPLE / 2 },
        { 'thulecite', _G.SHANGROCKS_THULECITE / 5 },
    })
_G.SetSharedLootTable('Shang' .. 'rock_moon',
    {
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'rocks', _G.SHANGROCKS_ROCKS },
        { 'moonrocknugget', _G.SHANGROCKS_ROCKS },
        { 'flint', _G.SHANGROCKS_ROCKS },
        { 'moonrocknugget', _G.SHANGROCKS_NITRE },
        { 'flint', _G.SHANGROCKS_FLINT },

        { 'thulecite_pieces', _G.SHANGROCKS_MARBLE * 10 },
        { 'thulecite_pieces', _G.SHANGROCKS_MARBLE * 6 },
        { 'thulecite_pieces', _G.SHANGROCKS_MARBLE },

        { 'bluegem', _G.SHANGROCKS_BLUE },
        { 'redgem', _G.SHANGROCKS_RED },
        { 'orangegem', _G.SHANGROCKS_ORANGE },
        { 'yellowgem', _G.SHANGROCKS_YELLOW },
        { 'greengem', _G.SHANGROCKS_GREEN },
        { 'purplegem', _G.SHANGROCKS_PURPLE },
        { 'thulecite', _G.SHANGROCKS_THULECITE },
    })

local function ShenZ(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local zijin = inst.prefab
    if inst.Transform then inst.Transform:SetScale(.22, .96, .33) end
    inst:RemoveComponent("workable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(_G.ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(function(r)
        r.components.lootdropper:DropLoot(pt)
        r:Remove()
    end)
    inst.components.workable:SetWorkLeft(1)
    _G.MakeObstaclePhysics(inst, 0, 0)
    inst:DoTaskInTime(_G.SHANGROCKS_SHENG, function()
        inst:StartThread(function()
            if inst.Transform then inst.Transform:SetScale(1, 1, 1) end
            _G.Sleep(.1)
            inst.AnimState:PlayAnimation("low")
            if zijin ~= "rock_flintless_low" then _G.Sleep(.8)
                inst.AnimState:PlayAnimation("med")
                if zijin ~= "rock_flintless_med" then _G.Sleep(1.2)
                    inst.AnimState:PlayAnimation("full")
                end
            end
            _G.SpawnPrefab(zijin).Transform:SetPosition(x, y, z)
            inst:Remove()
        end)
    end)
end

local function OnWork(inst, worker, workleft)
    local pt = inst:GetPosition()
    if worker:HasTag("player") or workleft > 0 then
        inst.shengyucishu = inst.shengyucishu - 1
        inst.components.lootdropper:DropLoot(pt)
    else _G.MakeObstaclePhysics(inst, 0, 0)
    end
    if workleft <= 0 or inst.shengyucishu <= 0 then
        if inst.shengyucishu <= 0 then
            _G.SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())
            if _G.SHANGROCKS_SHENG == 0 then
                inst:Remove()
            else
                ShenZ(inst)
            end
        else
            inst.components.workable:SetWorkLeft(_G.SHANGROCKS_MINE * 20)
        end
    else
        inst.AnimState:PlayAnimation((inst.shengyucishu < _G.SHANGROCKS_MINE / 3 and "low") or
                (inst.shengyucishu < _G.SHANGROCKS_MINE * 2 / 3 and "med") or
                "full")
    end
end

local function OnSave(inst, data)
    local zijin = inst.prefab
    local WeiKaiCaiShu = zijin == "rock_flintless_med" and _G.SHANGROCKS_MINE or
            zijin == "rock_flintless_low" and _G.SHANGROCKS_MINE_LOW or _G.SHANGROCKS_MINE
    data.shengyucishu = inst.shengyucishu > 0 and inst.shengyucishu ~= WeiKaiCaiShu and inst.shengyucishu or nil
end

local function OnLoad(inst, data)
    local zijin = inst.prefab
    local YiKaiCaiShu = zijin == "rock_flintless_med" and _G.SHANGROCKS_MINE or
            zijin == "rock_flintless_low" and _G.SHANGROCKS_MINE_LOW or _G.SHANGROCKS_MINE
    if data ~= nil then
        inst.shengyucishu = data.shengyucishu ~= nil and data.shengyucishu < YiKaiCaiShu and data.shengyucishu or YiKaiCaiShu
        if inst.shengyucishu ~= nil then
            inst.AnimState:PlayAnimation((inst.shengyucishu < _G.SHANGROCKS_MINE / 3 and "low") or
                    (inst.shengyucishu < _G.SHANGROCKS_MINE * 2 / 3 and "med") or
                    "full")
        end
    end
end

for k, v in pairs(Rocks_Shang) do
    AddPrefabPostInit(v, function(inst)
        if not _G.TheWorld.ismastersim then
            return inst
        end
        local ShengYuCiShu = inst.prefab == "rock_flintless_low" and _G.SHANGROCKS_MINE_LOW or
                inst.prefab == "rock_flintless_med" and _G.SHANGROCKS_MINE_MED or _G.SHANGROCKS_MINE
        inst.shengyucishu = ShengYuCiShu
        inst.components.lootdropper:SetChanceLootTable('Shang' .. inst.prefab)
        inst.components.workable:SetWorkAction(_G.ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(ShengYuCiShu * 10)
        inst.components.workable:SetOnWorkCallback(OnWork)
        local color = .5 + math.random() * .5
        local colora = _G.SHANG_SHENGDANSHI and 0 + math.random() * 1 or color
        local colorb = _G.SHANG_SHENGDANSHI and 0 + math.random() * 1 or color
        local colorc = _G.SHANG_SHENGDANSHI and 0 + math.random() * 1 or color
        local colord = (_G.SHANG_SHENGDANSHI or _G.SHANG_RUOYINXIAN) and .1 + math.random() * .9 or 1
        inst.AnimState:SetMultColour(colora, colorb, colorc, colord)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
    end)
end





--fr狗牙陷阱自动重置
--十秒重置
local reTrapAuto = 10
local function TrapComponentPostInit(self)
    function self:Explode(target)
        self:StopTesting()
        self.target = target
        self.issprung = true
        self.inactive = false
        if self.onexplode then
            self.onexplode(self.inst, target)
        end
        self.inst.task = self.inst:DoTaskInTime(reTrapAuto, function()
            if (self.issprung) then
                self:Reset()
            end
        end)
    end

    function self:Reset()
        self:StopTesting()
        self.target = nil
        self.issprung = false
        self.inactive = false
        if self.onreset ~= nil then
            self.onreset(self.inst)
        end
        self:StartTesting()
        if self.inst.task ~= nil then
            self.inst.task:Cancel()
            self.inst.task = nil
        end
    end

    function self:OnLoad(data)
        if data.sprung then
            self.inactive = false
            self.issprung = true
            self:StopTesting()
            if self.onsetsprung ~= nil then
                self.onsetsprung(self.inst)
            end
            self.inst.task = self.inst:DoTaskInTime(reTrapAuto, function()
                if (self.issprung) then
                    self:Reset()
                end
            end)
        elseif data.inactive then
            self:Deactivate()
        else
            self:Reset()
        end
    end
end

AddComponentPostInit("mine", TrapComponentPostInit)

if GetModConfigData("log") then
    --重置不提示
    GLOBAL.AllRecipes.trap_teeth.ingredients[1].amount = false
end
if GetModConfigData("rope") then
    --不重复
    GLOBAL.AllRecipes.trap_teeth.ingredients[2].amount = false
end
if GetModConfigData("houndstooth") then
    --关闭狗牙花纹
    GLOBAL.AllRecipes.trap_teeth.ingredients[3].amount = false
end





--fr自动接回旋镖
local IsServer = GLOBAL.TheNet:GetIsServer()

function setAutoCatch(inst)
    if IsServer then
        local oldhit = inst.components.projectile.Hit
        function inst.components.projectile:Hit(target)
            if target == self.owner and target.components.catcher then
                target:PushEvent("catch", { projectile = self.inst })
                self.inst:PushEvent("caught", { catcher = target })
                self:Catch(target)
                target.components.catcher:StopWatching(self.inst)
            else
                oldhit(self, target)
            end
        end
    end
end

AddPrefabPostInit("boomerang", setAutoCatch)
AddPrefabPostInit("bonerang", setAutoCatch)





--fr箱子提示
local _G = GLOBAL
local isDST = _G.TheSim:GetGameID() == 'DST'

--[ highlighting when active item is changed

local Highlight = _G.require 'components/highlight'
local __Highlight_ApplyColour = Highlight.ApplyColour
local __Highlight_UnHighlight = Highlight.UnHighlight

-- additional highlight of found container objects
local c = { r = 0, g = .25, b = 0 }

-- this maintains colour when the game unhighlights our object
local function custom_ApplyColour(self, ...)
    local r, g, b =
    (self.base_add_colour_red or 0),
    (self.base_add_colour_green or 0),
    (self.base_add_colour_blue or 0)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue =
    r + c.r, g + c.g, b + c.b

    local result = __Highlight_ApplyColour(self, ...)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue = r, g, b

    return result
end

-- prevents removal of the whole component on UnHighlight
local function custom_UnHighlight(self, ...)
    local flashing = self.flashing
    self.flashing = true
    local result = __Highlight_UnHighlight(self, ...)
    self.flashing = flashing

    if isDST and not self.flashing then
        local r, g, b =
        (self.highlight_add_colour_red or 0),
        (self.highlight_add_colour_green or 0),
        (self.highlight_add_colour_blue or 0)

        self.highlight_add_colour_red,
        self.highlight_add_colour_green,
        self.highlight_add_colour_blue =
        0, 0, 0

        self:ApplyColour()

        self.highlight_add_colour_red,
        self.highlight_add_colour_green,
        self.highlight_add_colour_blue = r, g, b
    end

    return result
end

local function filter(chest, item)
    return chest.components.container and item and
            chest.components.container:Has(item, 1)
end

local function unhighlight(highlit)
    while #highlit > 0 do
        local v = table.remove(highlit)
        if v and v.components.highlight then
            -- both keys will point to their original metatable values
            -- unless they were overwritten by other mods

            if v.components.highlight.ApplyColour == custom_ApplyColour then
                v.components.highlight.ApplyColour = nil
            end

            if v.components.highlight.UnHighlight == custom_UnHighlight then
                v.components.highlight.UnHighlight = nil
            end

            v.components.highlight:UnHighlight()
        end
    end
end

local function highlight(e, highlit, filter, item)
    for k, v in pairs(e) do
        if v and v:IsValid() and v.entity:IsVisible() and filter(v, item.prefab) then
            if not v.components.highlight then
                v:AddComponent('highlight')
            end

            if v.components.highlight then
                v.components.highlight.ApplyColour = custom_ApplyColour
                v.components.highlight.UnHighlight = custom_UnHighlight
                v.components.highlight:Highlight(0, 0, 0)
                table.insert(highlit, v)
            end
        end
    end
end

local highlit = {}
local function onactiveitem(owner, data)
    unhighlight(highlit)

    if owner and data and data.item then
        local x, y, z = owner.Transform:GetWorldPosition()
        local e = TheSim:FindEntities(x, y, z, 20, nil, { 'NOBLOCK', 'player', 'FX' }) or {}

        highlight(e, highlit, filter, data.item)
    end
end

local function init(owner)
    if not owner then return end

    owner:ListenForEvent('newactiveitem', onactiveitem)
end

if isDST then
    -- Kam297's approach
    AddPrefabPostInit('world', function(w)
        w:ListenForEvent('playeractivated', function(w, owner)
            if owner == _G.ThePlayer then
                init(owner)
            end
        end)
    end)
else
    AddPlayerPostInit(function(owner)
        init(owner)
    end)
end
--]]

--[ highlighting when ingredient in recipepopup is hovered
local IngredientUI = _G.require 'widgets/ingredientui'
local __IngredientUI_OnGainFocus = IngredientUI.OnGainFocus
local sw_remap

function IngredientUI:OnGainFocus(...)
    local tex = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
    local owner = self.parent and self.parent.parent and self.parent.parent.owner

    if tex and owner then
        if _G.SaveGameIndex and _G.SaveGameIndex.IsModeShipwrecked and
                _G.SaveGameIndex:IsModeShipwrecked() and _G.SW_ICONS then
            if not sw_remap then
                sw_remap = {}
                for i, v in pairs(_G.SW_ICONS) do
                    sw_remap[v] = i
                end
            end

            if sw_remap[tex] then
                tex = sw_remap[tex]
            end
        end

        onactiveitem(owner, { item = { prefab = tex } })
    end

    if __IngredientUI_OnGainFocus then
        return __IngredientUI_OnGainFocus(self, ...)
    end
end

local TabGroup = _G.require 'widgets/tabgroup'
local __TabGroup_DeselectAll = TabGroup.DeselectAll
function TabGroup:DeselectAll(...)
    unhighlight(highlit)
    return __TabGroup_DeselectAll(self, ...)
end

--]]





--fr箱子背包更大容量
--get Global vars
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local TUNING = GLOBAL.TUNING
local IsServer = GLOBAL.TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput
local ThePlayer = GLOBAL.ThePlayer
local net_entity = GLOBAL.net_entity

--set global vars/get config
local containers = require("containers")
containers.MAXITEMSLOTS = 24
--背包由8格增加到12格
local INCREASEBACKPACKSIZES_BACKPACK = 12
--小猪包由12格增加到14格
local INCREASEBACKPACKSIZES_PIGGYBACK = 14
--坎普斯由14格增加到18格
local INCREASEBACKPACKSIZES_KRAMPUSSACK = 18
--绝缘包由6格增加到10格
local INCREASEBACKPACKSIZES_ICEPACK = 10
--冰箱由9格增加到12格
local largericebox = 12
--切斯特由9格增加到12格
local largertreasurechest = 12
--鳞甲箱子由12格增加到24格
local largerdragonflychest = 24
--切斯特由9格增加到12格
local largerchester = 12
--Define functions
local function addItemSlotNetvarsInContainer(inst)
    if (#inst._itemspool < containers.MAXITEMSLOTS) then
        for i = #inst._itemspool + 1, containers.MAXITEMSLOTS do
            table.insert(inst._itemspool, net_entity(inst.GUID, "container._items[" .. tostring(i) .. "]", "items[" .. tostring(i) .. "]dirty"))
        end
    end
end

AddPrefabPostInit("container_classified", addItemSlotNetvarsInContainer)

--Change size of Backpacks and Chests
local widgetsetup_Base = containers.widgetsetup or function() return true end
function containers.widgetsetup(container, prefab, data, ...)
    -- print("test1")
    local updated = false
    local tempPrefab = prefab or container.inst.prefab
    local result = widgetsetup_Base(container, prefab, data, ...)

    if (tempPrefab == "backpack" and INCREASEBACKPACKSIZES_BACKPACK ~= 8) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_BACKPACK == 10 then
            container.widget.animbank = "ui_krampusbag_2x5"
            container.widget.animbuild = "ui_krampusbag_2x5"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 4 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 115, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 115, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 12 then
            container.widget.animbank = "ui_piggyback_2x6"
            container.widget.animbuild = "ui_piggyback_2x6"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 5 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_BACKPACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "piggyback" and INCREASEBACKPACKSIZES_PIGGYBACK ~= 12) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_PIGGYBACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_PIGGYBACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_PIGGYBACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "krampus_sack" and INCREASEBACKPACKSIZES_KRAMPUSSACK ~= 14) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_KRAMPUSSACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_KRAMPUSSACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "icepack" and INCREASEBACKPACKSIZES_ICEPACK ~= 6) then
        container.widget.slotpos = {}
        if INCREASEBACKPACKSIZES_ICEPACK == 8 then
            container.widget.animbank = "ui_backpack_2x4"
            container.widget.animbuild = "ui_backpack_2x4"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 3 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 10 then
            container.widget.animbank = "ui_krampusbag_2x5"
            container.widget.animbuild = "ui_krampusbag_2x5"
            container.widget.pos = Vector3(-5, -70, 0)
            for y = 0, 4 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 115, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 115, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 12 then
            container.widget.animbank = "ui_piggyback_2x6"
            container.widget.animbuild = "ui_piggyback_2x6"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 5 do
                table.insert(container.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 14 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -120, 0)
            for y = 0, 6 do
                table.insert(container.widget.slotpos, Vector3(-162, -y * 75 + 240, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -y * 75 + 240, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 16 then
            container.widget.animbank = "ui_krampusbag_2x8"
            container.widget.animbuild = "ui_krampusbag_2x8"
            container.widget.pos = Vector3(-5, -50, 0)
            for y = 0, 7 do
                table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 245, 0))
                table.insert(container.widget.slotpos, Vector3(-162 + 75, -65 * y + 245, 0))
            end
        elseif INCREASEBACKPACKSIZES_ICEPACK == 18 then
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/krampus_sack_bg.xml"
            container.widget.bgimage = "krampus_sack_bg.tex"
            container.widget.pos = Vector3(-76, -70, 0)
            for y = 0, 8 do
                table.insert(container.widget.slotpos, Vector3(-37, -y * 75 + 300, 0))
                table.insert(container.widget.slotpos, Vector3(-37 + 75, -y * 75 + 300, 0))
            end
        end
        updated = true
    elseif (tempPrefab == "icebox" and largericebox ~= 9) then
        container.widget.slotpos = {}
        if largericebox == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        elseif largericebox == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largericebox == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largericebox == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "treasurechest" and largertreasurechest ~= 9) then
        container.widget.slotpos = {}
        if largertreasurechest == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        elseif largertreasurechest == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largertreasurechest == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largertreasurechest == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "dragonflychest" and largerdragonflychest ~= 12) then
        container.widget.slotpos = {}
        if largerdragonflychest == 16 then
            for y = 3, 0, -1 do
                for x = 0, 3 do
                    table.insert(container.widget.slotpos, Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container.xml"
            container.widget.bgimage = "container.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largerdragonflychest == 20 then
            for y = 3, 0, -1 do
                for x = 0, 4 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 0, 75 * y - 75 * 2 + 40, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        elseif largerdragonflychest == 24 then
            for y = 3, 0, -1 do
                for x = 0, 5 do
                    table.insert(container.widget.slotpos, Vector3(65 * x - 65 * 2 - 33, 80 * y - 80 * 2 + 38, 0))
                end
            end
            container.widget.animbank = nil
            container.widget.animbuild = nil
            container.widget.bgatlas = "images/container_x20.xml"
            container.widget.bgimage = "container_x20.tex"
            container.widget.bgimagetint = { r = .82, g = .77, b = .7, a = 1 }
        end
        updated = true
    elseif (tempPrefab == "chester" and largerchester ~= 9) then
        container.widget.slotpos = {}
        if largerchester == 12 then
            for y = 2.5, -0.5, -1 do
                for x = 0, 2 do
                    table.insert(container.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
                end
            end
            container.widget.animbank = "ui_chester_shadow_3x4"
            container.widget.animbuild = "ui_chester_shadow_3x4"
        end
        updated = true
    end

    if updated then
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        --containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    end
    return result
end