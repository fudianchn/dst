local easing = require("easing")

local AVERAGE_WALK_SPEED = 4
local WALK_SPEED_VARIATION = 2
local SPEED_VAR_INTERVAL = .5
local ANGLE_VARIANCE = 10

local assets =
{
    Asset("ANIM", "anim/tumbleweed.zip"),
}

local prefabs =
{
    "splash_ocean",
    "tumbleweedbreakfx",
    "ash",
    "cutgrass",
    "twigs",
    "petals",
    "foliage",
    "silk",
    "rope",
    "seeds",
    "purplegem",
    "bluegem",
    "redgem",
    "orangegem",
    "yellowgem",
    "greengem",
    "seeds",
    "trinket_6",
    "cutreeds",
    "feather_crow",
    "feather_robin",
    "feather_robin_winter",
    "feather_canary",
    "trinket_3",
    "beefalowool",
    "rabbit",
    "mole",
    "butterflywings",
    "fireflies",
    "beardhair",
    "berries",
    "TOOLS_blueprint",
    "LIGHT_blueprint",
    "SURVIVAL_blueprint",
    "FARM_blueprint",
    "SCIENCE_blueprint",
    "WAR_blueprint",
    "TOWN_blueprint",
    "REFINE_blueprint",
    "MAGIC_blueprint",
    "DRESS_blueprint",
    "petals_evil",
    "trinket_8",
    "houndstooth",
    "stinger",
    "gears",
    "spider",
    "frog",
    "bee",
    "mosquito",
    "boneshard",
	--自己添加内容
	"log",--木头
	"charcoal",--木炭
	"lightbulb",--荧光果
	"pinecone",--松果
	"acorn",--桦木果
	"flint",--燧石
	"nitre",--硝石
	"rocks",--石头
	"goldnugget",--黄金
	"thulecite",--铥矿
	"thulecite_pieces",--铥矿碎片
	"boards",--木板
	"cutstone",--石砖
	"papyrus",--纸
	"pigskin",--猪皮
	"manrabbit_tail",--兔毛
	"spidergland",--蜘蛛腺体
	"spidereggsack",--蜘蛛卵
	"honeycomb",--蜂巢
	"walrus_tusk",--象牙
	"tentaclespots",--触手皮
	"trunk_summer",--夏象鼻
	"trunk_winter",--冬象鼻
	"slurtleslime",--蜗牛黏液
	"slurtle_shellpieces",--蜗牛壳碎片
	"mosquitosack",--蚊子血囊
	"slurper_pelt",--啜食者皮
	"minotaurhorn",--远古守护者角
	"deerclops_eyeball",--巨鹿眼球
	"lightninggoathorn",--闪电羊角
	"glommerfuel",--咕噜姆黏液
	"livinglog",--活木
	"nightmarefuel",--噩梦燃料
	"transistor",--电子元件
	"marble",--大理石
	"ice",--冰
	"poop",--便便
	"guano",--鸟粪
	"dragon_scales",--蜻蜓鳞片
	"goose_feather",--鹿鸭羽毛
	"bearger_fur",--熊皮
	"red_cap",--红蘑菇
	"green_cap",--绿蘑菇
	"blue_cap",--蓝蘑菇
	"dug_grass",--草丛
	"dug_sapling",--树苗
	"dug_berrybush",--普通浆果丛
	"dug_berrybush2",--三叶浆果丛
	"shroom_skin",--蛤蟆皮
	"steelwool",--钢绒
	"waxpaper",--蜡纸
	"bundlewrap",--捆绑包装纸
	"moonrocknugget",--月石
	"fossil_piece",--化石碎片
	"shadowheart",--暗影之心
	--怪物
	"beefalo",--牛
	"lightninggoat",--闪电羊
	"pigman",--猪人
	"pigguard",--猪人守卫
	"bunnyman",--兔人
	"merm",--鱼人
	"spider_warrior",--蜘蛛战士
	"spiderqueen",--蜘蛛女王
	"hound",--猎狗
	"firehound",--火狗
	"icehound",--冰狗
	"leif",--树精
	"leif_sparse",--稀有树精
	"walrus",--海象
	"tallbird",--高鸟
	"koalefant_summer",--夏象
	"koalefant_winter",--冬象
	"bat",--蝙蝠
	"rocky",--石虾
	"monkey",--猴子
	"knight",--发条骑士
	"bishop",--发条主教
	"rook",--发条战车
	"crawlinghorror",--暗影爬行怪
	"terrorbeak",--尖嘴暗影怪
	"deerclops",--巨鹿
	"minotaur",--远古守护者
	"worm",--洞穴蠕虫
	"krampus",--小偷
	"moose",--鹿鸭
	"mossling",--小鸭
	"dragonfly",--龙蝇
	"warg",--座狼
	"bearger",--熊大
	"toadstool",--蘑菇蛤
	"beequeen",--蜂后
	"spat",--钢羊
	"shadow_rook",--暗影战车
	"shadow_knight",--暗影骑士
	"shadow_bishop",--暗影主教
	"carrot_seeds",--胡萝卜种子
	"pumpkin_seeds",--南瓜种子
	"dragonfruit_seeds",--火龙果种子
	"pomegranate_seeds",--石榴种子
	"corn_seeds",--玉米种子
	"durian_seeds",--榴莲种子
	"eggplant_seeds",--茄子种子
	"pumpkin",--南瓜
	"dragonfruit",--火龙果
	"pomegranate",--石榴
	"corn",--玉米
	"durian",--榴莲
	"eggplant",--茄子
	"cave_banana",--洞穴香蕉
	"cactus_meat",--仙人掌肉
	"watermelon",--西瓜
	"smallmeat",--小肉
	"meat",--大肉
	"drumstick",--鸡腿
	"monstermeat",--疯肉
	"plantmeat",--食人花肉
	"bird_egg",--鸡蛋
	"tallbirdegg",--高鸟蛋
	"fish",--鱼
	"froglegs",--蛙腿
	"batwing",--蝙蝠翅膀
	"mandrake",--曼德拉草
	"honey",--蜂蜜
	"butter",--黄油
	"goatmilk",--羊奶
	"butterflymuffin",--蝴蝶松饼
	"frogglebunwich",--蛙腿三明治
	"honeyham",--蜜汁火腿
	"dragonpie",--火龙果馅饼
	"taffy",--太妃糖
	"pumpkincookie",--南瓜饼
	"kabobs",--肉串
	"powcake",--芝士蛋糕
	"mandrakesoup",--曼德拉草汤
	"baconeggs",--培根煎蛋
	"bonestew",--肉汤
	"wetgoop",--湿腻焦糊
	"ratatouille",--蔬菜什锦
	"fruitmedley",--水果圣代
	"fishtacos",--玉米鱼卷
	"waffles",--华夫饼
	"turkeydinner",--火鸡正餐
	"fishsticks",--鱼排
	"stuffedeggplant",--香酥茄盒
	"honeynuggets",--甜蜜金砖
	"meatballs",--肉丸
	"jammypreserves",--果酱
	"monsterlasagna",--怪物千层饼
	"flowersalad",--仙人掌沙拉
	"icecream",--冰淇淋
	"watermelonicle",--西瓜冰
	"trailmix",--坚果
	"guacamole",--鳄梨沙拉
	"tentacle",--触手
	"wasphive",--杀人蜂窝
	"townportaltalisman",--砂石
	"axe",--斧头
	"goldenaxe",--黄金斧头
	"pickaxe",--鹤嘴锄
	"goldenpickaxe",--黄金鹤嘴锄
	"shovel",--铲子
	"goldenshovel",--黄金铲子
	"hammer",--锤子
	"pitchfork",--草叉
	"razor",--剃刀
	"trap",--陷阱
	"grass_umbrella",--普通花伞
	"compass",--指南针
	"backpack",--背包
	"bedroll_straw",--凉席
	"torch",--火炬
	"featherpencil",--羽毛笔
	"saddlehorn",--鞍角
	"saddle_basic",--上鞍
	"healingsalve",--治疗药膏
	"bandage",--蜂蜜药膏
	"lifeinjector",--强心针
	"birdtrap",--捕鸟陷阱
	"bugnet",--捕虫网
	"fishingrod",--钓竿
	"umbrella",--雨伞
	"waterballoon",--水球
	"heatrock",--热能石
	"piggyback",--猪皮背包
	"bedroll_furry",--毛皮铺盖
	"fertilizer",--堆肥桶
	"sewing_kit",--针线包
	"minerhat",--矿工帽
	"molehat",--鼹鼠帽
	"lantern",--提灯
	"deer_antler",--鹿角
	"saddle_war",--战争牛鞍
	"saddle_race",--薄弱牛鞍
	"brush",--洗刷
	"featherfan",--羽毛扇
	"icepack",--保鲜背包
	"krampus_sack",--坎普斯背包
	"multitool_axe_pickaxe",--多功能工具
	"klaussackkey",--克劳斯钥匙
	"spear",--长矛
	"armorgrass",--草甲
	"armorwood",--木甲
	"footballhat",--橄榄球头盔
	"flowerhat",--花环
	"strawhat",--草帽
	"watermelonhat",--西瓜帽
	"featherhat",--羽毛帽
	"bushhat",--灌木帽
	"hambat",--火腿棍
	"nightstick",--晨星
	"tentaclespike",--狼牙棒
	"whip",--三尾猫鞭
	"armormarble",--大理石甲
	"blowdart_sleep",--催眠吹箭
	"blowdart_fire",--火焰吹箭
	"blowdart_pipe",--吹箭
	"blowdart_yellow",--电箭
	"boomerang",--回旋镖
	"beemine",--蜜蜂地雷
	"trap_teeth",--犬牙陷阱
	"tophat",--绅士高帽
	"rainhat",--防雨帽
	"earmuffshat",--小兔耳罩
	"beefalohat",--牛角帽
	"winterhat",--冬帽
	"catcoonhat",--浣熊猫帽子
	"icehat",--冰块帽
	"beehat",--养蜂帽
	"raincoat",--雨衣
	"sweatervest",--格子背心
	"trunkvest_summer",--保暖小背心
	"reflectivevest",--清凉夏装
	"hawaiianshirt",--花衬衫
	"armorslurper",--饥饿腰带
	"wathgrithrhat",--战斗头盔
	"spear_wathgrithr",--战斗长矛
	"armordragonfly",--鳞甲
	"staff_tornado",--天气棒
	"goggleshat",--时髦目镜
	"deserthat",--沙漠目镜
	"trunkvest_winter",--寒冬背心
	"cane",--步行手杖
	"beargervest",--熊皮背心
	"eyebrellahat",--眼球伞
	"red_mushroomhat",--红蘑菇帽
	"green_mushroomhat",--绿蘑菇帽
	"blue_mushroomhat",--蓝蘑菇帽
	"panflute",--排箫
	"armor_sanity",--暗影护甲
	"nightsword",--暗夜剑
	"batbat",--蝙蝠棒
	"amulet",--重生护符
	"blueamulet",--寒冰护符
	"purpleamulet",--噩梦护符
	"firestaff",--火焰法杖
	"icestaff",--冰魔杖
	"telestaff",--传送魔杖
	"orangeamulet",--懒人强盗
	"yellowamulet",--魔光护符
	"greenamulet",--建造护符
	"orangestaff",--瞬移魔杖
	"yellowstaff",--唤星者法杖
	"greenstaff",--解构魔杖
	"ruinshat",--图勒皇冠
	"armorruins",--图勒护甲
	"ruins_bat",--图勒棒
	"eyeturret_item",--眼球塔
	"slurtlehat",--蜗牛帽
	"armorsnurtleshell",--蜗牛盔甲
	"hivehat",--蜂后头冠
	"opalstaff",--唤月法杖
	"armorskeleton",--远古骨甲
	"prayer_symbol",--祈运符
	"lucky_gem",--幸运宝石
	"keep_amulet",--保运护符
}

local CHESS_LOOT =
{
    "chesspiece_pawn_sketch",
    "chesspiece_muse_sketch",
    "chesspiece_formal_sketch",
    "trinket_15", --bishop
    "trinket_16", --bishop
    "trinket_28", --rook
    "trinket_29", --rook
    "trinket_30", --knight
    "trinket_31", --knight
}

for k, v in ipairs(CHESS_LOOT) do
    table.insert(prefabs, v)
end

local SFX_COOLDOWN = 5

local function onplayerprox(inst)
    if not inst.last_prox_sfx_time or (GetTime() - inst.last_prox_sfx_time > SFX_COOLDOWN) then
       inst.last_prox_sfx_time = GetTime()
       inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_choir")
    end
end

local function CheckGround(inst)
    if not inst:IsOnValidGround() then
        SpawnPrefab("splash_ocean").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:PushEvent("detachchild")
        inst:Remove()
    end
end

local function startmoving(inst)
    inst.AnimState:PushAnimation("move_loop", true)
    inst.bouncepretask = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncetask = inst:DoPeriodicTask(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
            CheckGround(inst)
        end)
    end)
    inst.components.blowinwind:Start()
    inst:RemoveEventCallback("animover", startmoving)
end


--生成滚草内容
local function MakeLoot(inst,picker)
	--获取人物幸运值
	local pickerLucky=50
	if picker~=nil and picker.components.lucky~=nil then
		pickerLucky=picker.components.lucky:getLucky()
	end
	
	--有益资源权重
	local good_min=1
	local good_mid=1
	local good_max=1
	if pickerLucky>50 then
		good_min=pickerLucky/10-4--1~6倍爆率
		good_mid=pickerLucky/5-9--1~11倍爆率
		good_max=pickerLucky/2.5-19--1~21倍爆率
	end
	--有害资源权重
	local bad_min=1
	local bad_mid=1
	local bad_max=1
	if pickerLucky<50 then
		bad_min=6-pickerLucky/10--1~6倍爆率
		bad_mid=11-pickerLucky/5--1~11倍爆率
		bad_max=21-pickerLucky/2.5--1~21倍爆率
	end
	
    local possible_loot =
    {
        {chance = 40,   item = "cutgrass"},--干草
        {chance = 40,   item = "twigs"},--树枝
    }
	--幸运道具
	local lucky_times=TUNING.GAME_LEVEL*good_mid
	local lucky_loot=
	{
		{chance = 0.2*lucky_times,   item = "prayer_symbol"},--祈运符
		{chance = 0.05*lucky_times,   item = "lucky_gem"},--幸运宝石
		{chance = 0.01*lucky_times,   item = "keep_amulet"},--保运护符
		{chance = 0.1*lucky_times,   item = "dyed_bucket_blueprint"},--染色桶蓝图
		{chance = 0.2*lucky_times,   item = "lucky_ash"},--幸运粉尘
		{chance = 0.05*lucky_times,   item = "keep_pill"},--保运丸
		{chance = 0.05*lucky_times,   item = "transport_pill"},--转运丸
		{chance = 0.01*lucky_times,   item = "lucky_staff"},--幸运法杖
		{chance = 0.01*lucky_times,   item = "lucky_hat"},--幸运帽
		{chance = 0.05*lucky_times,   item = "lucky_hat_blueprint"},--幸运帽蓝图
		{chance = 0.1*lucky_times,   item = "lucky_fruit_seeds"},--幸运种子
		{chance = 0.05*lucky_times,   item = "lucky_fruit"},--幸运果实
		{chance = 0.05*lucky_times,   item = "lucky_juice"},--幸运果汁
	}
	--基础资源
	local jczy_times=TUNING.JCZY_TIMES*good_min
	local jczy_loot=
	{
		{chance = 10*jczy_times,   item = "log"},--木头
		{chance = 1*jczy_times,   item = "charcoal"},--木炭
		{chance = 5*jczy_times,   item = "pinecone"},--松果
		{chance = 5*jczy_times,   item = "acorn"},--桦木果
		{chance = 10*jczy_times,   item = "flint"},--燧石
		{chance = 5*jczy_times,   item = "nitre"},--硝石
		{chance = 10*jczy_times,   item = "rocks"},--石头
		{chance = 1*jczy_times,   item = "marble"},--大理石
		{chance = 2*jczy_times,   item = "goldnugget"},--黄金
		{chance = 5*jczy_times,   item = "ice"},--冰
		{chance = 1*jczy_times,   item = "dug_grass"},--草丛
		{chance = 1*jczy_times,   item = "dug_sapling"},--树苗
		{chance = 2*jczy_times,   item = "dug_berrybush"},--普通浆果丛
		{chance = 1*jczy_times,   item = "dug_berrybush2"},--三叶浆果丛
        {chance = 5*jczy_times,    item = "petals_evil"},--恶魔花瓣
        {chance = 5*jczy_times,    item = "petals"},--花瓣
        {chance = 5*jczy_times,    item = "cutreeds"},--芦苇
	}
	--高级资源
	local gjzy_times=TUNING.GJZY_TIMES*good_mid
	local gjzy_loot={
		{chance = 0.5*gjzy_times,   item = "boards"},--木板
		{chance = 0.5*gjzy_times,   item = "cutstone"},--石砖
		{chance = 0.2*gjzy_times,   item = "papyrus"},--纸
		{chance = 0.2*gjzy_times,   item = "pigskin"},--猪皮
		{chance = 0.2*gjzy_times,   item = "manrabbit_tail"},--兔毛
		{chance = 0.5*gjzy_times,   item = "spidergland"},--蜘蛛腺体
		{chance = 0.2*gjzy_times,   item = "honeycomb"},--蜂巢
		{chance = 0.2*gjzy_times,   item = "tentaclespots"},--触手皮
		{chance = 0.5*gjzy_times,   item = "mosquitosack"},--蚊子血囊
		{chance = 0.2*gjzy_times,   item = "lightninggoathorn"},--闪电羊角
		{chance = 0.2*gjzy_times,   item = "glommerfuel"},--咕噜姆黏液
		{chance = 0.2*gjzy_times,   item = "nightmarefuel"},--噩梦燃料
		{chance = 0.2*gjzy_times,   item = "transistor"},--电子元件
		{chance = 0.5*gjzy_times,   item = "poop"},--便便
		{chance = 0.2*gjzy_times,   item = "waxpaper"},--蜡纸
		{chance = 0.2*gjzy_times,   item = "moonrocknugget"},--月石
        {chance = 0.5*gjzy_times,    item = "houndstooth"},--狗牙
        {chance = 0.5*gjzy_times,    item = "stinger"},--蜂刺
        {chance = 0.2*gjzy_times,    item = "gears"},--齿轮
        {chance = 0.2*gjzy_times,  item = "boneshard"},--骨头碎片
        {chance = 0.5*gjzy_times,    item = "silk"},--蜘蛛网
		{chance = 0.1*gjzy_times,    item = "spidereggsack"},--蜘蛛卵
        {chance = 0.5*gjzy_times,    item = "rope"},--绳子
        {chance = 0.5*gjzy_times, item = "feather_crow"},--乌鸦羽毛
        {chance = 0.5*gjzy_times, item = "feather_robin"},--红雀羽毛
        {chance = 0.5*gjzy_times, item = "feather_robin_winter"},--冬雀羽毛
        {chance = 0.3*gjzy_times, item = "feather_canary"},--金丝雀羽毛
        {chance = 0.3*gjzy_times,    item = "beefalowool"},--牛毛
        {chance = 0.5*gjzy_times,  item = "beardhair"},--胡子
        {chance = 0.2*gjzy_times,  item = "trinket_6"},--玩具6
        {chance = 0.2*gjzy_times,  item = "trinket_4"},--玩具4
        {chance = 0.2*gjzy_times,    item = "trinket_3"},--玩具3
        {chance = 0.2*gjzy_times,    item = "trinket_8"},--玩具8
	}
	--稀有资源
	local xyzy_times=TUNING.XYZY_TIMES*good_max
	local xyzy_loot={
		{chance = 0.03*xyzy_times,   item = "walrus_tusk"},--象牙
		{chance = 0.01*xyzy_times,   item = "minotaurhorn"},--远古守护者角
		{chance = 0.01*xyzy_times,   item = "deerclops_eyeball"},--巨鹿眼球
		{chance = 0.08*xyzy_times,   item = "livinglog"},--活木
		{chance = 0.01*xyzy_times,   item = "dragon_scales"},--蜻蜓鳞片
		{chance = 0.05*xyzy_times,   item = "goose_feather"},--鹿鸭羽毛
		{chance = 0.01*xyzy_times,   item = "bearger_fur"},--熊皮
		{chance = 0.01*xyzy_times,   item = "shroom_skin"},--蛤蟆皮
		{chance = 0.06*xyzy_times,   item = "steelwool"},--钢绒
		{chance = 0.01*xyzy_times,   item = "shadowheart"},--暗影之心
        {chance = 0.01*xyzy_times, item = "purplegem"},--紫宝石
        {chance = 0.04*xyzy_times, item = "bluegem"},--蓝宝石
        {chance = 0.02*xyzy_times, item = "redgem"},--红宝石
        {chance = 0.02*xyzy_times, item = "orangegem"},--橙宝石
        {chance = 0.01*xyzy_times, item = "yellowgem"},--黄宝石
        {chance = 0.02*xyzy_times, item = "greengem"},--绿宝石
		{chance = 0.05*xyzy_times, item = "townportaltalisman"},--砂石
	}
	--地穴资源
	local dxzy_times=TUNING.DXZY_TIMES*good_mid
	local dxzy_loot={
		{chance = 0.5*dxzy_times,   item = "lightbulb"},--荧光果
        {chance = 0.5*dxzy_times,    item = "foliage"},--蕨叶
		{chance = 0.08*dxzy_times,   item = "thulecite"},--铥矿
		{chance = 0.2*dxzy_times,   item = "thulecite_pieces"},--铥矿碎片
		{chance = 0.2*dxzy_times,   item = "slurtleslime"},--蜗牛黏液
		{chance = 0.2*dxzy_times,   item = "slurtle_shellpieces"},--蜗牛壳碎片
		{chance = 0.2*dxzy_times,   item = "slurper_pelt"},--啜食者皮
		{chance = 0.5*dxzy_times,   item = "guano"},--鸟粪
		{chance = 0.1*dxzy_times,   item = "fossil_piece"},--化石碎片
	}
	--基础食物
	local jcsw_times=TUNING.JCSW_TIMES*good_min
	local jcsw_loot={
        {chance = 2*jcsw_times,    item = "berries"},--浆果
        {chance = 4*jcsw_times,    item = "seeds"},--种子
		{chance = 1*jcsw_times,   item = "red_cap"},--红蘑菇
		{chance = 0.5*jcsw_times,   item = "green_cap"},--绿蘑菇
		{chance = 1*jcsw_times,   item = "blue_cap"},--蓝蘑菇
        {chance = 1*jcsw_times,    item = "butterflywings"},--蝴蝶翅膀
		{chance = 1*jcsw_times,   item = "carrot_seeds"},--胡萝卜种子
		{chance = 1*jcsw_times,   item = "pumpkin_seeds"},--南瓜种子
		{chance = 0.3*jcsw_times,   item = "dragonfruit_seeds"},--火龙果种子
		{chance = 1*jcsw_times,   item = "pomegranate_seeds"},--石榴种子
		{chance = 1*jcsw_times,   item = "corn_seeds"},--玉米种子
		{chance = 1*jcsw_times,   item = "durian_seeds"},--榴莲种子
		{chance = 1*jcsw_times,   item = "eggplant_seeds"},--茄子种子
	}
	--高级食物
	local gjsw_times=TUNING.GJSW_TIMES*good_mid
	local gjsw_loot={
		{chance = 0.3*gjsw_times,   item = "trunk_summer"},--夏象鼻
		{chance = 0.2*gjsw_times,   item = "trunk_winter"},--冬象鼻
		{chance = 0.4*gjsw_times,   item = "pumpkin"},--南瓜
		{chance = 0.2*gjsw_times,   item = "dragonfruit"},--火龙果
		{chance = 0.4*gjsw_times,   item = "pomegranate"},--石榴
		{chance = 0.4*gjsw_times,   item = "corn"},--玉米
		{chance = 0.4*gjsw_times,   item = "durian"},--榴莲
		{chance = 0.4*gjsw_times,   item = "eggplant"},--茄子
		{chance = 0.3*gjsw_times,   item = "cave_banana"},--洞穴香蕉
		{chance = 0.3*gjsw_times,   item = "cactus_meat"},--仙人掌肉
		{chance = 0.3*gjsw_times,   item = "watermelon"},--西瓜
		{chance = 0.3*gjsw_times,   item = "smallmeat"},--小肉
		{chance = 0.2*gjsw_times,   item = "meat"},--大肉
		{chance = 0.3*gjsw_times,   item = "drumstick"},--鸡腿
		{chance = 0.5*gjsw_times,   item = "monstermeat"},--疯肉
		{chance = 0.5*gjsw_times,   item = "plantmeat"},--食人花肉
		{chance = 0.4*gjsw_times,   item = "bird_egg"},--鸡蛋
		{chance = 0.2*gjsw_times,   item = "tallbirdegg"},--高鸟蛋
		{chance = 0.3*gjsw_times,   item = "fish"},--鱼
		{chance = 0.3*gjsw_times,   item = "froglegs"},--蛙腿
		{chance = 0.3*gjsw_times,   item = "batwing"},--蝙蝠翅膀
		{chance = 0.05*gjsw_times,   item = "mandrake"},--曼德拉草
		{chance = 0.5*gjsw_times,   item = "honey"},--蜂蜜
		{chance = 0.1*gjsw_times,   item = "butter"},--黄油
		{chance = 0.1*gjsw_times,   item = "goatmilk"},--羊奶
	}
	--食谱料理
	local spll_times=TUNING.SPLL_TIMES*good_max
	local spll_loot={
		{chance = 0.05*spll_times,   item = "butterflymuffin"},--蝴蝶松饼
		{chance = 0.05*spll_times,   item = "frogglebunwich"},--蛙腿三明治
		{chance = 0.04*spll_times,   item = "honeyham"},--蜜汁火腿
		{chance = 0.04*spll_times,   item = "dragonpie"},--火龙果馅饼
		{chance = 0.05*spll_times,   item = "taffy"},--太妃糖
		{chance = 0.05*spll_times,   item = "pumpkincookie"},--南瓜饼
		{chance = 0.05*spll_times,   item = "kabobs"},--肉串
		{chance = 0.05*spll_times,   item = "powcake"},--芝士蛋糕
		{chance = 0.02*spll_times,   item = "mandrakesoup"},--曼德拉草汤
		{chance = 0.04*spll_times,   item = "baconeggs"},--培根煎蛋
		{chance = 0.04*spll_times,   item = "bonestew"},--肉汤
		{chance = 0.05*spll_times,   item = "wetgoop"},--湿腻焦糊
		{chance = 0.05*spll_times,   item = "ratatouille"},--蔬菜什锦
		{chance = 0.05*spll_times,   item = "fruitmedley"},--水果圣代
		{chance = 0.05*spll_times,   item = "fishtacos"},--玉米鱼卷
		{chance = 0.05*spll_times,   item = "waffles"},--华夫饼
		{chance = 0.05*spll_times,   item = "turkeydinner"},--火鸡正餐
		{chance = 0.04*spll_times,   item = "fishsticks"},--鱼排
		{chance = 0.05*spll_times,   item = "stuffedeggplant"},--香酥茄盒
		{chance = 0.05*spll_times,   item = "honeynuggets"},--甜蜜金砖
		{chance = 0.05*spll_times,   item = "meatballs"},--肉丸
		{chance = 0.05*spll_times,   item = "jammypreserves"},--果酱
		{chance = 0.05*spll_times,   item = "monsterlasagna"},--怪物千层饼
		{chance = 0.05*spll_times,   item = "flowersalad"},--仙人掌沙拉
		{chance = 0.05*spll_times,   item = "icecream"},--冰淇淋
		{chance = 0.05*spll_times,   item = "watermelonicle"},--西瓜冰
		{chance = 0.05*spll_times,   item = "trailmix"},--坚果
		{chance = 0.05*spll_times,   item = "guacamole"},--鳄梨沙拉
	}
	--各种蓝图
	local gzlt_times=TUNING.GZLT_TIMES*good_mid
	local gzlt_loot={
        {chance = 0.1*gzlt_times,    item = "TOOLS_blueprint"},--工具蓝图
        {chance = 0.1*gzlt_times,    item = "LIGHT_blueprint"},--点燃蓝图
        {chance = 0.1*gzlt_times,    item = "SURVIVAL_blueprint"},--生存蓝图
        {chance = 0.1*gzlt_times,    item = "FARM_blueprint"},--食物蓝图
        {chance = 0.1*gzlt_times,    item = "SCIENCE_blueprint"},--科技蓝图
        {chance = 0.1*gzlt_times,    item = "WAR_blueprint"},--战斗蓝图
        {chance = 0.1*gzlt_times,    item = "TOWN_blueprint"},--建筑蓝图
        {chance = 0.1*gzlt_times,    item = "REFINE_blueprint"},--合成蓝图
        {chance = 0.1*gzlt_times,    item = "MAGIC_blueprint"},--魔法蓝图
        {chance = 0.1*gzlt_times,    item = "DRESS_blueprint"},--衣物蓝图
	}
	--基础道具
	local jcdj_times=TUNING.JCDJ_TIMES*good_min
	local jcdj_loot={
        {chance = 0.5*jcdj_times,    item = "axe"},--斧头
		{chance = 0.25*jcdj_times,    item = "goldenaxe"},--黄金斧头
		{chance = 0.5*jcdj_times,    item = "pickaxe"},--鹤嘴锄
		{chance = 0.25*jcdj_times,    item = "goldenpickaxe"},--黄金鹤嘴锄
		{chance = 0.4*jcdj_times,    item = "shovel"},--铲子
		{chance = 0.25*jcdj_times,    item = "goldenshovel"},--黄金铲子
		{chance = 0.4*jcdj_times,    item = "hammer"},--锤子
		{chance = 0.5*jcdj_times,    item = "pitchfork"},--草叉
		{chance = 0.5*jcdj_times,    item = "razor"},--剃刀
		{chance = 0.5*jcdj_times,    item = "trap"},--陷阱
		{chance = 0.5*jcdj_times,    item = "grass_umbrella"},--普通花伞
		{chance = 0.5*jcdj_times,    item = "compass"},--指南针
		{chance = 0.4*jcdj_times,    item = "backpack"},--背包
		{chance = 0.4*jcdj_times,    item = "bedroll_straw"},--凉席
		{chance = 1*jcdj_times,    item = "torch"},--火炬
	}
	--进阶道具
	local jjdj_times=TUNING.JJDJ_TIMES*good_mid
	local jjdj_loot={
        {chance = 0.25*jjdj_times,    item = "featherpencil"},--羽毛笔
		{chance = 0.1*jjdj_times,    item = "saddlehorn"},--鞍角
		{chance = 0.1*jjdj_times,    item = "saddle_basic"},--上鞍
		{chance = 0.15*jjdj_times,    item = "healingsalve"},--治疗药膏
		{chance = 0.1*jjdj_times,    item = "bandage"},--蜂蜜药膏
		{chance = 0.1*jjdj_times,    item = "lifeinjector"},--强心针
		{chance = 0.25*jjdj_times,    item = "birdtrap"},--捕鸟陷阱
		{chance = 0.25*jjdj_times,    item = "bugnet"},--捕虫网
		{chance = 0.25*jjdj_times,    item = "fishingrod"},--钓竿
		{chance = 0.25*jjdj_times,    item = "umbrella"},--雨伞
		{chance = 0.1*jjdj_times,    item = "waterballoon"},--水球
		{chance = 0.1*jjdj_times,    item = "heatrock"},--热能石
		{chance = 0.1*jjdj_times,    item = "piggyback"},--猪皮背包
		{chance = 0.1*jjdj_times,    item = "bedroll_furry"},--毛皮铺盖
		{chance = 0.1*jjdj_times,    item = "fertilizer"},--堆肥桶
		{chance = 0.1*jjdj_times,    item = "sewing_kit"},--针线包
		{chance = 0.1*jjdj_times,    item = "minerhat"},--矿工帽
		{chance = 0.1*jjdj_times,    item = "molehat"},--鼹鼠帽
		{chance = 0.1*jjdj_times,    item = "lantern"},--提灯
		{chance = 0.1*jjdj_times,    item = "deer_antler"},--鹿角
	}
	--稀有道具
	local xydj_times=TUNING.XYDJ_TIMES*good_max
	--print("稀有道具爆率*"..xydj_times)--测试用代码
	local xydj_loot={
        {chance = 0.03*xydj_times,    item = "saddle_war"},--战争牛鞍
		{chance = 0.05*xydj_times,    item = "saddle_race"},--薄弱牛鞍
		{chance = 0.05*xydj_times,    item = "brush"},--洗刷
		{chance = 0.1*xydj_times,   item = "bundlewrap"},--捆绑包装纸
		{chance = 0.05*xydj_times,    item = "featherfan"},--羽毛扇
		{chance = 0.02*xydj_times,    item = "icepack"},--保鲜背包
		{chance = 0.01*xydj_times,    item = "krampus_sack"},--坎普斯背包
		{chance = 0.08*xydj_times,    item = "multitool_axe_pickaxe"},--多功能工具
		{chance = 0.01*xydj_times,    item = "klaussackkey"},--克劳斯钥匙
	}
	--基础装备
	local jczb_times=TUNING.JCZB_TIMES*good_min
	local jczb_loot={
        {chance = 0.5*jczb_times,    item = "spear"},--长矛
		{chance = 0.5*jczb_times,    item = "armorgrass"},--草甲
		{chance = 0.33*jczb_times,    item = "armorwood"},--木甲
		{chance = 0.25*jczb_times,    item = "footballhat"},--橄榄球头盔
		{chance = 0.5*jczb_times,    item = "flowerhat"},--花环
		{chance = 0.5*jczb_times,    item = "strawhat"},--草帽
		{chance = 0.5*jczb_times,    item = "watermelonhat"},--西瓜帽
		{chance = 0.5*jczb_times,    item = "featherhat"},--羽毛帽
		{chance = 0.5*jczb_times,    item = "bushhat"},--灌木帽
	}
	--进阶装备
	local jjzb_times=TUNING.JJZB_TIMES*good_mid
	local jjzb_loot={
        {chance = 0.15*jjzb_times,    item = "hambat"},--火腿棍
		{chance = 0.2*jjzb_times,    item = "nightstick"},--晨星
		{chance = 0.15*jjzb_times,    item = "tentaclespike"},--狼牙棒
		{chance = 0.2*jjzb_times,    item = "whip"},--三尾猫鞭
		{chance = 0.1*jjzb_times,    item = "armormarble"},--大理石甲
		{chance = 0.15*jjzb_times,    item = "blowdart_sleep"},--催眠吹箭
		{chance = 0.15*jjzb_times,    item = "blowdart_fire"},--火焰吹箭
		{chance = 0.15*jjzb_times,    item = "blowdart_pipe"},--吹箭
		{chance = 0.1*jjzb_times,    item = "blowdart_yellow"},--电箭
		{chance = 0.2*jjzb_times,    item = "boomerang"},--回旋镖
		{chance = 0.1*jjzb_times,    item = "beemine"},--蜜蜂地雷
		{chance = 0.15*jjzb_times,    item = "trap_teeth"},--犬牙陷阱
		{chance = 0.2*jjzb_times,    item = "tophat"},--绅士高帽
		{chance = 0.15*jjzb_times,    item = "rainhat"},--防雨帽
		{chance = 0.15*jjzb_times,    item = "earmuffshat"},--小兔耳罩
		{chance = 0.1*jjzb_times,    item = "beefalohat"},--牛角帽
		{chance = 0.15*jjzb_times,    item = "winterhat"},--冬帽
		{chance = 0.2*jjzb_times,    item = "catcoonhat"},--浣熊猫帽子
		{chance = 0.2*jjzb_times,    item = "icehat"},--冰块帽
		{chance = 0.15*jjzb_times,    item = "beehat"},--养蜂帽
		{chance = 0.2*jjzb_times,    item = "raincoat"},--雨衣
		{chance = 0.33*jjzb_times,    item = "sweatervest"},--格子背心
		{chance = 0.15*jjzb_times,    item = "trunkvest_summer"},--保暖小背心
		{chance = 0.33*jjzb_times,    item = "reflectivevest"},--清凉夏装
		{chance = 0.33*jjzb_times,    item = "hawaiianshirt"},--花衬衫
		{chance = 0.15*jjzb_times,    item = "armorslurper"},--饥饿腰带
		{chance = 0.15*jjzb_times,    item = "wathgrithrhat"},--战斗头盔
		{chance = 0.15*jjzb_times,    item = "spear_wathgrithr"},--战斗长矛
	}
	--稀有装备
	local xyzb_times=TUNING.XYZB_TIMES*good_max
	local xyzb_loot={
        {chance = 0.05*xyzb_times,    item = "armordragonfly"},--鳞甲
		{chance = 0.05*xyzb_times,    item = "staff_tornado"},--天气棒
		{chance = 0.05*xyzb_times,    item = "goggleshat"},--时髦目镜
		{chance = 0.05*xyzb_times,    item = "deserthat"},--沙漠目镜
		{chance = 0.05*xyzb_times,    item = "trunkvest_winter"},--寒冬背心
		{chance = 0.02*xyzb_times,    item = "cane"},--步行手杖
		{chance = 0.02*xyzb_times,    item = "beargervest"},--熊皮背心
		{chance = 0.02*xyzb_times,    item = "eyebrellahat"},--眼球伞
		{chance = 0.05*xyzb_times,    item = "red_mushroomhat"},--红蘑菇帽
		{chance = 0.05*xyzb_times,    item = "green_mushroomhat"},--绿蘑菇帽
		{chance = 0.05*xyzb_times,    item = "blue_mushroomhat"},--蓝蘑菇帽
		{chance = 0.01*xyzb_times,    item = "panflute"},--排箫
		{chance = 0.05*xyzb_times,    item = "armor_sanity"},--暗影护甲
		{chance = 0.05*xyzb_times,    item = "nightsword"},--暗夜剑
		{chance = 0.05*xyzb_times,    item = "batbat"},--蝙蝠棒
		{chance = 0.05*xyzb_times,    item = "amulet"},--重生护符
		{chance = 0.05*xyzb_times,    item = "blueamulet"},--寒冰护符
		{chance = 0.03*xyzb_times,    item = "purpleamulet"},--噩梦护符
		{chance = 0.05*xyzb_times,    item = "firestaff"},--火焰法杖
		{chance = 0.05*xyzb_times,    item = "icestaff"},--冰魔杖
		{chance = 0.02*xyzb_times,    item = "telestaff"},--传送魔杖
		{chance = 0.02*xyzb_times,    item = "orangeamulet"},--懒人强盗
		{chance = 0.02*xyzb_times,    item = "yellowamulet"},--魔光护符
		{chance = 0.01*xyzb_times,    item = "greenamulet"},--建造护符
		{chance = 0.01*xyzb_times,    item = "orangestaff"},--瞬移魔杖
		{chance = 0.05*xyzb_times,    item = "yellowstaff"},--唤星者法杖
		{chance = 0.01*xyzb_times,    item = "greenstaff"},--解构魔杖
		{chance = 0.05*xyzb_times,    item = "ruinshat"},--图勒皇冠
		{chance = 0.05*xyzb_times,    item = "armorruins"},--图勒护甲
		{chance = 0.05*xyzb_times,    item = "ruins_bat"},--图勒棒
		{chance = 0.01*xyzb_times,    item = "eyeturret_item"},--眼球塔
		{chance = 0.03*xyzb_times,    item = "slurtlehat"},--蜗牛帽
		{chance = 0.03*xyzb_times,    item = "armorsnurtleshell"},--蜗牛盔甲
		{chance = 0.01*xyzb_times,    item = "hivehat"},--蜂后头冠
		{chance = 0.01*xyzb_times,    item = "opalstaff"},--唤月法杖
		{chance = 0.01*xyzb_times,    item = "armorskeleton"},--远古骨甲
	}
	--普通怪物
	local ptgw_times=TUNING.PTGW_TIMES*bad_min
	local ptgw_loot={
        {chance = 0.5*ptgw_times,  item = "rabbit"},--兔子
        {chance = 0.5*ptgw_times,  item = "mole"},--鼹鼠
        {chance = 1*ptgw_times,  item = "spider", aggro = true},--蜘蛛
        {chance = 1*ptgw_times,  item = "frog", aggro = true},--青蛙
        {chance = 1*ptgw_times,  item = "bee", aggro = true},--蜜蜂
        {chance = 1*ptgw_times,  item = "mosquito", aggro = true},--蚊子
	}
	--进阶怪物
	local jjgw_times=TUNING.JJGW_TIMES*bad_mid
	local jjgw_loot={
		{chance = 0.1*jjgw_times,  item = "beefalo", aggro = true},--牛
		{chance = 0.1*jjgw_times,  item = "lightninggoat", aggro = true},--闪电羊
		{chance = 0.1*jjgw_times,  item = "pigman", aggro = true},--猪人
		{chance = 0.1*jjgw_times,  item = "pigguard", aggro = true},--猪人守卫
		{chance = 0.1*jjgw_times,  item = "bunnyman", aggro = true},--兔人
		{chance = 0.1*jjgw_times,  item = "merm", aggro = true},--鱼人
		{chance = 0.1*jjgw_times,  item = "spider_warrior", aggro = true},--蜘蛛战士
		{chance = 0.1*jjgw_times,  item = "hound", aggro = true},--猎狗
		{chance = 0.1*jjgw_times,  item = "firehound", aggro = true},--火狗
		{chance = 0.1*jjgw_times,  item = "icehound", aggro = true},--冰狗
		{chance = 0.08*jjgw_times,  item = "walrus", aggro = true},--海象
		{chance = 0.1*jjgw_times,  item = "tallbird", aggro = true},--高鸟
		{chance = 0.1*jjgw_times,  item = "koalefant_summer", aggro = true},--夏象
		{chance = 0.1*jjgw_times,  item = "koalefant_winter", aggro = true},--冬象
		{chance = 0.1*jjgw_times,  item = "bat", aggro = true},--蝙蝠
		{chance = 0.1*jjgw_times,  item = "rocky", aggro = true},--石虾
		{chance = 0.1*jjgw_times,  item = "monkey", aggro = true},--猴子
		{chance = 0.1*jjgw_times,  item = "knight", aggro = true},--发条骑士
		{chance = 0.1*jjgw_times,  item = "bishop", aggro = true},--发条主教
		{chance = 0.1*jjgw_times,  item = "rook", aggro = true},--发条战车
		{chance = 0.1*jjgw_times,  item = "crawlinghorror", aggro = true},--暗影爬行怪
		{chance = 0.1*jjgw_times,  item = "terrorbeak", aggro = true},--尖嘴暗影怪
		{chance = 0.1*jjgw_times,  item = "worm", aggro = true},--洞穴蠕虫
		{chance = 0.1*jjgw_times,  item = "krampus", aggro = true},--小偷
		{chance = 0.1*jjgw_times,  item = "mossling", aggro = true},--小鸭
		{chance = 0.1*jjgw_times,  item = "tentacle", aggro = true},--触手
	}
	--高级怪物
	local gjgw_times=TUNING.GJGW_TIMES*bad_max
	local gjgw_loot={
		{chance = 0.05*gjgw_times,  item = "spiderqueen", aggro = true},--蜘蛛女王
		{chance = 0.05*gjgw_times,  item = "leif", aggro = true},--树精
		{chance = 0.05*gjgw_times,  item = "leif_sparse", aggro = true},--稀有树精
		{chance = 0.03*gjgw_times,  item = "deerclops", aggro = true},--巨鹿
		{chance = 0.01*gjgw_times,  item = "minotaur", aggro = true},--远古守护者
		{chance = 0.05*gjgw_times,  item = "moose", aggro = true},--鹿鸭
		{chance = 0.01*gjgw_times,  item = "dragonfly", aggro = true},--龙蝇
		{chance = 0.05*gjgw_times,  item = "warg", aggro = true},--座狼
		{chance = 0.03*gjgw_times,  item = "bearger", aggro = true},--熊大
		{chance = 0.01*gjgw_times,  item = "toadstool", aggro = true},--蘑菇蛤
		{chance = 0.05*gjgw_times,  item = "spat", aggro = true},--钢羊
		{chance = 0.02*gjgw_times,  item = "shadow_rook", aggro = true},--暗影战车
		{chance = 0.02*gjgw_times,  item = "shadow_knight", aggro = true},--暗影骑士
		{chance = 0.02*gjgw_times,  item = "shadow_bishop", aggro = true},--暗影主教
		{chance = 0.01*gjgw_times,  item = "beequeen", aggro = true},--蜂后
	}
	--花样作死
	local hyzs_times=TUNING.HYZS_TIMES*bad_max
	local hyzs_loot={
		{chance = 0.1*hyzs_times,  item = "lightning"},--晴天霹雳
		{chance = 0.2*hyzs_times,  item = "sanity"},--精神风暴
		{chance = 0.05*hyzs_times,  item = "tallbird_circle"},--高鸟牢笼
		{chance = 0.05*hyzs_times,  item = "wasphive_circle"},--杀人蜂阵
		{chance = 0.05*hyzs_times,  item = "tentacle_circle"},--触手牢笼
		{chance = 0.02*hyzs_times,  item = "boom_circle"},--爆炸法阵
		{chance = 0.04*hyzs_times,   item = "woodwall_circle"},--火烧藤甲兵
	}
	--特殊福利
	local tsfl_times=TUNING.TSFL_TIMES*good_max
	local tsfl_loot={
		{chance = 0.03*tsfl_times,  item = "warg_fuli"},--圈养狗王
		{chance = 0.03*tsfl_times,  item = "dachu_fuli"},--大厨套装
		{chance = 0.01*tsfl_times,  item = "yuangu_fuli"},--远古祭坛
		{chance = 0.05*tsfl_times,  item = "fuhuo_fuli"},--复活石
		{chance = 0.03*tsfl_times,  item = "zhanlu_fuli"},--站撸三件套
	}

	--添加主表函数
	local function insertLoot(lootname)
		for a,b in ipairs(lootname) do
			table.insert(possible_loot, b)
		end
	end
	
	--判断是否需要加入表格
	if TUNING.JCZY_TIMES>0 then
		insertLoot(jczy_loot)--加入基础资源
	end
	if TUNING.GJZY_TIMES>0 then
		insertLoot(gjzy_loot)--加入高级资源
	end
	if TUNING.XYZY_TIMES>0 then
		insertLoot(xyzy_loot)--加入稀有资源
	end
	if TUNING.DXZY_TIMES>0 then
		insertLoot(dxzy_loot)--加入地穴资源
	end
	if TUNING.JCSW_TIMES>0 then
		insertLoot(jcsw_loot)--加入基础食物
	end
	if TUNING.GJSW_TIMES>0 then
		insertLoot(gjsw_loot)--加入高级食物
	end
	if TUNING.SPLL_TIMES>0 then
		insertLoot(spll_loot)--加入食谱料理
	end
	if TUNING.GZLT_TIMES>0 then
		insertLoot(gzlt_loot)--加入各种蓝图
	end
	if TUNING.JCDJ_TIMES>0 then
		insertLoot(jcdj_loot)--加入基础道具
	end
	if TUNING.JJDJ_TIMES>0 then
		insertLoot(jjdj_loot)--加入进阶道具
	end
	if TUNING.XYDJ_TIMES>0 then
		insertLoot(xydj_loot)--加入稀有道具
	end
	if TUNING.JCZB_TIMES>0 then
		insertLoot(jczb_loot)--加入基础装备
	end
	if TUNING.JJZB_TIMES>0 then
		insertLoot(jjzb_loot)--加入进阶装备
	end
	if TUNING.XYZB_TIMES>0 then
		insertLoot(xyzb_loot)--加入稀有装备
	end
	if TUNING.PTGW_TIMES>0 then
		insertLoot(ptgw_loot)--加入普通怪物
	end
	if TUNING.JJGW_TIMES>0 then
		insertLoot(jjgw_loot)--加入进阶怪物
	end
	if TUNING.GJGW_TIMES>0 then
		insertLoot(gjgw_loot)--加入高级怪物
	end
	if TUNING.HYZS_TIMES>0 then
		insertLoot(hyzs_loot)--加入花样作死
	end
	if TUNING.TSFL_TIMES>0 then
		insertLoot(tsfl_loot)--加入特殊福利
	end
	if TUNING.GAME_LEVEL>0 then
		insertLoot(lucky_loot)--加入幸运道具
	end
	
    local chessunlocks = TheWorld.components.chessunlocks
    if chessunlocks ~= nil then
        for i, v in ipairs(CHESS_LOOT) do
            if not chessunlocks:IsLocked(v) then
                table.insert(possible_loot, { chance = .1, item = v })
            end
        end
    end

    local totalchance = 0
    for m, n in ipairs(possible_loot) do
        totalchance = totalchance + n.chance
    end

    inst.loot = {}
    inst.lootaggro = {}
    local next_loot = nil
    local next_aggro = nil
    local next_chance = nil
    local num_loots = 3
    while num_loots > 0 do
        next_chance = math.random()*totalchance
        next_loot = nil
        next_aggro = nil
        for m, n in ipairs(possible_loot) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next_loot = n.item
                if n.aggro then next_aggro = true end
                break
            end
        end
        if next_loot ~= nil then
            table.insert(inst.loot, next_loot)
            if next_aggro then 
                table.insert(inst.lootaggro, true)
            else
                table.insert(inst.lootaggro, false)
            end
            num_loots = num_loots - 1
        end
    end
end

--打开风滚草
local function onpickup(inst, picker)
    local x, y, z = inst.Transform:GetWorldPosition()
	local px,py,pz= picker.Transform:GetWorldPosition()
	local firstPickup=false;
	
	--判断打开风滚草的是不是玩家，防止眼球草吃风滚草后崩档
	if picker~=nil and picker.components.lucky~=nil then
		--判断难度是不是为简单
		if TUNING.GAME_LEVEL ==0 then
			picker.components.lucky:SetLucky(50)
		end
		--判断玩家是不是第一次打开风滚草
		if picker.components.lucky:isFirst()==1 then
			firstPickup=true
		end
	end
	
	--生成风滚草内容
	if firstPickup then
		inst.loot = {
			"keep_amulet",
			"lucky_gem",
			"prayer_symbol",
		}
		inst.lootaggro = {}
		picker.components.lucky:DoFirst()
	else
		MakeLoot(inst,picker)
	end
	
	
	--print(picker.player_classified.currentsanity:value())--获取玩家脑残值，测试用
	
	--扣除幸运值
	if picker~=nil and picker.components.lucky~=nil then
		picker.components.lucky:DoMinus(-TUNING.GAME_LEVEL)
		--print(picker:GetDisplayName().."的幸运值："..picker.components.lucky:getLucky())--测试用代码
	end
	
    inst:PushEvent("detachchild")

    local item = nil
    for i, v in ipairs(inst.loot) do
		--晴天霹雳
		if v == "lightning" then
			local num_lightnings = 10
			picker:StartThread(function()
				for k = 0, num_lightnings do
					local rad = math.random(3, 10)
					local angle = k * 2 * PI / (num_lightnings+1)
					local pos = Vector3(rad * math.cos(angle)+px, py, rad * math.sin(angle)+pz)
					TheWorld:PushEvent("ms_sendlightningstrike", pos)
					Sleep(.3 + math.random() * .2)
				end
			end)
			
			break
		--精神风暴
		elseif v == "sanity" then 
			if picker ~= nil and picker.components.sanity ~= nil then
				picker.components.sanity:DoDelta(-TUNING.SANITY_LARGE*3)
			end
			break
		--高鸟牢笼
		elseif v == "tallbird_circle" then
			local num_tallbird=5;
			for k=0,num_tallbird do
				local angle = k * 2 * PI / (num_tallbird+1)
				--判断生成位置是否超出地图边界
				if TheWorld.Map:IsPassableAtPoint(4*math.cos(angle)+px, py, 4*math.sin(angle)+pz) then
					item = SpawnPrefab("tallbird")
					item.Transform:SetPosition(4*math.cos(angle)+px, py, 4*math.sin(angle)+pz)
					if picker ~= nil then
						item.components.combat:SuggestTarget(picker)
					end
				end
			end
			break
		--杀人蜂阵
		elseif v == "wasphive_circle" then
			local num_wasphive=5;
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				--判断生成位置是否超出地图边界
				if TheWorld.Map:IsPassableAtPoint(7*math.cos(angle)+px, py, 7*math.sin(angle)+pz) then
					item = SpawnPrefab("wasphive")
					item.Transform:SetPosition(7*math.cos(angle)+px, py, 7*math.sin(angle)+pz)
				end
			end
			break
		--触手牢笼
		elseif v == "tentacle_circle" then
			local num_wasphive=7;
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				--判断生成位置是否超出地图边界并生成石墙牢笼
				if TheWorld.Map:IsPassableAtPoint(2*math.cos(angle)+px, py, 2*math.sin(angle)+pz) then
					item = SpawnPrefab("wall_stone")
					item.Transform:SetPosition(2*math.cos(angle)+px, py, 2*math.sin(angle)+pz)
				end
				if TheWorld.Map:IsPassableAtPoint(5*math.cos(angle)+px, py, 5*math.sin(angle)+pz) then
					item = SpawnPrefab("tentacle")
					item.Transform:SetPosition(5*math.cos(angle)+px, py, 5*math.sin(angle)+pz)
					if picker ~= nil then
						item.components.combat:SuggestTarget(picker)
					end
				end
			end
			break
		--爆炸法阵（必死）
		elseif v == "boom_circle" then
			local num_wasphive=7;
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				if TheWorld.Map:IsPassableAtPoint(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz) then
					item = SpawnPrefab("gunpowder")
					item.Transform:SetPosition(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz)
					item.components.explosive:OnBurnt()
				end
			end
			break
		--火烧藤甲兵
		elseif v == "woodwall_circle" then
			local num_wasphive=7;
			--生成燃烧的木墙圈
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				if TheWorld.Map:IsPassableAtPoint(2*math.cos(angle)+px, py, 2*math.sin(angle)+pz) then
					item = SpawnPrefab("wall_wood")
					item.Transform:SetPosition(2*math.cos(angle)+px, py, 2*math.sin(angle)+pz)
					item.components.burnable:Ignite(true)
				end
			end
			break
		--圈养狗王
		elseif v == "warg_fuli" then
			local num_wasphive=7;
			--生成狗王
			item = SpawnPrefab("warg")
			item.Transform:SetPosition(px, py, pz)
			--生成烧焦的树圈
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				if TheWorld.Map:IsPassableAtPoint(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz) then
					item = SpawnPrefab("evergreen")
					item.Transform:SetPosition(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz)
					item:AddTag("burnt")
				end
			end
			break
		--大厨套装
		elseif v == "dachu_fuli" then
			local num_wasphive=5;
			--生成冰箱
			item = SpawnPrefab("icebox")
			item.Transform:SetPosition(px, py, pz)
			--生成锅
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				if TheWorld.Map:IsPassableAtPoint(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz) then
					item = SpawnPrefab("cookpot")
					item.Transform:SetPosition(3*math.cos(angle)+px, py, 3*math.sin(angle)+pz)
				end
			end
			break
		--远古祭坛
		elseif v == "yuangu_fuli" then
			local num_wasphive=7;
			--生成祭坛
			item = SpawnPrefab("ancient_altar")
			item.Transform:SetPosition(px, py, pz)
			--生成远古法师雕像
			for k=0,num_wasphive do
				local angle = k * 2 * PI / (num_wasphive+1)
				if TheWorld.Map:IsPassableAtPoint(4*math.cos(angle)+px, py, 4*math.sin(angle)+pz) then
					item = SpawnPrefab("ruins_statue_mage")
					item.Transform:SetPosition(4*math.cos(angle)+px, py, 4*math.sin(angle)+pz)
				end
			end
			break
		--复活石
		elseif v == "fuhuo_fuli" then
			item = SpawnPrefab("resurrectionstone")
			item.Transform:SetPosition(px, py, pz)
			break
		--站撸三件套
		elseif v == "zhanlu_fuli" then
			item = SpawnPrefab("ruins_bat")
			item.Transform:SetPosition(px, py, pz)
			item = SpawnPrefab("ruinshat")
			item.Transform:SetPosition(px, py, pz)
			item = SpawnPrefab("armorruins")
			item.Transform:SetPosition(px, py, pz)
			break
		--生成物品
		else
			item = SpawnPrefab(v)
			item.Transform:SetPosition(x, y, z)
			if item.components.inventoryitem ~= nil and item.components.inventoryitem.ondropfn ~= nil then
				item.components.inventoryitem.ondropfn(item)
			end
			if inst.lootaggro[i] and item.components.combat ~= nil and picker ~= nil then
				if not (item:HasTag("spider") and (picker:HasTag("spiderwhisperer") or picker:HasTag("monster"))) then
					item.components.combat:SuggestTarget(picker)
				end
			end
		end
    end

    SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
    inst:Remove()
    return true --This makes the inventoryitem component not actually give the tumbleweed to the player
end


local function DoDirectionChange(inst, data)

    if not inst.entity:IsAwake() then return end

    if data and data.angle and data.velocity and inst.components.blowinwind then
        if inst.angle == nil then
            inst.angle = math.clamp(GetRandomWithVariance(data.angle, ANGLE_VARIANCE), 0, 360)
            inst.components.blowinwind:Start(inst.angle, data.velocity)
        else
            inst.angle = math.clamp(GetRandomWithVariance(data.angle, ANGLE_VARIANCE), 0, 360)
            inst.components.blowinwind:ChangeDirection(inst.angle, data.velocity)
        end
    end
end

local function spawnash(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(x, y, z)

    if inst.components.stackable ~= nil then
        ash.components.stackable.stacksize = math.min(ash.components.stackable.maxsize, inst.components.stackable.stacksize)
    end

    inst:PushEvent("detachchild")
    SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function onburnt(inst)
    inst:PushEvent("detachchild")
    inst:AddTag("burnt")

    inst.components.pickable.canbepicked = false
    inst.components.propagator:StopSpreading()

    inst.Physics:Stop()
    inst.components.blowinwind:Stop()
    inst:RemoveEventCallback("animover", startmoving)

    if inst.bouncepretask then
        inst.bouncepretask:Cancel()
        inst.bouncepretask = nil
    end
    if inst.bouncetask then
        inst.bouncetask:Cancel()
        inst.bouncetask = nil
    end
    if inst.restartmovementtask then
        inst.restartmovementtask:Cancel()
        inst.restartmovementtask = nil
    end
    if inst.bouncepst1 then
        inst.bouncepst1:Cancel()
        inst.bouncepst1 = nil
    end
    if inst.bouncepst2 then
        inst.bouncepst2:Cancel()
        inst.bouncepst2 = nil
    end

    inst.AnimState:PlayAnimation("move_pst")
    inst.AnimState:PushAnimation("idle")
    inst.bouncepst1 = inst:DoTaskInTime(4*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst1 = nil
    end)
    inst.bouncepst2 = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst2 = nil
    end)

    inst:DoTaskInTime(1.2, spawnash)
end

local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        onburnt(inst)
    end
end

local function CancelRunningTasks(inst)
    if inst.bouncepretask then
       inst.bouncepretask:Cancel()
        inst.bouncepretask = nil
    end
    if inst.bouncetask then
        inst.bouncetask:Cancel()
        inst.bouncetask = nil
    end
    if inst.restartmovementtask then
        inst.restartmovementtask:Cancel()
        inst.restartmovementtask = nil
    end
    if inst.bouncepst1 then
       inst.bouncepst1:Cancel()
        inst.bouncepst1 = nil
    end
    if inst.bouncepst2 then
        inst.bouncepst2:Cancel()
        inst.bouncepst2 = nil
    end
end

local function OnEntityWake(inst)
    inst.AnimState:PlayAnimation("move_loop", true)
    inst.bouncepretask = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncetask = inst:DoPeriodicTask(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
            CheckGround(inst)
        end)
    end)
end

local function OnLongAction(inst)
    inst.Physics:Stop()
    inst.components.blowinwind:Stop()
    inst:RemoveEventCallback("animover", startmoving)

    CancelRunningTasks(inst)

    inst.AnimState:PlayAnimation("move_pst")
    inst.bouncepst1 = inst:DoTaskInTime(4*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst1 = nil
    end)
    inst.bouncepst2 = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst2 = nil
    end)
    inst.AnimState:PushAnimation("idle", true)
    inst.restartmovementtask = inst:DoTaskInTime(math.random(2,6), function(inst)
        if inst and inst.components.blowinwind then
            inst.AnimState:PlayAnimation("move_pre")
            inst.restartmovementtask = nil
            inst:ListenForEvent("animover", startmoving)
        end
    end)
end

local function burntfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("tumbleweed")
    inst.AnimState:SetBank("tumbleweed")
    inst.AnimState:PlayAnimation("break")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    -- In case we're off screen and animation is asleep
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(1.7, .8)

    inst.AnimState:SetBuild("tumbleweed")
    inst.AnimState:SetBank("tumbleweed")
    inst.AnimState:PlayAnimation("move_loop", true)

    MakeCharacterPhysics(inst, .5, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetTriggersCreep(false)

    inst:AddComponent("blowinwind")
    inst.components.blowinwind.soundPath = "dontstarve_DLC001/common/tumbleweed_roll"
    inst.components.blowinwind.soundName = "tumbleweed_roll"
    inst.components.blowinwind.soundParameter = "speed"
    inst.angle = (TheWorld and TheWorld.components.worldwind) and TheWorld.components.worldwind:GetWindAngle() or nil
    inst:ListenForEvent("windchange", function(world, data)
        DoDirectionChange(inst, data)
    end, TheWorld)
    if inst.angle ~= nil then
        inst.angle = math.clamp(GetRandomWithVariance(inst.angle, ANGLE_VARIANCE), 0, 360)
        inst.components.blowinwind:Start(inst.angle)
    else
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_roll", "tumbleweed_roll")
    end

    ---local color = 0.5 + math.random() * 0.5
    ---inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetOnPlayerNear(onplayerprox)
    inst.components.playerprox:SetDist(5,10)

    --inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true

    inst:ListenForEvent("startlongaction", OnLongAction)

    --MakeLoot(inst)

    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("character_fire", Vector3(.1, 0, .1), "swap_fire")
    inst.components.burnable.canlight = true
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetBurnTime(10)

    MakeSmallPropagator(inst)
    inst.components.propagator.flashpoint = 5 + math.random()*3
    inst.components.propagator.propagaterange = 5

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = CancelRunningTasks
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            onpickup(inst, nil)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
        end
        return true
    end)

    return inst
end

return Prefab("tumbleweed", fn, assets, prefabs),
    Prefab("tumbleweedbreakfx", burntfxfn, assets)
