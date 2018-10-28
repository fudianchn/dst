name = "每月更新"
description = "自用"
author = "guido"
version = "0.0.2"
forumthread = ""
--api版本联机10，单机6
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
--兼容单机
dont_starve_compatible = false
--兼容联机
dst_compatible = true
--兼容巨人国
reign_of_giants_compatible = false
--兼容海难
shipwrecked_compatible = false
--仅客户端
client_only_mod = false
--所有客户端
all_clients_require_mod = true
--仅服务器
server_only_mod = false
--服务器标签
server_filter_tags = { "每月更新" }

standalone = false
restart_required = false

local sections = 0

local function divide(label, tip)
	sections = sections + 1
	return
	{	
		name = "menu_divider" .. sections,
		label = label,
		options =
		{	
			{ description = "", data = false },
		},
		default = false,
	}
end

local function recipe_ingredients(description, steelwool, cutstone, gunpowder)
	return
	{
		description = description,
		data = "" .. steelwool .. "/" .. cutstone .. "/" .. gunpowder,
		hover = "Steel Wool x" .. steelwool .. ", Cut Stone x" .. cutstone .. ", Gunpowder x" .. gunpowder .. ".",
	}
end

local function recipe_tab(tab)
	return
	{
		description = tab,
		data = tab:upper(),
		hover = "Crafting Tab: " .. tab,
	}
end

local options_loot_percent = {}
local count = 0
for k = 0.25, 1, 0.25 do
	count = count + 1
	options_loot_percent[count] = { description = "" .. k * 100 .. "%", data = k }
end

--[[local options_recipe_limit = {}
local count = 0
for k = 0, 20, 2 do
	count = count + 1
	if k <= 0 then
		k = 1
	end
	options_recipe_limit[count] = { description = "" .. k .. " unit(s)", data = k }
end
options_recipe_limit[#options_recipe_limit + 1] = { description = "Unlimited", data = 9001 }]]

local function sanity(value)
	return
	{
		description = value ~= 0 and ("" .. value .. "/min") or "Disabled",
		data = value,
		hover = "",
	}
end

local options_temperature = {}
local count = 0
for k = 0, -40, -5 do
	count = count + 1
	options_temperature[count] =
	{
		description = k ~= 0 and ("" .. k) or "Disabled",
		data = k,
		hover = "",
	}
end

local options_mist = {}
local count = 0
for k = 0, 1.41, 0.2 do
	count = count + 1
	options_mist[count] = { description = "" .. k * 100 .. "%", data = k }
end

configuration_options = 
{
	divide("Localization", "In-Game Strings Language."),
	
	{	
		name = "language",
		label = "语言",
		hover = [[默认中文]],
		options =
		{	
			{ description = "English", data = "en", hover = "English." },
		},
		default = "en",
	},
	
	divide("Craft Recipe", "Recipe configuration options."),
	
	{	
		name = "recipe_ingredients",
		label = "地下室材料",
		hover = "地下室所需的材料,默认困难",
		options =
		{	
			recipe_ingredients("Free", 1, 1, 1),
			recipe_ingredients("Very Easy", 4, 30, 8),
			recipe_ingredients("Easy", 6, 42, 12),
			recipe_ingredients("Medium", 8, 50, 20),
			recipe_ingredients("Hard", 12, 68, 20),
			recipe_ingredients("Very Hard", 20, 68, 20),
			recipe_ingredients("Ewecus Grinder", 40, 68, 20),
		},
		default = "12/68/20",
	},
	
	{	
		name = "recipe_tab",
		label = "所需科技",
		hover = "地下室所需科技,默认科学机器",
		options =
		{	
			recipe_tab("Survival"),
			recipe_tab("Farm"),
			recipe_tab("Science"),
			recipe_tab("Town"),
		},
		default = "SCIENCE",
	},
	
	{
		name = "loot_percent",
		label = "摧毁地下室返还材料",
		hover = "摧毁地下室,返还75%材料",
		options = options_loot_percent,
		default = 0.75,
	},
	
	{
		name = "recipe_tech",
		label = "原型科技",
		hover = "每个人都能使用还是只在创意模式下使用?",
		options =
		{	
			{ description = "Alchemy Engine", data = "SCIENCE_TWO", hover = "任何人都可以使用" },
			{ description = "Creative Only", data = "LOST", hover = "只有拥有免费构建模式的玩家才能制作." },
		},
		default = "SCIENCE_TWO",
	},
			
	divide("Basement Environment", "Set up basement environment options."),
	
	{	
		name = "sanity",
		label = "san值",
		hover = "下跳掉多少san值,默认不掉san.",
		options =
		{
			sanity(0),
			sanity(-3),
			sanity(-5),
			sanity(-10),
		},
		default = 0,
	},
	
	{	
		name = "temperature",
		label = "地下室温度 正常温度",
		hover = "角色所感受到的温度.",
		options = options_temperature,
		default = 0,
	},
	
	divide("Miscellaneous", ""),
		
	{	
		name = "mist",
		label = "雾的密度",
		hover = "地下室的雾气.",
		options = options_mist,
		default = 1,
	},
}