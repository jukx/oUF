
local tags = {
	name = UnitName,
}

local currentunit
local function subber(tag)
	local f = tags[string.sub(tag, 2, -2)]
	return f and f(currentunit) or tag
end

local function processtags(taggedstring, unit)
	if not unit then return taggedstring end
	currentunit = unit
	return (taggedstring:gsub("[[][%w]+[]]", subber):gsub("  ", " "))
end


local unitlessevents = {PLAYER_TARGET_CHANGED = true, PLAYER_FOCUS_CHANGED = true}
local function OnEvent(self, event, unit)
	if not unitlessevents[event] and unit ~= self.unit then return end
	self.fontstring:SetText(processtags(self.tagstring, self.unit))
end


local function OnShow(self)
	self.fontstring:SetText(processtags(self.tagstring, self.unit))
end


table.insert(oUF.subTypes, function(self, unit)
	if self.TaggedStrings then
		for i,fs in pairs(self.TaggedStrings) do
			local parent = fs:GetParent()
			local tagstring = fs:GetText()

			local f = CreateFrame("Frame", nit, parent)
			f:SetScript("OnEvent", OnEvent)
			f:SetScript("OnShow", OnShow)
			f.tagstring, f.fontstring, f.unit = tagstring, fs, unit

			-- Register any update events we need
			for tag in string.gmatch(tagstring, "[[][%w]+[]]") do
				local tagevents = events[string.sub(tag, 2, -2)]
				if tagevents then
					for event in string.gmatch(tagevents, "%S+") do
						f:RegisterEvent(event)
					end
				end
			end
			if unit == "target" then f:RegisterEvent("PLAYER_TARGET_CHANGED") end
			if unit == "focus" then f:RegisterEvent("PLAYER_FOCUS_CHANGED") end

			OnShow(f)
		end
	end
end)


if true then return end


local tags = {
	["[curhp]"] = function(u) return UnitHealth(u) end,
	["[maxhp]"] = function(u) return UnitHealthMax(u) end,
	["[perhp]"] = function(u) return math.floor((UnitHealth(u) / UnitHealthMax(u)) * 100) end,
	["[perpp]"] = function(u) return math.floor((UnitPower(u) / UnitPowerMax(u)) * 100) end,
	["[curpp]"] = function(u) return UnitMana(u) end,
	["[maxpp]"] = function(u) return UnitManaMax(u) end,
	["[level]"] = function(u) return UnitLevel(u) end,
	["[class]"] = function(u) return UnitClass(u) end,
	["[name]"] = function(u) return UnitName(u) end,
	["[race]"] = function(u) return UnitRace(u) end,
	["[missinghp]"] = function(u) return UnitHealthMax(u) - UnitHealth(u) end,
	["[missingpp]"] = function(u) return UnitManaMax(u) - UnitMana(u) end,
	["[smartcurhp]"] = function(u) return siVal(UnitHealthMax(u)) end,
	["[smartmaxhp]"] = function(u) return siVal(UnitHealth(u)) end,
	["[smartcurpp]"] = function(u) return siVal(UnitMana(u)) end,
	["[smartmaxpp]"] = function(u) return siVal(UnitManaMax(u)) end,
}

local eventsTable = {
	["[curhp]"] = {"UNIT_HEALTH"},
	["[smartcurhp]"] = {"UNIT_HEALTH"},
	["[perhp]"] = {"UNIT_HEALTH", "UNIT_MAXHEALTH"},
	["[maxhp]"] = {"UNIT_MAXHEALTH"},
	["[smartmaxhp]"] = {"UNIT_MAXHEALTH"},
	["[curpp]"] = {"UNIT_ENERGY", "UNIT_FOCUS", "UNIT_MANA", "UNIT_RAGE"},
	["[smartcurpp]"] = {"UNIT_ENERGY", "UNIT_FOCUS", "UNIT_MANA", "UNIT_RAGE"},
	["[maxpp]"] = {"UNIT_MAXENERGY", "UNIT_MAXFOCUS", "UNIT_MAXMANA", "UNIT_MAXRAGE"},
	["[smartmaxpp]"] = {"UNIT_MAXENERGY", "UNIT_MAXFOCUS", "UNIT_MAXMANA", "UNIT_MAXRAGE"},
	["[perpp]"] = {"UNIT_MAXENERGY", "UNIT_MAXFOCUS", "UNIT_MAXMANA", "UNIT_MAXRAGE", "UNIT_ENERGY", "UNIT_FOCUS", "UNIT_MANA", "UNIT_RAGE"},
	["[level]"] = {"UNIT_LEVEL"},
	["[name]"] = {"UNIT_NAME_UPDATE"},
	["[missinghp]"] = {"UNIT_HEALTH", "UNIT_MAXHEALTH"},
	["[missingmp]"] = {"UNIT_MAXENERGY", "UNIT_MAXFOCUS", "UNIT_MAXMANA", "UNIT_MAXRAGE", "UNIT_ENERGY", "UNIT_FOCUS", "UNIT_MANA", "UNIT_RAGE"},
}



-- OMG ANCIENT TAGS FROM WATCHDOG
WatchDog_UnitInformation = {
	["name"] = function (u) if type(u) == "string" then return (UnitName(u) or "Unknown") elseif type(u) == "table" then local name = UnitName(u.unit) or "Unknown" if string.len(name) > u.length then return string.sub(name, 1, u.length) .. "..." else return name end else return "" end end,

	["status"] = function (u) if UnitIsDead(u) then return "Dead" elseif UnitIsGhost(u) then return "Ghost" elseif (not UnitIsConnected(u)) then return "Offline" elseif (UnitAffectingCombat(u)) then return "Combat" elseif (u== "player" and IsResting()) then return "Resting" else return "" end end,
	["statuscolor"] = function (u) if UnitIsDead(u) then return "|cffff0000" elseif UnitIsGhost(u) then return "|cff9d9d9d" elseif (not UnitIsConnected(u)) then return "|cffff8000" elseif (UnitAffectingCombat(u)) then return "|cffFF0000" elseif (u== "player" and IsResting()) then return GetHex(UnitReactionColor[4]) else return "" end end,
	["happycolor"] = function (u) local x=GetPetHappiness() return ( (x==2) and "|cffFFFF00" or (x==1) and "|cffFF0000" or "" ) end,

	["curhp"] = function (u) return wd_curhp end,
	["maxhp"] = function (u) return wd_maxhp end,
	["percenthp"] = function (u) return ( (wd_maxhp~=0) and floor(wd_curhp/wd_maxhp*100+0.5) or 0) end,
	["missinghp"] = function (u) return ((wd_maxhp - wd_curhp) or 0) end,

	["curmp"] = function (u) return wd_curmp end,
	["maxmp"] = function (u) return wd_maxmp end,
	["percentmp"] = function (u) return wd_permp end,
	["missingmp"] = function (u) return (wd_maxmp - wd_curmp) end,
	["typemp"] = function (u) local p=UnitPowerType(u) return ( (p==1) and "Rage" or (p==2) and "Focus" or (p==3) and "Energy" or "Mana" ) end,
	["level"] = function (u) local x = UnitLevel(u) return ((x>0) and x or "??") end,
	["class"] = function (u) return (UnitClass(u) or "Unknown") end,
	["creature"] = function (u) return (UnitCreatureFamily(u) or UnitCreatureType(u) or "Unknown") end,
	["smartclass"] = function (u) if UnitIsPlayer(u) then return WatchDog_UnitInformation["class"](u) else return WatchDog_UnitInformation["creature"](u) end end,
	["combos"] = function (u) return (GetComboPoints() or 0) end,
	["combos2"] = function (u) return string.rep("@", GetComboPoints()) end,
	["classification"] = function (u) if UnitClassification(u) == "rare" then return "Rare " elseif UnitClassification(u) == "eliterare" then return "Rare Elite " elseif UnitClassification(u) == "elite" then return "Elite " elseif UnitClassification(u) == "worldboss" then return "Boss " else return "" end end,
	["faction"] = function (u) return (UnitFactionGroup(u) or "") end,
	["connect"] = function (u) return ( (UnitIsConnected(u)) and "" or "Offline" ) end,
	["race"] = function (u) return ( UnitRace(u) or "") end,
	["pvp"] = function (u) return ( UnitIsPVP(u) and "PvP" or "" ) end,
	["plus"] = function (u) return ( UnitIsPlusMob(u) and "+" or "" ) end,
	["sex"] = function (u) local x = UnitSex(u) return ( (x==0) and "Male" or (x==1) and "Female" or "" ) end,
	["rested"] = function (u) return (GetRestState()==1 and "Rested" or "") end,
	["leader"] = function (u) return (UnitIsPartyLeader(u) and "(L)" or "") end,
	["leaderlong"] = function (u) return (UnitIsPartyLeader(u) and "(Leader)" or "") end,

	["happynum"] = function (u) return (GetPetHappiness() or 0) end,
	["happytext"] = function (u) return ( getglobal("PET_HAPPINESS"..(GetPetHappiness() or 0)) or "" ) end,
	["happyicon"] = function (u) local x=GetPetHappiness() return ( (x==3) and ":)" or (x==2) and ":|" or (x==1) and ":(" or "" ) end,

	["curxp"] = function (u) return (UnitXP(u) or "") end,
	["maxxp"] = function (u) return (UnitXPMax(u) or "") end,
	["percentxp"] = function (u) local x=UnitXPMax(u) if (x>0) then return floor( UnitXP(u)/x*100+0.5) else return 0 end end,
	["missingxp"] = function (u) return (UnitXPMax(u) - UnitXP(u)) end,
	["restedxp"] = function (u) return (GetXPExhaustion() or "") end,

	["tappedbyme"] = function (u) if UnitIsTappedByPlayer("target") then return "*" else return "" end end,
	["istapped"] = function (u) if UnitIsTapped(u) and (not UnitIsTappedByPlayer("target")) then return "*" else return "" end end,
	["pvpranknum"] = function (u) return (UnitPVPRank(u) or "") end,
	["pvprank"] = function (u) if (UnitPVPRank(u) >= 1) then return (GetPVPRankInfo(UnitPVPRank(u), u) or "" ) else return "" end end,
	["fkey"] = function (u) local _,_,fkey = string.find(u, "^party(%d)$") if not fkey then return "" else return "F"..fkey end end,

	["white"] = function (u) return "|cFFFFFFFF" end,
	["aggro"] = function (u) local reaction = UnitReaction(u, "player"); return UnitPlayerControlled(u) and (UnitCanAttack(u, "player") and UnitCanAttack("player", u) and "|cffFF0000" or UnitCanAttack("player", u) and "|cffffff00" or UnitIsPVP("target") and "|cff00ff00" or "|cFFFFFFFF") or (UnitIsTapped(u) and (not UnitIsTappedByPlayer(u)) and "|cff808080") or ((reaction == 1) and "|cffff0000" or (reaction == 2) and "|cffff0000" or (reaction == 4) and "|cffffff00" or (reaction == 5) and "|cff00ff00") or "|cFFFFFFFF"; end,
	["difficulty"] = function (u) if UnitCanAttack("player",u) then local x = (UnitLevel(u)>0) and UnitLevel(u) or 99 return GetHex( GetDifficultyColor(x) ) else return "" end end,
	["colormp"] = function (u) local x = ManaBarColor[UnitPowerType(u)] return GetHex(x.r, x.g, x.b) end,
	["inmelee"] = function (u) if PlayerFrame.inCombat then return "|cffFF0000" else return "" end end,
	["incombat"] = function (u) if UnitAffectingCombat(u) then return "|cffFF0000" else return "" end end,
	["raidcolor"] = function (u) local _,x=UnitClass(u) if x then return (GetHex(RAID_CLASS_COLORS[x]) or "") else return "" end end,
	["lowhpcolor"] = function (u) if wd_perhp <= 20 then return "|cffFF0000" else return "" end end,
	["lowmpcolor"] = function (u) if wd_permp <= 20 then return "|cff0000FF" else return "" end end,
}
