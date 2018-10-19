local STRINGS =
{
    ACTIONS =
    {
        JUMPIN =
        {
            USE = "Usa",
        },
    },
   
    NAMES =
    {
        BASEMENT_ENTRANCE_BUILDER = "Sòtano",
        BASEMENT_ENTRANCE = "Escotilla",
        BASEMENT_EXIT = "Escaleras",
        BASEMENT_UPGRADE_WALL = "Bloque de muro de piedra",
        BASEMENT_UPGRADE_FLOOR_1 = "Suelo rocoso",
        BASEMENT_UPGRADE_FLOOR_2 = "Suelo de madera",
        BASEMENT_UPGRADE_FLOOR_3 = "Suelo a cuadros",
        BASEMENT_UPGRADE_STAIRS_1 = "Escaleras de piedra",
        BASEMENT_UPGRADE_STAIRS_2 = "Escaleras de piedra anchas",
        BASEMENT_UPGRADE_STAIRS_3 = "Escaleras de piedra completa",
        BASEMENT_UPGRADE_STAIRS_4 = "Amplia escalera de piedra completa",
        BASEMENT_UPGRADE_GUNPOWDER = "Pólvora catalizada",
    },
   
    RECIPE_DESC =
    {
        BASEMENT_ENTRANCE_BUILDER = "Una bóveda brumosa en la que esconderse.",
        BASEMENT_UPGRADE_WALL = "Usa un pico para revertir los cambios.",
        BASEMENT_UPGRADE_FLOOR_1 = "Piso predeterminado.",
        BASEMENT_UPGRADE_STAIRS_1 = "Escaleras por defecto.",
        BASEMENT_UPGRADE_STAIRS_2 = "Versión más amplia.",
        BASEMENT_UPGRADE_STAIRS_3 = "Sin un arco.",
        BASEMENT_UPGRADE_STAIRS_4 = "Ancho y sin arco.",
        BASEMENT_UPGRADE_GUNPOWDER = "Una especie de fuegos artificiales de despedida.",
    },
   
    HUD =
    {
        BASEMENT =
        {
            ANNOUNCE_INVALID_POSITION = "Error al encontrar una posición válida para el sótano.",
            ANNOUNCE_LOST_ENTITIES = "Tras la eliminación del sótano, estas entidades se han perdido bajo los escombros:\n%s",
            ANNOUNCE_PLAYER_RETURNED_TO_LAND = "%s han sido devueltos a la tierra, ya que el sótano donde estaban no se puede encontrar.",
        },
    },
   
    TABS =
    {
        BASEMENT = "Sòtano",
    },
   
    CHARACTERS =
    {
        GENERIC =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No encajará aquí.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Los químicos están burbujeando debajo.",
                    OPEN = "Al laboratorio secreto!",
                },
                BASEMENT_EXIT = "Es descortés a las escaleras.",
            },
        },
       
        WILLOW =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No encajará ¡Entonces lo voy a quemar!",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Puede el fuego obtener suficiente aire ahí abajo?",
                    OPEN = "Podría atrapar el humo aquí.",
                },
                BASEMENT_EXIT = "La leña está allá arriba.",
            },
        },
       
        WOLFGANG =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No cabe!",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "El agujero aterrador está cerrado.",
                    OPEN = "Wolfgang no le gusta el sótano aterrador.",
                },
                BASEMENT_EXIT = "Escapar de la habitación aterradora",
            },
        },
       
        WENDY =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No encajará aquí, como mi alma ...",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Todo embotellado como mi pena.",
                    OPEN = "Uno podría crecer tan hambriento de luz como de comida",
                },
                BASEMENT_EXIT = "La inacción no lleva a ninguna parte.",
            },
        },
       
        WX78 =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "DEBEMOS ELEVAR EL TECHO.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "ABRA LAS PUERTAS GRISES DE LA BODEGA",
                    OPEN = "UN LUGAR PARA OCULTAR DE INFERIORES",
                },
                BASEMENT_EXIT = "ARRIBA Y ÁTOMO",
            },
        },
       
        WICKERBOTTOM =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "La altura de este sótano es bastante limitada.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Espero que nadie esté allí.",
                    OPEN = "Un lugar tranquilo para leer.",
                },
                BASEMENT_EXIT = "Estas escaleras carecen de barandillas y balaustres.",
            },
        },
       
        WOODIE =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "Este techo es más bajo que un siempreverde caído eh?",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Genial sotano, no?",
                    OPEN = "Más profundo que la fosa de un tocon eh?",
                },
                BASEMENT_EXIT = "Quieres ir a cortar algunos árboles, Lucy?",
            },
        },
       
        WAXWELL =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "Parece que tendremos que reducir esto al tamaño.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Esto no los detendrá.",
                    OPEN = "Charlie debe estar arrastrándose por algún lado.",
                },
                BASEMENT_EXIT = "Arriba hasta la luz del día.",
            },
        },
       
        WATHGRITHR =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No es una etapa apropiada para construir eso.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Habrá un enemigo allí?",
                    OPEN = "Prefiero pelear.",
                },
                BASEMENT_EXIT = "Todo el mundo es un escenario!",
            },
        },
       
        WEBBER =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "No cabrá!",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Queremos desconectar!",
                    OPEN = "Parece aterrador allá abajo.",
                },
                BASEMENT_EXIT = "No se supone que deba jugar en las escaleras.",
            },
        },
       
        WINONA =
        {
            ACTIONFAIL =
            {
                BUILD =
                {
                    LOWCEILING = "Es un poco demasiado estrecho aquí.",
                },
            },
            DESCRIBE =
            {
                BASEMENT_ENTRANCE =
                {
                    GENERIC = "Hora de irse!",
                    OPEN = "El taller está abierto para los negocios.",
                },
                BASEMENT_EXIT = "Un poco áspero en los bordes, pero lo hará.",
            },
        },
    },
}

return require "strings/merge" (STRINGS, require "strings/en")