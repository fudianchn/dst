local Widget = require "widgets/widget"
local Core = require "widgets/epichealthbar/core"

return {
    init = function(self)
        local bar = self.top_root:AddChild(Core(TALKINGFONT, 28))
		bar:Hide()
		
		local inst, player, boss, time = bar.inst, self.owner
		
		local function HasTargetPlayer(boss)
			local target = boss.replica.combat and boss.replica.combat:GetTarget()
			return target ~= nil and target:HasTag("player")
		end

        bar.OnUpdate = function(dt)						
            local x, y, z = player.Transform:GetWorldPosition()
            for _,ent in pairs(TheSim:FindEntities(x, y, z, 20, { "epic", "_health", "_combat" }, { "FX", "NOCLICK", "INLIMBO", "player" })) do
				if HasTargetPlayer(ent) and ent.health_epic then
					if boss and boss ~= ent then
						bar:DoFlick()
					end
					
					boss, time = ent, GetTime()
					break
				end
			end
			                      
			if boss == nil then
				bar:Disappear()
				return
			end
			
			if GetTime() - time >= 10 then
				bar:Disappear()
				boss = nil
				return
			end
			
			if player:HasTag("playerghost") or boss:HasTag("flight") or
			(boss:HasTag("sleeping") and not HasTargetPlayer(boss)) then
				bar:Disappear()
				boss = nil
				return
			end
			
			if boss.health_epic.act <= 0 then 
				bar:Disappear()
				boss = nil
				return
			end

            if boss:IsValid() and player:IsNear(boss, 30) then
                bar:Appear()
            else
                bar:Disappear()
                boss = nil
                return
            end
									
			bar:SetData(boss, boss.health_epic)
        end
		

		local function IsValidBoss(ent)
			return ent ~= nil and ent:HasTag("epic") and ent:HasTag("_health") and ent:HasTag("_combat")
		end
				
		local function CheckAction(player)
    		if player:HasTag("attack") and
			IsValidBoss(player.replica.combat:GetTarget()) then
				bar:StartUpdating()
    		end
		end
		
		local function OnAttacked(player, data)
    		if data ~= nil and
			(data.isattackedbydanger or IsValidBoss(data.attacker)) then
        		bar:StartUpdating()
    		end
		end
		
		local function OnTriggeredEvent(player, data)
			bar:StartUpdating()
		end
				
		inst:ListenForEvent("performaction", CheckAction, player)
    	inst:ListenForEvent("attacked", OnAttacked, player)
    	inst:ListenForEvent("triggeredevent", OnTriggeredEvent, player)
    end
}