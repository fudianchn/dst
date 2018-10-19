local STRINGS =
{
	ACTIONS =
	{
		JUMPIN =
		{
			USE = "Использовать",
		},
	},
	
	NAMES =
	{
		BASEMENT_ENTRANCE_BUILDER = "Подвал",
		BASEMENT_ENTRANCE = "Люк",
		BASEMENT_EXIT = "Лестница",
		BASEMENT_UPGRADE_WALL = "Блок каменной стены",
		BASEMENT_UPGRADE_FLOOR_1 = "Каменное покрытие",
		BASEMENT_UPGRADE_FLOOR_2 = "Деревянное покрытие",
		BASEMENT_UPGRADE_FLOOR_3 = "Шахматное покрытие",
		BASEMENT_UPGRADE_STAIRS_1 = "Каменная лестница",
		BASEMENT_UPGRADE_STAIRS_2 = "Широкая каменная лестница",
		BASEMENT_UPGRADE_STAIRS_3 = "Полная каменная лестница",
		BASEMENT_UPGRADE_STAIRS_4 = "Широкая полная каменная лестница",
		BASEMENT_UPGRADE_GUNPOWDER = "Катализированный порох",
	},
	
	RECIPE_DESC =
	{
		BASEMENT_ENTRANCE_BUILDER = "Туманное убежище.",
		BASEMENT_UPGRADE_WALL = "В случае чего - используй кирку.",
		BASEMENT_UPGRADE_FLOOR_1 = "Стандартное покрытие.",
		BASEMENT_UPGRADE_STAIRS_1 = "Стандартная лестница.",
		BASEMENT_UPGRADE_STAIRS_2 = "Более широкая.",
		BASEMENT_UPGRADE_STAIRS_3 = "Без арки.",
		BASEMENT_UPGRADE_STAIRS_4 = "Шире и без арки.",
		BASEMENT_UPGRADE_GUNPOWDER = "Своего рода прощальный фейерверк.",
	},
	
	HUD =
	{
		BASEMENT =
		{
			ANNOUNCE_INVALID_POSITION = "Не удалось найти пространства для генерации подвала.",
			ANNOUNCE_LOST_ENTITIES = "Данные объекты были похоронены под обломками при детонации подвала:\n%s",
			ANNOUNCE_PLAYER_RETURNED_TO_LAND = "%s возвращается на землю, поскольку подвал,\nв котором они покидали игру, не удалось найти.",
		},
	},
	
	TABS =
	{
		BASEMENT = "Подвал",
	},
}

return require "strings/merge" (STRINGS, require "strings/en")