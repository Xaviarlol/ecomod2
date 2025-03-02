--------------------------------------------------------------------
-- Economics Overview
--------------------------------------------------------------------
MapModData.gT = MapModData.gT or {}
gT = MapModData.gT
--------------------------------------------------------------------
include("IconSupport")
include("InstanceManager")
include("Econ_Math.lua")
include("Econ_Global.lua")
--------------------------------------------------------------------
local g_OurSummaryManager = InstanceManager:new( "OurSummaryInstance", "Base", Controls.OurSummaryStack)
local g_OurRevenueManager = InstanceManager:new( "OurRevenueInstance", "Base", Controls.OurRevenueStack)
local g_OurExpenseManager = InstanceManager:new( "OurExpenseInstance", "Base", Controls.OurExpenseStack)
local g_WorldEconomyManager = InstanceManager:new("WorldEconomyInstance", "Base", Controls.WorldEconomyStack)
local g_HistoricManager = InstanceManager:new( "HistoricInstance", "Base", Controls.HistoricStack)
local g_Policies01Manager = InstanceManager:new("PolicyInstance", "Button", Controls.PolicyStack01)
local g_Policies02Manager = InstanceManager:new("PolicyInstance", "Button", Controls.PolicyStack02)
--------------------------------------------------------------------
local IsExpansion = IsGNK or IsBNW
local GAME_MAX_ERAS = GAME_MAX_ERAS
local GROWTH_BOOM = GROWTH_BOOM
local GROWTH_EXPANSION = GROWTH_EXPANSION
local GROWTH_STAGNATION = GROWTH_STAGNATION
local GROWTH_RECESSION = GROWTH_RECESSION
local GROWTH_BUST = GROWTH_BUST
local MAX_TAX_RATE = MAX_TAX_RATE
local MIN_TAX_RATE = MIN_TAX_RATE
local POLICY_COOLDOWN = POLICY_COOLDOWN
local strUknown = locale("TXT_KEY_FA_ECON_POPUP_UNKNOWN")
local strUnknownHelp = locale("TXT_KEY_FA_ECON_POPUP_UNKNOWN_HELP")
local strDepressionTT = locale("TXT_KEY_FA_ECON_POPUP_DEPRESSION_TT")
local insert = table.insert
local concat = table.concat
local sort = table.sort
local g_Current
local g_Economy
local g_World
local g_History
local print = gT.bDisablePrint and function() end or print
local bPopup = false
--------------------------------------------------------------------
g_Tabs = {
	["OurEconomy"] = {
		Panel = Controls.OurEconomyPanel,
		SelectHighlight = Controls.OurEconomySelectHighlight,
	},
	
	["WorldEconomy"] = {
		Panel = Controls.WorldEconomyPanel,
		SelectHighlight = Controls.WorldEconomySelectHighlight,
	},
	
	["EconomicHistory"] = {
		Panel = Controls.EconomicHistoryPanel,
		SelectHighlight = Controls.EconomicHistorySelectHighlight,
	},
}
--------------------------------------------------------------------
function TabSelect(tab)
	for i,v in pairs(g_Tabs) do
		local bHide = i ~= tab;
		v.Panel:SetHide(bHide);
		v.SelectHighlight:SetHide(bHide);
	end
	g_Tabs[tab].RefreshContent();
end
--------------------------------------------------------------------
Controls.TabButtonOurEconomy:RegisterCallback( Mouse.eLClick, function() TabSelect("OurEconomy"); end)
Controls.TabButtonWorldEconomy:RegisterCallback( Mouse.eLClick, function() TabSelect("WorldEconomy"); end )
Controls.TabButtonHistory:RegisterCallback( Mouse.eLClick, function() TabSelect("EconomicHistory"); end )
--------------------------------------------------------------------
--Policies
--------------------------------------------------------------------
local iSelectedPolicy = -1
local iCurrentEra = 0
local iPolicyTurn = -1
local bChangedPolicy = false
local g_PolicyButtons = {}
--------------------------------------------------------------------
g_PolicyScreen = {
--------------------------------------------------------------
["CheckBox"] = {
	Init = function()
		for row in GameInfo.Econ_Policies() do
			local instance
			local policyID = row.ID
			if (policyID <= 6) then
				instance = g_Policies01Manager:GetInstance()
			else	
				instance = g_Policies02Manager:GetInstance()
			end

			local checkboxButton = instance.Button:GetTextButton()
			checkboxButton:SetText(locale(row.Description))

			function OnPolicyChecked(bCheck)
				iSelectedPolicy = bCheck and row.ID or -1
				bChangedPolicy = true
				PolicyScreen("Update")
			end
			instance.Button:RegisterCheckHandler( OnPolicyChecked )

			g_PolicyButtons[row.ID] = instance
		end
		Controls.PolicyStack01:CalculateSize()
		Controls.PolicyStack01:ReprocessAnchoring()
		Controls.PolicyStack02:CalculateSize()
		Controls.PolicyStack02:ReprocessAnchoring()
	end,
		
	Update = function()
		for id, instance in pairs(g_PolicyButtons) do
			instance.Button:SetCheck( iSelectedPolicy == id )
		end
	end,
},
--------------------------------------------------------------
["Accept"] = {
	Init = function()
		function OnSelectPolicy()
			local archive = gT.g_EconData[Game.GetActivePlayer()][Game.GetGameTurn()]
			archive.iPolicyID = iSelectedPolicy
			archive.iPolicyTurn = (Game.GetGameTurn() + POLICY_COOLDOWN)
			RefreshAll()
			ClosePopups()
		end
		Controls.AcceptPolicies:RegisterCallback( Mouse.eLClick, OnSelectPolicy )
	end,
	
	Update = function()
		local archive = gT.g_EconData[Game.GetActivePlayer()][Game.GetGameTurn()]
		Controls.AcceptPolicies:SetDisabled( not bChangedPolicy or (archive == nil) )
	end,
},
--------------------------------------------------------------
["Close"] = {
	Init = function()
		function OnCancelPolicies()
			ClosePopups()
		end
		Controls.CancelPolicies:RegisterCallback( Mouse.eLClick, OnCancelPolicies )
	end,
},
}
--------------------------------------------------------------------
function PolicyScreen(func, ...)
	for _,v in pairs(g_PolicyScreen) do
		if(v[func]) then
			v[func](...)
		end
	end
end
--------------------------------------------------------------------
function OnPolicyScreen()
	bPopup = true
	bChangedPolicy = false
	
	iCurrentEra = g_Current.iCurrentEra
	iSelectedPolicy = g_Current.iPolicyID
	iPolicyTurn = g_Current.iPolicyTurn
	
	local bCanChangePolicy = (iPolicyTurn <= Game.GetGameTurn())
	
	for id, instance in pairs(g_PolicyButtons) do
		local policyInfo = GameInfo.Econ_Policies[id]
		
		local eraInfo = GameInfo.Eras[policyInfo.EraReq]
		local iReqEra = eraInfo and eraInfo.ID or GAME_MAX_ERAS
		local bDisabled = (iReqEra > iCurrentEra) or false
		local strHelp = GetPolicyToolTip(id, bDisabled)
		
		bDisabled = not bCanChangePolicy and true or bDisabled
		instance.Button:SetToolTipString( strHelp )
		instance.Button:SetDisabled( bDisabled )
		instance.Button:SetCheck( iSelectedPolicy == id )
	end

	local strAcceptButton = ""
	if not bCanChangePolicy then
		strAcceptButton = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_POLICY_CHOOSE_TURN", iPolicyTurn)
	else
		strAcceptButton = locale("TXT_KEY_POPUP_FA_ECON_CHOOSE_POLICY")
	end

	Controls.AcceptPolicies:SetText(strAcceptButton)
	Controls.AcceptPolicies:SetDisabled(true)
	Controls.SelectPolicies:SetHide(false)
	Controls.BGBlock:SetHide(true)
end
Controls.PoliciesButton:RegisterCallback( Mouse.eLClick, OnPolicyScreen )
--------------------------------------------------------------------
--Tax
--------------------------------------------------------------------
local iTaxGDPThreshold = decimalshift(TAX_GDP_THRESHOLD, 2)
local iMaxTax = decimalshift(MAX_TAX_RATE, 2)
local iMinTax = decimalshift(MIN_TAX_RATE, 2)
local fAverageSlider = iMinTax
local fIncomeSlider = iMinTax
local fBusinessSlider = iMinTax
local fImportSlider = iMinTax
local fExportSlider = iMinTax
local bCanAverageTax = false
local bCanExpandedTax = false
local bChangedTax = false
--------------------------------------------------------------------
g_TaxSliders = {
--------------------------------------------------------------
["Average"] = {
	Init = function()
		function OnAverageTaxSlider( fValue )
			local iValue = round(fValue * iMaxTax)
			fAverageSlider = (iValue < iMinTax) and iMinTax or iValue
			fIncomeSlider = fAverageSlider
			fBusinessSlider = fAverageSlider
			fImportSlider = fAverageSlider
			fExportSlider = fAverageSlider
			
			bChangedTax = true
			TaxScreen("Update")
		end
		Controls.AverageTaxSlider:RegisterSliderCallback( OnAverageTaxSlider )
	end,
	
	Update = function()
		local strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_AVERAGE_TAX", fAverageSlider)
		if (fAverageSlider > iTaxGDPThreshold) then
			strSlider = WarningText(strSlider)
		end
		Controls.AverageTaxLabel:SetText( strSlider )

		if bCanExpandedTax then
			Controls.AverageTaxSlider:SetValue( fAverageSlider/iMaxTax )
		else
			Controls.IncomeTaxSlider:SetValue( fIncomeSlider/iMaxTax )
			Controls.BusinessTaxSlider:SetValue( fBusinessSlider/iMaxTax )
			Controls.ImportTaxSlider:SetValue( fImportSlider/iMaxTax )
			Controls.ExportTaxSlider:SetValue( fExportSlider/iMaxTax )
		end
	end,
},
--------------------------------------------------------------
["Income"] = {
	Init = function()
		function OnIncomeTaxSlider( fValue )
			local iValue = round(fValue * iMaxTax)
			fIncomeSlider = (iValue < iMinTax) and iMinTax or iValue
			fAverageSlider = round((fIncomeSlider + fBusinessSlider + fImportSlider + fExportSlider)/4)
			
			bChangedTax = true
			TaxScreen("Update")
		end
		Controls.IncomeTaxSlider:RegisterSliderCallback( OnIncomeTaxSlider )
	end,
	
	Update = function()
		local strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_INCOME_TAX", fIncomeSlider)
		if (fIncomeSlider > iTaxGDPThreshold) then
			strSlider = WarningText(strSlider)
		end
		Controls.IncomeTaxLabel:SetText( strSlider )
	end,
},
--------------------------------------------------------------
["Business"] = {
	Init = function()
		function OnBusinessTaxSlider( fValue )
			local iValue = round(fValue * iMaxTax)
			fBusinessSlider = (iValue < iMinTax) and iMinTax or iValue
			fAverageSlider = round((fIncomeSlider + fBusinessSlider + fImportSlider + fExportSlider)/4)
		
			bChangedTax = true
			TaxScreen("Update")
		end
		Controls.BusinessTaxSlider:RegisterSliderCallback( OnBusinessTaxSlider )
	end,
	
	Update = function()
		local strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_BUSINESS_TAX", fBusinessSlider)
		if (fBusinessSlider > iTaxGDPThreshold) then
			strSlider = WarningText(strSlider)
		end
		Controls.BusinessTaxLabel:SetText( strSlider )
	end,
},
--------------------------------------------------------------
["Import"] = {
	Init = function()
		function OnImportTaxSlider( fValue )
			local iValue = round(fValue * iMaxTax)
			fImportSlider = (iValue < iMinTax) and iMinTax or iValue
			fAverageSlider = round((fIncomeSlider + fBusinessSlider + fImportSlider + fExportSlider)/4)
		
			bChangedTax = true
			TaxScreen("Update")
		end
		Controls.ImportTaxSlider:RegisterSliderCallback( OnImportTaxSlider )
	end,
	
	Update = function()
		local strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_IMPORT_TAX", fImportSlider)
		if (fImportSlider > iTaxGDPThreshold) then
			strSlider = WarningText(strSlider)
		end
		Controls.ImportTaxLabel:SetText( strSlider )
	end,
},
--------------------------------------------------------------
["Export"] = {
	Init = function()
		function OnExportTaxSlider( fValue )
			local iValue = round(fValue * iMaxTax)
			fExportSlider = (iValue < iMinTax) and iMinTax or iValue
			fAverageSlider = round((fIncomeSlider + fBusinessSlider + fImportSlider + fExportSlider)/4)

			bChangedTax = true
			TaxScreen("Update")
		end
		Controls.ExportTaxSlider:RegisterSliderCallback( OnExportTaxSlider )
	end,
	
	Update = function()
		local strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_EXPORT_TAX", fExportSlider)
		if (fExportSlider > iTaxGDPThreshold) then
			strSlider = WarningText(strSlider)
		end
		Controls.ExportTaxLabel:SetText( strSlider )
	end,
},
--------------------------------------------------------------
["Accept"] = {
	Init = function()
		function OnAcceptTaxes()
			local archive = gT.g_EconData[Game.GetActivePlayer()][Game.GetGameTurn()]
			archive.fTaxRate_Average = decimalshift(fAverageSlider, -2)
			archive.fTaxRate_Income	= decimalshift(fIncomeSlider, -2) 
			archive.fTaxRate_Business = decimalshift(fBusinessSlider, -2)
			archive.fTaxRate_Imports = decimalshift(fImportSlider, -2)
			archive.fTaxRate_Exports = decimalshift(fExportSlider, -2) 

			RefreshAll()
			bChangedTax = false
			ClosePopups()
		end
		Controls.AcceptTaxes:RegisterCallback( Mouse.eLClick, OnAcceptTaxes )
	end,
	
	Update = function()
		local archive = gT.g_EconData[Game.GetActivePlayer()][Game.GetGameTurn()]
		Controls.AcceptTaxes:SetDisabled( not bChangedTax or (archive == nil) )
	end,
},
--------------------------------------------------------------
["Close"] = {
	Init = function()
		function OnCancelTaxes()
			ClosePopups()
		end
		Controls.CancelTaxes:RegisterCallback( Mouse.eLClick, OnCancelTaxes )
	end,
},
}
--------------------------------------------------------------------
function TaxScreen(func, ...)
	for _,v in pairs(g_TaxSliders) do
		if(v[func]) then
			v[func](...)
		end
	end
end
--------------------------------------------------------------------
function OnChangeTaxes()
	bPopup = true
	bChangedTax = false
	
	iSelectedPolicy = g_Current.iPolicyID
	fAverageSlider = decimalshift(g_Current.fTaxRate_Average, 2)
	fIncomeSlider = decimalshift(g_Current.fTaxRate_Income, 2)
	fBusinessSlider = decimalshift(g_Current.fTaxRate_Business, 2)
	fImportSlider = decimalshift(g_Current.fTaxRate_Imports, 2)	
	fExportSlider = decimalshift(g_Current.fTaxRate_Exports, 2)
	bCanAverageTax = g_Current.bEnableBasicTax
	bCanExpandedTax = g_Current.bEnableExpandTax
	
	local strDisabled = ""
	
	if not bCanAverageTax then
		strDisabled = GameInfo.Eras[BASE_TAX_ERA].Description
		Controls.AverageTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
		Controls.AcceptTaxes:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
	elseif bCanExpandedTax then
		strDisabled = GameInfo.Eras[EXPANDED_TAX_ERA].Description
		Controls.AverageTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_AVERAGE_DISABLED_TT", strDisabled)
	end

	if not bCanExpandedTax then
		strDisabled = GameInfo.Eras[EXPANDED_TAX_ERA].Description
		Controls.IncomeTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
		Controls.BusinessTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
		Controls.ImportTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
		Controls.ExportTaxLabel:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_TAX_DISABLED_TT", strDisabled)
	end
	
	Controls.AverageTaxSlider:SetDisabled(not bCanAverageTax or bCanExpandedTax)
	Controls.IncomeTaxSlider:SetDisabled(not bCanAverageTax or not bCanExpandedTax)
	Controls.BusinessTaxSlider:SetDisabled(not bCanAverageTax or not bCanExpandedTax)
	Controls.ImportTaxSlider:SetDisabled(not bCanAverageTax or not bCanExpandedTax)
	Controls.ExportTaxSlider:SetDisabled(not bCanAverageTax or not bCanExpandedTax)
	Controls.AcceptTaxes:SetDisabled( not bChangedTax )
	
	local policyInfo = GameInfo.Econ_Policies[iSelectedPolicy]
	if policyInfo then
		if (policyInfo.IncomeTax ~= 0) then
			Controls.IncomeTaxSlider:SetDisabled(true)
		end
		if (policyInfo.BusinessTax ~= 0) then
			Controls.BusinessTaxSlider:SetDisabled(true)
		end
		if (policyInfo.TradeTax ~= 0) then
			Controls.ImportTaxSlider:SetDisabled(true)
			Controls.ExportTaxSlider:SetDisabled(true)
		end
	end

	local strSlider = ""
	
	strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_AVERAGE_TAX", fAverageSlider)
	if (fAverageSlider > iTaxGDPThreshold) then
		strSlider = WarningText(strSlider)
	end
	Controls.AverageTaxLabel:SetText( strSlider )
	Controls.AverageTaxSlider:SetValue( fAverageSlider/iMaxTax )

	strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_INCOME_TAX", fIncomeSlider)
	if (fIncomeSlider > iTaxGDPThreshold) then
		strSlider = WarningText(strSlider)
	end
	Controls.IncomeTaxLabel:SetText( strSlider )
	Controls.IncomeTaxSlider:SetValue( fIncomeSlider/iMaxTax )
	
	strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_BUSINESS_TAX", fBusinessSlider)
	if (fBusinessSlider > iTaxGDPThreshold) then
		strSlider = WarningText(strSlider)
	end
	Controls.BusinessTaxLabel:SetText( strSlider )
	Controls.BusinessTaxSlider:SetValue( fBusinessSlider/iMaxTax )
	
	strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_IMPORT_TAX", fImportSlider)
	if (fImportSlider > iTaxGDPThreshold) then
		strSlider = WarningText(strSlider)
	end
	Controls.ImportTaxLabel:SetText( strSlider )
	Controls.ImportTaxSlider:SetValue( fImportSlider/iMaxTax )
	
	strSlider = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_EXPORT_TAX", fExportSlider)
	if (fExportSlider > iTaxGDPThreshold) then
		strSlider = WarningText(strSlider)
	end
	Controls.ExportTaxLabel:SetText( strSlider )
	Controls.ExportTaxSlider:SetValue( fExportSlider/iMaxTax )

	Controls.ChangeTaxes:SetHide(false)
	Controls.BGBlock:SetHide(true)
end
Controls.TaxButton:RegisterCallback( Mouse.eLClick, OnChangeTaxes )
--------------------------------------------------------------------
--Debt
--------------------------------------------------------------------
local BASE_DEBT_TERM = BASE_DEBT_TERM
local iMaxDebt = BASE_MAX_DEBT
local iMinDebt = BASE_MIN_DEBT
local bCanIssueDebt = false			
local fInterestRate = 0
local iPrincipalSlider = 0
local iLoanTotal = 0
local iLoanPayment = 0
local bChangedDebt = false
--------------------------------------------------------------------
g_DebtScreen = {
--------------------------------------------------------------
["Slider"] = {
	Init = function()
		function OnDebtSlider( fValue )
			iPrincipalSlider = round(fValue * iMaxDebt)
			bChangedDebt = true
			DebtScreen("Update")
		end
		Controls.DebtSlider:RegisterSliderCallback( OnDebtSlider )
	end,
	
	Update = function()
		iLoanTotal = up(iPrincipalSlider + (iPrincipalSlider * fInterestRate))
		iLoanPayment = up(iLoanTotal/BASE_DEBT_TERM)

		Controls.PrincipalLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_PRINCIPAL", iPrincipalSlider)
		Controls.LoanLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_LOAN", iLoanTotal)
		Controls.PaymentLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_PAYMENT", iLoanPayment, BASE_DEBT_TERM)
	end,
},
--------------------------------------------------------------
["Accept"] = {
	Init = function()
		function OnAcceptDebt()
			local iActivePlayer = Game.GetActivePlayer()
			local archive = gT.g_EconData[iActivePlayer][Game.GetGameTurn()]
			archive.iDebt_Total = (archive.iDebt_Total + iLoanTotal)
			archive.iDebt_Payment = (archive.iDebt_Payment + iLoanPayment)
			
			Players[iActivePlayer]:ChangeGold( iPrincipalSlider )

			RefreshAll()

			bChangedDebt = false
			iPrincipalSlider = 0
			iLoanTotal = 0
			iLoanPayment = 0

			ClosePopups()
		end
		Controls.AcceptDebt:RegisterCallback( Mouse.eLClick, OnAcceptDebt )
	end,
	
	Update = function()
		local archive = gT.g_EconData[Game.GetActivePlayer()][Game.GetGameTurn()]
		local bMinNotMet = (iPrincipalSlider<iMinDebt)
		local strTooltip = ""
		if bMinNotMet then
			strTooltip = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_DISABLED_MIN_TT", iMinDebt)
		end
		Controls.AcceptDebt:SetToolTipString(strTooltip)
		Controls.AcceptDebt:SetDisabled( not bChangedDebt or (archive == nil) or bMinNotMet )
	end,
},
--------------------------------------------------------------
["Close"] = {
	Init = function()
		function OnCancelDebt()
			ClosePopups()
		end
		Controls.CancelDebt:RegisterCallback( Mouse.eLClick, OnCancelDebt )
	end,
},
}
--------------------------------------------------------------------
function DebtScreen(func, ...)
	for _,v in pairs(g_DebtScreen) do
		if(v[func]) then
			v[func](...)
		end
	end
end
--------------------------------------------------------------------
function OnIssueDebt()
	bPopup = true
	
	bEnableDebt = g_Current.bEnableDebt
	fInterestRate = g_Current.fInterest_Rate
	iMaxDebt = (BASE_MAX_DEBT * g_Current.iCurrentEra)

	local policyInfo = GameInfo.Econ_Policies[g_Current.iPolicyID]
	if policyInfo and (policyInfo.DebtLimit ~= 0) then
		iMaxDebt = iMaxDebt + iMaxDebt*(policyInfo.DebtLimit/100)
		iMaxDebt = round(iMaxDebt)
	end

	local strMaxDebt = tostring(iMaxDebt)
	
	iMaxDebt = iMaxDebt - g_Current.iDebt_Total
	iMinDebt = BASE_MIN_DEBT * g_Current.iCurrentEra
	
	iPrincipalSlider = iMinDebt
	iLoanTotal = 0
	iLoanPayment = 0
	bChangedTax = false
	
	local bDisabled = not bEnableDebt or (iMaxDebt<=iMinDebt)
	
	if not bEnableDebt then
		local strDisabled = GameInfo.Eras[BASE_DEBT_ERA].Description
		Controls.DebtDisabledLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_DISABLED", strDisabled)
		Controls.AcceptDebt:LocalizeAndSetToolTip("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_DISABLED", strDisabled)
	else
		Controls.InterestLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_INTEREST_RATE", decimalshift(fInterestRate, 2))
		Controls.LoanLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_LOAN", iLoanTotal)
		Controls.PaymentLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_PAYMENT", iLoanPayment, BASE_DEBT_TERM)

		strMaxDebt = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_CURRENT_MAX", g_Current.iDebt_Total, strMaxDebt)
		strMaxDebtTT = ""
		if bDisabled then
			strMaxDebt = WarningText(strMaxDebt)
			strMaxDebtTT = locale("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_CURRENT_MAX_TT")
		end
		Controls.CurrentMaxLabel:SetText(strMaxDebt)
		Controls.CurrentMaxLabel:SetToolTipString(strMaxDebtTT)
		Controls.PrincipalLabel:SetToolTipString(strMaxDebtTT)
	end

	Controls.PrincipalLabel:LocalizeAndSetText("TXT_KEY_POPUP_FA_ECON_ADJUST_DEBT_PRINCIPAL", iPrincipalSlider)
	Controls.DebtSlider:SetDisabled( bDisabled )
	Controls.DebtSlider:SetValue( iMinDebt/iMaxDebt )
	Controls.InterestLabel:SetHide( bDisabled )
	Controls.LoanLabel:SetHide( bDisabled )
	Controls.PaymentLabel:SetHide( bDisabled )
	Controls.DebtDisabledLabel:SetHide( not bDisabled )
	Controls.CurrentMaxLabel:SetHide( not bEnableDebt )
	Controls.AcceptDebt:SetDisabled( true )

	Controls.IssueDebt:SetHide(false)
	Controls.BGBlock:SetHide(true)
end
Controls.DebtButton:RegisterCallback( Mouse.eLClick, OnIssueDebt )
--------------------------------------------------------------------
--Panel Content
--------------------------------------------------------------------
function RefreshOurEconomy()
	g_OurSummaryManager:ResetInstances()
	g_OurRevenueManager:ResetInstances()
	g_OurExpenseManager:ResetInstances()

if g_Economy then
	local metrics = {
		"Growth", "Total GDP", "Consumer GDP", "Government GDP", "Investment GDP", "Trade GDP", "Unemployment",
		"Total Revenue", "Average Tax", "Income Revenue", "Income Tax", "Business Revenue", "Business Tax", "Import Revenue", "Import Tax", "Export Revenue", "Export Tax",
		"Total Expense", "Policy Expense", "Military Expense", "Building Expense", "City Expense", "Culture Expense", "Total Debt", "Debt Payment", "Interest Rate"
	}

	local yearLabels = {}
	for i, v in ipairs(g_Economy) do
		table.insert(yearLabels, date(v.iYear))
	end

	local function CreateMetricRow(manager, metricName, values)
		local instance = manager:GetInstance()
		instance.SummaryYear:SetText(metricName)
		for i, value in ipairs(values) do
			instance["Year" .. i]:SetText(value)
		end
	end

	local summaryValues = {}
	for _, metric in ipairs(metrics) do
		local rowData = {}
		for _, yearData in ipairs(g_Economy) do
			if metric == "Growth" then
				table.insert(rowData, percent(yearData.fGDP_Growth, 1))
			elseif metric == "Total GDP" then
				table.insert(rowData, comma(yearData.iGDP_Total))
			elseif metric == "Consumer GDP" then
				table.insert(rowData, comma(yearData.iGDP_Consumer))
			elseif metric == "Government GDP" then
				table.insert(rowData, comma(yearData.iGDP_Government))
			elseif metric == "Investment GDP" then
				table.insert(rowData, comma(yearData.iGDP_Investment))
			elseif metric == "Trade GDP" then
				table.insert(rowData, comma(yearData.iGDP_Trade))
			elseif metric == "Unemployment" then
				table.insert(rowData, percent(yearData.fUnemploymentRate, 1))
			elseif metric == "Total Revenue" then
				table.insert(rowData, currency(yearData.iRevenue_Total))
			elseif metric == "Average Tax" then
				table.insert(rowData, percent(yearData.fTaxRate_Average, 0))
			elseif metric == "Income Revenue" then
				table.insert(rowData, currency(yearData.iRevenue_Income))
			elseif metric == "Income Tax" then
				table.insert(rowData, percent(yearData.fTaxRate_Income, 0))
			elseif metric == "Business Revenue" then
				table.insert(rowData, currency(yearData.iRevenue_Business))
			elseif metric == "Business Tax" then
				table.insert(rowData, percent(yearData.fTaxRate_Business, 0))
			elseif metric == "Import Revenue" then
				table.insert(rowData, currency(yearData.iRevenue_Imports))
			elseif metric == "Import Tax" then
				table.insert(rowData, percent(yearData.fTaxRate_Imports, 0))
			elseif metric == "Export Revenue" then
				table.insert(rowData, currency(yearData.iRevenue_Exports))
			elseif metric == "Export Tax" then
				table.insert(rowData, percent(yearData.fTaxRate_Exports, 0))
			elseif metric == "Total Expense" then
				table.insert(rowData, currency(yearData.iExpense_Total))
			elseif metric == "Policy Expense" then
				table.insert(rowData, currency(yearData.iExpense_Policy))
			elseif metric == "Military Expense" then
				table.insert(rowData, currency(yearData.iExpense_Military))
			elseif metric == "Building Expense" then
				table.insert(rowData, currency(yearData.iExpense_Building))
			elseif metric == "City Expense" then
				table.insert(rowData, currency(yearData.iExpense_Cities))
			elseif metric == "Culture Expense" then
				table.insert(rowData, culture(yearData.iExpense_Political))
			elseif metric == "Total Debt" then
				table.insert(rowData, currency(yearData.iDebt_Total))
			elseif metric == "Debt Payment" then
				table.insert(rowData, currency(GetDebtPayment(yearData.iDebt_Payment)))
			elseif metric == "Interest Rate" then
				table.insert(rowData, percent(yearData.fInterest_Rate, 1))
			end
		end
		table.insert(summaryValues, {metric, rowData})
	end

	for _, data in ipairs(summaryValues) do
		CreateMetricRow(g_OurSummaryManager, data[1], data[2])
	end

	Controls.OurSummaryStack:CalculateSize()
	Controls.OurSummaryStack:ReprocessAnchoring()
	Controls.OurSummaryScrollPanel:CalculateInternalSize()

	Controls.OurSummaryScrollPanel:SetHide(false)
	Controls.InfoStack:SetHide(false)
	Controls.NoEconomy:SetHide(true)
else
	Controls.OurSummaryScrollPanel:SetHide(true)
	Controls.InfoStack:SetHide(true)
	Controls.NoEconomy:SetHide(false)
end
g_Tabs["OurEconomy"].RefreshContent = RefreshOurEconomy
--------------------------------------------------------------------
function RefreshWorldEconomy()
	g_WorldEconomyManager:ResetInstances()

	if g_World then
		local iActivePlayer = Game.GetActivePlayer()
		local pActiveTeam = Teams[Game.GetActiveTeam()]
		local strGrowth = GetGrowthString(gT.g_GlobalEconomicIndex or 0, true)
		Controls.WorldGrowthIndex:SetText( locale("TXT_KEY_POPUP_FA_ECON_OUR_INDEX", strGrowth) )

		for i,v in ipairs(g_World) do
			local playerID = v.iPlayerID
			local pPlayer = Players[playerID]
			local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
			if civInfo then
				local worldEntry = g_WorldEconomyManager:GetInstance()
				
				local bIsHuman = (iActivePlayer == playerID)
				local bHasEmbassy = false

				if IsExpansion then
					bHasEmbassy = pActiveTeam:HasEmbassyAtTeam(pPlayer:GetTeam())
				else
					bHasEmbassy = pActiveTeam:IsHasMet(pPlayer:GetTeam())
				end

				local bDisplayDetails = bIsHuman or bHasEmbassy

				IconHookup(civInfo.PortraitIndex, 32, civInfo.IconAtlas, worldEntry.CivIcon)
				worldEntry.CivIcon:SetToolTipString( locale(civInfo.ShortDescription) )
				
				local strCivName = locale(civInfo.Description)
				if bIsHuman then
					strCivName = "[COLOR_POSITIVE_TEXT]"..strCivName.."[ENDCOLOR]"
				else
					worldEntry.CivDialog:SetVoid1( playerID )
					worldEntry.CivDialog:RegisterCallback( Mouse.eLClick, LeaderSelected )
				end
				
				worldEntry.CivName:SetText(locale( strCivName) )
				worldEntry.CivGDP:SetText( comma(v.iGDP_Total) )

				if bDisplayDetails then
					local strGrowth = percent(v.fGDP_Growth, 1)
					if (v.iTurn <= v.iEventTurn) then
						strGrowth = "[COLOR_FONT_RED]"..strGrowth.."[ENDCOLOR]"
						worldEntry.CivGrowth:SetToolTipString( strDepressionTT )
					end
					worldEntry.CivGrowth:SetText( strGrowth )
					
					local iPerCapita = round((v.iGDP_Total/v.iPopulation), 1)
					iPerCapita = ((iPerCapita ~= nil) and (iPerCapita > 0)) and iPerCapita or 0
					worldEntry.CivPerCapita:SetText( currency(iPerCapita) )
					worldEntry.CivUnemployment:SetText( percent(v.fUnemploymentRate, 1) )
					worldEntry.CivTaxRate:SetText( percent(v.fTaxRate_Average, 0) )
					worldEntry.CivBudget:SetText( currency(v.iRevenue_Total + v.iExpense_Total) )
					worldEntry.CivDebt:SetText( currency(v.iDebt_Total) )

					local strPolicy = GetPolicyString(v.iPolicyID)
					worldEntry.CivPolicy:SetText( strPolicy )
				else
					worldEntry.CivName:SetToolTipString( strUnknownHelp )
					worldEntry.CivGrowth:SetText( strUknown )
					worldEntry.CivPerCapita:SetText( strUknown )
					worldEntry.CivUnemployment:SetText( strUknown )
					worldEntry.CivTaxRate:SetText( strUknown )
					worldEntry.CivBudget:SetText( strUknown )
					worldEntry.CivDebt:SetText( strUknown )
					worldEntry.CivPolicy:SetText( strUknown )
				end
			end
		end
		
		Controls.WorldEconomyStack:CalculateSize()
		Controls.WorldEconomyStack:ReprocessAnchoring()
		Controls.WorldEconomiesScrollPanel:CalculateInternalSize()

		Controls.WorldEconomiesScrollPanel:SetHide(false)
		Controls.NoWorldEconomy:SetHide(true)
	else
		Controls.WorldEconomiesScrollPanel:SetHide(true)
		Controls.NoWorldEconomy:SetHide(false)
	end
end
g_Tabs["WorldEconomy"].RefreshContent = RefreshWorldEconomy
--------------------------------------------------------------------
function RefreshHistory()
	g_HistoricManager:ResetInstances()

	if g_History then
		
		for i,v in ipairs(g_History) do
			local historyEntry = g_HistoricManager:GetInstance();
			local iPerCapita = round((v.iGDP_Total/v.iPopulation), 1)
			iPerCapita = ((iPerCapita ~= nil) and (iPerCapita > 0)) and iPerCapita or 0

			historyEntry.HistoryYear:SetText( date(v.iYear) )
			historyEntry.HistoryGDP:SetText( comma(v.iGDP_Total) )

			local strGrowth = percent(v.fGDP_Growth, 1)
			if (v.iTurn <= v.iEventTurn) then
				strGrowth = "[COLOR_FONT_RED]"..strGrowth.."[ENDCOLOR]"
				historyEntry.HistoryGrowth:SetToolTipString( strDepressionTT )
			end

			historyEntry.HistoryGrowth:SetText( strGrowth )
			historyEntry.HistoryPerCapita:SetText( currency(iPerCapita) )
			historyEntry.HistoryUnemployment:SetText( percent(v.fUnemploymentRate, 1) )
			historyEntry.HistoryBudget:SetText( currency(v.iRevenue_Total + v.iExpense_Total) )
			historyEntry.HistoryTaxRate:SetText( percent(v.fTaxRate_Average, 0) )
			historyEntry.HistoryMarketRate:SetText( percent(v.fMarketRate or 0) )
			historyEntry.HistoryDebt:SetText( currency(v.iDebt_Total) )
			
			local policyInfo = GameInfo.Econ_Policies[v.iPolicyID]
			local strPolicy = ""
			if policyInfo then
				strPolicy = locale(policyInfo.Description)
			else
				strPolicy = locale("TXT_KEY_POPUP_FA_ECON_POLICY_NONE")
			end
			historyEntry.HistoryPolicy:SetText( strPolicy )
			
		end
		
		Controls.HistoricStack:CalculateSize()
		Controls.HistoricStack:ReprocessAnchoring()
		Controls.HistoricScrollPanel:CalculateInternalSize()

		Controls.HistoricScrollPanel:SetHide(false)
		Controls.NoHistoric:SetHide(true)
		
	else
		Controls.HistoricScrollPanel:SetHide(true)
		Controls.NoHistoric:SetHide(false)
	end
end
g_Tabs["EconomicHistory"].RefreshContent = RefreshHistory
--------------------------------------------------------------------
function LeaderSelected( playerID )
	local player = Players[playerID]
	if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
		return
	end
	
    if( player:IsHuman() ) then
        Events.OpenPlayerDealScreenEvent( playerID )
    else
        UI.SetRepeatActionPlayer(playerID)
        UI.ChangeStartDiploRepeatCount(1)
    	player:DoBeginDiploWithHuman()
	end
end
--------------------------------------------------------------------
function RefreshAll()
	SaveData()
	UpdateData()
	RefreshOurEconomy()
	RefreshWorldEconomy()
	RefreshHistory()
	LuaEvents.Economics_UpdateTopPanel()
end
--------------------------------------------------------------------
function SaveData()
	LuaEvents.Economics_UpdateFromArchive(Game.GetActivePlayer())
end
--------------------------------------------------------------------
function UpdateData()
	LuaEvents.Economics_UpdateToArchive()
	
	local iTurn = Game.GetGameTurn()
	local iActivePlayer = Game.GetActivePlayer()
	local iActiveTeam = Game.GetActiveTeam()
	local pTeam = Teams[iActiveTeam]
	local econData = gT.g_EconData
	local GetWorldEconomy = function() 
		local t = {}
		for i = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
			local archive = econData[i]
			if archive and (archive[iTurn] ~= nil) then
				local player = Players[i]
				if player and player:IsAlive() then
					local iTeamID = player:GetTeam()
					if pTeam:IsHasMet(iTeamID) or (iTeamID == iActiveTeam) then
						insert(t, archive[iTurn])
					end
				end
			end
		end
		sort(t, function(x,y) return (x.iGDP_Total > y.iGDP_Total) end)
		return t
	end
	local GetEconomicHistory = function()
		local t = {}
		local archive = econData[iActivePlayer]
		if archive then
			for _,archiveTurn in pairs(archive) do
				insert(t, archiveTurn)
			end
			sort(t, function(x,y) return (x.iYear > y.iYear) end)
		end
		return t
	end
	local GetEconomicSnapshot = function() 
		local t = {}
		local archive = econData[iActivePlayer]
		if archive then
			for i = iTurn, iTurn-2, -1 do
				local archiveTurn = archive[i]
				if (archiveTurn ~= nil) then
					insert(t, archiveTurn)
				end
			end
			sort(t, function(x,y) return (x.iYear > y.iYear) end)
		end
		return t
	end

	g_World = GetWorldEconomy()
	g_History = GetEconomicHistory()
	g_Economy = GetEconomicSnapshot()
	g_Current = g_Economy[1]

	iSelectedPolicy = g_Current.iPolicyID
end
--------------------------------------------------------------------
function GetGrowthString(iGrowth, bIsGlobal)
	local strGrowth = ""
	if not bIsGlobal and (g_Current.iTurn <= g_Current.iEventTurn) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_DEPRESSION_TT:upper}")
	elseif (iGrowth == GROWTH_STABLE) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_STABLE_TT:upper}")
	elseif (iGrowth > GROWTH_BOOM) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_BOOM_TT:upper}")
	elseif (iGrowth > GROWTH_EXPANSION) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_EXPANSION_TT:upper}")
	elseif (iGrowth > GROWTH_STAGNATION) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_STAGNATION_TT:upper}")
	elseif (iGrowth > GROWTH_RECESSION) then
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_RECESSION_TT:upper}")
	else
		strGrowth = locale("{TXT_KEY_FA_ECON_POPUP_PANIC_TT:upper}")
	end
	return strGrowth
end
--------------------------------------------------------------------
function GetPolicyString(iPolicyID)
	local strPolicy = ""
	local policyInfo = GameInfo.Econ_Policies[iPolicyID]
	if policyInfo then
		strPolicy = locale(policyInfo.Description)
	else
		strPolicy = locale("TXT_KEY_POPUP_FA_ECON_POLICY_NONE")
	end
	return strPolicy
end
--------------------------------------------------------------------
function GetPolicyToolTip(iPolicyID, bDisabled)
	local strTT = ""
	local tooltips = {}
	local policyInfo = GameInfo.Econ_Policies[iPolicyID]
	local SetColor = function(iValue, bInverse)
		local str = ""
		if (iValue > 0) then
			str = "+"..tostring(iValue)
		else
			str = tostring(iValue)
		end
		local bWarning = (iValue < 0)
		if bInverse then
			bWarning = not bWarning
		end
		if bWarning then
			str = "[COLOR_WARNING_TEXT]"..str.."[ENDCOLOR]"
		else
			str = "[COLOR_POSITIVE_TEXT]"..str.."[ENDCOLOR]"
		end
		return str
	end

	if (policyInfo.UnemploymentRate ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_UNEMPLOYMENT_TT", SetColor(policyInfo.UnemploymentRate, true)))
	end
	if (policyInfo.InterestRate ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_INTEREST_RATE_TT", policyInfo.InterestRate))
	end
	if (policyInfo.DebtLimit ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_DEBT_LIMIT_TT", SetColor(policyInfo.DebtLimit)))
	end
	if (policyInfo.DebtPayment ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_DEBT_PAYMENT_TT", SetColor(policyInfo.DebtPayment, true)))
	end
	if (policyInfo.ConsumerGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_CONSUMER_GDP_TT", SetColor(policyInfo.ConsumerGDP)))
	end
	if (policyInfo.ConsumerHappiness ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_CONSUMER_HAPPINESS_TT", SetColor(policyInfo.ConsumerHappiness)))
	end
	if (policyInfo.GovernmentGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_GOVERNMENT_GDP_TT", SetColor(policyInfo.GovernmentGDP)))
	end
	if (policyInfo.GovToConsumer ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_GOV_TO_CONSUMER_TT", SetColor(policyInfo.GovToConsumer)))
	end
	if (policyInfo.GovToInvestment ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_GOV_TO_INVESTMENT_TT", SetColor(policyInfo.GovToInvestment)))
	end
	if (policyInfo.ConsumerToInvestment ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_CONSUMER_TO_INVESTMENT_TT", SetColor(policyInfo.ConsumerToInvestment)))
	end
	if (policyInfo.InvestmentGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_INVESTMENT_GDP_TT", SetColor(policyInfo.InvestmentGDP)))
	end
	if (policyInfo.SpecialistInvest ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_SPECIALIST_INVEST_TT", SetColor(policyInfo.SpecialistInvest)))
	end
	if (policyInfo.ImportGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_IMPORT_GDP_TT", SetColor(policyInfo.ImportGDP)))
	end
	if (policyInfo.ExportGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_EXPORT_GDP_TT", SetColor(policyInfo.ExportGDP)))
	end
	if (policyInfo.IncomeRevenue ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_INCOME_REVENUE_TT", SetColor(policyInfo.IncomeRevenue)))
	end
	if (policyInfo.BusinessRevenue ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_BUSINESS_REVENUE_TT", SetColor(policyInfo.BusinessRevenue)))
	end
	if (policyInfo.TradeRevenue ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_TRADE_REVENUE_TT", SetColor(policyInfo.TradeRevenue)))
	end
	if (policyInfo.PolicyExpense ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_POLICIES_EXPENSE_TT", SetColor(policyInfo.PolicyExpense, true)))
	end
	if (policyInfo.GovernmentExpense ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_GOVERNMENT_EXPENSE_TT", SetColor(policyInfo.GovernmentExpense, true)))
	end
	if (policyInfo.MilitaryExpense ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_MILITARY_EXPENSE_TT", SetColor(policyInfo.MilitaryExpense, true)))
	end
	if (policyInfo.CityExpense ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_CITY_EXPENSE_TT", SetColor(policyInfo.CityExpense, true)))
	end
	if (policyInfo.PoliticalExpense ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_POLITICAL_EXPENSE_TT", SetColor(policyInfo.PoliticalExpense, true)))
	end
	if (policyInfo.IncomeTax ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_INCOME_TAX_TT", policyInfo.IncomeTax))
	end
	if (policyInfo.BusinessTax ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_BUSINESS_TAX_TT", policyInfo.BusinessTax))
	end
	if (policyInfo.TradeTax ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_TRADE_TAX_TT", policyInfo.TradeTax))
	end
	if policyInfo.ImprovementTax then
		local improvementInfo = GameInfo.Improvements[policyInfo.ImprovementTax]
		if improvementInfo then
			insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_IMPROVEMENT_TAX_TT", improvementInfo.Description, SetColor(decimalshift(policyInfo.TaxPerImproved, -2))))
		end
	end
	if (policyInfo.OpenBorderGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_OPEN_BORDER_GDP_TT", SetColor(policyInfo.OpenBorderGDP)))
	end
	if (policyInfo.EnemyGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_ENEMY_GDP_TT", SetColor(policyInfo.EnemyGDP)))
	end
	if (policyInfo.AlliedMinorGDP ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_ALLIED_GDP_TT", SetColor(policyInfo.AlliedMinorGDP)))
	end
	if policyInfo.NoTradeDeficit then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_NO_TRADE_DEFICIT_TT"))
	end
	if policyInfo.NoTaxPenalty then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_NO_TAX_PENALTY_TT"))
	end
	if policyInfo.BullMarket then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_BULL_MARKET_TT"))
	end
	if policyInfo.Stability then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_STABILITY_TT"))
	end
	if (policyInfo.DepressionChance ~= 0) then
		insert(tooltips, "[ICON_BULLET]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_DEPRESSION_CHANCE_TT", SetColor(policyInfo.DepressionChance, true)))
	end
	if bDisabled then
		local eraInfo = GameInfo.Eras[policyInfo.EraReq]
		if eraInfo then
			insert(tooltips, "[NEWLINE]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_DISABLED_ERA_TT", eraInfo.Description))
		else
			insert(tooltips, "[NEWLINE]" .. locale("TXT_KEY_POPUP_FA_ECON_POLICY_DISABLED_TOTAL_TT"))
		end
	end
	if (#tooltips > 0) then
		strTT = concat(tooltips, "[NEWLINE]")
	end
	return strTT
end
--------------------------------------------------------------------
function GetDebtPayment(iPayment)
	local iPayment = iPayment
	local policyInfo = GameInfo.Econ_Policies[iSelectedPolicy]
	if policyInfo and (policyInfo.DebtPayment ~= 0) then
		iPayment = round(iPayment + (iPayment*(policyInfo.DebtPayment/100)))
	end
	return negative(iPayment)
end
--------------------------------------------------------------------
function WarningText(str)
	return "[COLOR_WARNING_TEXT]"..str.."[ENDCOLOR]"
end
--------------------------------------------------------------------
function ClosePopups()
	bPopup = false
	Controls.SelectPolicies:SetHide(true)
	Controls.ChangeTaxes:SetHide(true)
	Controls.IssueDebt:SetHide(true)
	Controls.BGBlock:SetHide(false)
end
--------------------------------------------------------------------
function OnClose()
	ClosePopups()
	ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)
--------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )      
    if(uiMsg == KeyEvents.KeyDown) then
        if (wParam == Keys.VK_ESCAPE) then
			if bPopup then 
				ClosePopups()
			else
				OnClose()
			end
			return true
		elseif wParam == Keys.C and UIManager:GetControl() then
			OnClose()
			return true
        end
    end
end
ContextPtr:SetInputHandler( InputHandler )
--------------------------------------------------------------------
function ShowHideHandler(bIsHide, bInitState)
	if (not bInitState and not bIsHide) then
		TabSelect("OurEconomy")
	end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)
--------------------------------------------------------------------
function OnEconPopup()
	UpdateData()
	ContextPtr:SetHide(false)
end
LuaEvents.FA_Economics_EconOverview.Add( OnEconPopup )
--------------------------------------------------------------------
function OnAdditionalInformationDropdownGatherEntries(entries)
    table.insert(entries, {text = Locale.ConvertTextKey("TXT_KEY_DIPLO_CORNER_HOOK_FA_ECON_ADDINS"), call = OnEconPopup})
end
--------------------------------------------------------------------
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()
--------------------------------------------------------------------
ContextPtr:SetHide(true)
--------------------------------------------------------------------
function Initialize()
	TabSelect("OurEconomy")
	TaxScreen("Init")
	DebtScreen("Init")
	PolicyScreen("Init")
end
--------------------------------------------------------------------
 Initialize()
