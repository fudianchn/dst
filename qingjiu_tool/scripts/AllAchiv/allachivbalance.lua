--触发条件数据
allachiv_eventdata={
["intogame"] = nil,
["firsteat"] = nil,
["supereat"] = 100,
["danding"] = 10,
["messiah"] = 5,
["walkalot"] = 60*300,
["stopalot"] = 60*90,
["tooyoung"] = nil,
["evil"] = 3,
["snake"] = 10,

["deathalot"] = 10,
["nosanity"] = 600,
["sick"] = nil,
["coldblood"] = nil,
["burn"] = nil,
["freeze"] = nil,
["goodman"] = 30,
["brother"] = 30,
["fishmaster"] = 60,
["pickmaster"] = 1000,
["chopmaster"] = 500,
["cookmaster"] = 100,
["buildmaster"] = 1000,
["longage"] = 70,
["noob"] = nil,
["luck"] = nil,
["black"] = nil,
["tank"] = 3000,
["angry"] = 100000,
["icebody"] = 600,
["firebody"] = 600,
["moistbody"] = 600,


--=====================================
["a_yingguai"] = 50,
["a_worm"] = 25,
["a_monkey"] = 15,
["a_buzzard"] = 15,
["a_lightninggoat"] = 5,
["a_spiderqueen"] = 8,
["a_spider"] = 100,
["a_spider_warrior"] = 22,
["a_spider_dropper"] = 22,
["a_spider_hider"] = 22,
["a_spider_spitter"] = 22,
["a_warg"] = 6,
["a_hound"] = 200,
["a_firehound"] = 88,
["a_icehound"] = 88,
["a_koalefant_summer"] = 6,
["a_koalefant_winter"] = 6,
["a_catcoon"] = 15,
["a_bunnyman"] = 30,
["a_leif"] = 10,
["a_slurtle"] = 10,
["a_tallbird"] = 10,
["a_walrus"] = 10,
["a_bat"] = 100,
["a_butterfly"] = 233,
["a_killerbee"] = 100,
["a_deer"] = 5,
["a_mole"] = 30,
["a_mosquito"] = 50,
["a_penguin"] = 20,
["a_merm"] = 20,
["a_frog"] = 20,
["a_beefalo"] = 2,
["a_perd"] = 99,
["a_krampus"] = 66,
["a_robin_crow"] = 30,
["a_robin_robin"] = 30,
["a_robin_winter"] = 30,
["a_robin_canary"] = 30,
["a_pigman"] = 44,
["a_shadow_knight"] = nil,
["a_shadow_bishop"] = nil,
["a_shadow_rook"] = nil,
["a_moose"] = nil,
["a_dragonfly"] = nil,
["a_bearger"] = nil,
["a_deerclops"] = nil,
["a_stalker_forest"] = nil,
["a_stalker"] = nil,
["a_stalker_atrium"] = nil,
["a_klaus"] = nil,
["a_antlion"] = nil,
["a_minotaur"] = nil,
["a_beequeen"] = nil,
["a_toadstool"] = nil,
["a_toadstool_dark"] = nil,



["all"] = nil,

["a_1"] = 2000,
["a_2"] = 300,
["a_3"] = 3000,
["a_4"] = 1000000,
["a_5"] = 10000,

["a_6"] = 30,
["a_7"] = 10,
["a_8"] = 30,
["a_9"] = nil,
["a_10"] = 10,
["a_11"] = 10,
["a_12"] = 30,
["a_13"] = 22,

["a_14"] = nil,
["a_15"] = 1,


["a_tallbirdegg"] = 6,
["a_frogglebunwich"] = 30,
["a_baconeggs"] = 100,
["a_bonestew"] = 30,
["a_fishtacos"] = 100,
["a_turkeydinner"] = 100,
["a_fishsticks"] = 100,
["a_meatballs"] =100 ,
["a_perogies"] = 150,
["a_bisque"] = 22,--变更为辣椒酱
["a_surfnturf"] = 22,--变更为鳄梨酱
["a_tigershark"] = nil,
["a_twister"] = nil,
["a_snake"] = 50,--变更为机器人吃齿轮
["a_snake_poison"] = 55,
["a_crocodog"] = 250,
["a_poisoncrocodog"] = 100,
["a_watercrocodog"] = 100,
["a_coffee"] = 200,
["a_a1"] = 1,
["a_a2"] = 1,
["a_a3"] = 1,
["a_a4"] = 1,
["a_a5"] = 100,
["a_a6"] = 5,
["a_a7"] = 5,
["a_a8"] = 5,


["a_a9"] = 6,
["a_a10"] = 11,
["a_a11"] = 800,
["a_a12"] = 800,
["a_a13"] = 22,
["a_a14"] = 33,
["a_a15"] = 33,
["a_a16"] = 33,
["a_a17"] = 200,
["a_a18"] = 80,
["a_a19"] = 6,
["a_a20"] = 88,
["a_a21"] = 66,
["a_a22"] = 88,

["a_a23"] = 1,
["a_a24"] = 1,
["a_a25"] = 1,
["a_a26"] = 1,
["a_a27"] = 1,
["a_a28"] = 1,
["a_a29"] = 1,
["a_a30"] = 1,
["a_a31"] = 1,
["a_a32"] = 1,
["a_a33"] = 1,
["a_a34"] = 1,
["a_a35"] = 1,
["a_a36"] = 1,
["a_a37"] = 1,
["a_a38"] = 1,
["a_a39"] = 1,
["a_a40"] = 1,

--=====================================



}

--奖励获得数值
allachiv_coindata={
["hungerup"] = 1,
["sanityup"] = 1,
["healthup"] = 1,
["hungerrateup"] = TUNING.WILSON_HUNGER_RATE*.02,
["healthregen"] = .2,
["sanityregen"] = .2,
["speedup"] = .05,
["damageup"] = .05,
["absorbup"] = .05,
["crit"] = 5,
}

--成就获得点数
allachiv_coinget={
["intogame"] = 10,
["firsteat"] = 1,
["supereat"] = 2,
["danding"] = 2,

["messiah"] = 3,
["walkalot"] = 3,
["stopalot"] = 2,
["tooyoung"] = 2,
["evil"] = 2,
["snake"] = 2,

["deathalot"] = 2,
["nosanity"] = 3,
["sick"] = 2,
["coldblood"] = 2,
["burn"] = 1,
["freeze"] = 1,
["goodman"] = 3,
["brother"] = 3,

["fishmaster"] = 3,
["pickmaster"] = 3,
["chopmaster"] = 3,
["cookmaster"] = 3,
["buildmaster"] = 5,
["longage"] = 5,
["noob"] = 1,
["luck"] = 10,
["black"] = 7,
["tank"] = 5,
["angry"] = 5,
["icebody"] = 5,
["firebody"] = 5,
["moistbody"] = 5,
--=====================================
["a_yingguai"] = 1,
["a_worm"] = 2,
["a_monkey"] = 1,
["a_buzzard"] = 1,
["a_lightninggoat"] = 1,
["a_spiderqueen"] = 2,
["a_spider"] = 1,
["a_spider_warrior"] = 1,
["a_spider_dropper"] = 1,
["a_spider_hider"] = 1,
["a_spider_spitter"] = 1,
["a_warg"] = 2,
["a_hound"] = 2,
["a_firehound"] = 2,
["a_icehound"] = 2,
["a_koalefant_summer"] = 1,
["a_koalefant_winter"] = 1,
["a_catcoon"] = 1,
["a_bunnyman"] = 1,
["a_leif"] = 1,
["a_slurtle"] = 1,
["a_tallbird"] = 1,
["a_walrus"] = 1,
["a_bat"] = 1,
["a_butterfly"] = 1,
["a_killerbee"] = 1,
["a_deer"] = 1,
["a_mole"] = 1,
["a_mosquito"] = 1,
["a_penguin"] = 1,
["a_merm"] = 1,
["a_frog"] = 1,
["a_beefalo"] = 1,
["a_perd"] = 1,
["a_krampus"] = 2,
["a_robin_crow"] = 1,
["a_robin_robin"] = 1,
["a_robin_winter"] = 1,
["a_robin_canary"] = 1,
["a_pigman"] = 1,
["a_shadow_knight"] = 1,
["a_shadow_bishop"] = 1,
["a_shadow_rook"] = 1,
["a_moose"] = 3,
["a_dragonfly"] = 3,
["a_bearger"] = 3,
["a_deerclops"] = 3,
["a_stalker_forest"] = 1,
["a_stalker"] = 2,
["a_stalker_atrium"] = 3,
["a_klaus"] = 3,
["a_antlion"] = 3,
["a_minotaur"] = 3,
["a_beequeen"] = 5,
["a_toadstool"] = 5,
["a_toadstool_dark"] = 10,


["all"] = 1000,

["a_1"] = 4,
["a_2"] = 150,
["a_3"] = 4,
["a_4"] = 4,
["a_5"] = 4,

["a_6"] = 1,
["a_7"] = 1,
["a_8"] = 1,
["a_9"] = 1,
["a_10"] = 1,
["a_11"] = 1,
["a_12"] = 1,
["a_13"] = 1,
["a_14"] = 1,
["a_15"] = 1,

["a_tallbirdegg"] = 1,
["a_frogglebunwich"] = 1,
["a_baconeggs"] = 1,
["a_bonestew"] = 1,
["a_fishtacos"] =1,
["a_turkeydinner"] = 1,
["a_fishsticks"] = 1,
["a_meatballs"] = 1,
["a_perogies"] = 1,
["a_bisque"] = 1,
["a_surfnturf"] = 1,
["a_tigershark"] = 3,
["a_twister"] = 3,
["a_snake"] = 1,
["a_snake_poison"] = 1,
["a_crocodog"] = 1,
["a_poisoncrocodog"] = 1,
["a_watercrocodog"] = 1,
["a_coffee"] = 1,
["a_a1"] = 1,
["a_a2"] = 5,
["a_a3"] =1,
["a_a4"] = 1,
["a_a5"] = 1,
["a_a6"] = 1,
["a_a7"] = 1,
["a_a8"] = 1,
["a_a9"] = 1,
["a_a10"] = 1,

["a_a11"] = 1,
["a_a12"] = 1,
["a_a13"] = 1,
["a_a14"] = 1,
["a_a15"] = 1,
["a_a16"] = 1,
["a_a17"] = 1,
["a_a18"] = 1,
["a_a19"] = 1,
["a_a20"] = 1,
["a_a21"] = 1,
["a_a22"] = 1,
["a_a23"] = 1,
["a_a24"] = 1,
["a_a25"] = 1,
["a_a26"] = 1,
["a_a27"] = 1,
["a_a28"] = 1,
["a_a29"] = 1,
["a_a30"] = 1,
["a_a31"] = 1,
["a_a32"] = 1,
["a_a33"] = 1,
["a_a34"] = 1,
["a_a35"] = 1,
["a_a36"] = 1,
["a_a37"] = 1,
["a_a38"] = 1,
["a_a39"] = 1,
["a_a40"] = 1,

--=====================================


}

--奖励消耗点数
allachiv_coinuse={
["hungerup"] = 1,
["sanityup"] = 1,
["healthup"] = 1,
["hungerrateup"] = 2,
["healthregen"] = 6,
["sanityregen"] = 5,
["speedup"] = 15,
["damageup"] = 10,
["absorbup"] = 15,
["crit"] = 15,
["fireflylight"] = 50,
["nomoist"] = 45,
["doubledrop"] = 80,
["goodman"] = 25,
["fishmaster"] = 40,
["pickmaster"] = 40,
["chopmaster"] = 40,
["cookmaster"] = 40,
["buildmaster"] = 88,
["refresh"] = 60,
["icebody"] = 45,
["firebody"] = 45,
["supply"] = 50,
["reader"] = 50,
["jump"] = 50,
["level"] = 0,
["fastpicker"] = 25,
}