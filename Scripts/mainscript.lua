local Announce = mainForm:GetChildChecked("AnnounceItemTemplate", false)
local AnnounceTxt = Announce:GetChildChecked("Text", false)
local PanelofPets = mainForm:GetChildChecked("PanelofPets", false)
local PetsText = PanelofPets:GetChildChecked("Text", false)
local PetsIcon = PanelofPets:GetChildChecked("PetIcon", false)
local PetsDesc = PanelofPets:GetChildChecked("PetDesc", false)
local wtControl3D = stateMainForm:GetChildChecked( "MainAddonMainForm", false ):GetChildChecked( "MainScreenControl3D", false )
local MoveIndex = 1
local MoveTarget = 30
local TimeS = 500
local PetPanel
local PetTarget
local ShardName = common.GetShortString(mission.GetShardName())
local PetName = "default"
local PetCastName = "default"
local StatCfgId = 1
local SettingsPanel = mainForm:GetChildChecked("OptionsPanel", false)
local StatisticPanel = mainForm:GetChildChecked("StatisticPanel", false)
local StatisticHeader = StatisticPanel:GetChildChecked("Header", false)
local InfoPanel = mainForm:GetChildChecked("InfoPanel", false)
local wtContainer = StatisticPanel:GetChildChecked("Container", false)
local ButtonSettings = mainForm:GetChildChecked("ButtonSettings", false)
local EditorPanel = mainForm:GetChildChecked("EditorPanel", false)
local StatCfg = {}
local Debug = false
local CurrentKey = 0
local CurrentDate = 0

local wtOption = {}
local wtOptionContainer = {}
local tableofunits = {}
local petonlocation = {}
local itemtable = {}
local sortwt = {}
--Map
local wtMainPanel = mainForm:GetChildChecked( "MainPanel", false ) 
local wtMiniMapPanel = mainForm:GetChildChecked( "MiniMapPanel", false ) 

local zoneGeodata = {}
local MapPanels = {}
local MapLock = false

local wtMap = stateMainForm:GetChildChecked( "Map", false )
local wtMapPanel = wtMap:GetChildChecked( "MainPanel", false )
local wtMapEnginePanel = wtMap:GetChildChecked("MapEnginePanel",true)
local wtName = wtMap:GetChildChecked("MapTextPanel",true)

local zonesTable = {}
local prevScaleState = 0

-- Minimap related data
local MinimapCirclePanels = {}
local MinimapSquarePanels = {}
local MinimapLock = false

local wtCircle = stateMainForm:GetChildChecked("Minimap", false):GetChildChecked("Circle", false)
local wtMinimapCircleEnginePanel = wtCircle:GetChildChecked("MapEngine", true)
local wtSquare = stateMainForm:GetChildChecked("Minimap", false):GetChildChecked("Square", false)
local wtMinimapSquareEnginePanel = wtSquare:GetChildChecked("MapEngine", true)
wtSquare:SetOnShowNotification( true )
wtCircle:SetOnShowNotification( true )
local prevState = 0
local prevSize

local wtInfoPanel = mainForm:GetChildChecked( "Tooltip", false )  
local wtInfoPaneltxt = wtInfoPanel:GetChildChecked( "TooltipText", false ) 
local wtBtn = mainForm:GetChildChecked("ObjectButtonTemplate", false)

--local MapLock = false
--local MiniMapLock = false

local QuestShowBut=wtMap:GetChildChecked("ButtonQuestsHide",true)
wtMap:SetOnShowNotification( true )
QuestShowBut:SetOnShowNotification( true )

local wtMainPanelDesc = mainForm:GetChildChecked( "MainPanel", false ):GetWidgetDesc()
local wtBtnDesc = mainForm:GetChildChecked("ObjectButtonTemplate", false):GetWidgetDesc()
local wtMiniMapPanelDesc = mainForm:GetChildChecked( "MiniMapPanel", false ):GetWidgetDesc()

local Options = mainForm:GetChildChecked("OptionsPanel", false) 
local Header = Options:GetChildChecked("HeaderText", false) 
local GroupPanel = Options:GetChildChecked("GroupPanel", true) 
local GroupHeader = Options:GetChildChecked("GroupHeader", true) 
--local wtContainer = Options:GetChildChecked("GroupContainer", true)
local Container = Options:GetChildChecked("Container", true)
local SliderBG = Options:GetChildChecked("SliderBackground", false)
Header:SetVal("name", GTL("Search"))

local SettingsPS = {
["FastTakePet"] = true, -- Если true, то берет питомца в цель и сразу начинает каст усмирителя. Если false, то только берет в цель
["UseMapMark"] = true, -- Показывать точки респа питомцев на большой карте
["UseMiniMapMark"] = true,  -- Показывать точки респа питомцев на мини-карте
["UseZoneInfo"] = true, -- Показывать, какие питомцы водятся на текущей локации
["ShowAlert"] = true, -- Показывать оповещение об поиске питомца
["PlaySound"] = true, } -- Звук при респавне

local petsnames = {
--season 1
GTL("King Wolf Cub"),
GTL("Eagle"),
GTL("Dewy-Eyed Fawn"),
GTL("Squirrel"),
GTL("Holy Gobly"),
GTL("Russula"),
GTL("Crayfish"),
GTL("Dolly"),
GTL("Warlike Lizard"),
GTL("Lonesome Ghoul"),
GTL("Tiger Cat"),
GTL("Genlun’s Minion"),
GTL("Sly Foxie"),
GTL("Honey Bee"),
GTL("Midget Clown"),
GTL("Friendly Slug"),
GTL("Eye of the Sculptor"),
GTL("Echidna"),
GTL("Gastornis Nestling"),
GTL("Scaly Bird"),
--season 2
GTL("Miniature Hut"),
GTL("Oak Golem"),
GTL("Goblin Boffin"),
GTL("Nymph"),
GTL("Gentleman Dove"),
}

function PlaySound()
local soundId = common.GetAddonRelatedGroupSound( "Sound", "Sound1" )
local sound = common.CreateSound( soundId )
	if sound then
		sound:Play()
	end
end

local petslocations = {
{Name = GTL("King Wolf Cub"), Zone = "ZoneContested12_Map03"}, 
{Name = GTL("Eagle"), Zone = "ZoneContested12_Map03"}, 
{Name = GTL("Dewy-Eyed Fawn"), Zone = "HuntingGround01"}, 
{Name = GTL("Squirrel"), Zone = "HuntingGround01"}, 
{Name = GTL("Holy Gobly"), Zone = "ZoneContested3"}, 
{Name = GTL("Russula"), Zone = "ArchipelagoContested3"}, 
{Name = GTL("Crayfish"), Zone = "ZoneContested12_Map02_02"}, 
{Name = GTL("Dolly"), Zone = "AedIsle_Capital"}, 
{Name = GTL("Dolly"), Zone = "AedIsle_Centaurs"}, 
{Name = GTL("Warlike Lizard"), Zone = "AedIsle_Capital"}, 
{Name = GTL("Warlike Lizard"), Zone = "AedIsle_Centaurs"}, 
{Name = GTL("Lonesome Ghoul"), Zone = "ArchipelagoContested8"}, 
{Name = GTL("Tiger Cat"), Zone = "ZoneContested1"}, 
{Name = GTL("Genlun’s Minion"), Zone = "ZoneContested8"}, 
{Name = GTL("Sly Foxie"), Zone = "HuntingGround04"}, 
{Name = GTL("Honey Bee"), Zone = "HuntingGround04"}, 
{Name = GTL("Midget Clown"), Zone = "ZoneContested2"}, 
{Name = GTL("Friendly Slug"), Zone = "ZoneContested2"}, 
{Name = GTL("Friendly Slug"), Zone = "ZoneContested1"}, 
{Name = GTL("Eye of the Sculptor"), Zone = "ZoneContested12_Map02_05"}, 
{Name = GTL("Echidna"), Zone = "Ferris02"}, 
{Name = GTL("Echidna"), Zone = "Ferris03"}, 
{Name = GTL("Gastornis Nestling"), Zone = "Ferris02"},  
{Name = GTL("Gastornis Nestling"), Zone = "Ferris03"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld06"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld08"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld0910"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld00"}, 
{Name = GTL("Scaly Bird"), Zone = "IllusionWorld0102"}, 
}

function LIY()
local p = avatar.GetPos()
LogInfo("Zone: ", cartographer.GetZonesMapInfo(unit.GetZonesMapId(avatar.GetId())).sysName)
LogInfo("{ NAME = name, Pos = {posX = ", p.posX ,", posY =",p.posY, "}},")
end

function LogTable(t, tabstep)
    tabstep = tabstep or 1
    if t == nil then
        LogInfo("nil (no table)")
        return
    end
    assert(type(t) == "table", "Invalid data passed")
    local TabString = string.rep("    ", tabstep)
    local isEmpty = true
    for i, v in pairs(t) do
        if type(v) == "table" then
            LogInfo(TabString, i, ":")
            LogTable(v, tabstep + 1)
        else
            LogInfo(TabString, i, " = ", v)
        end
        isEmpty = false
    end
    if isEmpty then
        LogInfo(TabString, "{} (empty table)")
    end
end

function CurrentMap()
local children = wtName:GetNamedChildren()
for i = 0, GetTableSize( children ) - 1 do
 local wtChild = children[i]
 local name = wtChild:GetName()
	if wtChild:IsVisible() then
	return name
		end
	end
end

function CurrentMapID()
local children = wtName:GetNamedChildren()
for i = 0, GetTableSize( children ) - 1 do
 local wtChild = children[i]
 local name = wtChild:GetName()
	if wtChild:IsVisible() then
	local id = cartographer.GetZonesMapId(name)
		return id
		end
	end
end

function SetPosTT(wt, wtt)
	local Placement = wt:GetRealRect()
	local posX = Placement.x1 +15
	local posY = Placement.y1 -40
	SetPos(wtt,posX,nil,posY)
end

function ReactionOnPointing(params)
if params.active then
		wtInfoPanel:Show(true)
		local x = string.find(params.sender,"::")
		local zoneID = string.sub(params.sender,1,x-1)
		local i = string.sub(params.sender,x+2)
		local d = zoneObjects[zoneID][tonumber(i)].NAME
		wtInfoPanel:Show(true)
		wtInfoPaneltxt:SetVal("name", d)
		wtInfoPaneltxt:SetClassVal("style", "tip_golden")
		if params.widget:GetParent():GetName() == "MapPanel_"..zoneID then
		wtMap:AddChild(wtInfoPanel)
		SetPosTT(params.widget, wtInfoPanel)
		else
		stateMainForm:GetChildChecked("PetsSearch",false):AddChild(wtInfoPanel)
		SetPosTT(params.widget, wtInfoPanel)
		end
else 
	wtInfoPanel:Show(false)
	end
end

-----------------------------------------------------
function SetPos(wt,posX,sizeX,posY,sizeY,highPosX,highPosY,alignX, alignY, addchild)
  if wt then
    local p = wt:GetPlacementPlain()
    if posX then p.posX = posX end
    if sizeX then p.sizeX = sizeX end
    if posY then p.posY = posY end
    if sizeY then p.sizeY = sizeY end
    if highPosX then p.highPosX = highPosX end
    if highPosY then p.highPosY = highPosY end
	if alignX then p.alignX = alignX end
	if alignY then p.alignY = alignY end
    wt:SetPlacementPlain(p) 
  end
  if addchild then addchild = addchild:AddChild( wt ) end
end

function wtSetPlace(w, place )
	local p=w:GetPlacementPlain()
	for k, v in pairs(place) do	
		p[k]=place[k] or v
	end
	w:SetPlacementPlain(p)
end

function RePos(wt,posX,posY)
	local Placement = wt:GetPlacementPlain()
	Placement.posX = posX - Placement.sizeX/2
	Placement.posY = posY - Placement.sizeY/2
	wt:SetPlacementPlain(Placement) 
end

function CreateWG(desc, name, parent, show, place)
	local d1 = mainForm:GetChildChecked( desc, true )
	local d2= d1:GetWidgetDesc()
	local n
	n = mainForm:CreateWidgetByDesc( d2 )
	if name then n:SetName( name ) end
	if parent then parent:AddChild(n) end
	if place then wtSetPlace( n, place ) end
	n:Show( show == true )
	return n
end

function SpawnPet(params)
local objectName = object.GetName( params.unitId )
	for _, foundname in pairs(petsnames) do 
	if userMods.FromWString(objectName) ==  foundname then
		local buffs = object.GetBuffs( params.unitId )
		local buffsInfo = object.GetBuffsInfo( buffs )
		for buffId, buffInfo in pairs( buffsInfo) do
		local name = buffInfo.name
		if userMods.FromWString(buffInfo.name) == GTL("BuffName") then
		AnnounceTxt:SetVal("value", objectName)
		AnnounceTxt:SetClassVal("class", "LogColorBlue")
		Announce:Show(true)
		Announce:PlayFadeEffect( 1.0, 0.3, 1000, EA_SYMMETRIC_FLASH )
		PetPanel = CreateWG("PanelTarget", "PetPanel", nil, true)
		PetTarget = PetPanel:GetChildChecked("TargetOfPets", false)
		PetTarget:SetBackgroundTexture( common.GetAddonRelatedTexture("Arrow"))
		PetTarget:SetBackgroundColor( { r = 0.2; g = 0.6; b = 1.0; a = 1.0 } )
		tableofunits[params.unitId] = {	TARGET = PetPanel, NAME = objectName }
			local StPlacement = PetTarget:GetPlacementPlain()
			local EdPlacement = PetTarget:GetPlacementPlain()
			EdPlacement.posY = 30
			PetTarget:PlayMoveEffect( StPlacement, EdPlacement, 500, EA_MONOTONOUS_INCREASE   )
			MoveIndex=1
			wtControl3D:AddWidget3D( tableofunits[params.unitId].TARGET, {sizeX=1,sizeY=1}, object.GetPos(avatar.GetId()), false, true, 175.0, WIDGET_3D_BIND_POINT_CENTER, 0.7, 1 )
			object.AttachWidget3D( params.unitId, wtControl3D, tableofunits[params.unitId].TARGET, 2 )  
			if SettingsPS.PlaySound then PlaySound() end
			common.SetIconFlash( 5 )
				end
			end
		end
	end
end

function DespawnPet(params)
if tableofunits[params.unitId] then
	OnSavePetInfo(userMods.FromWString(tableofunits[params.unitId].NAME))
	PetCastName = userMods.FromWString(tableofunits[params.unitId].NAME)
	tableofunits[params.unitId].TARGET:DestroyWidget()
	tableofunits[params.unitId].NANE = nil
	tableofunits[params.unitId] = nil
	Announce:Show(false)
	end
local unitslist = avatar.GetUnitList()
		local newid
			for _, newid in pairs(unitslist) do
			local pars = {unitId=newid,}
			if tableofunits[newid] then
			tableofunits[newid].TARGET:DestroyWidget()
			tableofunits[newid].NANE = nil
			tableofunits[newid]=nil
			SpawnPet(pars)	
		end
	end
end

function StartInspect()
local unitslist = avatar.GetUnitList()
local newid
	for _, newid in pairs(unitslist) do
	local pars = {unitId=newid,}
	SpawnPet(pars)	
	end
end

function SelectPet()
for id, _ in pairs(tableofunits) do 
	avatar.SelectTarget( id )
	if SettingsPS.FastTakePet then
	local tab=avatar.GetInventoryItemIds()
		for _,itemId in pairs( tab ) do
			local info=itemLib.GetItemInfo( itemId )
			if info and userMods.FromWString(info.name) == GTL("ItemName") then
				avatar.UseItem( itemId )
				end
			end	
		end
	end
end

function PlayWidget(params)
if params.wtOwner:GetName()=="AnnounceItemTemplate" then
	if Announce:IsVisible() then 
	Announce:PlayFadeEffect( 0.3, 1.0, 1000, EA_SYMMETRIC_FLASH )
	else 
	Announce:FinishFadeEffect()
		end
	end
if params.wtOwner:GetName()=="TargetOfPets" then
	local StPlacement = params.wtOwner:GetPlacementPlain()
    local EdPlacement = params.wtOwner:GetPlacementPlain()
    if MoveIndex==0 then
      MoveIndex=1
      EdPlacement.posY = 0
      PetTarget:PlayFadeEffect( 1.0, 0.5, TimeS, EA_MONOTONOUS_INCREASE )
    else
      MoveIndex=0
      EdPlacement.posY = MoveTarget
      PetTarget:PlayFadeEffect( 0.5, 1.0, TimeS, EA_MONOTONOUS_INCREASE )
    end
	if PetPanel:IsVisible() then
    PetTarget:PlayMoveEffect( StPlacement, EdPlacement, 500, EA_MONOTONOUS_INCREASE   )
	else
	PetTarget:FinishMoveEffect()
	end
  end
end

function GetPetLocation()
if SettingsPS.UseZoneInfo then
clearVG()
local map = cartographer.GetZonesMapInfo(unit.GetZonesMapId(avatar.GetId())).sysName
for k, v in pairs(petslocations) do
	if map == v.Zone then 
	local PetIcon = CreateWG("PetIcon", "Icon"..v.Name, PanelofPets, true, { alignX = 0, sizeX=40, posX = 10, highPosX = 0, alignY = 0, sizeY=40, posY=15, highPosY=15})
	local PetDesc = CreateWG("Text", "Text"..v.Name, PanelofPets, true, { alignX = 0, sizeX=180, posX = 60, highPosX = 0, alignY = 0, sizeY=40, posY=0, highPosY=10})
	table.insert(petonlocation, {PetIcon=PetIcon, PetDesc=PetDesc })
	PetDesc:SetFormat(userMods.ToWString('<header alignx = "left" fontsize="14" outline="1"><rs class="class"><r name="name"/></rs></header>'))
	PetDesc:SetVal("name", v.Name)
	PetIcon:SetBackgroundTexture(FindIcons(v.Name))
	if CheckPetInBag(v.Name) then PetDesc:SetClassVal("class", "tip_green") end
		end
	end
	if tonumber(#petonlocation)==0 then PanelofPets:Show(false) else PanelofPets:Show(true) end
	updateBuffs()
	end
end

function clearVG()
	for k = #petonlocation, 1, -1 do
			petonlocation[k].PetDesc:DestroyWidget()
			petonlocation[k].PetIcon:DestroyWidget()
			table.remove(petonlocation, k)		
		end
	updateBuffs()
end

function updateBuffs()
	local pos = 1
	for k,v in pairs(petonlocation) do
		local textpet = petonlocation[k].PetDesc:GetPlacementPlain()
		local icopet = petonlocation[k].PetIcon:GetPlacementPlain()
		textpet.posY = (pos + 0.2) * 40
		textpet.sizeX = 180
		icopet.posY = pos * 40
		petonlocation[k].PetIcon:SetPlacementPlain(icopet)
		petonlocation[k].PetDesc:SetPlacementPlain(textpet)
		pos = pos + 1
	end
	SetPos(PanelofPets,nil,nil,nil,pos*40+40)
end

function FindIcons(name)
local categories = checkroomLib.GetCategories()
for k, v in pairs(categories) do
	if userMods.FromWString(categories[k]:GetInfo().name) == GTL("Category") then
		local collections = checkroomLib.GetCollections(v)
			for kk, vv in pairs(collections) do
				if userMods.FromWString(collections[kk]:GetInfo().name) == GTL("SubCategory") then
					local items = checkroomLib.GetItems(vv)
						for kkk, vvv in pairs(items) do
						local itemInfo = itemLib.GetItemInfo(vvv)
						if userMods.FromWString(itemInfo.name) == name then
						return itemInfo.icon 
						end
					end
				end
			end
		end 
	end
end

function CheckPetInBag(name)
local categories = checkroomLib.GetCategories()
for k, v in pairs(categories) do
	if userMods.FromWString(categories[k]:GetInfo().name) == GTL("Category") then
		local collections = checkroomLib.GetCollections(v)
			for kk, vv in pairs(collections) do
				if userMods.FromWString(collections[kk]:GetInfo().name) == GTL("SubCategory") then
					local items = checkroomLib.GetItems(vv)
						for kkk, vvv in pairs(items) do
						local itemInfo = itemLib.GetItemInfo(vvv)
						if userMods.FromWString(itemInfo.name) == name then
						if  checkroomLib.IsItemInCheckroom( itemInfo.id ) then
						return true
							end
						end
					end
				end
			end
		end 
	end
end

function GetMapWidgets()
if SettingsPS.UseMapMark then
local children = wtName:GetNamedChildren()
for i = 0, GetTableSize( children ) - 1 do
 local wtChild = children[i]
 local name = wtChild:GetName()
	wtChild:SetOnShowNotification( true )
		end
	end 
end

function OnButtonLeftClick(params)
if DnD:IsDragging() then return	end
if params.sender == "ButtonCloseStatistic" then
	StatisticPanel:Show(false)
	end
if params.sender:find("Edit") then
	local num = tonumber(string.sub(params.sender, 6))
		ShowEditInfo(num)
	end
if params.sender:find("Add_") then
	local num = tonumber(params.sender:sub(5))
		StatCfg[num].Show = true
		if StatCfg[num].Date < common.GetLocalDateTime().overallMs then
		StatCfg[num].Date = common.GetLocalDateTime().overallMs + 600000
		userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
		else
		StatCfg[num].Date = StatCfg[num].Date + 600000
		userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
		end
	end
if params.sender:find("Del_") then
	local num = tonumber(params.sender:sub(5))
	if StatCfg[num].Date > common.GetLocalDateTime().overallMs then
	StatCfg[num].Date = StatCfg[num].Date - 600000
	userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
	else 
	StatCfg[num].Date = common.GetLocalDateTime().overallMs - 1000
	userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
		end
	end
if params.sender == "ButtonOK" then
	InfoPanel:Show(false)
end
if params.sender == "ButtonSettings" then
	if DnD:IsDragging() then return	end
	if Options:IsVisible() then	
		Options:Show(false)
		Container:RemoveItems()
	else
		Options:Show(true)	
		ShowSettings()
		end
	end  
if params.sender == "ButtonEditor" then
	EditorPanel:Show(true)
	end
if params.sender == "ButtonCloseEditor" then
	EditorPanel:Show(false)
	end
if params.sender == "ButtonEditOK" then
	StatCfg[CurrentKey] = nil
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))] = {}
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Shard = sortwt.EditLineShard:GetText()
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Date = CurrentDate
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Name = userMods.FromWString(sortwt.EditLineName:GetText())
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Attempts = tonumber(userMods.FromWString(sortwt.EditLineAttempts:GetText()))
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Achive = tonumber(userMods.FromWString(sortwt.EditLineAchive:GetText()))
	userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
	OnShowStatisticPanel()
	EditorPanel:Show(false)
	end
if params.sender == "ButtonAccept" then
	StatCfg[CurrentKey] = nil
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))] = {}
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Shard = sortwt.EditLineShard:GetText()
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Date = CurrentDate
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Name = userMods.FromWString(sortwt.EditLineName:GetText())
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Attempts = tonumber(userMods.FromWString(sortwt.EditLineAttempts:GetText()))
	StatCfg[tonumber(userMods.FromWString(sortwt.EditLineKey:GetText()))].Achive = tonumber(userMods.FromWString(sortwt.EditLineAchive:GetText()))
	userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
	OnShowStatisticPanel()
	end
if params.sender == "ButtonCancel" then
	EditorPanel:Show(false)
	end
end

function OnButtonRightClick(params)
if DnD:IsDragging() then return	end
    if params.sender == 'ButtonSettings' then
        StatisticPanel:Show(not StatisticPanel:IsVisible()) OnShowStatisticPanel()
    end
end

function OnSavePetInfo(name)
    local found = false
        for i, v in pairs(StatCfg) do
            if (userMods.FromWString(StatCfg[i].Shard) == userMods.FromWString(ShardName)) and StatCfg[i].Name == name then	
                StatCfg[i].Date = common.GetMsFromDateTime(common.GetLocalDateTime()) + 3600000
                StatCfg[i].Show = true
                StatCfg[i].Shard = ShardName
                userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
                found = true
                break
            end
        end
        if not found then
            StatCfg[GetTableSize(StatCfg) + 1] = {
                Name = name,
                Shard = ShardName,
                Date = common.GetMsFromDateTime(common.GetLocalDateTime()) + 3600000,
				Achive = 0,
				Attempts = 0,
                Show = true,
            }
            StatCfgId = StatCfgId + 1
		userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
	end
end

local ContextAnnounceText = stateMainForm:GetChildChecked( "ContextAnnounceCustom", false ):GetChildChecked( "Announce", false )
ContextAnnounceText:SetOnShowNotification( true )

function GetPetAchivement(name, achive)
for i, v in pairs(StatCfg) do
    if (userMods.FromWString(StatCfg[i].Shard) == userMods.FromWString(ShardName)) and StatCfg[i].Name == name then	
			StatCfg[i].Attempts = StatCfg[i].Attempts + 1
		if achive then StatCfg[i].Achive = StatCfg[i].Achive + 1 end
		userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg)
		OnShowStatisticPanel()
		end
	end
end

function OnShowStatisticPanel()
    itemtable = nil itemtable = {}
    wtContainer:RemoveItems()
    for k, v in pairs(StatCfg) do
        local ItemSlot = CreateWG("ItemPanel", "Panel", nil, true, { alignX = 3, sizeX = 372, posX = 5, highPosX = 25, alignY = 3, sizeY = 30, posY = 0, highPosY = 0, })
        local ShardName = CreateWG("Shard", "Shard", ItemSlot, true, { alignX = 0, sizeX = 50, posX = 0, highPosX = 0, alignY = 0, sizeY = 20, posY = 6, highPosY = 0, })
        ShardName:SetFormat(userMods.ToWString('<header alignx = "center" fontsize="14" outline="1"><rs class="class"><tip_white><r name="value"/></tip_white></rs></header>'))
        ShardName:SetVal("value", v.Shard)
        local Name = CreateWG("Name", "Name", ItemSlot, true, { alignX = 0, sizeX = 200, posX = 50, highPosX = 0, alignY = 0, sizeY = 20, posY = 6, highPosY = 0, })
        Name:SetFormat(userMods.ToWString('<header alignx = "center" fontsize="14" outline="1"><rs class="class"><tip_white><r name="value"/></tip_white></rs></header>'))
        Name:SetVal("value", v.Name)
        local Timer = CreateWG("Timer", "ETimer"..k, ItemSlot, true,{ alignX = 0, sizeX = 140, posX = 225, highPosX = 0, alignY = 0, sizeY = 20, posY = 6, highPosY = 0, })
        Timer:SetFormat(userMods.ToWString('<header alignx = "center" fontsize="14" outline="1"><rs class="class"><tip_white><r name="value"/></tip_white></rs></header>'))
        Timer:SetVal("value", tostring(StartPetTimer(v.Date)))
        local Attempts = CreateWG("Attempts", "Attempts"..k, ItemSlot, true,{ alignX = 0, sizeX = 130, posX = 320, highPosX = 0, alignY = 0, sizeY = 30, posY = 6, highPosY = 0, })
		Attempts:SetFormat(userMods.ToWString('<header alignx = "center" fontsize="14" outline="1"><rs class="class"><tip_white><r name="value"/></tip_white></rs></header>'))
        Attempts:SetVal("value", tostring(v.Attempts))
	    local Achive = CreateWG("Achive", "Achive"..k, ItemSlot, true,{ alignX = 0, sizeX = 120, posX = 390, highPosX = 0, alignY = 0, sizeY = 30, posY = 6, highPosY = 0, })
		Achive:SetFormat(userMods.ToWString('<header alignx = "center" fontsize="14" outline="1"><rs class="class"><tip_white><r name="value"/></tip_white></rs></header>'))
		Achive:SetVal("value", tostring(v.Achive))
        local Delete = CreateWG("ButtonEdit", 'Edit_' .. k, ItemSlot, true, { highPosX = -2})
        local AddTime = CreateWG("ButtonPlus", 'Add_' .. k, ItemSlot, true, { highPosX = 165, sizeX = 25, sizeY = 25, posY = 3})
        local DelTime = CreateWG("ButtonMinus", 'Del_' .. k, ItemSlot, true, { highPosX = 251, sizeX = 25, sizeY = 25, posY = 3})
        table.insert(itemtable, { ItemSlot = ItemSlot })
        wtContainer:PushFront(ItemSlot)
    end
end

sortwt.SortShard = CreateWG("SortButton", 'SortShard', StatisticPanel, true, { alignX = 0, posX = 20, highPosX = 0, sizeX = 55, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortShard:SetVal("button_label", userMods.ToWString(GTL("Server"))) 
sortwt.SortShard:Enable(false)
sortwt.SortName = CreateWG("SortButton", 'SortName', StatisticPanel, true, { alignX = 0, posX = 70, highPosX = 0, sizeX = 200, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortName:SetVal("button_label", userMods.ToWString(GTL("Pet"))) 
sortwt.SortName:Enable(false)
sortwt.SortTime = CreateWG("SortButton", 'SortTime', StatisticPanel, true,{ alignX = 0, posX = 265, highPosX = 0, sizeX = 105, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortTime:SetVal("button_label", userMods.ToWString(GTL("Time"))) 
sortwt.SortTime:Enable(false)
sortwt.SortAttempts = CreateWG("SortButton", 'SortAttempts', StatisticPanel, true,{ alignX = 0, posX = 365, highPosX = 0, sizeX = 76, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortAttempts:SetVal("button_label", userMods.ToWString(GTL("Attempts"))) 
sortwt.SortAttempts:Enable(false)
sortwt.SortAchive = CreateWG("SortButton", 'SortAchive', StatisticPanel, true,{ alignX = 0, posX = 437, highPosX = 0, sizeX = 73, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortAchive:SetVal("button_label", userMods.ToWString(GTL("Achive"))) 
sortwt.SortAchive:Enable(false)
sortwt.SortDelete = CreateWG("SortButton", 'SortDelete', StatisticPanel, true,{ alignX = 0, posX = 505, highPosX = 0, sizeX = 37, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.SortDelete:SetVal("button_label", userMods.ToWString(GTL("Edit"))) 
sortwt.SortDelete:Enable(false)

sortwt.EditKey = CreateWG("SortButton", 'EditKey', EditorPanel, true, { alignX = 0, posX = 20, highPosX = 0, sizeX = 50, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.EditKey:SetVal("button_label", userMods.ToWString(GTL("Key")))
sortwt.EditKey:Enable(false)
sortwt.EditShard = CreateWG("SortButton", 'EditShard', EditorPanel, true, { alignX = 0, posX = 65, highPosX = 0, sizeX = 55, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.EditShard:SetVal("button_label", userMods.ToWString(GTL("Server"))) 
sortwt.EditShard:Enable(false)
sortwt.EditName = CreateWG("SortButton", 'EditName', EditorPanel, true, { alignX = 0, posX = 115, highPosX = 0, sizeX = 200, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.EditName:SetVal("button_label", userMods.ToWString(GTL("Pet"))) 
sortwt.EditName:Enable(false)
sortwt.EditAttempts = CreateWG("SortButton", 'EditAttempts', EditorPanel, true,{ alignX = 0, posX = 310, highPosX = 0, sizeX = 76, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.EditAttempts:SetVal("button_label", userMods.ToWString(GTL("Attempts"))) 
sortwt.EditAttempts:Enable(false)
sortwt.EditAchive = CreateWG("SortButton", 'EditAchive', EditorPanel, true,{ alignX = 0, posX = 382, highPosX = 0, sizeX = 73, alignY = 0, posY = 34, highPosY = 20, sizeY = 30 }) 
sortwt.EditAchive:SetVal("button_label", userMods.ToWString(GTL("Achive"))) 
sortwt.EditAchive:Enable(false)

sortwt.EditLineKeyBG = CreateWG("EditLineBG", 'EditLineKeyBG', EditorPanel, true, { alignX = 0, posX = 20, highPosX = 0, sizeX = 48, alignY = 0, posY = 60, highPosY = 20, sizeY = 48 }) 
sortwt.EditLineShardBG = CreateWG("EditLineBG", 'EditLineShardBG', EditorPanel, true, { alignX = 0, posX = 65, highPosX = 0, sizeX = 55, alignY = 0, posY = 60, highPosY = 20, sizeY = 48 }) 
sortwt.EditLineNameBG = CreateWG("EditLineBG", 'EditLineNameBG', EditorPanel, true, { alignX = 0, posX = 115, highPosX = 0, sizeX = 200, alignY = 0, posY = 60, highPosY = 20, sizeY = 48 }) 
sortwt.EditLineAttemptsBG = CreateWG("EditLineBG", 'EditLineAttemptsBG', EditorPanel, true, { alignX = 0, posX = 310, highPosX = 0, sizeX = 76, alignY = 0, posY = 60, highPosY = 20, sizeY = 48 }) 
sortwt.EditLineAchiveBG = CreateWG("EditLineBG", 'EditLineAchiveBG', EditorPanel, true, { alignX = 0, posX = 382, highPosX = 0, sizeX = 73, alignY = 0, posY = 60, highPosY = 20, sizeY = 48 }) 
sortwt.EditLineKey = sortwt.EditLineKeyBG:GetChildChecked("EditLine", false)
sortwt.EditLineKey:SetName("EditLineKey")
sortwt.EditLineShard = sortwt.EditLineShardBG:GetChildChecked("EditLine", false)
sortwt.EditLineShard:SetName("EditLineShard")
sortwt.EditLineName = sortwt.EditLineNameBG:GetChildChecked("EditLine", false)
sortwt.EditLineName:SetName("EditLineName")
sortwt.EditLineAttempts = sortwt.EditLineAttemptsBG:GetChildChecked("EditLine", false)
sortwt.EditLineAttempts:SetName("EditLineAttempts")
sortwt.EditLineAchive = sortwt.EditLineAchiveBG:GetChildChecked("EditLine", false)
sortwt.EditLineAchive:SetName("EditLineAchive")

function StartPetTimer(data)
    if (data - common.GetLocalDateTime().overallMs) >= 0 then
        local timem = common.GetDateTimeFromMs(data - common.GetLocalDateTime().overallMs)
        if timem then
            local strTime = tostring(timem.min).."м" 
            if timem.h > 0 then
                strTime = tostring(timem.h).."ч".. strTime
            else
                if timem.h == 0 then
                    strTime = strTime..tostring(timem.s).."с"
                elseif timem.h == 0 and timem.min == 0 then
                    strTime = tostring(timem.s).."с"
                end
            end
            return strTime
        end
    else
        return "++"
    end
end

function ShowInfo(name)
if not SettingsPS.ShowAlert then return end
local textinfo = InfoPanel:GetChildChecked("Text", true)
local buttonok = InfoPanel:GetChildChecked("ButtonOK", true)
buttonok:SetVal("button_label", userMods.ToWString("OK"))
textinfo:SetVal("value", GTL("TimeToHunt"))
--textinfo:SetVal("value2", PetName)
if name then textinfo:SetVal("value2", name) end
InfoPanel:Show(true)
for i, _ in pairs(StatCfg) do
	if StatCfg[i].Name == name then
		StatCfg[i].Show = false
		break
		end
	end
end

function OnSecondTimer()
    if not itemtable then OnShowStatisticPanel() end
    for _, tab in pairs(itemtable) do
        for k, v in pairs(tab) do
            local children = v:GetNamedChildren()
            for i = 0, GetTableSize(children) - 1 do
                local wtChild = children[i]
                local name = wtChild:GetName() 
                if string.find(name, 'ETimer') then 
				local num = tonumber(string.sub(name, 7)) 
                    if tostring(StartPetTimer(StatCfg[num].Date)) == "++" and (not InfoPanel:IsVisible()) and (StatCfg[num].Show == true) then
					ShowInfo(StatCfg[num].Name)
					StatCfg[num].Show = false
					userMods.SetGlobalConfigSection("PetsSearch_Timer", StatCfg) 
                    else
                       wtChild:SetVal("value", tostring(StartPetTimer(StatCfg[num].Date)))
                    end
                end
            end
        end
    end
end

function createContainer(id, text)
local newWidget = {}
newWidget.widget = mainForm:CreateWidgetByDesc( GroupPanel:GetWidgetDesc() )
newWidget.widget:Show( true )
newWidget.header = newWidget.widget:GetChildChecked("GroupHeader", true) 
newWidget.header:Show( true )
newWidget.header:SetVal("value", text)
newWidget.container = newWidget.widget:GetChildChecked("GroupContainer", true) 

Container:PushBack(newWidget.widget)

wtOptionContainer[id] = newWidget
end


function сreateBoxPanel(id, container, text)
	local newWidget = {}
	newWidget.widget = CreateWG("CheckboxPanel")
	newWidget.widget:Show( true )
	newWidget.value = SettingsPS[id]
	newWidget.text = newWidget.widget:GetChildChecked( "CheckboxPanelText", false )
	newWidget.text:SetVal( "checkbox_text", text)
	newWidget.checkbox = newWidget.widget:GetChildChecked( "Checkbox", false )
	newWidget.checkbox:SetVariant( newWidget.value and 1 or 0 )
	newWidget.checkbox:SetName(id)
	
	function newWidget:update(id)
		self.value = SettingsPS[id]
		self.checkbox:SetVariant( self.value and 1 or 0 )
	
	end
	container:PushBack( newWidget.widget )
	wtOption[id] = newWidget
end


function ShowSettings()
createContainer(1, GTL("Settings"))
сreateBoxPanel("FastTakePet", wtOptionContainer[1].container, GTL("FastTakePet"))
сreateBoxPanel("UseMapMark", wtOptionContainer[1].container, GTL("UseMapMark"))
сreateBoxPanel("UseMiniMapMark", wtOptionContainer[1].container, GTL("UseMiniMapMark"))
сreateBoxPanel("UseZoneInfo", wtOptionContainer[1].container, GTL("UseZoneInfo"))
сreateBoxPanel("ShowAlert", wtOptionContainer[1].container, GTL("ShowAlert"))
сreateBoxPanel("PlaySound", wtOptionContainer[1].container, GTL("PlaySound"))
end

function OnCornerCross(param)
    if param.sender == 'ButtonCornerCross' then
        Options:Show(not Options:IsVisible()) Container:RemoveItems()
	end
end

function ShowEditInfo(id)
if EditorPanel:IsVisible() then return end
EditorPanel:Show(true)
CurrentKey = id
CurrentDate = StatCfg[id].Date
local wgts = {}
wgts.header = EditorPanel:GetChildChecked("HeaderEditor", false)
wgts.header:SetVal("name", GTL("EditHeader"))
wgts.buttonok = EditorPanel:GetChildChecked("ButtonEditOK", false)
wgts.buttonok:SetVal("button_label", userMods.ToWString("OK"))
wgts.buttoncancel =  EditorPanel:GetChildChecked("ButtonAccept", false)
wgts.buttoncancel:SetVal("button_label", userMods.ToWString(GTL("AcceptKey")))
wgts.buttonaccept =  EditorPanel:GetChildChecked("ButtonCancel", false)
wgts.buttonaccept:SetVal("button_label", userMods.ToWString(GTL("CancelKey")))
sortwt.EditLineKey:SetText(common.FormatNumber(id))
sortwt.EditLineShard:SetText(StatCfg[id].Shard)
sortwt.EditLineName:SetText(userMods.ToWString(StatCfg[id].Name))
sortwt.EditLineAttempts:SetText(common.FormatNumber(StatCfg[id].Attempts))
sortwt.EditLineAchive:SetText(common.FormatNumber(StatCfg[id].Achive))
end

function ReactionCBox(pars)
if pars.sender == pars.widget:GetName() then
	if pars.widget:GetVariant()==0 then 
    SettingsPS[pars.sender] = true
	pars.widget:SetVariant(1)
	userMods.SetGlobalConfigSection ("PS_config", SettingsPS)
	LoadSettings()
	else 
    SettingsPS[pars.sender] = false
	userMods.SetGlobalConfigSection ("PS_config", SettingsPS)
	pars.widget:SetVariant(0)
	LoadSettings()
	end
	userMods.SetGlobalConfigSection("PS_config", SettingsPS) 
	end
end 

function LoadSettings()
	if userMods.GetGlobalConfigSection("PS_config") then
		SettingsPS = userMods.GetGlobalConfigSection("PS_config")
	else userMods.SetGlobalConfigSection("PS_config", SettingsPS) end
end

function LoadCB()
for k, v in pairs(wtOptions) do
	if SettingsPS[k] == true then
		v:SetVariant(1)
	elseif SettingsPS[k] == false then
		v:SetVariant(0)
		end
	end
end

function CreateObjectMarker(Panel, Name, Icon)
	local wtMarker = mainForm:CreateWidgetByDesc(wtBtnDesc)
	wtMarker:SetName( Name )
	Panel:AddChild(wtMarker)
	SetPos(wtMarker,0,15,0,15)
	
	wtMarker:SetForegroundTexture( FindIcons(Icon.NAME) )
	wtMarker:SetBackgroundTexture( FindIcons(Icon.NAME) )
	wtMarker:Show(true)
	return wtMarker
end

function CreateMapObjects(zoneID)
	if zoneID and not MapPanels[zoneID] and zoneGeodata[zoneID] then
		if Debug then LogInfo( "creating MapPanel for ", zoneID) end
		MapPanels[zoneID] = mainForm:CreateWidgetByDesc(wtMainPanelDesc)
		MapPanels[zoneID]:SetName( "MapPanel_"..zoneID )
		wtMapEnginePanel:AddChild(MapPanels[zoneID])
		if not zoneObjects[zoneID] then
			return 
		end
		
		local ZO = zoneObjects[zoneID]
		if Debug then LogInfo( "creating ", tostring(GetTableSize(ZO)), " widgets for Map ", zoneID) end
		if ZO then
		for i,obj in pairs(ZO) do
				obj.wdtMap = CreateObjectMarker(MapPanels[zoneID], zoneID.."::"..i, obj, nil)
			end
		end
	end
end

function CreateMinimapCircleObjects(zoneID)
	if zoneID and not MinimapCirclePanels[zoneID] and zoneGeodata[zoneID] then
		if Debug then LogInfo( "creating MinimapCirclePanel for ", zoneID) end
		MinimapCirclePanels[zoneID] = mainForm:CreateWidgetByDesc(wtMiniMapPanelDesc)
		MinimapCirclePanels[zoneID]:SetName( "MinimapCirclePanel_"..zoneID )
		wtMinimapCircleEnginePanel:AddChild(MinimapCirclePanels[zoneID])
		if not zoneObjects[zoneID] then
			return 
		end
		local ZO = zoneObjects[zoneID]
		if Debug then LogInfo( "creating ", tostring(GetTableSize(ZO)), " widgets for Circle Minimap ", zoneID) end
		if ZO then
		for i,obj in pairs(ZO) do
				if Debug then LogInfo( "creating ", obj.Type, " name: ", zoneID.."::"..i) end
				obj.wdtMinimapC = CreateObjectMarker(MinimapCirclePanels[zoneID], zoneID.."::"..i, obj)
			end
		end
	end
end

function CreateMinimapSquareObjects(zoneID)
	if zoneID and not MinimapSquarePanels[zoneID] and zoneGeodata[zoneID] then
		if Debug then LogInfo( "creating MinimapSquarePanel for ", zoneID) end
		MinimapSquarePanels[zoneID] = mainForm:CreateWidgetByDesc(wtMiniMapPanelDesc)
		MinimapSquarePanels[zoneID]:SetName( "MinimapSquarePanel_"..zoneID )
		wtMinimapSquareEnginePanel:AddChild(MinimapSquarePanels[zoneID])
		if not zoneObjects[zoneID] then
			return
		end
		local ZO = zoneObjects[zoneID]
		if Debug then LogInfo( "creating ", tostring(GetTableSize(ZO)), " widgets for Square Minimap", zoneID) end
		if ZO then
		for i,obj in pairs(ZO) do
				if Debug then LogInfo( "creating ", obj.Type, " name: ", zoneID.."::"..i) end
				obj.wdtMinimapS = CreateObjectMarker(MinimapSquarePanels[zoneID], zoneID.."::"..i, obj)
			end
		end
	end
end

function UpdateMapObjects(zoneID)
	if zoneID and MapPanels[zoneID] and zoneGeodata[zoneID] then
		local ZO = zoneObjects[zoneID]
		local geodata = zoneGeodata[zoneID]

		local pl = wtMapEnginePanel:GetPlacementPlain()
		if Debug then LogInfo( "MapEnginePanel: < "..pl.posX.." , "..pl.posY.." , "..pl.sizeX.." x "..pl.sizeY.." >") end
		SetPos(MapPanels[zoneID], 0, pl.sizeX, 0, pl.sizeY)
		pl = MapPanels[zoneID]:GetPlacementPlain()

		if Debug then LogInfo( "updating position for ", tostring(GetTableSize(ZO)), " Map widgets ", zoneID) end
		if ZO then
		for _,obj in pairs(ZO) do
			if obj.wdtMap then
				RePos(obj.wdtMap,(obj.Pos.posX-geodata.x)*pl.sizeX/geodata.width,((geodata.y+geodata.height)-obj.Pos.posY)*pl.sizeY/geodata.height)
				end
			end
		end
	end
end

function UpdateMinimapCircleObjects(zoneID)
	if zoneID and MinimapCirclePanels[zoneID] and zoneGeodata[zoneID] then
		local ZO = zoneObjects[zoneID]
		local geodata = zoneGeodata[zoneID]

		local pl = wtMinimapCircleEnginePanel:GetPlacementPlain()
		if Debug then LogInfo( "MinimapCircleEnginePanel: < "..pl.posX.." , "..pl.posY.." , "..pl.sizeX.." x "..pl.sizeY.." >") end
		SetPos(MinimapCirclePanels[zoneID], 0, pl.sizeX, 0, pl.sizeY)
		pl = MinimapCirclePanels[zoneID]:GetPlacementPlain()

		if Debug then LogInfo( "updating position for ", tostring(GetTableSize(ZO)), " Circle Minimap widgets ", zoneID) end
		if ZO then
		for _,obj in pairs(ZO) do
			if obj.wdtMinimapC then
				RePos(obj.wdtMinimapC,(obj.Pos.posX-geodata.x)*pl.sizeX/geodata.width,((geodata.y+geodata.height)-obj.Pos.posY)*pl.sizeY/geodata.height)
				end
			end
		end
	end
end

function UpdateMinimapSquareObjects(zoneID)
	if zoneID and MinimapSquarePanels[zoneID] and zoneGeodata[zoneID] then
		local ZO = zoneObjects[zoneID]
		local geodata = zoneGeodata[zoneID]

		local pl = wtMinimapSquareEnginePanel:GetPlacementPlain()
		if Debug then LogInfo( "MinimapSquareEnginePanel: < "..pl.posX.." , "..pl.posY.." , "..pl.sizeX.." x "..pl.sizeY.." >") end
		SetPos(MinimapSquarePanels[zoneID], 0, pl.sizeX, 0, pl.sizeY)
		pl = MinimapSquarePanels[zoneID]:GetPlacementPlain()

		if Debug then LogInfo( "updating position for ", tostring(GetTableSize(ZO)), " Square Minimap widgets ", zoneID) end
		if ZO then
		for _,obj in pairs(ZO) do
			if obj.wdtMinimapS then
				RePos(obj.wdtMinimapS,(obj.Pos.posX-geodata.x)*pl.sizeX/geodata.width,((geodata.y+geodata.height)-obj.Pos.posY)*pl.sizeY/geodata.height)
				end
			end
		end
	end
end

function CurrentZoneID(MapName)
	local zoneInfo = cartographer.GetZonesMapInfo(unit.GetZonesMapId(avatar.GetId()))
	if Debug then LogInfo( "current zone: ", zoneInfo.sysName) end

	return zoneInfo.sysName
end

function CheckMap()
if not SettingsPS.UseMapMark then return end
if MapLock then return end
MapLock = true
	if wtMapPanel:IsVisible() then -- отображается ли карта вданный момент
		local QuestShow = wtMapPanel:GetChildChecked("ButtonQuestsHide",true)
		local ScaleState = QuestShow:IsVisible() and 1 or 2
		--  update points positions only if necessary: current map changed or quest panel toggled
		if prevScaleState ~= ScaleState then
			for _,z in pairs(MapPanels) do
				z:Show(false)
			end
			local zoneID = CurrentMap()
			CreateMapObjects(zoneID)
			UpdateMapObjects(zoneID)
			if zoneID and MapPanels[zoneID] then
				MapPanels[zoneID]:Show(true)
			end
			--prevScaleState = ScaleState
		end			
	else
		prevScaleState = 0
		for _,z in pairs(MapPanels) do
			z:Show(false)
		end
	end
	MapLock = false
end

function CheckMinimap()
if not SettingsPS.UseMiniMapMark then return end
	if MinimapLock then return end
	MinimapLock = true
	if wtCircle:IsVisible() then
		for _,z in pairs(MinimapSquarePanels) do
			z:Show(false)
		end
		local pl = wtMinimapCircleEnginePanel:GetPlacementPlain()
		local Size = pl.sizeX.."x"..pl.sizeY
		if Debug then LogInfo( "Circle size: <", Size, ">, was: <", prevSize or "", ">, state 1 was: ", tostring(prevState)) end
		if prevState ~= 1 or prevSize ~= Size then
			for _,z in pairs(MinimapCirclePanels) do
				z:Show(false)
			end
			local zoneID = CurrentZoneID()
			CreateMinimapCircleObjects(zoneID)
			UpdateMinimapCircleObjects(zoneID)
			if zoneID and MinimapCirclePanels[zoneID] then
				MinimapCirclePanels[zoneID]:Show(true)
			end
			prevSize = Size
			prevState = 1
		end
	elseif wtSquare:IsVisible() then
		for _,z in pairs(MinimapCirclePanels) do
			z:Show(false)
		end
		local pl = wtMinimapSquareEnginePanel:GetPlacementPlain()
		local Size = pl.sizeX.."x"..pl.sizeY
		if Debug then LogInfo( "Square size: <", Size, ">, was: <", prevSize or "", ">, state 2 was: ", tostring(prevState)) end
		if prevState ~= 2 or prevSize ~= Size then
			for _,z in pairs(MinimapSquarePanels) do
				z:Show(false)
			end
			local zoneID = CurrentZoneID()
			CreateMinimapSquareObjects(zoneID)
			UpdateMinimapSquareObjects(zoneID)
			if zoneID and MinimapSquarePanels[zoneID] then
				MinimapSquarePanels[zoneID]:Show(true)
			end
			prevSize = Size
			prevState = 2
		end
	else
		prevState = 0
		prevSize = nil
		for _,z in pairs(MinimapCirclePanels) do
			z:Show(false)
		end
		for _,z in pairs(MinimapSquarePanels) do
			z:Show(false)
		end
	end
	MinimapLock = false
end

function RememberZoneGeodata()
	local geodata = cartographer.GetObjectGeodata( avatar.GetId(), unit.GetZonesMapId(avatar.GetId()) )
	local zoneInfo = cartographer.GetZonesMapInfo( unit.GetZonesMapId(avatar.GetId()) )
	if Debug then LogInfo( "remember zone: ", zoneInfo.sysName) end
	local zoneID = zoneInfo.sysName
	if not zoneGeodata[zoneID] and geodata then
		zoneGeodata[zoneID] = geodata
	end
end

function RememberMapGeodata()
local geodata
	if CurrentMapID() then
	local markers = cartographer.GetMapMarkers( CurrentMapID() )
	if markers[0] then
	local markedobjects = cartographer.GetMapMarkerObjects( CurrentMapID(), markers[0] )
		if markedobjects[0] then 
		geodata = markedobjects[0].geodata
		if not zoneGeodata[CurrentMap()] and geodata then
		zoneGeodata[CurrentMap()] = geodata
				end
			end 
		end
	end
end

function OnZone()
	RememberZoneGeodata()
	prevState = 0
	CheckMinimap()
end

function OnShowWidget(params)
if params.widget:GetName() == "ButtonQuestsHide" and SettingsPS.UseMapMark then
	CheckMap()
	end
if params.widget:GetName() == "MainPanel" and params.widget:GetParent():GetName() == "Map" and SettingsPS.UseMapMark then
	CheckMap()
	end
if params.widget:GetName() == "Square" and params.widget:GetParent():GetName() == "Minimap" and SettingsPS.UseMiniMapMark then
	CheckMinimap()
	end
if params.widget:GetName() == "Circle" and params.widget:GetParent():GetName() == "Minimap" and SettingsPS.UseMiniMapMark then
	CheckMinimap()
	end
if params.widget:GetName() == "Container" and params.widget:GetParent():GetName() == "Tooltip" and SettingsPS.UseMiniMapMark then
	CheckMinimap()
	end
if params.widget:GetParent():GetName() == "MapTextPanel" and SettingsPS.UseMapMark then
	RememberMapGeodata()
	CheckMap()
	end
if params.widget:GetName()=="Announce" and (not params.widget:IsVisible()) then 
		local text = userMods.FromWString(common.ExtractWStringFromValuedText(ContextAnnounceText:GetValuedText()))
		if text:find(GTL("CatchFail")) then
		GetPetAchivement(PetCastName, false)
		elseif text:find(GTL("CatchSuccess")) then
		GetPetAchivement(PetCastName, true)
		end
	end
end

function FixConfig()
if userMods.GetGlobalConfigSection("PS_config") then
    local cfg = userMods.GetGlobalConfigSection("PS_config")
		if GetTableSize(cfg) ~= GetTableSize(SettingsPS) then
			cfg = SettingsPS
			userMods.SetGlobalConfigSection("PS_config", cfg)
		end
	end
end
----------------------------------------------------
function Init()
	FixConfig()
	LoadSettings()
	StartInspect()
	PetsText:SetFormat(userMods.ToWString('<header alignx = "left" fontsize="14" outline="1"><rs class="class"><r name="name"/></rs></header>'))
	PetsText:SetVal("name", GTL("SubCategory")..":")
	StatisticHeader:SetVal("name", GTL("Statistic"))
	GetPetLocation()
	GetMapWidgets()
	OnZone()
	StatCfg = userMods.GetGlobalConfigSection("PetsSearch_Timer") or {}
--	LIY()
	for num, _ in pairs(StatCfg) do
	if num then
		if common.GetLocalDateTime().overallMs - StatCfg[num].Date > 0 and (not InfoPanel:IsVisible()) and StatCfg[num].Show then 
			ShowInfo( StatCfg[num].Name) end
		end
    end
	common.RegisterEventHandler( SpawnPet, "EVENT_UNIT_SPAWNED")
	common.RegisterEventHandler( DespawnPet, "EVENT_UNIT_DESPAWNED")
	common.RegisterEventHandler( PlayWidget, "EVENT_EFFECT_FINISHED" )
	common.RegisterEventHandler( GetPetLocation, "EVENT_AVATAR_CLIENT_ZONE_CHANGED" )
	common.RegisterEventHandler( OnZone, "EVENT_AVATAR_CLIENT_ZONE_CHANGED" )
	common.RegisterEventHandler( OnShowWidget, "EVENT_WIDGET_SHOW_CHANGED" )
	common.RegisterEventHandler( OnSecondTimer, "EVENT_SECOND_TIMER" )
	common.RegisterReactionHandler( SelectPet, "target_click" )
	common.RegisterReactionHandler( OnButtonLeftClick, "ButtonReaction" )
	common.RegisterReactionHandler( OnButtonRightClick, "ButtonReactionRight" )
	common.RegisterReactionHandler( ReactionOnPointing, "over_mouse" )
	common.RegisterReactionHandler( ReactionCBox, "checkbox_pressed" )
	common.RegisterReactionHandler(OnCornerCross, "cross_pressed")
	DnD.Init(PanelofPets, PanelofPets, true, true, nil, KBF_SHIFT ) 
	DnD.Init(ButtonSettings, ButtonSettings, true, true ) 
	DnD.Init(SettingsPanel, SettingsPanel, true, true ) 
	DnD.Init(StatisticPanel, StatisticPanel, true, true ) 
	DnD.Init(InfoPanel, InfoPanel, true, true ) 
	DnD.Init(EditorPanel, EditorPanel, true, true ) 
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end