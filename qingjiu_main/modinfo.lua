name = "清酒"
description = "自用"
author = "guido"
version = "0.2.0"
forumthread = ""
--api版本联机10，单机6
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
--最后加载
priority = -999
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
server_filter_tags = { "清酒" }

configuration_options = {
    {
        name = "guido",
        default = true,
    }
}