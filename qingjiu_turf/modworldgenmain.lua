modimport 'tile_adder.lua'

-- The parameters passed are, in order:
-- The key to be used inside GROUND.
-- The numerical id to be used for the GROUND entry (i.e., the value of the new entry). This MUST be unique and CANNOT conflict with other mods.
-- The name of the tile (should match the texture and atlas in levels/tiles/).
-- The tile specification.
-- The minimap tile specification.
-- Should the tile type be treated as flooring, i.e. forbid planting things (saplings, grass, berry bushes, trees) on it
--
-- See tile_adder.lua for more details on the tile and minimap tile specifications.
--
-- The following will create a new tile type, GROUND.MODTEST.


-- sounds names taken from base tile types in worldtiledefs.lua
local sound_run_dirt = "dontstarve/movement/run_dirt"
local sound_run_marsh = "dontstarve/movement/run_marsh"
local sound_run_tallgrass = "dontstarve/movement/run_tallgrass"
local sound_run_forest = "dontstarve/movement/run_woods"
local sound_run_grass = "dontstarve/movement/run_grass"
local sound_run_wood = "dontstarve/movement/run_wood"
local sound_run_marble = "dontstarve/movement/run_marble"
local sound_run_carpet = "dontstarve/movement/run_carpet"
local sound_run_moss = "dontstarve/movement/run_moss"
local sound_run_mud = "dontstarve/movement/run_mud"

local sound_walk_dirt = "dontstarve/movement/walk_dirt"
local sound_walk_marsh = "dontstarve/movement/walk_marsh"
local sound_walk_tallgrass = "dontstarve/movement/walk_tallgrass"
local sound_walk_forest = "dontstarve/movement/walk_woods"
local sound_walk_grass = "dontstarve/movement/walk_grass"
local sound_walk_wood = "dontstarve/movement/walk_wood"
local sound_walk_marble = "dontstarve/movement/walk_marble"
local sound_walk_carpet = "dontstarve/movement/walk_carpet"
local sound_walk_moss = "dontstarve/movement/walk_moss"
local sound_walk_mud = "dontstarve/movement/walk_mud"

local sound_ice = "dontstarve/movement/run_ice"
local sound_snow = "dontstarve/movement/run_snow"

--不允许在草皮上种植
local EnableFlooringPlanting = false
EnableFlooringPlanting = EnableFlooringPlanting == true or EnableFlooringPlanting == "true" or EnableFlooringPlanting == 1
local isflooring = not EnableFlooringPlanting -- flooring setting for turfs that observe the configuration option
--每块草皮的奖金略有不同
local EnableIndividualization = true
EnableIndividualization = EnableIndividualization == true or EnableIndividualization == "true" or EnableIndividualization == 1
local legacyBonuses = not EnableIndividualization

--
-- turfed properties
--

-- insulationWinterMult, insulationWinterAdd, insulationSummerMult, insulationSummerAdd    (nil means 0)
--   winterInsulation = winterInsulation + InsulationDurationConfigValue * insulationWinterMult + insulationWinterAdd
--   summerInsulation = summerInsulation + InsulationDurationConfigValue * insulationSummerMult + insulationSummerAdd
-- sanityMult, sanityAdd    (nil means 0)
--   sanityRate = sanityRate + TuningValue * sanityMult + sanityAdd
-- moistureMult    (nil means 1)
--   moistureRate = moistureRate * moistureMult
--
-- speedMult, speedAdd    speed bonus of the turf (nil means don't affect at all, i.e. 0, but skip other checks)
-- speed is a table of {condition, speedBonusAdd}
--   condition is a string "\!?tag1(,\!?tagN)*"
--     tag1...tagN are tags which are checked against the entity, tagX means entity has the tag, !tagX means entity does not have the tag
--     if tag starts with %, the prefab is checked instead, i.e. %tagX means the entity's prefab is equal to tagX, !%tagX means the entity's prefab is not equal to tagX
--     it assumes no tag contains ',', '!', or '%'
--     tag subexpressions are joined by conjuction (AND), i.e. all have to be true for the condition to be true
--   speedCondAdd = sum of all speedBonusAdd whose condition is true; if none are true then the turf has no effect on the entity whatsoever
--   speed = speed * ((SpeedConfigValue - 1) * speedMult + 1 + speedAdd) * (1 + speedCondAdd)

-- shared speed tables
local speed_players = { { "player,!playerghost", 0 } } -- affect only non-ghost players
local speed_players_groundmobs = {
    -- affect non-ghost players and ground-walking mobs
    { "player,!playerghost", 0 },
    { "!player,!ghost,!flying,!mole,!shadow,!shadowhand,!worm,!%tumbleweed", 0 },
    -- !ghost for abigail and ghosts, !flying for bats etc., !mole for mole, !shadow for shadow creatures, !shadowhand for shadowhands, !worm for worm, !%tumbleweed for tumbleweed
    -- note: although bees, butterflies and mosquitos have flying tag, they don't evaluate the tile type they are currently on at all due to their inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    --    similar with mushtree spores (but without the flying tag part)
}

--
-- legacy settings, i.e. all turfs except frosty and naturedesert have the same bonuses
--
local turfed_legacy = {
    insulationWinterMult = 1,
    insulationWinterAdd = 0,
    insulationSummerMult = 1,
    insulationSummerAdd = 0,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0,
    speedMult = 1,
    speedAdd = 0,
    speed = speed_players,
}

local turfed_legacy_frostynaturedesert = {
    insulationWinterMult = nil,
    insulationWinterAdd = nil,
    insulationSummerMult = nil,
    insulationSummerAdd = nil,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0,
    speedMult = 1,
    speedAdd = 0,
    speed = speed_players,
}

--
-- individualized settings
--
local turfed_carpet = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 1,
    insulationWinterAdd = 60,
    insulationSummerMult = 0.25,
    insulationSummerAdd = 0,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0,
    speedMult = nil,
    speedAdd = nil,
    speed = nil,
}

local turfed_carpet_blackfur = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 1.25,
    insulationWinterAdd = 120,
    insulationSummerMult = 0.35,
    insulationSummerAdd = 0,
    sanityMult = 1,
    sanityAdd = TUNING.DAPPERNESS_SMALL,
    moistureMult = 0,
    speedMult = nil,
    speedAdd = nil,
    speed = nil,
}

local turfed_wood = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.4,
    insulationWinterAdd = 0,
    insulationSummerMult = 0.4,
    insulationSummerAdd = 0,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0,
    speedMult = 0.5,
    speedAdd = 0,
    speed = speed_players,
}

local turfed_rock = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.25,
    insulationWinterAdd = 0,
    insulationSummerMult = 1,
    insulationSummerAdd = 60,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0.01,
    speedMult = 1,
    speedAdd = 0,
    speed = speed_players,
}

local turfed_rockmoon = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.25,
    insulationWinterAdd = 0,
    insulationSummerMult = 0.5,
    insulationSummerAdd = 0,
    sanityMult = 0.5,
    sanityAdd = 0,
    moistureMult = 0.5,
    speedMult = 2,
    speedAdd = 0.5,
    speed = speed_players,
}

local turfed_tile = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.25,
    insulationWinterAdd = 0,
    insulationSummerMult = 1,
    insulationSummerAdd = 60,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0.01,
    speedMult = 1,
    speedAdd = 0.25,
    speed = speed_players,
}

local turfed_tilesq = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.25,
    insulationWinterAdd = 0,
    insulationSummerMult = 1,
    insulationSummerAdd = 60,
    sanityMult = 1,
    sanityAdd = 0,
    moistureMult = 0.01,
    speedMult = 1,
    speedAdd = 0.4,
    speed = speed_players,
}

local turfed_frosty = legacyBonuses and turfed_legacy_frostynaturedesert or {
    insulationWinterMult = -10,
    insulationWinterAdd = -960,
    insulationSummerMult = 10,
    insulationSummerAdd = 960,
    sanityMult = 0.25,
    sanityAdd = 0,
    moistureMult = 0.5,
    speedMult = 1,
    speedAdd = 0.5,
    speed = speed_players,
}

local turfed_naturedesert = legacyBonuses and turfed_legacy_frostynaturedesert or {
    insulationWinterMult = 10,
    insulationWinterAdd = 960,
    insulationSummerMult = -10,
    insulationSummerAdd = -960,
    sanityMult = 0.1,
    sanityAdd = 0,
    moistureMult = nil,
    speedMult = nil,
    speedAdd = nil,
    speed = nil,
}

local turfed_natureastroturf = legacyBonuses and turfed_legacy or {
    insulationWinterMult = 0.125,
    insulationWinterAdd = 0,
    insulationSummerMult = 0.125,
    insulationSummerAdd = 0,
    sanityMult = 0.5,
    sanityAdd = 0,
    moistureMult = nil,
    speedMult = 0.25,
    speedAdd = 0,
    speed = speed_players,
}

local turfed_spikes = {
    insulationWinterMult = nil,
    insulationWinterAdd = nil,
    insulationSummerMult = nil,
    insulationSummerAdd = nil,
    sanityMult = nil,
    sanityAdd = -TUNING.DAPPERNESS_TINY,
    moistureMult = 2, -- rain is twice effective here if you're not 100% covered by equipment
    speedMult = 0,
    speedAdd = -0.5,
    speed = {
        { "player,!playerghost", 0 }, -- non-ghost players have 50% speed
        { "!player,!ghost,!flying,!mole,!shadow,!shadowhand,!worm,!%tumbleweed", -0.5 }, -- ground-walking mobs have 25% speed (50% from speedAdd, 50% from here)
    },
}

AddTile("MODTEST", 80, "modtest", { noise_texture = "levels/textures/noise_modtest.tex" }, { noise_texture = "levels/textures/mini_noise_modtest.tex" }, nil)
AddTile("NATUREASTROTURF", 60, "natureastroturf", { name = "deciduous", noise_texture = "levels/textures/noise_natureastroturf.tex", runsound = sound_run_moss, walksound = sound_walk_moss, snowsound = sound_snow, turfed = turfed_natureastroturf }, { noise_texture = "levels/textures/mini_noise_natureastroturf.tex" }, false)
AddTile("NATUREDESERT", 61, "naturedesert", { name = "modtest", noise_texture = "levels/textures/noise_naturedesert.tex", runsound = sound_run_dirt, walksound = sound_walk_dirt, snowsound = sound_snow, turfed = turfed_naturedesert }, { noise_texture = "levels/textures/mini_noise_naturedesert.tex" }, false)
AddTile("WOODCHERRY", 69, "woodcherry", { name = "blocky", noise_texture = "levels/textures/noise_woodcherry.tex", runsound = sound_run_wood, walksound = sound_walk_wood, snowsound = sound_snow, turfed = turfed_wood }, { noise_texture = "levels/textures/mini_noise_woodcherry.tex" }, isflooring)
AddTile("WOODDARK", 70, "wooddark", { name = "blocky", noise_texture = "levels/textures/noise_wooddark.tex", runsound = sound_run_wood, walksound = sound_walk_wood, snowsound = sound_snow, turfed = turfed_wood }, { noise_texture = "levels/textures/mini_noise_wooddark.tex" }, isflooring)
AddTile("WOODPINE", 71, "woodpine", { name = "blocky", noise_texture = "levels/textures/noise_woodpine.tex", runsound = sound_run_wood, walksound = sound_walk_wood, snowsound = sound_snow, turfed = turfed_wood }, { noise_texture = "levels/textures/mini_noise_woodpine.tex" }, isflooring)
AddTile("ROCKBLACKTOP", 62, "rockblacktop", { name = "modtest", noise_texture = "levels/textures/noise_rockblacktop.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_rock }, { noise_texture = "levels/textures/mini_noise_rockblacktop.tex" }, isflooring)
AddTile("ROCKGIRAFFE", 63, "rockgiraffe", { name = "modtest", noise_texture = "levels/textures/noise_rockgiraffe.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_rock }, { noise_texture = "levels/textures/mini_noise_rockgiraffe.tex" }, isflooring)
AddTile("ROCKMOON", 64, "rockmoon", { name = "modtest", noise_texture = "levels/textures/noise_rockmoon.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_rockmoon }, { noise_texture = "levels/textures/mini_noise_rockmoon.tex" }, isflooring)
AddTile("ROCKYELLOWBRICK", 65, "rockyellowbrick", { name = "modtest", noise_texture = "levels/textures/noise_rockyellowbrick.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_rock }, { noise_texture = "levels/textures/mini_noise_rockyellowbrick.tex" }, isflooring)
AddTile("TILECHECKERBOARD", 66, "tilecheckerboard", { name = "blocky", noise_texture = "levels/textures/noise_tilecheckerboard.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_tile }, { noise_texture = "levels/textures/mini_noise_tilecheckerboard.tex" }, isflooring)
AddTile("TILEFROSTY", 67, "tilefrosty", { name = "blocky", noise_texture = "levels/textures/noise_tilefrosty.tex", runsound = sound_ice, walksound = sound_ice, snowsound = sound_ice, turfed = turfed_frosty }, { noise_texture = "levels/textures/mini_noise_tilefrosty.tex" }, isflooring)
AddTile("TILESQUARES", 68, "tilesquares", { name = "blocky", noise_texture = "levels/textures/noise_tilesquares.tex", runsound = sound_run_marble, walksound = sound_walk_marble, snowsound = sound_ice, turfed = turfed_tilesq }, { noise_texture = "levels/textures/mini_noise_tilesquares.tex" }, isflooring)
AddTile("CARPETBLACKFUR", 50, "carpetblackfur", { name = "carpet", noise_texture = "levels/textures/noise_carpetblackfur.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet_blackfur }, { noise_texture = "levels/textures/mini_noise_carpetblackfur.tex" }, isflooring)
AddTile("CARPETBLUE", 51, "carpetblue", { name = "carpet", noise_texture = "levels/textures/noise_carpetblue.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetblue.tex" }, isflooring)
AddTile("CARPETCAMO", 52, "carpetcamo", { name = "carpet", noise_texture = "levels/textures/noise_carpetcamo.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetcamo.tex" }, isflooring)
AddTile("CARPETFUR", 53, "carpetfur", { name = "carpet", noise_texture = "levels/textures/noise_carpetfur.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetfur.tex" }, isflooring)
AddTile("CARPETPINK", 54, "carpetpink", { name = "carpet", noise_texture = "levels/textures/noise_carpetpink.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetpink.tex" }, isflooring)
AddTile("CARPETPURPLE", 55, "carpetpurple", { name = "carpet", noise_texture = "levels/textures/noise_carpetpurple.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetpurple.tex" }, isflooring)
AddTile("CARPETRED", 56, "carpetred", { name = "carpet", noise_texture = "levels/textures/noise_carpetred.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetred.tex" }, isflooring)
AddTile("CARPETRED2", 57, "carpetred2", { name = "carpet", noise_texture = "levels/textures/noise_carpetred2.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetred2.tex" }, isflooring)
AddTile("CARPETTD", 58, "carpettd", { name = "carpet", noise_texture = "levels/textures/noise_carpettd.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpettd.tex" }, isflooring)
AddTile("CARPETWIFI", 59, "carpetwifi", { name = "carpet", noise_texture = "levels/textures/noise_carpetwifi.tex", runsound = sound_run_carpet, walksound = sound_walk_carpet, snowsound = sound_snow, turfed = turfed_carpet }, { noise_texture = "levels/textures/mini_noise_carpetwifi.tex" }, isflooring)
AddTile("SPIKES", 72, "spikes", { name = "blocky", noise_texture = "levels/textures/noise_spikes.tex", runsound = sound_run_dirt, walksound = sound_walk_dirt, snowsound = sound_snow, turfed = turfed_spikes }, { noise_texture = "levels/textures/mini_noise_spikes.tex" }, false)


-- move some base tile types just below ours of the same category
ChangeTileTypeRenderOrder(GLOBAL.GROUND.WOODFLOOR, GLOBAL.GROUND.WOODCHERRY)
ChangeTileTypeRenderOrder(GLOBAL.GROUND.CHECKER, GLOBAL.GROUND.ROCKBLACKTOP)
ChangeTileTypeRenderOrder(GLOBAL.GROUND.CARPET, GLOBAL.GROUND.CARPETBLACKFUR)

-- assign turfed property to some base tile types
SetTileTypeProperty(GLOBAL.GROUND.WOODFLOOR, "turfed", turfed_wood)
SetTileTypeProperty(GLOBAL.GROUND.CHECKER, "turfed", turfed_tile)
SetTileTypeProperty(GLOBAL.GROUND.CARPET, "turfed", turfed_carpet)
SetTileTypeProperty(GLOBAL.GROUND.SCALE, "turfed", turfed_rock)
