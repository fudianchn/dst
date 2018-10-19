local function LaunchItems(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	for i,v in ipairs(TheSim:FindEntities(x, y, z, 1.5, { "_inventoryitem" }, { "INLIMBO", "locomotor", "heavy" })) do
		if v:IsValid() then
			Launch(v, inst, 1)
			x, y, z = v.Physics:GetVelocity()
			v.Physics:SetVel(x, 3, z)
		end
	end
end

local events = {}

local states =
{
	State
	{
		name = "idle",
		tags = { "idle" },
		
		onenter = function(inst)
			inst.hatch.AnimState:PlayAnimation("idle_closed")
		end,
	},

	State
	{
		name = "open",
		tags = { "idle", "open" },
		
		onenter = function(inst)
			inst.hatch.AnimState:PlayAnimation("idle_opened", true)
			inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hiddenidle_LP", "ambient")
		end,
	},

	State
	{
		name = "opening",
		tags = { "busy", "open" },
		
		onenter = function(inst)
			inst.hatch.AnimState:PlayAnimation("open_pre")
			inst.hatch.AnimState:PushAnimation("open", false)
			inst.SoundEmitter:PlaySound("hatch/common/hatch/open")
		end,

		events =
		{
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("open")
			end),
		},
		
		timeline =
		{
			TimeEvent(5 * FRAMES, LaunchItems),			
			TimeEvent(7 * FRAMES, function(inst)
				SpawnPrefab("sparkle_fx"):Hook(inst.hatch.GUID, "hatch", 15, 15, 0)
			end),
		},
	},
		
	State
	{
		name = "closing",
		tags = { "busy" },
		
		onenter = function(inst)
			inst.hatch.AnimState:PlayAnimation("close")
			inst.SoundEmitter:PlaySound("hatch/common/hatch/close")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
		
		timeline =
		{
			TimeEvent(7 * FRAMES, function(inst)
				inst.SoundEmitter:KillSound("ambient")
				LaunchItems(inst)
			end),
		},
	},
}

return StateGraph("basement_entrance", states, events, "idle")