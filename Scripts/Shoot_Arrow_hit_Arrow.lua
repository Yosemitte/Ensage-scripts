require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.SkillShot")
require("libs.VectorOp")

config = ScriptConfig.new()
config:SetParameter("Hotkey", "F", config.TYPE_HOTKEY)
config:SetParameter("Arrowkey", "D", config.TYPE_HOTKEY)
config:Load()

local key = config.Hotkey
local arrowkey = config.Arrowkey

victimHandle = nil

local myFont = drawMgr:CreateFont("Mirana","Tahoma",14,550)
local statusText = drawMgr:CreateText(-40,-20,-1,"Shoot Arrow hit Arrow!",myFont);
local active = true
local shoot = nil
RangeA = 3000

function ArrowKey(msg,code)
	if msg ~= KEY_UP or code ~= arrowkey or client.chat then return end
	if active then
		if not shoot then
			shoot = true
			return true
		else
			shoot = nil
			return true
		end
	end
end

function Key(msg,code)	
    if msg ~= KEY_UP or code ~= key or client.chat then	return end

	if not active then
		active = true
		statusText.text = "Shoot Arrow hit Arrow!"
		return true
	else
		active = nil
		statusText.text = "   OFF!"
		return true
	end
end

function Arrow(tick)
	if not IsIngame() or client.console or client.paused then return end
	local me = entityList:GetMyHero()
	if not me then return end
	local arrow = me:GetAbility(2)
	if arrow.level > 0 and shoot then
		shoot = nil
		if me.alive and victimHandle then		
			local victim = entityList:GetEntity(victimHandle)		
			if victim and victim.visible and victim.alive and victim.health > 1 then
				if not victim:DoesHaveModifier("modifier_nyx_assassin_spiked_carapace") then
					local speed = 857 
					local castPoint = 500
					local aoe = 115
					local delay = client.latency
					local xyz = SkillShot.SkillShotXYZ(me,victim,(castPoint + delay),speed)
					if xyz then
						if me:GetDistance2D(xyz) > (RangeA + aoe) then
							xyz = (xyz - me.position) * (RangeA - 100) / me:GetDistance2D(xyz) + me.position
						end
					me:SafeCastAbility(arrow, xyz)
					Sleep(250)
					end
				end
			end
		end
	end	
end

function target(tick)
	if not IsIngame() or client.console then return end
	
	local me = entityList:GetMyHero()
	
	if not me then return end
	
	local offset = me.healthbarOffset
	
	statusText.entity = me
	statusText.entityPosition = Vector(0,0,offset)
		
	if me.classId ~= CDOTA_Unit_Hero_Mirana then
		statusText.visible = false
		script:Disable()
		return
	end

	if active then	
		for i,v in ipairs(entityList:GetEntities({type=LuaEntity.TYPE_HERO,alive=true,illusion=false})) do
			if v.team ~= me.team then
				local victimm = targetFind:GetLowestEHP(3057.5)
				if victimm and victimm.visible and victimm.alive then
				local distance = GetDistance2D(victimm,me) 
					if distance < 3057.5 then
						victimHandle = victimm.handle
						statusText.text = "Shoot: " .. client:Localize(victimm.name)
					end
				else
					statusText.text = "Shoot Arrow hit Arrow!"
				end
			end
		end
	end
end

function GameClose()
	statusText.visible = false
	active = nil
end

function Load()
	statusText.visible = true
	statusText.text = "Shoot Arrow hit Arrow!"
	active = true
end


script:RegisterEvent(EVENT_TICK,target)
script:RegisterEvent(EVENT_TICK,Arrow)
script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_LOAD,Load)
script:RegisterEvent(EVENT_KEY,Key)
script:RegisterEvent(EVENT_KEY,ArrowKey)
