local STRINGS =
{
	ACTIONS =
	{
		JUMPIN =
		{
			USE = "Usar",
		},
	},
	
	NAMES =
	{
		BASEMENT_ENTRANCE_BUILDER = "Porão",
		BASEMENT_ENTRANCE = "Criar",
		BASEMENT_EXIT = "Escadas",
		BASEMENT_UPGRADE_WALL = "Bloco de Parede de Pedra",
		BASEMENT_UPGRADE_FLOOR_1 = "Piso Rochoso",
		BASEMENT_UPGRADE_FLOOR_2 = "Piso de Madeira",
		BASEMENT_UPGRADE_FLOOR_3 = "Pisos Quadriculados",
		BASEMENT_UPGRADE_STAIRS_1 = "Escadas de Pedra",
		BASEMENT_UPGRADE_STAIRS_2 = "Escadas de Pedras Largas",
		BASEMENT_UPGRADE_STAIRS_3 = "Escadas de Pedras Terminadas",
		BASEMENT_UPGRADE_STAIRS_4 = "Escadas de Pedras Largas Terminadas",
		BASEMENT_UPGRADE_GUNPOWDER = "Pólvora Catalisada",
	},
	
	RECIPE_DESC =
	{
		BASEMENT_ENTRANCE_BUILDER = "Uma cripta enevoada para se esconder dentro.",
		BASEMENT_UPGRADE_WALL = "Use uma picareta para reverter as mudanças.",
		BASEMENT_UPGRADE_FLOOR_1 = "Piso padrão.",
		BASEMENT_UPGRADE_STAIRS_1 = "Escadas padrão.",
		BASEMENT_UPGRADE_STAIRS_2 = "Versão mais larga.",
		BASEMENT_UPGRADE_STAIRS_3 = "Sem um arco.",
		BASEMENT_UPGRADE_STAIRS_4 = "Largo e sem nenhum arco.",
		BASEMENT_UPGRADE_GUNPOWDER = "Uma espécie de fogo de artifício de despedida.",
	},
	
	HUD =
	{
		BASEMENT =
		{
			ANNOUNCE_INVALID_POSITION = "Não foi possível encontrar uma posição válida para o abrigo subterrâneo.",
			ANNOUNCE_LOST_ENTITIES = "Ao remover o abrigo subterrâneo, essas entidades serão perdidos embaixo dos escombros:\n%s",
			ANNOUNCE_PLAYER_RETURNED_TO_LAND = "%s voltaram para a superfície, já que o abrigo subterrâneo em que estavam dentro não pôde ser encontrado.",
		},
	},
	
	TABS =
	{
		BASEMENT = "Porão",
	},
	
	CHARACTERS =
	{
		GENERIC =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não vai caber aqui.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Os produtos químicos estão borbulhando aí embaixo.",
					OPEN = "Para o Laboratório Secreto!",
				},
				BASEMENT_EXIT = "Acho melhor eu sair para tomar um ar fresco.",
			},
		},
		
		WILLOW =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não vai caber. Então vou queimá-lo!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "O fogo consegue ter oxigênio suficiente lá embaixo?",
					OPEN = "Eu poderia prender a fumaça aí embaixo.",
				},
				BASEMENT_EXIT = "A lenha está lá em cima.",
			},
		},
		
		WOLFGANG =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não cabe!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Buraco assustador está fechado.",
					OPEN = "Wolfgang não gosta de porão assustador.",
				},
				BASEMENT_EXIT = "Escapar do porão apavorante!",
			},
		},
		
		WENDY =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não vai caber aqui, como a minha alma...",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Todo engarrafado, como minha dor.",
					OPEN = "Pode-se crescer tão carente de luz quanto de comida.",
				},
				BASEMENT_EXIT = "Inação leva a lugar nenhum.",
			},
		},
		
		WX78 =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "NÓS PRECISAMOS LEVANTAR O TELHADO.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "ABRA AS PORTAS CINZAS DO PORÃO",
					OPEN = "UM LUGAR PARA SE ESCONDER DOS INFERIORES",
				},
				BASEMENT_EXIT = "DETECTADA GRANDE FONTE DE LUZ POR ESSE CAMINHO",
			},
		},
		
		WICKERBOTTOM =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "A altura deste abrigo subterrâneo é bastante limitada.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Espero que ninguém esteja aí.",
					OPEN = "Um lugar quieto para ler.",
				},
				BASEMENT_EXIT = "Estas escadas estão faltando grades e balaústres.",
			},
		},
		
		WOODIE =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Este teto é menor do que uma tora caída, certo?",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Belo abrigo subterrâneo, não acha?",
					OPEN = "Mais profundo do que a cova de um tronco, certo?",
				},
				BASEMENT_EXIT = "Que tal a gente ir cortar lenha, Lucy?",
			},
		},
		
		WAXWELL =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Parece que vamos ter que cortar o mal pelas raízes.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Isso não vai parar Eles.",
					OPEN = "Charlie deve estar se escondendo por aí.",
				},
				BASEMENT_EXIT = "A luz do dia está aí encima.",
			},
		},
		
		WATHGRITHR =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não é o lugar correto para construí-lo.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Será que há um inimigo aí?",
					OPEN = "Eu preferiria estar batalhando.",
				},
				BASEMENT_EXIT = "O mundo é um palco!",
			},
		},
		
		WEBBER =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Não vai caber!",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Nós queremos puxar a tomada!",
					OPEN = "Parece assustador lá em baixo.",
				},
				BASEMENT_EXIT = "Eu não deveria brincar nas escadas.",
			},
		},
		
		WINONA =
		{
			ACTIONFAIL =
			{
				BUILD =
				{
					LOWCEILING = "Está um pouco apertado aqui.",
				},
			},
			DESCRIBE =
			{
				BASEMENT_ENTRANCE =
				{
					GENERIC = "Hora de sair!",
					OPEN = "A oficina agora está aberta para negócios.",
				},
				BASEMENT_EXIT = "Um pouco áspero nas bordas, mas funciona.",
			},
		},
	},
}

return require "strings/merge" (STRINGS, require "strings/en")