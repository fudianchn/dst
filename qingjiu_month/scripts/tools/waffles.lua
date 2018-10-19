PrefabFiles = { "fakedynamicshadow", "sparkle_fx" }
Assets = {}

_G = GLOBAL

local isnative = {}
for k in pairs(env) do
	isnative[k] = true
end
local function ReferenceEnvironments()		
	for k,v in pairs(_G) do
		if not isnative[k] then
			env[k] = v
		end
	end
end

ReferenceEnvironments()

AddPrefabPostInit("world", ReferenceEnvironments)

IsServer, IsDedicated = TheNet:GetIsServer(), TheNet:IsDedicated()

FULL_REPLICATE_DELAY = 5 * FRAMES

--------------------------------------------------------------------------
--[[ Waffles ]]
--------------------------------------------------------------------------

Waffles = {}

function declarewaffles()
	if rawget(_G, "Waffles") ~= nil then
		for name, data in pairs(Waffles) do
			if type(data) == "table" then
				for subname, subdata in pairs(data) do				
					Waffles.GetPath(_G, "Waffles/" .. name)[subname] = subdata
				end
			else
				_G["Waffles"][name] = data
			end
		end
	else
		rawset(_G, "Waffles", Waffles)
	end
	
	local LANGUAGE = GetModConfigData("language")
	local RRN = rawget(_G, "RegisterRussianName")

	if RRN then
		stringimport({ "ru", RRN })
	else
		stringimport({ LANGUAGE or "en", true })
	end
end

local function cutpath(path_string)
	local path = {}
	for sub in path_string:gmatch("([^/]+)") do
		local num = tonumber(sub)	
		table.insert(path, num or sub)
	end
	return path
end

local function getgrid(grid)
	local x, z = grid:match("(%d+)x(%d+)")
	return x - 1, z - 1
end

local function tabletopath(root, keys, path)	
	keys = keys or {}
	path = path or ""
	
	for k,v in pairs(root) do
		if type(v) == "table" then
			tabletopath(v, keys, path..k.."/")
		else
			table.insert(keys, { path, k, v })
		end
	end
	
	return keys
end
local function absolutemerge(t1, t2)
	for i,v in pairs(tabletopath(t2)) do
		--Waffles.Announce(v[1]..v[2], v[3])
		Waffles.GetPath(t1, v[1])[v[2]] = v[3]
	end
end
function stringimport(data)
	local PATCHSTRINGS = require("strings/"..data[1])
	
	absolutemerge(STRINGS, PATCHSTRINGS)
	
	if type(PATCHSTRINGS.PO) == "table" and type(data[2]) == "function" then
		for i,v in ipairs(PATCHSTRINGS.PO) do
			if type(v) == "table" then
				data[2](unpack(v))
			end
		end
	end
end

local id = 990420

local wall_anim_variants =
{
	"fullA",
	"fullB",
	"fullC",
}

local MEMORY = {}
setmetatable(MEMORY, { __mode = "v" })

Waffles =
{	
	UpvalueHacker = require("tools/upvaluehacker"),
	
	Memory =
	{
		GetKey = function(...)
			local key = ""
			for i, v in ipairs(arg) do
				key = key.."["..tostring(v).."]"
			end
			return key
		end,
		
		Load = function(...)	
			return MEMORY[Waffles.Memory.GetKey(...)]
		end,
		
		Save = function(value, ...)	
			MEMORY[Waffles.Memory.GetKey(...)] = value
		end
	},
	
	Dummy = function() end,
		
	Valid = function(inst)
		return type(inst) == "table" and inst:IsValid()
	end,
					
	GetPath = function(root, path)		
		local t = root
		for _,v in pairs(cutpath(path)) do
			if type(t[v]) ~= "table" then
				t[v] = { GENERIC = t[v] }
			end
			t = t[v]
		end
		return t
	end,
	
	GetRandom = function(data)
		return data[math.random(#data)]
	end,
	
	Return = function(root, path)
		local t = root
		for _,v in pairs(cutpath(path)) do
			if type(t) ~= "table" then
				return
			end
			t = t[v]
		end
		return t
	end,
		
	Reset = function(inst)
		if inst.userid and #inst.userid > 0 then
			SerializeUserSession(inst)
			inst:Remove()
		else			
			local data = inst:GetSaveRecord()
			
			local x, y, z = data.x, data.y or 0, data.z
			--override position to prevent possible SoundEmitter events playing twice
			data.x, data.y, data.z = 0, 0, 0
			local isexists = table.invert(Waffles.FindNewEntities(x, y, z, 10))
						
			inst:Remove()
			
			--remove other prefabs that might be spawned by removal events
			for i,v in ipairs(Waffles.FindNewEntities(x, y, z, 10)) do
				if not isexists[v] then
					v:Remove()
				end
			end
			
			inst = SpawnSaveRecord(data)
			inst.Transform:SetPosition(x, y, z)
			return inst
		end
	end,
		
	AddChild = function(inst, child)
		inst:AddChild(child)
		child.entity:SetParent(nil)
		return child
	end,
			
	DespawnRecipe = function(inst, mult, nostack)
		if inst.prefab == nil then
			return
		end
		
		local staff = SpawnPrefab("greenstaff")
		staff.persists = false
		
		local despawnfn = Waffles.Return(staff, "components/spellcaster/spell")
		if despawnfn ~= nil then		
			local x, y, z = inst.Transform:GetWorldPosition()
			local time = GetTime()
			
			if AllRecipes[inst.prefab] == nil
			and AllRecipes[inst.prefab.."_builder"] ~= nil then
				inst.prefab = inst.prefab.."_builder"
			end
			despawnfn(staff, inst)

			if not nostack then
				local stackables = Waffles.FindNewEntities(x, y, z, 3, { "_stackable" })
				if #stackables > 0 then
					local restackedents = Waffles.StackEntities(stackables, mult)
					if mult ~= nil and mult > 0 and mult < 1 then
						for i,v in ipairs(restackedents) do
							local stackable = v.components.stackable
							if stackable ~= nil then
								stackable:SetStackSize(math.ceil(stackable:StackSize() * mult))
							end
						end
					end
				end
			end
		end
		
		if Waffles.Valid(staff) then
			staff:Remove()
		end
	end,
			
	DoEpicScare = function(inst, duration, range)
		local x, y, z = inst.Transform:GetWorldPosition()
		for i, v in ipairs(TheSim:FindEntities(x, y, z, range or 15, nil, { "epic", "INLIMBO" }, { "_combat", "locomotor" })) do
			if v ~= inst and v.entity:IsVisible() and not (v.components.health ~= nil and v.components.health:IsDead()) then
				v:PushEvent("epicscare", { scarer = inst, duration = duration or 5 })
			end
		end
	end,
		
	ListenForNextEvent = function(inst, event, fn, source, only_successful, ...)
		local arg = { ... }
		local function OnEvent(inst, data)
			if fn(inst, data, unpack(arg)) or not only_successful then
				inst:RemoveEventCallback(event, OnEvent, source)
			end
		end
		
		inst:ListenForEvent(event, OnEvent, source)
	end,
		
	NegateWorkableFX = function(inst, ignore)
		local x, y, z = inst.Transform:GetWorldPosition()
		local time = GetTime()
		for _,v in pairs(TheSim:FindEntities(x, y, z, 0, { "FX" }, { "INLIMBO" })) do
			if v ~= ignore and v.spawntime == time then
				--print("TTT", v)
				v:Remove()
				return
			end
		end
	end,
	
	GetDistanceDelay = function(inst, target, min, max, low, high)
		return Remap(math.sqrt(inst:GetDistanceSqToInst(target)), min, max, low or 0, high or 1)
	end,
	
	AnimState =
	{		
		PlayWallAnimation = function(inst)
			local x, y, z = inst.Transform:GetWorldPosition()
	
			x = math.floor(x)
			z = math.floor(z)
				
			local q1 = #wall_anim_variants + 1
			local q2 = #wall_anim_variants + 4
			local i = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #wall_anim_variants + 1
	
			inst.AnimState:PlayAnimation(wall_anim_variants[i])
		end,
	},
		
	FindAnyPlayerInRange = function(inst, range)
		for i, v in ipairs(AllPlayers) do
			if v:IsNear(inst, range) then
				return v
			end
		end
	end,
		
	FindNewEntities = function(...)
		local ents = {}
		local time = GetTime()
		for _,v in pairs(TheSim:FindEntities(...)) do
			if v.spawntime == time then
				table.insert(ents, v)
			end
		end
		return ents
	end,
	
	StackEntities = function(ents, mult)
		local prefabs = {}
		local stackingents = {}
		
		local insert = table.insert
		local remove = table.remove
		
		for i,v in ipairs(ents) do
			if v:HasTag("_stackable") then
				local data = prefabs[v.prefab]
				if data == nil then
					data = { stacksize = 0, pos = v:GetPosition() }
					prefabs[v.prefab] = data
				end
				
				data.stacksize = data.stacksize + 1
				
				if stackingents[v.prefab] == nil then
					stackingents[v.prefab] = {}
				end
				insert(stackingents[v.prefab], v)
			end
		end
				
		local stackedents = {} 
		for prefab, data in pairs(prefabs) do			
			local samestackedents = {}
			local stackingprefabs = stackingents[prefab]
			local newent = remove(stackingprefabs)
			insert(stackedents, newent)
			insert(samestackedents, newent)
			while #stackingprefabs > 1 and data.stacksize > 0 do
				local stackable = newent.components.stackable
				local roomleft = stackable ~= nil and stackable:RoomLeft() or 0 
				local delta = math.min(1 + roomleft, data.stacksize)
				
				data.stacksize = data.stacksize - delta
				
				if stackable ~= nil then
					while #stackingprefabs > 0 and roomleft > 0 do
						stackable:Put(remove(stackingprefabs), data.pos)
						roomleft = stackable ~= nil and stackable:RoomLeft() or 0
					end
				end
				
				if #stackingprefabs >= 1 and data.stacksize > 0 and roomleft <= 0 then
					newent = remove(stackingprefabs)
					insert(stackedents, newent)
					insert(samestackedents, newent)
				end
			end
			
			for i,v in ipairs(samestackedents) do
				v.Transform:SetPosition((data.pos + Point(math.random() * 2 - 1, 0, math.random() * 2 - 1)):Get())
			end
		end
		
		for _,t in ipairs(stackingents) do
			for i,v in ipairs(t) do
				if v:IsValid() then
					v:Remove()
				end
			end
		end
						
		return stackedents
	end,
		
	ForceDirty = function(netvar)
		local val = netvar:value()
		netvar:set_local(val)
		netvar:set(val)
	end,
	
	ForceUpdateTabs = function(inst)
		--master sim
		inst:PushEvent("unlockrecipe")
		
		--client
		local bufferedbuilds = Waffles.Return(inst, "player_classified/bufferedbuilds")
		if bufferedbuilds ~= nil then			
			local _, netvar = next(bufferedbuilds)
			if netvar ~= nil then
				Waffles.ForceDirty(netvar)
			end
		end
	end,
		
	SetFn = function(root, key, bool, fn, setfn)
		if type(root) ~= "table" then
			return
		end
		
		if root[key] == nil then
			root[key] = fn
		else
			if setfn == nil then
				setfn = Waffles.ExpandFn
			end
			setfn(root, key, bool, fn)
		end
	end,
	
	DummyCall = function(root, key, rep, ...)		
		local save = nil
		if root ~= nil then
			save = root[key]
			root[key] = Waffles.Dummy
		end
			
		rep(...)
				
		if save ~= nil then
			root[key] = save
		end
	end,
	
	ExpandFn = function(root, key, first, exp)
		if type(root) ~= "table" then
			return
		end
		
		local old = root[key] or Waffles.Dummy
		local mem = Waffles.Memory.Load("Expand", old, key, not not first, exp)
		
		if mem then
			root[key] = mem
		else
			if first then
				root[key] = function(...)
					exp(...)
					return old(...)
				end
			else
				root[key] = function(...)
					old(...)
					exp(...)
				end
			end
			Waffles.Memory.Save(root[key], "Expand", old, key, not not first, exp)
		end
		
		return root[key]
	end,
	
	SequenceFn = function(root, key, argself, exp)
		if type(root) ~= "table" then
			return
		end
		
		local old = root[key]
		local mem = Waffles.Memory.Load("Sequence", old, key, not not argself, exp)
		
		if mem then
			root[key] = mem
		else
			if argself then
				root[key] = function(self, ...)
					local data = { old(self, ...) }
					return exp(self, #data > 1 and data or data[1], ...)
				end
			else
				root[key] = function(...)
					local data = { old(...) }
					return exp(#data > 1 and data or data[1], ...)
				end
			end
			Waffles.Memory.Save(root[key], "Sequence", old, key, not not argself, exp)
		end
	end,
	
	Replace = function(root, key, replace)
		if type(root) ~= "table" then
			return
		end
		
		if replace ~= nil then
			if rawget(root, "__"..key) == nil then
				rawset(root, "__"..key, root[key])
			end
			root[key] = replace
		elseif rawget(root, "__"..key) ~= nil then
			root[key] = root["__"..key]
			root["__"..key] = nil
		end
	end,
	
	CreatePositions =
	{
		Rectangle = function(grid, centered, getall, step)
			local data = { getgrid(grid) }			
			local _x, _z = unpack(data)
			
			table.insert(data, 0)
			data = table.invert(data)
			
			local t = {}
			if step == nil then
				step = 1
			end
			
			local offset = { x = 0, z = 0 }
			if centered then
				offset.x = (_x + 1) / 2
				offset.z = (_z + 1) / 2
			end
			
			for x = 0, _x, step do
				for z = 0, _z, step do
					if getall or data[x] or data[z] then
						table.insert(t, { x = x - offset.x, z = z - offset.z })
					end
				end
			end
			
			return t
		end,
	},
		
	Announce = function(...)
		local _string = ""
		local strings = {}
		for k,v in pairs({ ... }) do
			table.insert(strings, tostring(v))
		end
		_string = table.concat(strings, " ")
		if #_string > 0 then
			TheNet:Announce(_string)
			print('[Waffles] '.._string)
		end
	end,
}

local function DisableHauntedState(inst)
	inst.AnimState:SetHaunted(false)
end

function Waffles.DoHauntFlick(inst, time)
	inst.AnimState:SetHaunted(true)
	inst:DoTaskInTime(time or 1, DisableHauntedState)
end

local function RemoveFakeDynamicShadow(inst)
	if Waffles.Valid(inst.dynamicshadowfake) then
		inst.dynamicshadowfake:Remove()
	end
	inst.dynamicshadowfake = nil
	inst.DynamicShadow:Enable(true)
	
	inst:RemoveEventCallback("newstate", RemoveFakeDynamicShadow)
end

function Waffles.PushFakeShadow(inst, ...)		
	if type(inst.DynamicShadow) ~= "userdata" then
		return
	end
	
	local shadow = SpawnPrefab("fakedynamicshadow")
	shadow:SetTarget(inst, ...)
	
	RemoveFakeDynamicShadow(inst)
	inst.DynamicShadow:Enable(false)
	inst.dynamicshadowfake = shadow
	
	inst:ListenForEvent("newstate", RemoveFakeDynamicShadow)
end

if IsServer then
	AddStategraphPostInit("wilson", function(sg)
		if Waffles.ToggleOffPhysics == nil then
			Waffles.ToggleOffPhysics = Waffles.UpvalueHacker.GetUpvalue(sg.states.jumpout.onenter, "ToggleOffPhysics")
			Waffles.ToggleOnPhysics = Waffles.UpvalueHacker.GetUpvalue(sg.states.jumpout.onexit, "ToggleOnPhysics")
		end
	end)
end

--------------------------------------------------------------------------
--[[ Script Extensions ]]
--------------------------------------------------------------------------

require("entityscript")

if EntityScript.SetEventMute == nil then
	local _PushEvent = EntityScript.PushEvent
	function EntityScript:PushEvent(event, data, ignoremute)
		if ignoremute or not self.eventmuted or not self.eventmuted[event] then
			_PushEvent(self, event, data)
			
			if self.eventshared and self.eventshared[event] then
				local parent = self.entity:GetParent()
				if parent then
					parent:PushEvent(event, data)
				end
			end
		else
			self:PushEvent("__"..event, data)
		end
	end
	
	function EntityScript:SetEventMute(event, muted)
		if self.eventmuted == nil then
			self.eventmuted = {}
		end
		self.eventmuted[event] = muted and true or nil
	end
	
	function EntityScript:SetEventShare(event, shared)
		if self.eventshared == nil then
			self.eventshared = {}
		end
		self.eventshared[event] = shared and true or nil
	end
		
	Waffles.ExpandFn(EntityScript, "Hide", false, function(self)
		self:PushEvent("entityhide")
	end)
	
	Waffles.ExpandFn(EntityScript, "Show", false, function(self)
		self:PushEvent("entityshow")
	end)
end

local AllWorldStateWatchers = nil

function Waffles.GetWorldStateWatchers(inst)
	if AllWorldStateWatchers == nil then
		AllWorldStateWatchers = Waffles.UpvalueHacker.GetUpvalue(TheWorld.components.worldstate.AddWatcher, "_watchers")
	end
	
	local istarget = { [inst] = true }
	for k,v in pairs(inst.components) do
		istarget[v] = true
	end	
	
	local allinstwatchers = {}
	for var, varwatchers in pairs(AllWorldStateWatchers) do
		for target, watchers in pairs(varwatchers) do
			if istarget[target] then
				Waffles.GetPath(allinstwatchers, var)[target] = watchers
			end
		end
	end
	
	return allinstwatchers
end