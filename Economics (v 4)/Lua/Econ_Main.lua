-- FA_Economics
-- Author: FramedArchitecture
-- DateCreated: 5/5/2015
--------------------------------------------------------------
MapModData.gT = MapModData.gT or {}
gT = MapModData.gT
--------------------------------------------------------------
gT.bDisablePrint = false
--------------------------------------------------------------
include("Econ_Player.lua")
include("JFD_TopPanelUpdated.lua")
include("TableSaverLoader016.lua")
--------------------------------------------------------------
local bHideTopPanel = ContextPtr:LookUpControl("/InGame/TopPanel/ClockOptionsPanel")
local IsHEALTHMOD = IsHEALTHMOD
local STRATEGIC_RESOURCE = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
local autoSaveFreq = OptionsManager.GetTurnsBetweenAutosave_Cached()
local print = gT.bDisablePrint and function() end or print
local insert = table.insert
local concat = table.concat
local tipControlTable = {}
TTManager:GetTypeControlTable( "TooltipTypeTopPanel", tipControlTable )
--------------------------------------------------------------
--Top Panel
--------------------------------------------------------------
function UpdateTopPanel()
	local player = Players[Game.GetActivePlayer()]

	if not bHideTopPanel and (player:GetNumCities() > 0) then
		local paddingX = 47
		local offsetX = paddingX + ContextPtr:LookUpControl("/InGame/TopPanel/TopPanelInfoStack"):GetSizeX()
	
		if not ContextPtr:LookUpControl("/InGame/TopPanel/UnitSupplyString"):IsHidden() then
			offsetX = offsetX + paddingX
		end

		if IsHEALTHMOD then
			offsetX = offsetX - 80
		else
			local teamTechs = Teams[Game.GetActiveTeam()]:GetTeamTechs()
			local iShown = 0
			for row in GameInfo.Resources() do
				local resourceID = row.ID
				if (Game.GetResourceUsageType(resourceID) == STRATEGIC_RESOURCE) then
					if (teamTechs:HasTech(GameInfoTypes[row.TechReveal])) and (teamTechs:HasTech(GameInfoTypes[row.TechCityTrade])) then
						iShown = iShown + 1
					elseif (player:GetNumResourceUsed(resourceID) > 0) then
						iShown = iShown + 1
					end	
				end
			end
			if (iShown > 0) then
				paddingX = 43
				offsetX = offsetX - 90 + (paddingX * iShown)
			end
		end
		Controls.InfoIcon:SetOffsetX( offsetX )

		local econPlayer = g_EconPlayers[Game.GetActivePlayer()]
		local strGDP = "[ICON_ECONOMICS]"
		if econPlayer then
			strGDP =  strGDP .. econPlayer:GetGrowthRateString()
		end 
		Controls.EconString:SetText( strGDP )
		Controls.EconString:SetHide( false )
	else
		Controls.EconString:SetHide( true )
	end
end
Events.SerialEventGameDataDirty.Add( UpdateTopPanel )
Events.SerialEventTurnTimerDirty.Add( UpdateTopPanel )
Events.SerialEventCityInfoDirty.Add( UpdateTopPanel )
LuaEvents.Economics_UpdateTopPanel.Add( UpdateTopPanel )
--------------------------------------------------------------
function OnEconClicked()
	LuaEvents.FA_Economics_EconOverview()
end
Controls.EconString:RegisterCallback( Mouse.eLClick, OnEconClicked )
--------------------------------------------------------------
function EconomicsTipHandler( control )
	local strTT = ""
	local tips = {}
	local econPlayer = g_EconPlayers[Game.GetActivePlayer()]

	if econPlayer then
		local iGDP = econPlayer:GetTotalGDP()
		local iGrowth = decimalshift(econPlayer:GetGrowthRate(), 2)
		
		insert(tips, locale("TXT_KEY_TP_FA_ECON_GDP_TOTAL_TT", iGDP))
		insert(tips, locale("TXT_KEY_TP_FA_ECON_GDP_GROWTH_TT", iGrowth))
		insert(tips, "---------------")
		insert(tips, locale("TXT_KEY_TP_FA_ECON_GDP_DEFINE_TOOLTIP"))
		insert(tips, "---------------")
		insert(tips, locale("TXT_KEY_TP_FA_ECON_SCREEN_TOOLTIP"))
	end

	if #tips > 0 then
		strTT = concat(tips, "[NEWLINE]")
	end

	tipControlTable.TooltipLabel:SetText( strTT )
	tipControlTable.TopPanelMouseover:SetHide(false)
    tipControlTable.TopPanelMouseover:DoAutoSize()
	
end
Controls.EconString:SetToolTipCallback( EconomicsTipHandler )
--------------------------------------------------------------
--Save Data
--------------------------------------------------------------
function OnEnterGame() 
	ContextPtr:LookUpControl("/InGame/GameMenu/SaveGameButton"):RegisterCallback(Mouse.eLClick, SaveGameIntercept)
	ContextPtr:LookUpControl("/InGame/GameMenu/QuickSaveButton"):RegisterCallback(Mouse.eLClick, QuickSaveIntercept)

	UpdateTopPanel()
end
Events.LoadScreenClose.Add(OnEnterGame)
--------------------------------------------------------------
function SaveGameIntercept()
	LuaEvents.Economics_UpdateToArchive()
	TableSave(gT, "FA_Economics")
	UIManager:QueuePopup(ContextPtr:LookUpControl("/InGame/GameMenu/SaveMenu"), PopupPriority.SaveMenu)
end
--------------------------------------------------------------
function QuickSaveIntercept()
	LuaEvents.Economics_UpdateToArchive()
	TableSave(gT, "FA_Economics")
	UI.QuickSave()
end
--------------------------------------------------------------
function OnGameOptionsChanged()
	autoSaveFreq = OptionsManager.GetTurnsBetweenAutosave_Cached()
end
Events.GameOptionsChanged.Add(OnGameOptionsChanged)
--------------------------------------------------------------
function OnAIProcessingEndedForPlayer(iPlayer)
	if iPlayer == 63 then
		if Game.GetGameTurn() % autoSaveFreq == 0 then
			TableSave(gT, "FA_Economics")
		end
	end
end
Events.AIProcessingEndedForPlayer.Add(OnAIProcessingEndedForPlayer)
--------------------------------------------------------------
function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_F11 then
			QuickSaveIntercept()
        	return true
		elseif wParam == Keys.S and UIManager:GetControl() then
			SaveGameIntercept()
			return true
		elseif wParam == Keys.C and UIManager:GetControl() then
			OnEconClicked()
			return true
		end
	end
end
ContextPtr:SetInputHandler(InputHandler)
--------------------------------------------------------------
function OnModLoaded()
	gT.g_EconData = {}
	local bNewGame = not TableLoad(gT, "FA_Economics")
	TableSave(gT, "FA_Economics")

	Events.LoadScreenClose.Add(OnLoadScreenClose)
end
--------------------------------------------------------------
OnModLoaded()

