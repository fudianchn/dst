require("stategraphs/commonstates")

local actionhandlers = {

}

local events = {

}

local states = {
    State {
        name = "idle_closed",
        tags = { "idle" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_closed", true)
        end,
        onexit = function(inst)
            inst.SoundEmitter:KillSound("graboid_close")
        end
    },
    State {
        name = "idle_opened",
        tags = { "idle", "open" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_opened", true)
        end,
        onexit = function(inst)
            inst.SoundEmitter:KillSound("graboid_open")
        end
    },
    State {
        name = "opening",
        tags = { "busy", "open" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("opening")
            inst.SoundEmitter:PlaySound("graboid/action/open", "graboid_open")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_opened")
            end),
        },
    },
    State {
        name = "closing",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closing")
            inst.SoundEmitter:PlaySound("graboid/action/close", "graboid_close")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        },
    },
    State {
        name = "eating",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("eating")
            inst.SoundEmitter:PlaySound("graboid/action/eat", "graboid_eat")
        end,
        events = {
            EventHandler("animover", function(inst)
                    inst.SoundEmitter:KillSound("graboid_eat")
                inst.sg:GoToState("idle_opened")
            end),
        },
    },
    State {
        name = "agree",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("eating")
            inst.SoundEmitter:PlaySound("graboid/action/eat", "graboid_eat")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("agree_opened")
            end),
        },
    },
    State {
        name = "agree_opened",
        tags = { "busy" },
        onenter = function(inst)
            inst.SoundEmitter:KillSound("graboid_eat")
            inst.AnimState:PlayAnimation("agree")
            inst.SoundEmitter:PlaySound("graboid/action/agree", "graboid_agree")
        end,
        events = {
            EventHandler("animover", function(inst)
            inst.SoundEmitter:KillSound("graboid_agree")
                inst.sg:GoToState("idle_opened")
            end),
        }
    },
    State {
        name = "spit",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("spit")
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        },
    },
    State {
        name = "emerge",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("emerge", false)
            inst.SoundEmitter:PlaySound("graboid/action/emerge", "graboid_emerge")
        end,
        events = {
            EventHandler("animover", function(inst)
            inst.SoundEmitter:KillSound("graboid_emerge")
                inst.sg:GoToState("idle_closed")
            end),
        },
    },
}

return StateGraph("graboid", states, events, "idle_closed", actionhandlers)
