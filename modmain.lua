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
    Asset("IMAGE", "images/wpicker.tex"),
    Asset("IMAGE", "minimap/campfire.tex"),
    Asset("ATLAS", "minimap/campfire.xml"),

    Asset("IMAGE", "images/status_bg.tex"),
    Asset("ATLAS", "images/status_bg.xml"),

    Asset("IMAGE", "images/sharelocation.tex"),
    Asset("ATLAS", "images/sharelocation.xml"),
    Asset("IMAGE", "images/unsharelocation.tex"),
    Asset("ATLAS", "images/unsharelocation.xml"),
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





--fr全球定位
PrefabFiles = {
    "globalposition_classified",
    "smoketrail",
    "globalmapicon_noproxy",
    "worldmapexplorer",
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





--防熊锁
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