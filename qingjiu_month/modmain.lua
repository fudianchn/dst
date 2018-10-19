modimport("scripts/tools/waffles")

local BASEMENT_TILES = {}

local function GetInteriorTileCenterPoint(x, y, z)
	return math.floor((x + 2) / 4) * 4, 0, math.floor((z + 2) / 4) * 4
end

local function GetInteriorTileKey(...)
	local x, y, z = GetInteriorTileCenterPoint(...)
	return x.."_"..z
end

Waffles.GetInteriorTileKey = GetInteriorTileKey

local function IsBasementAtPoint(map, x, y, z)
	local source = BASEMENT_TILES[GetInteriorTileKey(x, y, z)]
	return source ~= nil, source
end

local function IsPassableAtPoint(map, passable, x, y, z)
	if passable then
		return true
	end
	return map:IsBasementAtPoint(x, y, z)
end

--[[local function IsDeployPointClear(map, clear, pt)
	return clear or BASEMENT_TILES[GetInteriorTileKey(pt:Get())] ~= nil
end]]

local function GetTileCenterPoint(map, pos, ...)
	if pos ~= nil then
		return unpack(pos)
	end
	return GetInteriorTileCenterPoint(...)
end

local function IsPathClear(pathfinder, isclear, ...)
	if isclear then
		return true
	end
	if TheWorld.Map:IsBasementAtPoint(arg[1], arg[2], arg[3]) then
		if (arg[7] and arg[7].ignorewalls) or not TheWorld.Pathfinder:HasWall(arg[4], arg[5], arg[6]) then
			return true
		end
	end
	return false
end

local TELEBASES = nil

local function DisableInvalidTelebases()
	for telebase in pairs(TELEBASES) do
		if telebase:IsInBasement() then
			TELEBASES[telebase] = nil
		end
	end
end

local function AddTelebaseSearchExtension(inst)
	TELEBASES = Waffles.UpvalueHacker.GetUpvalue(Prefabs.telebase.fn, "TELEBASES") 
	Waffles.ExpandFn(_G, "FindNearestActiveTelebase", true, DisableInvalidTelebases)
end

AddPrefabPostInit("world", function(inst)
	local Map = getmetatable(inst.Map).__index
	Map.IsBasementAtPoint = IsBasementAtPoint
	Waffles.SequenceFn(Map, "IsPassableAtPoint", true, IsPassableAtPoint)
	Waffles.SequenceFn(Map, "IsAboveGroundAtPoint", true, IsPassableAtPoint)
	--Waffles.SequenceFn(Map, "IsDeployPointClear", true, IsDeployPointClear)
	Waffles.SequenceFn(Map, "GetTileCenterPoint", true, GetTileCenterPoint)
	
	local Pathfinder = getmetatable(inst.Pathfinder).__index
	Waffles.SequenceFn(Pathfinder, "IsClear", true, IsPathClear)
	
	if not IsServer then
		return
	end
	
	inst:DoTaskInTime(0, AddTelebaseSearchExtension)
end)

Waffles.GetPath(Waffles, "Map")["AddSyntTile"] =
function(x, y, z, source)
	if TheWorld.Map:GetTileAtPoint(x, y, z) == GROUND.INVALID then
		BASEMENT_TILES[GetInteriorTileKey(x, y, z)] = source or true
	end
end

Waffles.GetPath(Waffles, "Map")["RemoveSyntTile"] =
function(...)
	BASEMENT_TILES[GetInteriorTileKey(...)] = nil
end

if not IsServer then
	Waffles.GetPath(Waffles, "Map")["ClearSyntTiles"] =
	function()
		BASEMENT_TILES = {}
	end
end

require("entityscript")

function EntityScript:IsInBasement()
	return TheWorld.Map:IsBasementAtPoint(self:GetPosition():Get())
end

for _,v in ipairs({ "basement", "basement_upgrades", "explode_rain" }) do
	table.insert(PrefabFiles, v)
end

for _,v in ipairs({ "basement"--[[, "basement_exit"]] }) do
	table.insert(Assets, Asset("ATLAS", "images/inventoryimages/"..v..".xml"))
	AddMinimapAtlas("images/inventoryimages/"..v..".xml")
end

table.insert(Assets, Asset("ATLAS", "images/ui/tab_basement.xml"))

local function JUMPIN_strfn(str, act)
	if str ~= nil then
		return str
	elseif act.target ~= nil and act.target:HasTag("stairs") then
		return "USE"
	end
end

Waffles.SetFn(Waffles.GetPath(_G, "ACTIONS/JUMPIN"), "strfn", false, JUMPIN_strfn, Waffles.SequenceFn)

local steelwool, cutstone, gunpowder = string.match(GetModConfigData("recipe_ingredients"), "(%d+)/(%d+)/(%d+)")
AddRecipe("basement_entrance_builder", {Ingredient("steelwool", steelwool), Ingredient("cutstone", cutstone), Ingredient("gunpowder", gunpowder)},
RECIPETABS[GetModConfigData("recipe_tab")], TECH[GetModConfigData("recipe_tech")], "basement_entrance_placer", 4, nil, nil, nil, "images/inventoryimages/basement.xml", "basement.tex",
function(pt, rot)
	if #TheSim:FindEntities(pt.x, 0, pt.z, 36, { "basement_part" }) > 0 then
		return false
	end
	for x = -2, 1.5, 0.5 do
		for z = -2, 1.5, 0.5 do
			if not TheWorld.Map:IsPassableAtPoint(pt.x + x, 0, pt.z + z) then
				return false
			end
		end
	end
	return true
end)

AddRecipeTab("BASEMENT", 10, "images/ui/tab_basement.xml", "tab_basement.tex", nil, true)

local blockedtiles =
{
	["8_12"] = true,
	["8_8"] = true,
	["12_8"] = true,
	["12_12"] = true,
}

local function walltestfn(pt, rot)
	local pttile = GetInteriorTileKey(pt.x, 0, pt.z)
	local tx, ty, tz = TheWorld.Map:GetTileCenterPoint(pt.x, 0, pt.z)
	for i,v in ipairs(TheSim:FindEntities(tx, 0, tz, 6, nil, { "NOBLOCK", "FX", "INLIMBO", "DECOR" })) do
		if GetInteriorTileKey(v.Transform:GetWorldPosition()) == pttile then
			return false
		end
	end
	for i,v in ipairs(TheSim:FindEntities(tx, 0, tz, 6, nil, { "FX", "INLIMBO", "DECOR" })) do
		if GetInteriorTileKey(v.Transform:GetWorldPosition()) == pttile and v.Physics ~= nil then
			return false
		end
	end
	local basement = TheSim:FindEntities(pt.x, 0, pt.z, 70, { "basement_part", "basement_core" })[1]
	if basement == nil then
		return false
	else
		local bx, by, bz = TheWorld.Map:GetTileCenterPoint(basement.Transform:GetWorldPosition())
		if blockedtiles[GetInteriorTileKey(bx - tx, 0, bz - tz)] then
			return false
		end
	end
	return true
end

local UPGRAGE_RECIPES =
{	
	{
		prefab = "wall",
		ingredients = { Ingredient("cutstone", 2), Ingredient("nitre", 4) },
		placer = true,
		min_spacing = 0,
		image = "wall_stone_item",
		testfn = walltestfn,
	},
	
	{
		prefab = "floor_1",
		ingredients = { Ingredient("cutstone", 2), Ingredient("flint", 2) },
		image = "turf_rocky",
	},
	
	{
		prefab = "floor_2",
		ingredients = { Ingredient("boards", 4), Ingredient("flint", 4) },
		image = "turf_woodfloor",
		descoverride = "turf_woodfloor",
	},
	
	{
		prefab = "floor_3",
		ingredients = { Ingredient("marble", 4), Ingredient("silk", 6) },
		image = "turf_checkerfloor",
		descoverride = "turf_checkerfloor",
	},
			
	{
		prefab = "gunpowder",
		ingredients = { Ingredient("gunpowder", 3), Ingredient("nitre", 6) },
		placer = true,
		min_spacing = 3.7,
		tag = "basement_upgradeuser_owner",
		image = "gunpowder",
	},
}

for _, data in ipairs(UPGRAGE_RECIPES) do
	local prefab = "basement_upgrade_"..data.prefab
	
	AddRecipe(prefab,
		data.ingredients, CUSTOM_RECIPETABS.BASEMENT, data.tech or TECH.NONE,
		data.placer and prefab.."_placer", data.min_spacing, true, nil, data.tag or "basement_upgradeuser",
		data.atlas or "images/inventoryimages.xml", data.image..".tex", data.testfn
	)
	
	if data.descoverride ~= nil then
		local path = Waffles.GetPath(_G, "STRINGS/RECIPE_DESC")
		path[prefab:upper()] = path[data.descoverride:upper()]
	end
end

--[[!]] if not IsServer then
	declarewaffles()
	return
end

AddStategraphState("wilson", State {
	name = "jumpout_ceiling",
	tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

	onenter = function(inst)
		Waffles.ToggleOffPhysics(inst)
		inst.components.locomotor:Stop()
		
		inst.AnimState:PlayAnimation("jumpout")
		inst.AnimState:SetTime(0.2)
		
		local x, y, z = inst.Transform:GetWorldPosition()
		inst.Physics:Teleport(x, 4, z)
		inst.Physics:SetMotorVel(5, -8, 0)
		
		Waffles.PushFakeShadow(inst, 1.3, 0.6)
		
		inst.AnimState:SetMultColour(0, 0, 0, 1)
		inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, 10 * FRAMES)
	end,

	timeline =
	{
		TimeEvent(10 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(2, -8, 0)
		end),
		TimeEvent(15 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(0, -8, 0)
		end),
		TimeEvent(16 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
		end),
		TimeEvent(17 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(0, -8, 0)
		end),
	},

	events =
	{
		EventHandler("animover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.Physics:Stop()
				inst.sg:GoToState("idle")
			end
		end),
	},
	
	onexit = function(inst)
		Waffles.ToggleOnPhysics(inst)
	end,
})

AddStategraphPostInit("wilson", function(sg)
	local jumpin = sg.states.jumpin
	if jumpin ~= nil then
		local onenter = jumpin.onenter
		jumpin.onenter = function(inst, data)
			if data ~= nil and data.teleporter ~= nil
			and data.teleporter:HasTag("stairs") then
				inst.sg:GoToState("jump_stairs", data)
			else
				onenter(inst, data)
			end
		end
	end
end)

AddStategraphState("wilson", State {
	name = "jump_stairs",
	tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

	onenter = function(inst, data)
		Waffles.ToggleOffPhysics(inst)
		inst.components.locomotor:Stop()
		
		inst.sg.statemem.target = data.teleporter
		inst.sg.statemem.teleportarrivestate = "jumpout"
		
		inst.AnimState:PlayAnimation("jump_pre")
		
		Waffles.PushFakeShadow(inst, 1.3, 0.6)
	end,

	timeline =
	{
		TimeEvent(5 * FRAMES, function(inst)
			inst.AnimState:PlayAnimation("jumpout")
			inst.AnimState:SetTime(0.15)
			inst.Physics:SetMotorVel(1 / inst.Transform:GetScale() * 4, 5, 0)
			
			if inst.components.inventory:IsHeavyLifting() then
				inst:PushEvent("encumberedwalking")
			end
		end),
		TimeEvent(16 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
		end),
		TimeEvent(20 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(0, 0, 0)
			local turn = (math.random() < 0.5 and -1 or 1) * 90
			inst.Transform:SetRotation(inst.Transform:GetRotation() + turn)
			inst.AnimState:PushAnimation("jump_pre")
		end),
		TimeEvent(31 * FRAMES, function(inst)
			inst.components.colourtweener:StartTween({ 0, 0, 0, 1 }, 6 * FRAMES)
		end),
		TimeEvent(33 * FRAMES, function(inst)
			inst.AnimState:PlayAnimation("jumpout")
			inst.AnimState:SetTime(0.15)
		end),
		TimeEvent(35 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(1 / inst.Transform:GetScale() * 3, 6, 0)
		end),
		TimeEvent(41 * FRAMES, function(inst)
			inst.Physics:SetMotorVel(0, 0, 0)
			if inst.sg.statemem.target ~= nil
			and	inst.sg.statemem.target:IsValid()
			and	inst.sg.statemem.target.components.teleporter ~= nil then
				inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
				if inst.sg.statemem.target.components.teleporter:Activate(inst) then
					inst.sg.statemem.isteleporting = true
					inst.components.health:SetInvincible(true)
					if inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(false)
					end
					inst:Hide()
					inst.DynamicShadow:Enable(false)
					return
				end
			end
			inst.sg:GoToState("jumpout")
		end),
	},
	
	onexit = function(inst)
		inst.Physics:Stop()
		Waffles.ToggleOnPhysics(inst)
		
		inst.AnimState:SetMultColour(1, 1, 1, 1)		
		if inst.sg.statemem.isteleporting then
			inst.components.health:SetInvincible(false)
			if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:Enable(true)
			end
			inst:Show()
			inst.DynamicShadow:Enable(true)
		elseif inst.sg.statemem.target ~= nil
		and inst.sg.statemem.target:IsValid()
		and inst.sg.statemem.target.components.teleporter ~= nil then
			inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
		end
	end,
})

local function TelestaffMutedSpell(inst, ...)
	if inst:IsInBasement() then
		if TheWorld:HasTag("cave") then
			TheWorld:PushEvent("ms_miniquake", { rad = 3, num = 5, duration = 1.5, target = inst })
		else
			SpawnPrefab("thunder_close")
		end
		if inst.components.finiteuses ~= nil then
			inst.components.finiteuses:Use(1)
		end
	else
		inst.components.spellcaster.__spell(inst, ...)
	end
end

AddPrefabPostInit("telestaff", function(inst)
	Waffles.Replace(inst.components.spellcaster, "spell", TelestaffMutedSpell)
end)

AddPrefabPostInit("basement_entrance_builder_blueprint", function(inst)
	inst:DoTaskInTime(0, inst.Remove)
end)

if IsServer and not IsDedicated then	
	local function GetIsWet(self, iswet)
		if self:IsInBasement() then
			local replica = self.replica.inventoryitem or self.replica.moisture
			if replica ~= nil then
				return replica:IsWet()
			end
			return self:HasTag("wet")
		else
			return iswet
		end
	end
	
	Waffles.SetFn(EntityScript, "GetIsWet", true, GetIsWet, Waffles.SequenceFn)
end

local function SpawnSinkhole(self, spawnpt, ...)
	local basement = select(2, TheWorld.Map:IsBasementAtPoint(spawnpt.x, 0, spawnpt.z))
	if basement ~= nil then
		local fx = SpawnPrefab("cavein_debris")
		fx.Transform:SetScale(1, 0.25 + math.random() * 0.07, 1)
		fx.Transform:SetPosition(spawnpt.x, 0, spawnpt.z)
		--spawnpt = basement:GetNormalPosition(spawnpt)
	else
		self:__SpawnSinkhole(spawnpt, ...)
	end
end

AddComponentPostInit("sinkholespawner", function(self, inst)
	Waffles.Replace(self, "SpawnSinkhole", SpawnSinkhole)
end)

local function OnBoulderStartFalling(inst)
	if inst:IsInBasement() then
		local x, y, z = inst.Transform:GetWorldPosition()
		local fx = SpawnPrefab("cavein_debris")
		fx.Transform:SetScale(1, 0.25 + math.random() * 0.07, 1)
		fx.Transform:SetPosition(x, 0, z)
		
		inst:Remove()
	end
end

AddPrefabPostInit("cavein_boulder", function(inst)
	inst:ListenForEvent("startfalling", OnBoulderStartFalling)
end)

--------------------------------------------------------------------------
--[[ Basement World State ]]
--------------------------------------------------------------------------

local BASEMENT_WORLD_STATE =
{	
	DATA =
	{
		moisture = 0,
		moistureceil = 0,
		wetness	= 0,
		pop	= 0,
		snowlevel = 0,
		
		phase =	"night",
		cavephase =	"night",

		season = "autumn",
		iswinter = false,
		isspring = false,
		issummer = false,
		isautumn = true,

		precipitation = "none",
		issnowing = false,
		issnowcovered = false,
		israining = false,
		iswet = false,

		isday = false,
		isdusk = false,
		isnight = true,
		iscaveday = false,
		iscavedusk = false,	
		iscavenight	= true,
	},
	
	TIME = 0,
	LAST = nil,
	STACK = 0,
}

Waffles.BasementWorldState = BASEMENT_WORLD_STATE

function Waffles.PushBasementWorldState()
	BASEMENT_WORLD_STATE.STACK = BASEMENT_WORLD_STATE.STACK + 1
	if BASEMENT_WORLD_STATE.STACK > 1 then
		return
	end

	local state = nil
	local time = GetTime()
	if BASEMENT_WORLD_STATE.LAST ~= nil
	and time - BASEMENT_WORLD_STATE.TIME > 10 then
		state = BASEMENT_WORLD_STATE.LAST
	else
		state = {}
		for k,v in pairs(TheWorld.state) do
			if BASEMENT_WORLD_STATE.DATA[k] ~= nil then
				state[k] = BASEMENT_WORLD_STATE.DATA[k]
			else
				state[k] = v
			end
		end
		
		BASEMENT_WORLD_STATE.TIME = time
		BASEMENT_WORLD_STATE.LAST = state
	end
	
	Waffles.Replace(TheWorld, "state", state)
end

function Waffles.PopBasementWorldState()
	BASEMENT_WORLD_STATE.STACK = math.max(BASEMENT_WORLD_STATE.STACK - 1, 0)
	if BASEMENT_WORLD_STATE.STACK > 1 then
		return
	end
	Waffles.Replace(TheWorld, "state")
end

local function SpawnSaveRecord(saved, ...)
	if TheWorld.Map:GetTileAtPoint(saved.x or 0, saved.y or 0, saved.z or 0) == GROUND.INVALID
	and not saved.prefab:find("basement") then
		--print("SpawnSaveRecord", saved.prefab)
		Waffles.PushBasementWorldState()
		local inst = __SpawnSaveRecord(saved, ...)
		Waffles.PopBasementWorldState()
		if inst ~= nil then
			inst.spawnedinbasement = true
		end
		return inst
	end
	return __SpawnSaveRecord(saved, ...)
end

Waffles.Replace(_G, "SpawnSaveRecord", SpawnSaveRecord)

declarewaffles()