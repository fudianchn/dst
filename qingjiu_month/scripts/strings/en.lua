return
{
	ACTIONS =
	{
		JUMPIN =
		{
			USE = "上",
		},
	},
	
	NAMES =
	{
		BASEMENT_ENTRANCE_BUILDER = "梦乡",
		BASEMENT_ENTRANCE = "梦乡",
		BASEMENT_EXIT = "楼梯",
		BASEMENT_UPGRADE_WALL = "石墙块",
		BASEMENT_UPGRADE_FLOOR_1 = "石质地板",
		BASEMENT_UPGRADE_FLOOR_2 = "木质地板",
		BASEMENT_UPGRADE_FLOOR_3 = "网纹地板",
		BASEMENT_UPGRADE_STAIRS_1 = "石头楼梯",
		BASEMENT_UPGRADE_STAIRS_2 = "宽阔的石阶",
		BASEMENT_UPGRADE_STAIRS_3 = "全石楼梯",
		BASEMENT_UPGRADE_STAIRS_4 = "宽而满的石阶",
		BASEMENT_UPGRADE_GUNPOWDER = "催化火药",
	},
	
	RECIPE_DESC =
	{
		BASEMENT_ENTRANCE_BUILDER = "每人限一座,可使用鹤嘴锄来扩建.",
		BASEMENT_UPGRADE_WALL = "用鹤嘴锄扩展梦乡.",
		BASEMENT_UPGRADE_FLOOR_1 = "默认地板.",
		BASEMENT_UPGRADE_STAIRS_1 = "默认楼梯.",
		BASEMENT_UPGRADE_STAIRS_2 = "更广泛的版本.",
		BASEMENT_UPGRADE_STAIRS_3 = "需要一个门.",
		BASEMENT_UPGRADE_STAIRS_4 = "虽然巨大,但是少了一个大门.",
		BASEMENT_UPGRADE_GUNPOWDER = "一种节日烟火.",
	},
	
	HUD =
	{
		BASEMENT =
		{
			ANNOUNCE_INVALID_POSITION = "没有找到该城堡的梦乡.",
			ANNOUNCE_LOST_ENTITIES = "在拆除梦乡时，这些实体已经在废墟下消失了:\n%s",
			ANNOUNCE_PLAYER_RETURNED_TO_LAND = "%s 已经返回城堡，因为他们在梦乡找不到.",
		},
	},
	
	TABS =
	{
		BASEMENT = "梦乡",
	},
	
	CHARACTERS =
	{
		GENERIC =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "它不适合这里.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "听到了咕嘟咕嘟咕嘟的声音.",
					OPEN = "去往梦乡!",
				},
				BASEMENT_EXIT = "这种姿势上楼梯有点不太礼貌.",
			},
		},
		
		WILLOW =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "我想烧了它!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "下面的空气够吗?",
					OPEN = "我忘了造个烟囱.",
				},
				BASEMENT_EXIT = "我不想离开这里.",
			},
		},
		
		WOLFGANG =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "它不合适!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "可爱的梦乡关闭了.",
					OPEN = "沃尔夫冈喜欢梦乡.",
				},
				BASEMENT_EXIT = "我想一辈子住在梦乡!",
			},
		},
		
		WENDY =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "它不适合这里,就像我的灵魂...",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "一切都像我的快乐一样.",
					OPEN = "一个人对光的渴求就像对食物的渴求一样.",
				},
				BASEMENT_EXIT = "我想和姐姐留在梦乡.",
			},
		},
		
		WX78 =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "我们必须把屋顶升起来.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "打开梦乡的门",
					OPEN = "远离嘈杂的世界",
				},
				BASEMENT_EXIT = "我想在梦乡研制原子弹",
			},
		},
		
		WICKERBOTTOM =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "这个梦乡的高度相当有限.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "我真希望里面没有陌生人.",
					OPEN = "一个安静的阅读场所.",
				},
				BASEMENT_EXIT = "这些楼梯没有栏杆.",
			},
		},
		
		WOODIE =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "这天花板比常青树苗还低,是吗??",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "好酷的梦乡!",
					OPEN = "比树桩的坑还要深,是吗?",
				},
				BASEMENT_EXIT = "露茜,想去砍树吗?",
			},
		},
		
		WAXWELL =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "看来我们需要缩减规模.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "这不会阻止他们.",
					OPEN = "查理一定是在什么地方鬼鬼祟祟的.",
				},
				BASEMENT_EXIT = "好喜欢梦乡,可以不离开吗?",
			},
		},
		
		WATHGRITHR =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "这不是一个合适的台阶.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "里面会有敌人吗?",
					OPEN = "我宁愿战斗.",
				},
				BASEMENT_EXIT = "整个世界都是我的舞台!",
			},
		},
		
		WEBBER =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "它不合适!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "我们要拔掉插头!",
					OPEN = "下面看起来很神奇.",
				},
				BASEMENT_EXIT = "我不应该在梦乡外面玩.",
			},
		},
		
		WINONA =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "这里有点太挤了,如何扩建?",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "跟我走吧,天亮就出发!",
					OPEN = "梦乡对我是敞开的.",
				},
				BASEMENT_EXIT = "我想留在梦乡继续缝补.",
			},
		},
	},
}