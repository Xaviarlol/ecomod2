-- FA_Economics
-- Author: FramedArchitecture
-- DateCreated: 5/5/2015
--------------------------------------------------------------
MapModData.gT = MapModData.gT or {}
gT = MapModData.gT
--------------------------------------------------------------
include("Econ_Global.lua")
include("Econ_Math.lua")
--------------------------------------------------------------
local IsBNW = IsBNW
local IsExpansion = IsBNW or IsGNK
local GAME_MAX_ERAS = GAME_MAX_ERAS
local BASE_DEBT_TERM = BASE_DEBT_TERM
local BASE_UNEMPLOYMENT_RATE = BASE_UNEMPLOYMENT_RATE
local BASE_INTEREST_RATE = BASE_INTEREST_RATE
local MAX_INTEREST_RATE = MAX_INTEREST_RATE
local MIN_INTEREST_RATE = MIN_INTEREST_RATE
local DEBT_RATIO_THRESHOLD = DEBT_RATIO_THRESHOLD
local BASE_TAX_RATE = BASE_TAX_RATE
local BASE_EXPENSE_RATE = BASE_EXPENSE_RATE
local BASE_TAX_ERA = BASE_TAX_ERA
local BASE_DEBT_ERA = BASE_DEBT_ERA
local BASE_MARKETS_ERA = BASE_MARKETS_ERA
local EXPANDED_TAX_ERA = EXPANDED_TAX_ERA
local BASE_EVENT_ERA = BASE_EVENT_ERA
local BRANCH_COMMERCE = BRANCH_COMMERCE
local BRANCH_FREEDOM = BRANCH_FREEDOM
local BRANCH_ORDER = BRANCH_ORDER
local BRANCH_AUTOCRACY = BRANCH_AUTOCRACY
local YIELD_PRODUCTION = YIELD_PRODUCTION
local YIELD_GOLD = YIELD_GOLD
local PRODUCTION_MOD = PRODUCTION_MOD
local PURCHASE_DIVISOR = PURCHASE_DIVISOR
local TRADE_MOD = TRADE_MOD
local POLITICAL_CAPITAL_MOD = POLITICAL_CAPITAL_MOD
local BASE_REVENUE_DIVISOR = BASE_REVENUE_DIVISOR
local POPULATION_MULTIPLIER = POPULATION_MULTIPLIER
local POPULATION_CITY_MULTIPLIER = POPULATION_CITY_MULTIPLIER
local BASE_WORLD_SIZE = BASE_WORLD_SIZE
local MAX_BORDERS_BONUS = MAX_BORDERS_BONUS
local MAX_TAX_RATE = MAX_TAX_RATE
local MIN_TAX_RATE = MIN_TAX_RATE
local AI_ACTION_THRESHOLD = AI_ACTION_THRESHOLD
local AI_TAX_DECREMENT = AI_TAX_DECREMENT
local TAX_GDP_THRESHOLD = TAX_GDP_THRESHOLD
local AI_BASE_TAX_INCREMENTS = AI_BASE_TAX_INCREMENTS
local AI_BASE_DEBT_RATIO = AI_BASE_DEBT_RATIO
local AI_BASE_DEBT_RESISTANCE = AI_BASE_DEBT_RESISTANCE
local AI_POLITICAL_THRESHOLD = AI_POLITICAL_THRESHOLD
local AI_POLICY_RESISTANCE = AI_POLICY_RESISTANCE
local AI_POLICY_WEIGHT = AI_POLICY_WEIGHT
local AI_RATE_THRESHOLD = AI_RATE_THRESHOLD
local AI_DEBT_TAX_RATIO = AI_DEBT_TAX_RATIO
local AI_MIN_DEBT_PAYMENT = AI_MIN_DEBT_PAYMENT
local GROWTH_BOOM = GROWTH_BOOM
local GROWTH_EXPANSION = GROWTH_EXPANSION
local GROWTH_STABLE = GROWTH_STABLE
local GROWTH_STAGNATION = GROWTH_STAGNATION
local GROWTH_RECESSION = GROWTH_RECESSION
local GROWTH_BUST = GROWTH_BUST
local BASE_EVENT_TURNS = BASE_EVENT_TURNS
local BASE_EVENT_UNEMPLOYED = BASE_EVENT_UNEMPLOYED
local BASE_EVENT_CHANCE = BASE_EVENT_CHANCE
local MIN_EVENT_MALUS = MIN_EVENT_MALUS
local MED_EVENT_MALUS = MED_EVENT_MALUS
local MAX_EVENT_MALUS = MAX_EVENT_MALUS
local BULL_MARKET = BULL_MARKET
local BEAR_MARKET = BEAR_MARKET
local POLICY_COOLDOWN = POLICY_COOLDOWN
--------------------------------------------------------------
local print = gT.bDisablePrint and function() end or print
local insert = table.insert
local remove = table.remove
local sort = table.sort
local currentEra = 0
--------------------------------------------------------------
g_EconPlayers = {}
g_EconClass = {
	--------------------------------------------------------------
    m_PlayerID		= -1,
	m_Player		= nil,
	m_TeamID		= -1,
	m_bIsAIPlayer	= false,
	m_bIsAIMinor	= false,
	
	m_iPopulation	= 0,
	m_iTurn			= 0,
	m_iYear			= 0,
	m_iCurrentEra	= 0,

	m_iGDP_Total		= 0,
	m_iGDP_Consumer		= 0,
	m_iGDP_Government	= 0,
	m_iGDP_Investment	= 0,
	m_iGDP_Trade		= 0,
	m_iGDP_Export		= 0,
	m_iGDP_Import		= 0,
	m_fGDP_Growth		= 0.00,

	m_bEnableMarkets	= false,
	m_fMarketRate		= 0.00,

	--caches for dynamic changes
	m_iGovern_Cache	= 0,
	m_iInvest_Cache	= 0,
	
	m_fUnemploymentRate	= BASE_UNEMPLOYMENT_RATE,

	m_bEnableBasicTax	= false,
	m_bEnableExpandTax	= false,
	m_fTaxRate_Average	= BASE_TAX_RATE,
	m_fTaxRate_Income	= BASE_TAX_RATE,
	m_fTaxRate_Business = BASE_TAX_RATE,
	m_fTaxRate_Imports	= BASE_TAX_RATE,
	m_fTaxRate_Exports	= BASE_TAX_RATE,
	
	m_iRevenue_Total	= 0,
	m_iRevenue_Income	= 0,
	m_iRevenue_Business = 0,
	m_iRevenue_Exports	= 0,
	m_iRevenue_Imports	= 0,
	
	m_iExpense_Total	 = 0,
	m_iExpense_Policy	 = 0,
	m_iExpense_Military	 = 0,
	m_iExpense_Building  = 0,
	m_iExpense_Cities	 = 0,
	m_iPolitical_Capital = 0,
	
	m_bEnableDebt		= false,
	m_fInterest_Rate	= BASE_INTEREST_RATE,
	m_iDebt_Total		= 0,
	m_iDebt_Payment		= 0,

	m_bEnableEvents		= false,
	m_iEventTurn		= -1,
	m_fEventMalus		= 0.00,
	
	m_iPolicyID		= -1,
	m_iPolicyTurn	= -1,
	
	--------------------------------------------------------------
	-- CONSTRUCTOR
	--------------------------------------------------------------
    new = function( self, playerID )
		local o = {}
		setmetatable( o, self )
		self.__index = self
		
		if( playerID ~= -1 ) then
			o.m_PlayerID	= playerID
			o.m_Player		= Players[o.m_PlayerID]
			o.m_TeamID		= o.m_Player:GetTeam()
			o.m_bIsAIPlayer = not o.m_Player:IsHuman()
			o.m_bIsAIMinor	= o.m_Player:IsMinorCiv()

			o.m_iPopulation	= (o.m_Player:GetRealPopulation() * POPULATION_MULTIPLIER)
			o.m_iTurn		= Game.GetGameTurn()
			o.m_iYear		= Game.GetGameTurnYear()
			o.m_iCurrentEra = o.m_Player:GetCurrentEra()

			o.m_bEnableMarkets	 = (BASE_MARKETS_ERA <= o.m_iCurrentEra)
			o.m_bEnableBasicTax	 = (BASE_TAX_ERA <= o.m_iCurrentEra)
			o.m_bEnableExpandTax = (EXPANDED_TAX_ERA <= o.m_iCurrentEra)
			o.m_bEnableDebt		 = (BASE_DEBT_ERA <= o.m_iCurrentEra)
			o.m_bEnableEvents	 = (BASE_EVENT_ERA <= o.m_iCurrentEra)
			
			local bLoaded = o:RestoreFromArchive(o.m_iTurn)
			if not bLoaded then
				o:UpdateGlobal()
			end
		end

		return o
    end,
    --------------------------------------------------------------
    destroy = function( self )
		g_EconPlayers[self.m_PlayerID] = nil
    end,
	--------------------------------------------------------------
	-- SAVE
	--------------------------------------------------------------
    Archive = function( self )
		if (gT.g_EconData[self.m_PlayerID] == nil) then
			gT.g_EconData[self.m_PlayerID] = {}
		end
		self:UpdateTurn()
		gT.g_EconData[self.m_PlayerID][self.m_iTurn] = {
			iPlayerID			 = self.m_PlayerID,
			iPopulation			 = self.m_iPopulation,			
			iTurn				 = self.m_iTurn,			
			iYear				 = self.m_iYear,
			iCurrentEra			 = self.m_iCurrentEra,	
			iGDP_Total			 = self.m_iGDP_Total,			
			iGDP_Consumer		 = self.m_iGDP_Consumer,			
			iGDP_Government		 = self.m_iGDP_Government,		
			iGDP_Investment		 = self.m_iGDP_Investment,		
			iGDP_Trade			 = self.m_iGDP_Trade,		
			iGDP_Export			 = self.m_iGDP_Export,
			iGDP_Import			 = self.m_iGDP_Import,
			fGDP_Growth			 = self.m_fGDP_Growth,
			bEnableMarkets		 = self.m_bEnableMarkets,
			fMarketRate			 = self.m_fMarketRate,
			iGovern_Cache		 = self.m_iGovern_Cache,			
			iInvest_Cache		 = self.m_iInvest_Cache,	
			fUnemploymentRate	 = self.m_fUnemploymentRate,		
			bEnableBasicTax		 = self.m_bEnableBasicTax,		
			bEnableExpandTax	 = self.m_bEnableExpandTax,		
			fTaxRate_Average	 = self.m_fTaxRate_Average,		
			fTaxRate_Income		 = self.m_fTaxRate_Income,		
			fTaxRate_Business	 = self.m_fTaxRate_Business,		
			fTaxRate_Imports	 = self.m_fTaxRate_Imports,		
			fTaxRate_Exports	 = self.m_fTaxRate_Exports,		
			iRevenue_Total		 = self.m_iRevenue_Total,		
			iRevenue_Income		 = self.m_iRevenue_Income,		
			iRevenue_Business	 = self.m_iRevenue_Business,		
			iRevenue_Exports	 = self.m_iRevenue_Exports,		
			iRevenue_Imports	 = self.m_iRevenue_Imports,
			iExpense_Total		 = self.m_iExpense_Total,	
			iExpense_Policy		 = self.m_iExpense_Policy,	
			iExpense_Military	 = self.m_iExpense_Military,	
			iExpense_Building	 = self.m_iExpense_Building,
			iExpense_Cities		 = self.m_iExpense_Cities,
			iExpense_Political	 = self.m_iPolitical_Capital,
			bEnableDebt			 = self.m_bEnableDebt,			
			fInterest_Rate		 = self.m_fInterest_Rate,		
			iDebt_Total			 = self.m_iDebt_Total,			
			iDebt_Payment		 = self.m_iDebt_Payment,
			bEnableEvents		 = self.m_bEnableEvents,
			iEventTurn			 = self.m_iEventTurn,
			fEventMalus			 = self.m_fEventMalus,	
			iPolicyID			 = self.m_iPolicyID,
			iPolicyTurn			 = self.m_iPolicyTurn,		
		}
    end,
	--------------------------------------------------------------
    RestoreFromArchive = function( self, iTurn )
		if (gT.g_EconData[self.m_PlayerID] == nil) then
			gT.g_EconData[self.m_PlayerID] = {}
		end

		local archive
		if gT.g_EconData[self.m_PlayerID][iTurn] then
			archive = gT.g_EconData[self.m_PlayerID][iTurn]
		elseif gT.g_EconData[self.m_PlayerID][iTurn-1] then
			archive = gT.g_EconData[self.m_PlayerID][iTurn-1]
		end

		if archive then
			self.m_PlayerID				= archive.iPlayerID
			self.m_iPopulation			= archive.iPopulation	
			self.m_iTurn				= archive.iTurn			
			self.m_iYear				= archive.iYear			
			self.m_iCurrentEra			= archive.iCurrentEra	
			self.m_iGDP_Total			= archive.iGDP_Total		
			self.m_iGDP_Consumer		= archive.iGDP_Consumer		
			self.m_iGDP_Government		= archive.iGDP_Government	
			self.m_iGDP_Investment		= archive.iGDP_Investment	
			self.m_iGDP_Trade			= archive.iGDP_Trade
			self.m_iGDP_Export			= archive.iGDP_Export
			self.m_iGDP_Import			= archive.iGDP_Import
			self.m_fGDP_Growth			= archive.fGDP_Growth
			self.m_bEnableMarkets		= archive.bEnableMarkets
			self.m_fMarketRate			= archive.fMarketRate	
			self.m_iGovern_Cache		= archive.iGovern_Cache			
			self.m_iInvest_Cache		= archive.iInvest_Cache	
			self.m_fUnemploymentRate	= archive.fUnemploymentRate
			self.m_bEnableBasicTax		= archive.bEnableBasicTax	
			self.m_bEnableExpandTax		= archive.bEnableExpandTax	
			self.m_fTaxRate_Average		= archive.fTaxRate_Average	
			self.m_fTaxRate_Income		= archive.fTaxRate_Income	
			self.m_fTaxRate_Business	= archive.fTaxRate_Business
			self.m_fTaxRate_Imports		= archive.fTaxRate_Imports	
			self.m_fTaxRate_Exports		= archive.fTaxRate_Exports	
			self.m_iRevenue_Total		= archive.iRevenue_Total	
			self.m_iRevenue_Income		= archive.iRevenue_Income	
			self.m_iRevenue_Business	= archive.iRevenue_Business
			self.m_iRevenue_Exports		= archive.iRevenue_Exports	
			self.m_iRevenue_Imports		= archive.iRevenue_Imports
			self.m_iExpense_Total		= archive.iExpense_Total	
			self.m_iExpense_Policy		= archive.iExpense_Policy	
			self.m_iExpense_Military	= archive.iExpense_Military	
			self.m_iExpense_Building	= archive.iExpense_Building
			self.m_iExpense_Cities		= archive.iExpense_Cities
			self.m_iPolitical_Capital   = archive.iExpense_Political
			self.m_bEnableDebt			= archive.bEnableDebt		
			self.m_fInterest_Rate		= archive.fInterest_Rate	
			self.m_iDebt_Total			= archive.iDebt_Total		
			self.m_iDebt_Payment		= archive.iDebt_Payment
			self.m_bEnableEvents		= archive.bEnableEvents
			self.m_iEventTurn			= archive.iEventTurn
			self.m_fEventMalus			= archive.fEventMalus
			self.m_iPolicyID			= archive.iPolicyID
			self.m_iPolicyTurn			= archive.iPolicyTurn
		end
		return (archive ~= nil)
    end,
	--------------------------------------------------------------
    GetArchiveTurn = function( self, iTurn )
		local archive = gT.g_EconData[self.m_PlayerID]
		if (archive[iTurn] ~= nil) then
			return archive[iTurn]
		end
		return nil
    end,
	--------------------------------------------------------------
	-- AI
	--------------------------------------------------------------
    AIDoPolicy = function( self )
		if not self:IsAIPlayer() then
			return
		end
		if not self:CanChangePolicy() then
			return
		end

		local iPolicyID = self.m_iPolicyID
		
		--already have a policy, consider sticking with it
		if (iPolicyID ~= -1) and (random() < AI_POLICY_RESISTANCE) then
			return
		end

		local options = {}
		local iCurrentEra = self:GetCurrentEraID()
		
		for row in GameInfo.Econ_Policies() do
			local eraInfo = GameInfo.Eras[row.EraReq]
			local iReqEra = eraInfo and eraInfo.ID or GAME_MAX_ERAS
			if (iReqEra == iCurrentEra-1) or (iReqEra == iCurrentEra) then
				insert(options, row)
			end
		end

		if (#options == 0) then
			return
		end

		if (#options == 1) then
			iPolicyID = options[1].ID

		elseif (#options > 1) then
			local iGoldTotal = self.m_Player:GetGold()
			local iGoldIncomeTotal = self.m_Player:CalculateGoldRate()
			
			local iFlavorExpand = self:GetLeaderFlavor("FLAVOR_EXPANSION")
			local iFlavorWarmonger = average({self:GetLeaderFlavor("MAJOR_CIV_APPROACH_WAR"), self:GetLeaderFlavor("MINOR_CIV_APPROACH_CONQUEST")})
			local iFlavorCultured = average({self:GetLeaderFlavor("FLAVOR_CULTURE"), self:GetLeaderFlavor("FLAVOR_HAPPINESS")})
			local iFlavorExpansive = average({iFlavorExpand, self:GetLeaderFlavor("FLAVOR_SCIENCE")})
			local iFlavorDiplomat =  average({self:GetLeaderFlavor("MINOR_CIV_APPROACH_PROTECTIVE"), self:GetLeaderFlavor("FLAVOR_DIPLOMACY")})
			local iFlavorTrader = average({self:GetLeaderFlavor("FLAVOR_GOLD"), self:GetLeaderFlavor("FLAVOR_GROWTH")})
			local iFlavorProductive = average({self:GetLeaderFlavor("FLAVOR_PRODUCTION"), self:GetLeaderFlavor("FLAVOR_INFRASTRUCTURE")})
			
			local fIncomeTax, fBusinessTax, fImportTax, fExportTax = self:GetSectorTaxRates()
			local fInterestRate = self:GetInterestRate()
			local iFiscalBalance = self:GetFiscalBalance()
			local iGovernmentGDP = self:GetGovernmentGDP()
			local iGrowth = self:GetGrowthRate()
			local iTradeGDP = self:GetTradeGDP()
			local iInvestmentGDP = self:GetInvestmentGDP()
			local iConsumerGDP = self:GetConsumerGDP()
			local iWars = Teams[self.m_TeamID]:GetAtWarCount(true)
			local fMaxDebtRatio = (AI_BASE_DEBT_RATIO + decimalshift(iFlavorExpand, -2))
			local bCultureDeficit = (self.m_Player:GetTotalJONSCulturePerTurn() + self:GetPoliticalExpense()) < 0
			
			local bDepressionRisk = (self:GetAverageGrowthRate(BASE_EVENT_TURNS) < GROWTH_STAGNATION)
			local bBudgetRisk = ((iFiscalBalance + iGoldIncomeTotal) < 0) or (self:GetDebtPayment() > iGoldIncomeTotal)
			local bUnemploymentRisk = (self:GetUnemploymentRate() > (2*BASE_UNEMPLOYMENT_RATE))
			local bDebtRisk = (fInterestRate > (2*BASE_INTEREST_RATE)) or (self:GetDebtRatio() > fMaxDebtRatio)
			
			local bWarmonger = (iWars > 2) or (iFlavorWarmonger > AI_ACTION_THRESHOLD)
			local bCultured = bCultureDeficit or (iFlavorCultured > AI_ACTION_THRESHOLD)
			local bExpansive = (self.m_Player:GetNumCities() > BASE_WORLD_SIZE) or (iFlavorExpansive > AI_ACTION_THRESHOLD)
			local bDiplomat = (self:GetOpenBordersCount() > (BASE_WORLD_SIZE/2)) or (iFlavorDiplomat > AI_ACTION_THRESHOLD)
			local bTrader = (iTradeGDP < 0) or (iFlavorTrader > AI_ACTION_THRESHOLD) 
			local bProductive = (iGrowth < GROWTH_RECESSION) or (iFlavorProductive > AI_ACTION_THRESHOLD)
			
			for _,policy in ipairs(options) do
				local aiWeight = 0
				if bDepressionRisk then
					if (policy.DepressionChance < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.DepressionChance > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if policy.Stability then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					end
				end
				if bBudgetRisk then
					if (policy.IncomeRevenue > 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.IncomeRevenue < 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.BusinessRevenue > 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.BusinessRevenue < 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.TradeRevenue > 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.TradeRevenue < 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.GovernmentExpense < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.GovernmentExpense > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.PolicyExpense < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.PolicyExpense > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.CityExpense < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.CityExpense > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.IncomeTax ~= 0) then
						if (policy.IncomeTax > fIncomeTax) then
							aiWeight = aiWeight + AI_POLICY_WEIGHT
						end
					end
					if (policy.BusinessTax ~= 0) then
						if (policy.BusinessTax > fBusinessTax) then
							aiWeight = aiWeight + AI_POLICY_WEIGHT
						end
					end
					if (policy.TradeTax ~= 0) then
						if (policy.TradeTax > fImportTax) 
							or (policy.TradeTax > fExportTax) then
							aiWeight = aiWeight + AI_POLICY_WEIGHT
						end
					end
					if policy.ImprovementTax then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					end
					if policy.NoTaxPenalty then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					end
				end
				if bUnemploymentRisk then
					if (policy.UnemploymentRate < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.UnemploymentRate > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
				end
				if bDebtRisk then
					if (policy.InterestRate ~= 0) then
						if (policy.InterestRate < fInterestRate) then
							aiWeight = aiWeight + AI_POLICY_WEIGHT
						elseif (policy.InterestRate > fInterestRate) then
							aiWeight = aiWeight - AI_POLICY_WEIGHT
						end
					end
					if (policy.DebtLimit > 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.DebtLimit < 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
					if (policy.DebtPayment < 0) then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					elseif (policy.DebtPayment > 0) then
						aiWeight = aiWeight - AI_POLICY_WEIGHT
					end
				end

				if bWarmonger then
					if policy.Stability then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					end
					if (policy.MilitaryExpense < 0) then
						aiWeight = aiWeight + iFlavorWarmonger
					elseif (policy.MilitaryExpense > 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if (policy.GovernmentGDP > 0) then
						aiWeight = aiWeight + iFlavorWarmonger
					elseif (policy.GovernmentGDP < 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if (policy.GovToInvestment > 0) then
						aiWeight = aiWeight + iFlavorWarmonger
					elseif (policy.GovToInvestment < 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if (policy.OpenBorderGDP < 0) then
						aiWeight = aiWeight + iFlavorWarmonger
					elseif (policy.OpenBorderGDP > 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if (policy.IncomeTax > fIncomeTax) then
						aiWeight = aiWeight + iFlavorWarmonger
					end
					if (policy.AlliedMinorGDP > 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if (policy.OpenBorderGDP > 0) then
						aiWeight = aiWeight - iFlavorWarmonger
					end
					if policy.ImprovementTax then
						aiWeight = aiWeight + iFlavorWarmonger
					end
					if (policy.EnemyGDP > 0) then
						aiWeight = aiWeight + iFlavorWarmonger
					end
				end
				if bCultured then
					if (policy.ConsumerGDP > 0) then
						aiWeight = aiWeight + iFlavorCultured
					elseif (policy.ConsumerGDP < 0) then
						aiWeight = aiWeight - iFlavorCultured
					end
					if (policy.GovToConsumer > 0) then
						aiWeight = aiWeight + iFlavorCultured
					elseif (policy.GovToConsumer < 0) then
						aiWeight = aiWeight - iFlavorCultured
					end
					if (policy.PoliticalExpense < 0) then
						aiWeight = aiWeight + iFlavorCultured
					elseif (policy.PoliticalExpense > 0) then
						aiWeight = aiWeight - iFlavorCultured
					end
					if (policy.PolicyExpense < 0) then
						aiWeight = aiWeight + iFlavorCultured
					elseif (policy.PolicyExpense > 0) then
						aiWeight = aiWeight - iFlavorCultured
					end
					if (policy.UnemploymentRate < 0) then
						aiWeight = aiWeight + iFlavorCultured
					elseif (policy.UnemploymentRate > 0) then
						aiWeight = aiWeight - iFlavorCultured
					end
					if (policy.IncomeTax ~= 0) then
						if (policy.IncomeTax < fIncomeTax) then
							aiWeight = aiWeight + iFlavorCultured
						elseif (policy.IncomeTax > fIncomeTax) then
							aiWeight = aiWeight - iFlavorCultured
						end
					end
					if (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight + iFlavorCultured
					end
					if (policy.ConsumerHappiness > 0) then
						aiWeight = aiWeight + iFlavorCultured
					end
					if policy.NoTaxPenalty then
						aiWeight = aiWeight + iFlavorCultured
					end
				end
				if bExpansive then
					if (policy.GovernmentGDP < 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.GovernmentGDP > 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if (policy.ImportGDP > 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.ImportGDP < 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if (policy.CityExpense < 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.CityExpense > 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if (policy.DebtLimit > 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.DebtLimit < 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if (policy.BusinessTax ~= 0) then
						if (policy.BusinessTax < fBusinessTax) then
							aiWeight = aiWeight + iFlavorExpansive
						elseif (policy.BusinessTax > fBusinessTax) then
							aiWeight = aiWeight - iFlavorExpansive
						end
					end
					if (policy.SpecialistInvest < 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if policy.BullMarket then
						aiWeight = aiWeight + iFlavorExpansive
					end
					if policy.ImprovementTax then
						aiWeight = aiWeight - iFlavorExpansive
					end
					if (policy.ConsumerHappiness < 0) then
						aiWeight = aiWeight + iFlavorExpansive
					elseif (policy.ConsumerHappiness > 0) then
						aiWeight = aiWeight - iFlavorExpansive
					end
				end
				if bTrader then
					if (policy.InterestRate ~= 0) then
						if (policy.InterestRate < fInterestRate) then
							aiWeight = aiWeight + AI_POLICY_WEIGHT
						elseif (policy.InterestRate > fInterestRate) then
							aiWeight = aiWeight - AI_POLICY_WEIGHT
						end
					end
					if (policy.ImportGDP > 0) then
						aiWeight = aiWeight + iFlavorTrader
					elseif (policy.ImportGDP < 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if (policy.ExportGDP > 0) then
						aiWeight = aiWeight + iFlavorTrader
					elseif (policy.ExportGDP < 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if (policy.TradeRevenue > 0) then
						aiWeight = aiWeight + iFlavorTrader
					elseif (policy.TradeRevenue < 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if (policy.OpenBorderGDP > 0) then
						aiWeight = aiWeight + iFlavorTrader
					elseif (policy.OpenBorderGDP < 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if (policy.TradeTax ~= 0) then
						if (policy.TradeTax < fImportTax) 
							or (policy.TradeTax < fExportTax) then
							aiWeight = aiWeight + iFlavorTrader
						end
					end
					if (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if policy.BullMarket then
						aiWeight = aiWeight + iFlavorTrader
					end
					if (policy.ConsumerToInvestment > 0) then
						aiWeight = aiWeight + iFlavorTrader
					elseif (policy.ConsumerToInvestment < 0) then
						aiWeight = aiWeight - iFlavorTrader
					end
					if policy.NoTaxPenalty then
						aiWeight = aiWeight - iFlavorTrader
					end
				end
				if bDiplomat then
					if (policy.OpenBorderGDP > 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					end
					if policy.NoTradeDeficit then
						aiWeight = aiWeight + iFlavorDiplomat
					end
					if (policy.AlliedMinorGDP > 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					end
					if (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					end
					if (policy.ConsumerHappiness > 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					elseif (policy.ConsumerHappiness < 0) then
						aiWeight = aiWeight - iFlavorDiplomat
					end
					if (policy.DebtPayment < 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					elseif (policy.DebtPayment > 0) then
						aiWeight = aiWeight - iFlavorDiplomat
					end
					if (policy.ConsumerToInvestment > 0) then
						aiWeight = aiWeight + iFlavorDiplomat
					elseif (policy.ConsumerToInvestment < 0) then
						aiWeight = aiWeight - iFlavorDiplomat
					end
					if policy.NoTaxPenalty then
						aiWeight = aiWeight + iFlavorDiplomat
					end
					if (policy.EnemyGDP > 0) then
						aiWeight = aiWeight - iFlavorDiplomat
					end
				end
				if bProductive then
					if policy.Stability then
						aiWeight = aiWeight + AI_POLICY_WEIGHT
					end
					if (policy.GovToInvestment > 0) then
						aiWeight = aiWeight + iFlavorProductive
					end
					if (policy.InvestmentGDP > 0) then
						aiWeight = aiWeight + iFlavorProductive
					elseif (policy.InvestmentGDP < 0) then
						aiWeight = aiWeight - iFlavorProductive
					end
					if (policy.ExportGDP > 0) then
						aiWeight = aiWeight + iFlavorProductive
					end
					if (policy.BusinessRevenue < 0) then
						aiWeight = aiWeight + iFlavorProductive
					elseif (policy.BusinessRevenue > 0) then
						aiWeight = aiWeight - iFlavorProductive
					end
					if policy.NoTradeDeficit then
						aiWeight = aiWeight - iFlavorProductive
					end
					if (policy.SpecialistInvest > 0) then
						aiWeight = aiWeight + iFlavorProductive
					end
					if policy.ImprovementTax then
						aiWeight = aiWeight - iFlavorProductive
					end
					if (policy.DebtPayment < 0) then
						aiWeight = aiWeight + iFlavorProductive
					elseif (policy.DebtPayment > 0) then
						aiWeight = aiWeight - iFlavorProductive
					end
				end
				policy.AIWeight = aiWeight
			end

			sort(options, function(x,y) return (x.AIWeight > y.AIWeight) end)

			local iBestChoice = options[1].AIWeight
			for i,policy in ipairs(options) do
				if (policy.AIWeight < iBestChoice) then
					remove(options, i)
				end
			end

			iPolicyID = options[random(1, #options)].ID
		end

		self:SetPolicyTurn(self.m_iTurn + POLICY_COOLDOWN)
		self:SetCurrentPolicy(iPolicyID)

	end,
	--------------------------------------------------------------
    AIDoFiscal = function( self )
		if not self:IsAIPlayer() then
			return
		end
		if not self:CanBasicTax() then
			return
		end

		local bExpandedTax = self:CanExpandedTax()
		
		local iEnemies = Teams[self.m_TeamID]:GetAtWarCount(true)
		local iFlavorGold = self:GetLeaderFlavor("FLAVOR_GOLD")
		local iFlavorProd = self:GetLeaderFlavor("FLAVOR_PRODUCTION")
		local iFlavorGrowth = self:GetLeaderFlavor("FLAVOR_GROWTH")
		local iFlavorCulture = self:GetLeaderFlavor("FLAVOR_CULTURE")
		local iFlavorWar = self:GetLeaderFlavor("MAJOR_CIV_APPROACH_WAR")
		local iFlavorDiplo = self:GetLeaderFlavor("FLAVOR_DIPLOMACY")
		local iFlavorExpand = self:GetLeaderFlavor("FLAVOR_EXPANSION")
		
		local iGrowth = self:GetGrowthRate()
		local iCurrentExpense = self:GetExpenseTotal()
		local iPoliticalExpense = self:GetPoliticalExpense()
		local iFiscalBalance = self:GetFiscalBalance()
		local iTradeGDP = self:GetTradeGDP()
		local iTradeRoutes = 0
		local bCultureDeficit = ((self.m_Player:GetTotalJONSCulturePerTurn() + iPoliticalExpense) <= 0)
		local bDeficit = (iFiscalBalance < 0)
		
		local iDebtPayment = self:GetDebtPayment()
		local iGoldIncomeTotal = self.m_Player:CalculateGoldRate()
		local iGoldTotal = self.m_Player:GetGold()
		local iAverageTaxRate = self:GetAverageTaxRate()
		local iIncomeTax, iBusinessTax, iImportTax, iExportTax = self:GetSectorTaxRates()
		
		local i = AI_BASE_TAX_INCREMENTS
		local bIncreaseRevenue = false
		local isDivergentBudget = function()
			if bIncreaseRevenue then
				return true
			else
				if bDeficit then
					if bExpandedTax then
						return ((iCurrentExpense + self:GetRevenueEstimate(nil, iIncomeTax, iBusinessTax, iImportTax, iExportTax)) < 1)
					else
						return ((iCurrentExpense + self:GetRevenueEstimate(iAverageTaxRate)) < 1)
					end
				else
					if bExpandedTax then
						return ((iCurrentExpense + self:GetRevenueEstimate(nil, iIncomeTax, iBusinessTax, iImportTax, iExportTax)) > 1)
					else
						return ((iCurrentExpense + self:GetRevenueEstimate(iAverageTaxRate)) > 1)
					end
				end
			end
		end 
		
		if IsBNW then
			iTradeRoutes = #self.m_Player:GetTradeRoutes()
		end
		
		local bAdjustIncomeTax = true
		local bAdjustBusinessTax = true
		local bAdjustTradeTax = true

		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo then
			if (policyInfo.IncomeTax ~= 0) then
				bAdjustIncomeTax = false
			end
			if (policyInfo.BusinessTax ~= 0) then
				bAdjustBusinessTax = false
			end
			if (policyInfo.TradeTax ~= 0) then
				bAdjustTradeTax = false
			end
		end

		
		--positive balance, consider lowering taxes
		if (iFiscalBalance > iFlavorGold) or bCultureDeficit then
			local bLowerTaxes = true
			--dangerously high taxes
			if (TAX_GDP_THRESHOLD < iAverageTaxRate) then
				bLowerTaxes = true
			--our economy is tanking, so let's be conservative
			elseif (iGrowth < GROWTH_STAGNATION) then
				bLowerTaxes = false
			--this war could require a lot of gold...
			elseif (2 < iEnemies) then
				bLowerTaxes = false
			--we're in serious debt or financial crisis, so we'll need more gold
			elseif (iGoldTotal < iDebtPayment) then
				bLowerTaxes = false
			--we like gold more than culture, roll for it
			elseif (iFlavorCulture < iFlavorGold ) then
				bLowerTaxes = (random() < (iFlavorGold + iFlavorCulture))
			end
			
			if bLowerTaxes then
				local bLowerGlobal = false
				--outrageous taxes, lower a lot
				if (TAX_GDP_THRESHOLD < iAverageTaxRate) then
					bLowerGlobal = true
					i = i + 5
				--good economy, lower all taxes more
				elseif (iGrowth > GROWTH_BOOM) then
					bLowerGlobal = true
					i = i + 4
				elseif (iGrowth > GROWTH_EXPANSION) then
					bLowerGlobal = true
					i = i + 3
				elseif (iGrowth > GROWTH_STABLE) then
					bLowerGlobal = true
					i = i + 2
				end
				--we like gold, lower less
				if (AI_ACTION_THRESHOLD < iFlavorGold) then
					i = i - 1
				end
				--we like culture more than gold, lower more
				if (iFlavorGold < iFlavorCulture) then
					i = i + 1
				end
				--lower the tax rate a little
				if bExpandedTax then
					--we like production, lower business tax
					if bAdjustBusinessTax and (AI_ACTION_THRESHOLD < iFlavorProd) and not bLowerGlobal then
						while isDivergentBudget() and (iBusinessTax > MIN_TAX_RATE) and (i > 0) do
							iBusinessTax = iBusinessTax - AI_TAX_DECREMENT
							i = i - 1
						end
					--we like growth, lower income tax
					elseif bAdjustIncomeTax and (AI_ACTION_THRESHOLD < iFlavorGrowth) and not bLowerGlobal then
						while isDivergentBudget() and (iIncomeTax > MIN_TAX_RATE) and (i > 0) do
							iIncomeTax = iIncomeTax - AI_TAX_DECREMENT
							i = i - 1
						end
					--we're an export economy, so lower taxes on exports
					elseif bAdjustTradeTax and (iTradeGDP > 0) and not bLowerGlobal then
						while isDivergentBudget()  and (iExportTax > MIN_TAX_RATE) and (i > 0) do
							iExportTax = iExportTax - AI_TAX_DECREMENT
							i = i - 1
						end
					--we're an import economy, so lower taxes on imports
					elseif bAdjustTradeTax and (AI_ACTION_THRESHOLD < iFlavorDiplo) and not bLowerGlobal then
						while isDivergentBudget() and (iImportTax > MIN_TAX_RATE)  and (i > 0) do
							iImportTax = iImportTax - AI_TAX_DECREMENT
							i = i - 1
						end
					--lower everything!
					else
						while isDivergentBudget() and (i > 0) do
							if bAdjustIncomeTax then
								iIncomeTax = (MIN_TAX_RATE <= (iIncomeTax - AI_TAX_DECREMENT)) and (iIncomeTax - AI_TAX_DECREMENT) or iIncomeTax
							end
							if bAdjustBusinessTax then
								iBusinessTax = (MIN_TAX_RATE <= (iBusinessTax - AI_TAX_DECREMENT)) and (iBusinessTax - AI_TAX_DECREMENT) or iBusinessTax
							end
							if bAdjustTradeTax then 
								iExportTax = (MIN_TAX_RATE <= (iExportTax - AI_TAX_DECREMENT)) and (iExportTax - AI_TAX_DECREMENT) or iExportTax
								iImportTax = (MIN_TAX_RATE <= (iImportTax - AI_TAX_DECREMENT)) and (iImportTax - AI_TAX_DECREMENT) or iImportTax
							end
							i = i - 1
						end
					end
					self:SetTaxRates(nil, iIncomeTax, iBusinessTax, iImportTax, iExportTax)
				else
					while isDivergentBudget() and (iAverageTaxRate > MIN_TAX_RATE) and (i > 0) do
						iAverageTaxRate = (iAverageTaxRate - AI_TAX_DECREMENT)
						i = i - 1
					end
					self:SetTaxRates(iAverageTaxRate)
				end
			end
		--negative balance, consider increasing taxes
		else
			local bRaiseTaxes = true
			if (iAverageTaxRate <= BASE_TAX_RATE) then
				bRaiseTaxes = true
			--dangerously high taxes, we may gamble on higher rates
			elseif (TAX_GDP_THRESHOLD < iAverageTaxRate) then
				bRaiseTaxes = (random() > decimalshift(TAX_GDP_THRESHOLD, 2))
			--we're in a serious war, raise taxes
			elseif (1 < iEnemies) then
				bRaiseTaxes = true
			--our economy is growing, let's postpone taxing
			elseif (GROWTH_BOOM < iGrowth) then
				bRaiseTaxes = false
			--we have a good gold reserve, let's postpone taxing
			elseif ((iGoldTotal + iFiscalBalance) > (BASE_MAX_DEBT/2)) then
				bRaiseTaxes = false
			end
			--raise taxes to solve the problem
			if bRaiseTaxes then
				local bRaiseGlobal = false
				--bad economy, raise taxes more
				if (iGrowth <= GROWTH_BUST) then
					bRaiseGlobal = true
					i = i + 4
				elseif (iGrowth <= GROWTH_RECESSION) then
					bRaiseGlobal = true
					i = i + 3
				elseif (iGrowth <= GROWTH_STAGNATION) then
					i = i + 2
				end
				--we like gold, raise more
				if (AI_ACTION_THRESHOLD < iFlavorGold) then
					bIncreaseRevenue = true
					bRaiseGlobal = true
					i = i + 1
				end
				--debt or financial issues, raise more
				if (iGoldIncomeTotal < iDebtPayment) then
					bIncreaseRevenue = true
					i = i + 2
				end
				--we like culture more than gold, raise a bit less
				if (iFlavorGold < iFlavorCulture) then
					i = i - 1
				end
				
				if bExpandedTax then
					--we have a trade deficit, let's get protectionist!
					if bAdjustTradeTax and (iTradeGDP < 0) and not bRaiseGlobal then
						while isDivergentBudget() and (i > 0) do
							iImportTax = ((iImportTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iImportTax or (iImportTax + AI_TAX_DECREMENT)
							i = i - 1
						end
					--we like production, don't raise business and export taxes
					elseif bAdjustIncomeTax and bAdjustTradeTax and (AI_ACTION_THRESHOLD < iFlavorProd) and not bRaiseGlobal then
						while isDivergentBudget() and (i > 0) do
							iIncomeTax = ((iIncomeTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iIncomeTax or (iIncomeTax + AI_TAX_DECREMENT)
							iImportTax = ((iImportTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iImportTax or (iImportTax + AI_TAX_DECREMENT)
							i = i - 1
						end
					--we like growth, don't raise income and import taxes
					elseif bAdjustBusinessTax and bAdjustTradeTax and (AI_ACTION_THRESHOLD < iFlavorGrowth) and not bRaiseGlobal then
						while isDivergentBudget() and (i > 0) do
							iBusinessTax = ((iBusinessTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iBusinessTax or (iBusinessTax + AI_TAX_DECREMENT)
							iExportTax = ((iExportTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iExportTax or (iExportTax + AI_TAX_DECREMENT)
							i = i - 1
						end
					--we're internationlist, raise everything except trade taxes
					elseif bAdjustIncomeTax and bAdjustBusinessTax and ((AI_ACTION_THRESHOLD < iFlavorDiplo) or (iTradeRoutes > 0)) and not bRaiseGlobal then
						while isDivergentBudget() and (i > 0) do
							iIncomeTax = ((iIncomeTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iIncomeTax or (iIncomeTax + AI_TAX_DECREMENT)
							iBusinessTax = ((iBusinessTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iBusinessTax or (iBusinessTax + AI_TAX_DECREMENT)
							i = i - 1
						end
					--raise everything!
					else
						while isDivergentBudget() and (i > 0) do
							if bAdjustIncomeTax then
								iIncomeTax = ((iIncomeTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iIncomeTax or (iIncomeTax + AI_TAX_DECREMENT)
							end
							if bAdjustBusinessTax then
								iBusinessTax = ((iBusinessTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iBusinessTax or (iBusinessTax + AI_TAX_DECREMENT)
							end
							if bAdjustTradeTax then 
								iExportTax = ((iExportTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iExportTax or (iExportTax + AI_TAX_DECREMENT)
								iImportTax = ((iImportTax + AI_TAX_DECREMENT) > MAX_TAX_RATE) and iImportTax or (iImportTax + AI_TAX_DECREMENT)
							end
							i = i - 1
						end
					end
					self:SetTaxRates(nil, iIncomeTax, iBusinessTax, iImportTax, iExportTax)
				else
					while isDivergentBudget() and (iAverageTaxRate < MAX_TAX_RATE) and (i > 0) do
						iAverageTaxRate = (iAverageTaxRate + AI_TAX_DECREMENT)
						i = i - 1
					end
					self:SetTaxRates(iAverageTaxRate)
				end
			end


		end

		--consider a loan
		if not self:CanIssueDebt() then
			return
		end

		--we've borrowed too much
		local fMaxDebtRatio = (AI_BASE_DEBT_RATIO + decimalshift(iFlavorExpand, -2))
		if (self:GetDebtRatio() > fMaxDebtRatio) then
			return
		end
		
		--tax base cannot sustain debt
		if (self:GetAverageTaxRate() > AI_DEBT_TAX_RATIO) then
			return
		end

		--can't afford debt service
		local iMaxPayment = (iGoldIncomeTotal + iFiscalBalance)
		if (iMaxPayment < AI_MIN_DEBT_PAYMENT) then
			return
		end

		local bIssueDebt = false
		--we need gold fast
		if bDeficit or (iGoldTotal < 50) then
			bIssueDebt = true
		--in a serious war
		elseif (2 <= iEnemies) then
			bIssueDebt = true
		--in a depression
		elseif self:IsActiveEvent() then
			bIssueDebt = true
		--debt is fun!
		else
			bIssueDebt = (random() > (AI_BASE_DEBT_RESISTANCE - iFlavorGrowth))	
		end

		if bIssueDebt then
			local iPrincipal = down(AI_INIT_LOAN_PERCENT * self:GetTotalGDP())
			while (self:GetDebtPaymentEstimate(iPrincipal) > iMaxPayment) do 
				iPrincipal = down(0.75*iPrincipal)
			end
			self:DoIssueDebt(iPrincipal)
		end
    end,
	--------------------------------------------------------------
    IsActive = function( self )
		if not self.m_Player:IsAlive() then
			return false
		end
		if (self.m_Player:GetNumCities() == 0) then
			return false
		end
		return true
    end,
	--------------------------------------------------------------
    IsAIPlayer = function( self )
		return self.m_bIsAIPlayer
    end,
	--------------------------------------------------------------
    GetLeaderFlavor = function( self, sType )
		local leader = GameInfo.Leaders[self.m_Player:GetLeaderType()]
		if leader then
			local constraint = "LeaderType='" .. leader.Type .. "'" 
			for row in GameInfo.Leader_Flavors(constraint) do
				if (row.FlavorType == sType) then
					return row.Flavor
				end
			end
			--no return, try major civ approaches
			for row in GameInfo.Leader_MajorCivApproachBiases(constraint) do
				if (row.MajorCivApproachType == sType) then
					return row.Bias
				end
			end
			--no return, try minor civ approaches
			for row in GameInfo.Leader_MinorCivApproachBiases(constraint) do
				if (row.MinorCivApproachType == sType) then
					return row.Bias
				end
			end
		end
		return 0
    end,
	--------------------------------------------------------------
	-- GLOBAL
	--------------------------------------------------------------
    UpdateGlobal = function( self, bTurnEnd )
		if self:IsActive() then
			self:UpdateGDP()
			self:UpdateBudget()
			self:UpdateIndices()
			if bTurnEnd then
				self:DoBudget()
				self:DoEvent()
				self:Archive()
				self:ClearCaches()
			end
		end
    end,
	--------------------------------------------------------------
    UpdateIndices = function( self )
		self:UpdateInterestRate()
		self:UpdateUnemploymentRate()
		self:UpdateGrowthRate()
		self:UpdateMarketRate()
    end,
	--------------------------------------------------------------
    ClearCaches = function( self )
		self.m_iGovern_Cache = 0
		self.m_iInvest_Cache = 0
    end,
	--------------------------------------------------------------
    ChangeGovernmentSpending = function( self, iChange )
		self.m_iGovern_Cache = self.m_iGovern_Cache + iChange
    end,
	--------------------------------------------------------------
    ChangeInvestmentSpending = function( self, iChange )
		self.m_iInvest_Cache = self.m_iInvest_Cache + iChange
    end,
	--------------------------------------------------------------
    UpdateTurn = function( self )
		self.m_iTurn = Game.GetGameTurn()
		self.m_iYear = Game.GetGameTurnYear()
    end,
	--------------------------------------------------------------
    GetCurrentEraID = function( self )
		return self.m_iCurrentEra
    end,
	--------------------------------------------------------------
    UpdateEraEnables = function( self, iEra )
		self.m_iCurrentEra = iEra
		self.m_bEnableBasicTax = (BASE_TAX_ERA <= iEra)
		self.m_bEnableMarkets = (BASE_MARKETS_ERA <= iEra)
		self.m_bEnableExpandTax	= (EXPANDED_TAX_ERA <= iEra)
		self.m_bEnableDebt = (BASE_DEBT_ERA <= iEra)
		self.m_bEnableEvents = (BASE_EVENT_ERA <= iEra)

		if (self.m_Player:IsHuman()) then
			local popupInfo = {}
			local eraInfo = GameInfo.Eras[iEra]
			if (iEra == BASE_TAX_ERA) then
				popupInfo.Text = locale("TXT_KEY_POPUP_FA_ECON_ERA_UPDATE_TAX", eraInfo.Description)
			elseif (iEra == BASE_DEBT_ERA) then
				popupInfo.Text = locale("TXT_KEY_POPUP_FA_ECON_ERA_UPDATE_DEBT", eraInfo.Description)
			elseif (iEra == EXPANDED_TAX_ERA) then
				popupInfo.Text = locale("TXT_KEY_POPUP_FA_ECON_ERA_UPDATE_TAX_EXPANDED", eraInfo.Description)
			end
			if popupInfo.Text then
				popupInfo.Title = locale("TXT_KEY_POPUP_FA_ECON_ERA_UPDATE")
				LuaEvents.FA_Economics_EconPopup(popupInfo)
			end
		end
    end,
	--------------------------------------------------------------
    UpdateUnemploymentRate = function( self )
		local fRate = BASE_UNEMPLOYMENT_RATE

		fRate = fRate - (self:GetGrowthRate()/2)
		fRate = fRate - (Teams[self.m_TeamID]:GetAtWarCount(true)/100)
		
		if self.m_Player:IsPolicyBranchUnlocked(BRANCH_FREEDOM) then
			fRate = fRate + 0.05
		elseif self.m_Player:IsPolicyBranchUnlocked(BRANCH_ORDER) then
			fRate = fRate - 0.03
		elseif self.m_Player:IsPolicyBranchUnlocked(BRANCH_AUTOCRACY) then
			fRate = fRate - 0.01
		end

		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo and (policyInfo.UnemploymentRate ~= 0) then
			fRate = fRate + policyInfo.UnemploymentRate/100
		end

		if self:IsActiveEvent() then
			fRate = fRate + BASE_EVENT_UNEMPLOYED
		end

		fRate = round(fRate, 2)
		fRate = (fRate < 0.02) and 0.02 or fRate
		fRate = (fRate > 0.66) and 0.66 or fRate

		self.m_fUnemploymentRate = fRate
    end,
	--------------------------------------------------------------
    GetUnemploymentRate = function( self )
		return self.m_fUnemploymentRate
    end,
	--------------------------------------------------------------
    GetCurrentPopulation = function( self )
		self.m_iPopulation = (self.m_Player:GetTotalPopulation() * POPULATION_MULTIPLIER)
		return self.m_iPopulation
    end,
	--------------------------------------------------------------
    UpdateGrowthRate = function( self )
		local archive = self:GetArchiveTurn( (self.m_iTurn - 1) )
		if archive then
			local fRate = 0.0
			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			if (policyInfo and policyInfo.Stability) or not self:CanBasicTax() then
				fRate = GROWTH_STABLE
			else
				fRate = (self.m_iGDP_Total - archive.iGDP_Total)/archive.iGDP_Total
			end
			fRate = round(fRate, 2) or 0.00
			fRate = (fRate > 0.5) and 0.5 or fRate
			fRate = (fRate < -0.5) and -0.5 or fRate
			self.m_fGDP_Growth = fRate
		end
    end,
	--------------------------------------------------------------
    GetGrowthRate = function( self ) 
		return self.m_fGDP_Growth
    end,
	--------------------------------------------------------------
    GetAverageGrowthRate = function( self, iTurns ) 
		local growthRates = {}
		local iTurns = iTurns or 1
		local iAverage = 0
		local archive = gT.g_EconData[self.m_PlayerID]
		if archive then
			for i = self.m_iTurn, (self.m_iTurn-iTurns), -1 do
				local archiveTurn = archive[i]
				if (archiveTurn ~= nil) then
					insert(growthRates, archiveTurn.fGDP_Growth)
				end
			end
		end
		if (#growthRates > 0) then
			iAverage = round( average(growthRates), 2 )
		end
		return iAverage
    end,
	--------------------------------------------------------------
    GetGrowthRateString = function( self ) 
		local iGrowth = self:GetGrowthRate()
		local strGrowth = ""
		if self:IsActiveEvent() then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_DEPRESSION_TT")
		elseif (iGrowth == GROWTH_STABLE) then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_STABLE_TT")
		elseif (iGrowth > GROWTH_BOOM) then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_BOOM_TT")
		elseif (iGrowth > GROWTH_EXPANSION) then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_EXPANSION_TT")
		elseif (iGrowth > GROWTH_STAGNATION) then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_STAGNATION_TT")
		elseif (iGrowth > GROWTH_RECESSION) then
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_RECESSION_TT")
		else
			strGrowth = locale("TXT_KEY_FA_ECON_POPUP_PANIC_TT")
		end
		return strGrowth
    end,
	--------------------------------------------------------------
    GetOpenBordersCount = function( self ) 
		local iCount = 0
		for i = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
			local player = Players[i]
			if player then
				if self.m_Player:IsPlayerHasOpenBorders(i) then
					iCount = iCount + 0.5
				end
				if player:IsPlayerHasOpenBorders(self.m_PlayerID) then
					iCount = iCount + 0.5
				end
			end
		end
		return up(iCount)
    end,
	--------------------------------------------------------------
    GetAlliedMinorsCount = function( self ) 
		local iCount = 0
		for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1, 1 do
			local player = Players[i]
			if player and player:IsAllies(self.m_PlayerID) then
				iCount = iCount + 1
			end
		end
		return iCount
    end,
	--------------------------------------------------------------
    GetSpecialistYield = function( self )
		local iYield = 0
		local constraint = "ID <= 5"
		for city in self.m_Player:Cities() do
			for yield in GameInfo.Yields(constraint) do
				local bonus = city:GetBaseYieldRateFromSpecialists(yield.ID)
				iYield = iYield + city:GetBaseYieldRateFromSpecialists(yield.ID)
			end
		end
		iYield = round(PRODUCTION_MOD * pow(0.75, self:GetCurrentEraID()) * iYield)
		return iYield
    end,
	--------------------------------------------------------------
	-- EVENT
	--------------------------------------------------------------
    DoEvent = function( self )
		if not self:CanEvents() then
			return
		end
		
		if self.m_Player:IsGoldenAge() then
			return
		end

		local iEventChance = BASE_EVENT_CHANCE
		
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo then
			if policyInfo.Stability then
				return
			end
			if (policyInfo.DepressionChance ~= 0) then
				iEventChance = iEventChance + iEventChance*(policyInfo.DepressionChance/100)
			end
		end

		local fAverageGrowth = self:GetAverageGrowthRate(BASE_EVENT_TURNS)
		if self:IsActiveEvent() then
			if (fAverageGrowth < GROWTH_STAGNATION) then
				self:ChangeEventTurn( random(0,1) )
			end
			return
		end
	
		if (fAverageGrowth < GROWTH_STAGNATION) and (random() < iEventChance) then
			local iTurns = BASE_EVENT_TURNS
			local fEventMalus = 0.00
			local strTitle = ""

			if (fAverageGrowth < GROWTH_RECESSION) then
				iTurns = iTurns + random(1, BASE_EVENT_TURNS)
				fEventMalus = random(MED_EVENT_MALUS,MAX_EVENT_MALUS)/100
				strTitle = locale("TXT_KEY_POPUP_FA_ECON_EVENT_DEPRESSION_SEVERE", date(self.m_iYear))
			else
				fEventMalus = random(MIN_EVENT_MALUS,MED_EVENT_MALUS)/100
				strTitle = locale("TXT_KEY_POPUP_FA_ECON_EVENT_DEPRESSION", date(self.m_iYear))
			end

			self:SetEventTurn( self.m_iTurn + iTurns )
			self:SetEventMalus( round(fEventMalus, 2) )
			self:UpdateGlobal()

			if (self.m_PlayerID == Game.GetActivePlayer()) then 
				local popupInfo = {Title=strTitle, Text=locale("TXT_KEY_POPUP_FA_ECON_EVENT_HELP", percent(fEventMalus), iTurns)}
				LuaEvents.FA_Economics_EconPopup(popupInfo)
			end
		end
    end,
	--------------------------------------------------------------
    CanEvents = function( self ) 
		return self.m_bEnableEvents
    end,
	--------------------------------------------------------------
    SetEventTurn = function( self, iTurn ) 
		self.m_iEventTurn = iTurn
    end,
	--------------------------------------------------------------
    ChangeEventTurn = function( self, iChange ) 
		self.m_iEventTurn = self.m_iEventTurn + iChange
    end,
	--------------------------------------------------------------
    IsActiveEvent = function( self ) 
		return (self.m_iTurn <= self.m_iEventTurn)
    end,
	--------------------------------------------------------------
	GetEventMalus = function( self ) 
		return self.m_fEventMalus
    end,
	--------------------------------------------------------------
	SetEventMalus = function( self, fValue )
		self.m_fEventMalus = fValue
    end,
	--------------------------------------------------------------
	-- GDP
	--------------------------------------------------------------
    GetTotalGDP = function( self )
		return self.m_iGDP_Total
    end,
	--------------------------------------------------------------
    UpdateGDP = function( self )
		self:UpdateGovernmentGDP()
		self:UpdateConsumerGDP()
		self:UpdateInvestmentGDP()
		self:UpdateTradeGDP()

		self.m_iGDP_Total = (self.m_iGDP_Consumer + self.m_iGDP_Government + self.m_iGDP_Investment + self.m_iGDP_Trade)
    end,
	--------------------------------------------------------------
    GetConsumerGDP = function( self )
		return self.m_iGDP_Consumer
    end,
	--------------------------------------------------------------
    UpdateConsumerGDP = function( self )
		local bTaxRatePenalty = true
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		local iPopulation = self:GetCurrentPopulation()
		local iPopulation = iPopulation - (iPopulation * self:GetUnemploymentRate())
		local iPopulation = up(iPopulation * ( (self:GetCurrentEraID()+1) / GAME_MAX_ERAS))
		local iHappiness = self.m_Player:GetExcessHappiness()
		
		if policyInfo and (policyInfo.ConsumerHappiness ~= 0) then
			iHappiness = (iHappiness + iHappiness*(policyInfo.ConsumerHappiness/100))
		end

		local iSpending = iPopulation + (iPopulation * (iHappiness/100))
		
		if policyInfo then
			if (policyInfo.ConsumerGDP ~= 0) then
				iSpending = iSpending + iSpending*(policyInfo.ConsumerGDP/100)
			end
			if (policyInfo.GovToConsumer ~= 0) then
				iSpending = iSpending + (self:GetGovernmentGDP()*(policyInfo.GovToConsumer/100))
			end
			if (policyInfo.OpenBorderGDP ~= 0) then
				local iBonus = self:GetOpenBordersCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.OpenBorderGDP/100)) )
			end
			if (policyInfo.AlliedMinorGDP ~= 0) then
				local iBonus = self:GetAlliedMinorsCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.AlliedMinorGDP/100)) )
			end
			if (policyInfo.SpecialistInvest ~= 0) then
				iSpending = iSpending + (self:GetSpecialistYield()*(policyInfo.SpecialistInvest/100))
			end
			bTaxRatePenalty = not policyInfo.NoTaxPenalty
		end

		if self:IsActiveEvent() then
			iSpending = iSpending - (iSpending*self:GetEventMalus())
		end
		if bTaxRatePenalty then
			iSpending = decay(iSpending, self:GetIncomeTaxRate())
		end

		iSpending = up(iSpending)

		self.m_iGDP_Consumer = iSpending
    end,
	--------------------------------------------------------------
    GetGovernmentGDP = function( self )
		return self.m_iGDP_Government
    end,
	--------------------------------------------------------------
    GetTurnGovernmentGDP = function( self )
		return self.m_iGovern_Cache
    end,
	--------------------------------------------------------------
    UpdateGovernmentGDP = function( self )
		local iSpending = self:GetTurnGovernmentGDP()

		for city in self.m_Player:Cities() do
			if not city:IsOccupied() then
				local iProduction = (PRODUCTION_MOD * city:GetYieldRate(YIELD_PRODUCTION))
				iProduction = city:IsPuppet() and (iProduction/2) or iProduction
				if (city:GetProductionUnit() ~= -1) then
					local unitInfo = GameInfo.Units[city:GetProductionUnit()]
					if (unitInfo.WorkRate <= 1) then
						iSpending = iSpending + iProduction
					end
				elseif (city:GetProductionBuilding() ~= -1) then
					local buildingInfo = GameInfo.Buildings[city:GetProductionBuilding()]
					if buildingInfo.NukeImmune or buildingInfo.NeverCapture then
						iSpending = iSpending + iProduction
					end
				else
					iSpending = iSpending + iProduction	
				end
			end
		end

		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo then
			if (policyInfo.GovernmentGDP ~= 0) then
				iSpending = iSpending + iSpending*(policyInfo.GovernmentGDP/100)
			end
			if (policyInfo.EnemyGDP ~= 0) then
				local iBonus = Teams[self.m_TeamID]:GetAtWarCount(true)
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.EnemyGDP/100)) )
			end
		end

		iSpending = up(iSpending)
		self.m_iGDP_Government = iSpending
    end,
	--------------------------------------------------------------
    GetInvestmentGDP = function( self )
		return self.m_iGDP_Investment
    end,
	--------------------------------------------------------------
    GetTurnInvestmentGDP = function( self )
		return self.m_iInvest_Cache
    end,
	--------------------------------------------------------------
    UpdateInvestmentGDP = function( self )
		local bTaxRatePenalty = true
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		local iSpending = self:GetTurnInvestmentGDP()
		
		for city in self.m_Player:Cities() do
			if not city:IsOccupied() then
				local iProduction = (PRODUCTION_MOD * city:GetYieldRate(YIELD_PRODUCTION))
				iProduction = city:IsPuppet() and (iProduction/2) or iProduction
				if (city:GetProductionUnit() ~= -1) then
					local unitInfo = GameInfo.Units[city:GetProductionUnit()]
					if (unitInfo.WorkRate > 1) then
						iSpending = iSpending + iProduction
					end
				elseif (city:GetProductionBuilding() ~= -1) then
					local buildingInfo = GameInfo.Buildings[city:GetProductionBuilding()]
					if not buildingInfo.NukeImmune and not buildingInfo.NeverCapture then
						iSpending = iSpending + iProduction
					end
				end
			end
		end

		for row in GameInfo.Building_YieldModifiers("YieldType='YIELD_GOLD'") do
			local buildingInfo = GameInfo.Buildings[row.BuildingType]
			if buildingInfo then
				local iCount = self.m_Player:CountNumBuildings(buildingInfo.ID)
				iSpending = iSpending + (PRODUCTION_MOD * row.Yield * iCount)
			end
		end

		if IsBNW then
			for _,v in ipairs( self.m_Player:GetTradeRoutes() ) do
				if (v.ToProduction > 0) then
					iSpending = iSpending + (PRODUCTION_MOD * v.ToProduction)
				end
			end
		end
		
		if policyInfo then
			if (policyInfo.InvestmentGDP ~= 0) then
				iSpending = iSpending + iSpending*(policyInfo.InvestmentGDP/100)
			end
			if (policyInfo.OpenBorderGDP ~= 0) then
				local iBonus = self:GetOpenBordersCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.OpenBorderGDP/100)) )
			end
			if (policyInfo.AlliedMinorGDP ~= 0) then
				local iBonus = self:GetAlliedMinorsCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.AlliedMinorGDP/100)) )
			end
			if (policyInfo.EnemyGDP ~= 0) then
				local iBonus = Teams[self.m_TeamID]:GetAtWarCount(true)
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iSpending = iSpending + ( iSpending*(iBonus*(policyInfo.EnemyGDP/100)) )
			end
			if (policyInfo.GovToInvestment ~= 0) then
				iSpending = iSpending + (self:GetGovernmentGDP()*(policyInfo.GovToInvestment/100))
			end
			if (policyInfo.ConsumerToInvestment ~= 0) then
				iSpending = iSpending + (self:GetConsumerGDP()*(policyInfo.ConsumerToInvestment/100))
			end
			if (policyInfo.SpecialistInvest ~= 0) then
				iSpending = iSpending + (self:GetSpecialistYield()*(policyInfo.SpecialistInvest/100))
			end
			bTaxRatePenalty = not policyInfo.NoTaxPenalty
		end
				
		if self:IsActiveEvent() then
			iSpending = iSpending - (iSpending*self:GetEventMalus())
		end
		if bTaxRatePenalty then
			iSpending = decay(iSpending, self:GetBusinessTaxRate())
		end
		
		iSpending = iSpending + (iSpending*self:GetMarketRate())
		iSpending = up(iSpending)

		self.m_iGDP_Investment = iSpending
    end,
	--------------------------------------------------------------
    CanMarkets = function( self )
		return self.m_bEnableMarkets
    end,
	--------------------------------------------------------------
    UpdateMarketRate = function( self )
		if self:CanMarkets() then
			local fMarketRate = 0.00
			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			local bBullMarket = policyInfo and policyInfo.BullMarket or false
			if self:IsActiveEvent() then
				fMarketRate = (random(BEAR_MARKET,0)/100)
			elseif bBullMarket then
				fMarketRate = (random(5,BULL_MARKET)/100)
			else
				fMarketRate = (random(BEAR_MARKET,BULL_MARKET)/100)
			end
			fMarketRate = round(fMarketRate, 2)
			self:SetMarketRate( fMarketRate )
		end
    end,
	--------------------------------------------------------------
    GetMarketRate = function( self )
		return self.m_fMarketRate
    end,
	--------------------------------------------------------------
    SetMarketRate = function( self, fValue )
		self.m_fMarketRate = fValue
    end,
	--------------------------------------------------------------
    GetTradeGDP = function( self )
		return self.m_iGDP_Trade
    end,
	--------------------------------------------------------------
    GetExportGDP = function( self )
		return self.m_iGDP_Export
    end,
	--------------------------------------------------------------
    GetImportGDP = function( self )
		return self.m_iGDP_Import
    end,
	--------------------------------------------------------------
    UpdateTradeGDP = function( self )
		local bTaxRatePenalty = true
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		local iImport = 0
		local iExport = 0
		
		for row in GameInfo.Resources() do
			local iNum = self.m_Player:GetResourceImport(row.ID)
			if (iNum > 0) then
				local tradeMod = (row.AITradeModifier > 0) and row.AITradeModifier or 10
				iImport = iImport + (iNum * tradeMod)
			end
		end
		if IsBNW then
			for _,v in ipairs( self.m_Player:GetTradeRoutesToYou() ) do
				if (v.ToGPT ~= 0) and (v.FromGPT ~= 0) then
					iImport = iImport + ((v.FromGPT - v.ToGPT)/100)
				end
			end
		end

		for row in GameInfo.Resources() do
			local iNum = self.m_Player:GetResourceExport(row.ID)
			if (iNum > 0) then
				local tradeMod = (row.AITradeModifier > 0) and row.AITradeModifier or 10
				iExport = iExport + (iNum * tradeMod)
			end
		end
		if IsBNW then
			for _,v in ipairs( self.m_Player:GetTradeRoutes() ) do
				if (v.ToGPT ~= 0) and (v.FromGPT ~= 0) then
					iExport = iExport + ((v.FromGPT - v.ToGPT)/100)
				end
			end
		end

		iImport = round( TRADE_MOD * iImport )
		iExport = round( TRADE_MOD * iExport )

		if policyInfo then
			if (policyInfo.OpenBorderGDP ~= 0) then
				local iBonus = self:GetOpenBordersCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iExport = iExport + ( iExport*(iBonus*(policyInfo.OpenBorderGDP/100)) )
				iImport = iImport + ( iImport*(iBonus*(policyInfo.OpenBorderGDP/100)) )
			end
			if (policyInfo.AlliedMinorGDP ~= 0) then
				local iBonus = self:GetAlliedMinorsCount()
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iExport = iExport + ( iExport*(iBonus*(policyInfo.AlliedMinorGDP/100)) )
				iImport = iImport + ( iImport*(iBonus*(policyInfo.AlliedMinorGDP/100)) )
			end
			if (policyInfo.EnemyGDP ~= 0) then
				local iBonus = Teams[self.m_TeamID]:GetAtWarCount(true)
				iBonus = (iBonus > MAX_BORDERS_BONUS) and MAX_BORDERS_BONUS or iBonus
				iExport = iExport + ( iExport*(iBonus*(policyInfo.EnemyGDP/100)) )
				iImport = iImport + ( iImport*(iBonus*(policyInfo.EnemyGDP/100)) )
			end
			if (policyInfo.ExportGDP ~= 0) then
				iExport = iExport + iExport*(policyInfo.ExportGDP/100)
			end
			if (policyInfo.ImportGDP ~= 0) then
				iImport = iImport + iImport*(policyInfo.ImportGDP/100)
			end
			if (iExport < iImport) and policyInfo.NoTradeDeficit then
				iExport = iImport
			end
			if (policyInfo.SpecialistInvest ~= 0) then
				local iBonus = (self:GetSpecialistYield()*(policyInfo.SpecialistInvest/100))
				iExport = iExport + iBonus
				iImport = iImport + iBonus
			end
			if policyInfo.NoTaxPenalty then
				local iBonus = (self:GetSpecialistYield()*(policyInfo.SpecialistInvest/100))
				iExport = iExport + iBonus
				iImport = iImport + iBonus
			end
			bTaxRatePenalty = not policyInfo.NoTaxPenalty
		end

		if self:IsActiveEvent() then
			local fMalus = self:GetEventMalus()
			iImport = iImport - (iImport*fMalus)
			iExport = iExport - (iExport*fMalus)
		end
		if bTaxRatePenalty then
			iImport = decay(iImport, self:GetImportTaxRate())
			iExport = decay(iExport, self:GetExportTaxRate())
		end

		iImport = up(iImport)
		iExport = up(iExport)

		self.m_iGDP_Import = iImport
		self.m_iGDP_Export = iExport
		self.m_iGDP_Trade = (iExport - iImport)
    end,
	--------------------------------------------------------------
	-- FISCAL POLICY
	--------------------------------------------------------------
    DoBudget = function( self )
		local iPayment = self:GetDebtPayment()
		if (iPayment > 0) then
			local iDebt = self:GetDebtTotal()
			if (iDebt > 0) then
				local iGoldTotal = self.m_Player:GetGold()
				iPayment = (iPayment > iGoldTotal) and iGoldTotal or iPayment
				iPayment = smaller(iPayment, iDebt)
				self:ChangeDebtTotal( -iPayment )
			end
			if (self:GetDebtTotal() == 0) then
				self:SetDebtPayment(0)
			end
		end

		local iBalance = self:GetFiscalBalance()
		self.m_Player:ChangeGold(iBalance)

		local iChange = self:GetPoliticalExpense()
		iChange = (self.m_Player:GetJONSCulture() > absolute(iChange)) and iChange or 0
		self.m_Player:ChangeJONSCulture(iChange)
    end,
	--------------------------------------------------------------
    UpdateBudget = function( self )
		self:UpdateTaxRates()
		self:UpdateRevenue()
		self:UpdateExpense()
		self:UpdatePoliticalCapital()
    end,
	--------------------------------------------------------------
    CanBasicTax = function( self )
		return self.m_bEnableBasicTax
    end,
	--------------------------------------------------------------
    CanExpandedTax = function( self )
		return self.m_bEnableExpandTax
    end,
	--------------------------------------------------------------
    GetFiscalBalance = function( self )
		return (self:GetRevenueTotal() + self:GetExpenseTotal())
    end,
	--------------------------------------------------------------
    GetAverageTaxRate = function( self )
		return self.m_fTaxRate_Average
    end,
	--------------------------------------------------------------
    SetAverageTaxRate = function( self, fValue )
		self.m_fTaxRate_Average = fValue
    end,
	--------------------------------------------------------------
    GetIncomeTaxRate = function( self )
		return self.m_fTaxRate_Income
    end,
	--------------------------------------------------------------
    GetBusinessTaxRate = function( self )
		return self.m_fTaxRate_Business
    end,
	--------------------------------------------------------------
    GetImportTaxRate = function( self )
		return self.m_fTaxRate_Imports
    end,
	--------------------------------------------------------------
    GetExportTaxRate = function( self )
		return self.m_fTaxRate_Exports
    end,
	--------------------------------------------------------------
    GetSectorTaxRates = function( self )
		return self.m_fTaxRate_Income, self.m_fTaxRate_Business, self.m_fTaxRate_Imports, self.m_fTaxRate_Exports
    end,
	--------------------------------------------------------------
    UpdateTaxRates = function( self )
		if not self:CanBasicTax() then
			return
		end
		local taxRates = {}
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo then
			local iIncomeTax, iBusinessTax, iImportTax, iExportTax = self:GetSectorTaxRates()
			if (policyInfo.IncomeTax ~= 0) then
				iIncomeTax = round(policyInfo.IncomeTax/100, 2)
				self.m_fTaxRate_Income = iIncomeTax
			end
			if (policyInfo.BusinessTax ~= 0) then
				iBusinessTax = round(policyInfo.BusinessTax/100, 2)
				self.m_fTaxRate_Business = iBusinessTax
			end
			if (policyInfo.TradeTax ~= 0) then
				iImportTax = round(policyInfo.TradeTax/100, 2)
				iExportTax = round(policyInfo.TradeTax/100, 2)
				self.m_fTaxRate_Imports	= iImportTax
				self.m_fTaxRate_Exports	= iExportTax
			end

			insert(taxRates, iIncomeTax)
			insert(taxRates, iBusinessTax)
			insert(taxRates, iImportTax)
			insert(taxRates, iExportTax)
		
			self:SetAverageTaxRate( round(average(taxRates), 2) )
		end
    end,
	--------------------------------------------------------------
    SetTaxRates = function( self, iGlobal, iIncome, iBusiness, iImports, iExports)
		if not self:CanBasicTax() then
			return
		end

		local taxRates = {}
		local iGlobal = iGlobal or BASE_TAX_RATE
		local iIncome = iIncome or iGlobal
		local iBusiness = iBusiness or iGlobal
		local iImports = iImports or iGlobal
		local iExports = iExports or iGlobal
		
		iGlobal = round(iGlobal, 2)
		iIncome = round(iIncome, 2)
		iBusiness = round(iBusiness, 2)
		iImports = round(iImports, 2)
		iExports = round(iExports, 2)

		insert(taxRates, iIncome)
		insert(taxRates, iBusiness)
		insert(taxRates, iImports)
		insert(taxRates, iIncome)

		if self.m_bEnableExpandTax then
			self.m_fTaxRate_Income	= iIncome
			self.m_fTaxRate_Business = iBusiness
			self.m_fTaxRate_Imports	= iImports
			self.m_fTaxRate_Exports	= iExports
		else
			self.m_fTaxRate_Income	= iGlobal
			self.m_fTaxRate_Business = iGlobal
			self.m_fTaxRate_Imports	= iGlobal
			self.m_fTaxRate_Exports	= iGlobal
		end

		local fAverage = round( average(taxRates), 2 )
		self:SetAverageTaxRate( fAverage )
    end,
	--------------------------------------------------------------
	UpdatePoliticalCapital = function( self )
		local iChange = 0.00
		if (self:GetAverageTaxRate() > BASE_TAX_RATE) then
			iChange = (BASE_TAX_RATE - self:GetAverageTaxRate())
			iChange = (iChange < -0.50) and -0.50 or iChange
			iChange = (POLITICAL_CAPITAL_MOD * iChange * self:GetCurrentEraID() * self.m_Player:GetNumPolicies())

			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			if policyInfo and (policyInfo.PoliticalExpense ~= 0) then
				iChange = iChange + (iChange*(policyInfo.PoliticalExpense/100))
			end

			iChange = round(iChange)
		end
		self:SetPoliticalCapital(iChange)
    end,
	--------------------------------------------------------------
    GetPoliticalExpense = function( self )
		return self.m_iPolitical_Capital
    end,
	--------------------------------------------------------------
    SetPoliticalCapital = function( self, iValue)
		self.m_iPolitical_Capital = iValue
    end,	
	--------------------------------------------------------------
    UpdateRevenue = function( self )
		if self:CanBasicTax() then
			local iIncome =	(self:GetConsumerGDP() / BASE_REVENUE_DIVISOR)
			local iBusiness = (self:GetInvestmentGDP() / BASE_REVENUE_DIVISOR)
			local iImport = (self:GetImportGDP() / BASE_REVENUE_DIVISOR)
			local iExport = (self:GetExportGDP() / BASE_REVENUE_DIVISOR)
			
			if self:CanExpandedTax() then
				iIncome = round(self.m_fTaxRate_Income * iIncome)
				iBusiness = round(self.m_fTaxRate_Business * iBusiness)
				iImport = round(self.m_fTaxRate_Imports * iImport)
				iExport = round(self.m_fTaxRate_Exports * iExport)
			else
				iIncome = round(self.m_fTaxRate_Average * iIncome)
				iBusiness = round(self.m_fTaxRate_Average * iBusiness)
				iImport = round(self.m_fTaxRate_Average * iImport)
				iExport = round(self.m_fTaxRate_Average * iExport)
			end

			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			if policyInfo then
				if (policyInfo.IncomeRevenue ~= 0) then
					iIncome = round(iIncome + iIncome*(policyInfo.IncomeRevenue/100))
				end
				if (policyInfo.BusinessRevenue ~= 0) then
					iBusiness = round(iBusiness + iBusiness*(policyInfo.BusinessRevenue/100))
				end
				if (policyInfo.TradeRevenue ~= 0) then
					iImport = round(iImport + iImport*(policyInfo.TradeRevenue/100))
					iExport = round(iExport + iExport*(policyInfo.TradeRevenue/100))
				end
				if policyInfo.ImprovementTax then
					local improvementInfo = GameInfo.Improvements[policyInfo.ImprovementTax]
					if improvementInfo then
						iIncome = round(iIncome + (self.m_Player:GetImprovementCount(improvementInfo.ID)*(policyInfo.TaxPerImproved/100))) 
					end
				end
			end

			self.m_iRevenue_Income = iIncome
			self.m_iRevenue_Business = iBusiness
			self.m_iRevenue_Imports	= iImport
			self.m_iRevenue_Exports	= iExport
			self.m_iRevenue_Total = (iIncome + iBusiness + iImport + iExport)
		end
    end,
	--------------------------------------------------------------
    GetRevenueEstimate = function( self, iGlobalTax, iIncomeTax, iBusinessTax, iExportsTax, iImportsTax )
		local iEstimate = self:GetRevenueTotal()
		if self:CanBasicTax() then
			local iGlobalTax = iGlobalTax or BASE_TAX_RATE
			local iIncomeTax = iIncomeTax or iGlobalTax
			local iBusinessTax = iBusinessTax or iGlobalTax
			local iImportsTax = iImportsTax or iGlobalTax
			local iExportsTax = iExportsTax or iGlobalTax
			
			local iIncome =	(self:GetConsumerGDP() / BASE_REVENUE_DIVISOR)
			local iBusiness = (self:GetInvestmentGDP() / BASE_REVENUE_DIVISOR)
			local iImport = absolute(self:GetImportGDP() / BASE_REVENUE_DIVISOR)
			local iExport = absolute(self:GetExportGDP() / BASE_REVENUE_DIVISOR)
			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]

			if self:CanExpandedTax() then
				iIncome = round(iIncomeTax * iIncome)
				iBusiness = round(iBusinessTax * iBusiness)
				iImport = round(iImportsTax * iImport)
				iExport = round(iExportsTax * iExport)
			else
				iIncome = round(iGlobalTax * iIncome)
				iBusiness = round(iGlobalTax * iBusiness)
				iImport = round(iGlobalTax * iImport)
				iExport = round(iGlobalTax * iExport)
			end

			if policyInfo then
				if (policyInfo.IncomeRevenue ~= 0) then
					iIncome = round(iIncome + iIncome*(policyInfo.IncomeRevenue/100))
				end
				if (policyInfo.BusinessRevenue ~= 0) then
					iBusiness = round(iBusiness + iBusiness*(policyInfo.BusinessRevenue/100))
				end
				if (policyInfo.TradeRevenue ~= 0) then
					iImport = round(iImport + iImport*(policyInfo.TradeRevenue/100))
					iExport = round(iExport + iExport*(policyInfo.TradeRevenue/100))
				end
				if policyInfo.ImprovementTax then
					local improvementInfo = GameInfo.Improvements[policyInfo.ImprovementTax]
					if improvementInfo then
						iIncome = round(iIncome + (self.m_Player:GetImprovementCount(improvementInfo.ID)*(policyInfo.TaxPerImproved/100))) 
					end
				end
			end

			iEstimate = (iIncome + iBusiness + iImport + iExport)
		end
		return iEstimate
    end,
	--------------------------------------------------------------
    GetRevenueTotal = function( self )
		return self.m_iRevenue_Total
    end,
	--------------------------------------------------------------
    GetIncomeTaxRevenue = function( self )
		return self.m_iRevenue_Income
    end,
	--------------------------------------------------------------
    GetBusinessTaxRevenue = function( self )
		return self.m_iRevenue_Business
    end,
	--------------------------------------------------------------
    GetExportTaxRevenue = function( self )
		return self.m_iRevenue_Exports
    end,
	--------------------------------------------------------------
    GetImportTaxRevenue = function( self )
		return self.m_iRevenue_Imports
    end,
	--------------------------------------------------------------
    UpdateExpense = function( self )
		if self:CanBasicTax() then
			local player = self.m_Player
			local iCities = 0
			local iPolicy =	0
			local iMilitary = 0
			local iBuilding = 0
			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			local iDebtService = negative( self:GetDebtPayment() )
						
			--cities require maintenance
			local capital = player:GetCapitalCity()
			if capital then
				local x, y = capital:GetX(), capital:GetY()
				for city in player:Cities() do
					if not city:IsCapital() then
						local iDistance = Map.PlotDistance(x, y, city:GetX(), city:GetY())
						local iExpense = (-POPULATION_CITY_MULTIPLIER * city:GetPopulation() * (iDistance/BASE_WORLD_SIZE))
						if city:IsPuppet() then
							iExpense = (iExpense * 0.60)
						end
						if player:IsCapitalConnectedToCity(city) then
							iExpense = (iExpense * 0.85)
						end
						iCities = iCities + round(iExpense)
					end
				end
			end
			
			--policies require gold to implement
			iPolicy = round( -BASE_EXPENSE_RATE * player:GetNumPolicies() * (self:GetCurrentPopulation()/POPULATION_MULTIPLIER) )	
			
			--defensive, espionage, courthouses require maintenance
			for row in GameInfo.Buildings() do
				local iCount = player:CountNumBuildings(row.ID)
				if (iCount > 0) then
					local iCost = round(-BASE_EXPENSE_RATE * iCount * row.Cost)
					if (row.Defense > 0) then
						iMilitary = iMilitary + iCost
					elseif row.NoOccupiedUnhappiness or (row.NumCityCostMod > 0) then
						iBuilding = iBuilding + iCost
					elseif IsExpansion then
						if row.Espionage then
							iBuilding = iBuilding + iCost
						end
					end
				end
			end
			
			--military buildings require maintenance
			local temp = {}
			for row in GameInfo.Building_DomainFreeExperiences() do
				local buildingInfo = GameInfo.Buildings[row.BuildingType] 
				if buildingInfo then
					temp[row.BuildingType] = buildingInfo
				end
			end
			for _,buildingInfo in pairs(temp) do
				local iCount = player:CountNumBuildings(buildingInfo.ID)
				if (iCount > 0) then
					iMilitary = iMilitary + round(-BASE_EXPENSE_RATE * iCount * buildingInfo.Cost)
				end
			end
			
			if policyInfo then
				if (policyInfo.CityExpense ~= 0) then
					iCities = round(iCities + iCities*(policyInfo.CityExpense/100))
				end
				if (policyInfo.PolicyExpense ~= 0) then
					iPolicy = round(iPolicy + iPolicy*(policyInfo.PolicyExpense/100))
				end
				if (policyInfo.MilitaryExpense ~= 0) then
					iMilitary = round(iMilitary + iMilitary*(policyInfo.MilitaryExpense/100))
				end
				if (policyInfo.GovernmentExpense ~= 0) then
					iBuilding = round(iBuilding + iBuilding*(policyInfo.GovernmentExpense/100))
				end
			end
			
			self.m_iExpense_Cities = iCities
			self.m_iExpense_Policy = iPolicy
			self.m_iExpense_Military = iMilitary
			self.m_iExpense_Building = iBuilding
			self.m_iExpense_Total = (iCities + iPolicy + iMilitary + iBuilding + iDebtService)
		end
    end,
	--------------------------------------------------------------
    GetExpenseTotal = function( self )
		return self.m_iExpense_Total
    end,
	--------------------------------------------------------------
    GetExpenseCities = function( self )
		return self.m_iExpense_Cities
    end,
	--------------------------------------------------------------
    GetExpensePolicy = function( self )
		return self.m_iExpense_Policy
    end,
	--------------------------------------------------------------
    GetExpenseMilitary = function( self )
		return self.m_iExpense_Military
    end,
	--------------------------------------------------------------
    GetExpenseBuilding = function( self )
		return self.m_iExpense_Building
    end,	
	--------------------------------------------------------------
	-- DEBT MANAGEMENT
	--------------------------------------------------------------
    CanIssueDebt = function( self )
		return self.m_bEnableDebt
    end,
	--------------------------------------------------------------
    DoIssueDebt = function( self, iPrincipal )
		local iValue = up(iPrincipal + (iPrincipal * self:GetInterestRate()))
		self:ChangeDebtTotal( iValue )
		self:ChangeDebtPayment( up(iValue/BASE_DEBT_TERM) )
		self.m_Player:ChangeGold( iPrincipal )
    end,
	--------------------------------------------------------------
    GetDebtRatio = function( self )
		local fDebtRatio = 0.00
		if self:CanIssueDebt() then
			if (self:GetTotalGDP() > 0) then
				fDebtRatio = round((self:GetDebtTotal()/self:GetTotalGDP()), 2)
			end
			local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
			if policyInfo and (policyInfo.DebtLimit ~= 0) then
				fDebtRatio = fDebtRatio * policyInfo.DebtLimit/100
			end
		end
		return fDebtRatio
    end,
	--------------------------------------------------------------
    GetDebtTotal = function( self )
		return self.m_iDebt_Total
    end,
	--------------------------------------------------------------
    ChangeDebtTotal = function( self, iValue )
		local iTotal = self.m_iDebt_Total + iValue
		iTotal = (iTotal < 0) and 0 or iTotal
		iTotal = down(iTotal)
		self.m_iDebt_Total = iTotal
    end,
	--------------------------------------------------------------
    GetDebtPayment = function( self )
		local iPayment = self.m_iDebt_Payment
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo and (policyInfo.DebtPayment ~= 0) then
			iPayment = round(iPayment + (iPayment*(policyInfo.DebtPayment/100)))
		end
		return iPayment
    end,
	--------------------------------------------------------------
    GetDebtPaymentEstimate = function( self, iPrincipal )
		local iValue = up(iPrincipal + (iPrincipal * self:GetInterestRate()))
		return up(iValue/BASE_DEBT_TERM)
    end,
	--------------------------------------------------------------
    SetDebtPayment = function( self, iValue )
		self.m_iDebt_Payment = iValue
    end,
	--------------------------------------------------------------
    ChangeDebtPayment = function( self, iValue )
		local iTotal = self.m_iDebt_Payment + iValue
		iTotal = (iTotal < 0) and 0 or iTotal
		self.m_iDebt_Payment = up(iTotal)
    end,
	--------------------------------------------------------------
    GetInterestRate = function( self )
		return self.m_fInterest_Rate
    end,
	--------------------------------------------------------------
    UpdateInterestRate = function( self )
		if not self:CanIssueDebt() then
			return
		end

		local fRate = BASE_INTEREST_RATE
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]

		if policyInfo and (policyInfo.InterestRate ~= 0) then
			fRate = policyInfo.InterestRate/100
		else
			if ( (self:GetDebtTotal()/self:GetTotalGDP()) > DEBT_RATIO_THRESHOLD) then
				fRate = fRate + 0.05
			end

			local fGrowth = self:GetGrowthRate()
			if (fGrowth > GROWTH_BOOM) then
				fRate = fRate - 0.02
			elseif (fGrowth > GROWTH_EXPANSION) then
				fRate = fRate - 0.01
			elseif (fGrowth > GROWTH_STAGNATION) then
				fRate = fRate + 0.02
			elseif (fGrowth > GROWTH_RECESSION) then
				fRate = fRate + 0.04
			else
				fRate = fRate + 0.08
			end
			
			if (self:GetFiscalBalance() > 0) then
				fRate = fRate - 0.01
			else
				fRate = fRate + 0.02
			end

			if self.m_Player:IsPolicyBranchUnlocked(BRANCH_FREEDOM) then
				fRate = fRate + 0.02
			elseif self.m_Player:IsPolicyBranchUnlocked(BRANCH_ORDER) then
				fRate = fRate - 0.01
			elseif self.m_Player:IsPolicyBranchUnlocked(BRANCH_AUTOCRACY) then
				fRate = fRate + 0.04
			end
		end

		fRate = round(fRate, 2)
		fRate = (fRate > MAX_INTEREST_RATE) and MAX_INTEREST_RATE or fRate
		fRate = (fRate < MIN_INTEREST_RATE) and MIN_INTEREST_RATE or fRate

		self.m_fInterest_Rate = fRate
    end,
	--------------------------------------------------------------
    ChangeInterestRate = function( self, iChange )
		local fRate = self.m_fInterest_Rate
		fRate = (fRate + iChange)
		fRate = (fRate > 0.33) and 0.33 or fRate
		fRate = (fRate < 0.01) and 0.01 or fRate
		fRate = round(fRate, 2)
		self.m_fInterest_Rate = fRate
    end,
	--------------------------------------------------------------
	-- POLICY MANAGEMENT
	--------------------------------------------------------------
    SetPolicyTurn = function( self, iTurn )
		self.m_iPolicyTurn = iTurn
    end,
	--------------------------------------------------------------
    SetCurrentPolicy = function( self, iPolicy )
		self.m_iPolicyID = iPolicy
    end,
	--------------------------------------------------------------
    CanChangePolicy = function( self )
		return (self.m_iPolicyTurn <= self.m_iTurn)
    end,
	--------------------------------------------------------------
    GetCurrentPolicyString = function( self )
		local strPolicy = ""
		local policyInfo = GameInfo.Econ_Policies[self.m_iPolicyID]
		if policyInfo then
			strPolicy = locale(policyInfo.Description)
		else
			strPolicy = locale("TXT_KEY_POPUP_FA_ECON_POLICY_NONE")
		end
		return strPolicy
    end,
}
--------------------------------------------------------------
--GLOBAL
--------------------------------------------------------------
function UpdateToArchive()
	for _,econPlayer in pairs(g_EconPlayers) do
		econPlayer:Archive()
	end
end
LuaEvents.Economics_UpdateToArchive.Add( UpdateToArchive )
--------------------------------------------------------------
function UpdateFromArchive(playerID)
	local econPlayer = g_EconPlayers[playerID]
	if econPlayer then
		econPlayer:RestoreFromArchive(Game.GetGameTurn())
		econPlayer:UpdateGlobal()
	end
end
LuaEvents.Economics_UpdateFromArchive.Add( UpdateFromArchive )
--------------------------------------------------------------
function GetCurrentRevenueTotal(playerID)
	if g_EconPlayers[playerID] then
		return g_EconPlayers[playerID]:GetRevenueTotal()
	end
	return 0
end
--------------------------------------------------------------
function GetCurrentExpenseTotal(playerID)
	if g_EconPlayers[playerID] then
		return g_EconPlayers[playerID]:GetExpenseTotal()
	end
	return 0
end
--------------------------------------------------------------
function GetCurrentPoliticalCapital(playerID)
	if g_EconPlayers[playerID] then
		return g_EconPlayers[playerID]:GetPoliticalExpense()
	end
	return 0
end
--------------------------------------------------------------
function GetPoliticalCapitalTooltip()
	return locale("TXT_KEY_TP_FA_ECON_POLITICAL_CAPITAL_MISC")
end
--------------------------------------------------------------
function DoGlobalEvent()
	if (currentEra < BASE_EVENT_ERA) then
		return
	end

	local fGlobalIndex = gT.g_GlobalEconomicIndex or 0
	if (fGlobalIndex < GROWTH_STAGNATION) and (random() < BASE_EVENT_CHANCE) then
		local iTurns = random(2, BASE_EVENT_TURNS)
		local fEventMalus = random(MED_EVENT_MALUS,MAX_EVENT_MALUS)/100
		for _,econPlayer in pairs(g_EconPlayers) do
			if not econPlayer:IsActiveEvent() then
				econPlayer:SetEventTurn( Game.GetGameTurn() + iTurns )
				econPlayer:SetEventMalus( round(fEventMalus, 2) )
				if (econPlayer.m_Player:IsHuman()) then 
					local popupInfo = {
						Title = locale("TXT_KEY_POPUP_FA_ECON_EVENT_DEPRESSION_GLOBAL", date(Game.GetGameTurnYear())), 
						Text = locale("TXT_KEY_POPUP_FA_ECON_EVENT_GLOBAL_HELP", percent(fEventMalus), iTurns),
					}
					LuaEvents.FA_Economics_EconPopup(popupInfo)
				end
			end
		end
	end
end
--------------------------------------------------------------
--LISTENER
--------------------------------------------------------------
function PrintData(econPlayer)
	print("-----------------------------")
	print(econPlayer.m_Player:GetName() .. " Economic Report for Turn " .. econPlayer.m_iTurn)
	print("-----------------------------")
	print("GDP TOTAL:", econPlayer:GetTotalGDP())
	print("GDP GROWTH:", econPlayer:GetGrowthRate())
	print("GDP Consumer:", econPlayer:GetConsumerGDP())
	print("GDP Government:", econPlayer:GetGovernmentGDP())
	print("GDP Turn Gov:", econPlayer:GetTurnGovernmentGDP())
	print("GDP Investment:", econPlayer:GetInvestmentGDP())
	print("GDP Turn Invest:", econPlayer:GetTurnInvestmentGDP())
	print("GDP Trade:", econPlayer:GetTradeGDP())
	
	print("Market Speculation?:", econPlayer:CanMarkets())
	print("Market Rate:", econPlayer:GetMarketRate())
	
	print("Basic Tax?:", econPlayer:CanBasicTax())
	print("Expanded Tax?:", econPlayer:CanExpandedTax())
	print("Tax Rate AVG:", econPlayer:GetAverageTaxRate())
	
	print("Revenue TOTAL:", econPlayer:GetRevenueTotal())
	print("Income Tax:", econPlayer:GetIncomeTaxRevenue())
	print("Business Tax:", econPlayer:GetBusinessTaxRevenue())
	print("Exports Tax:", econPlayer:GetExportTaxRevenue())
	print("Imports Tax:", econPlayer:GetImportTaxRevenue())

	print("Expense TOTAL:", econPlayer:GetExpenseTotal())
	print("Cities Expense:", econPlayer:GetExpenseCities())
	print("Policy Expense:", econPlayer:GetExpensePolicy())
	print("Military Expense:", econPlayer:GetExpenseMilitary())
	print("Building Expense:", econPlayer:GetExpenseBuilding())
	print("Political Expense:", econPlayer:GetPoliticalExpense())
	print("Debt Service Expense:", econPlayer:GetDebtPayment())
	
	print("Unemployment:", econPlayer:GetUnemploymentRate())
	print("Issue Debt?:", econPlayer:CanIssueDebt())
	print("Debt TOTAL:", econPlayer:GetDebtTotal())
	print("Interest Rate:", econPlayer:GetInterestRate())

	print("Current Policy:", econPlayer:GetCurrentPolicyString())

	print("Events Enabled:", econPlayer:CanEvents())
	print("Active Event?:", econPlayer:IsActiveEvent())
	print("Event Turn:", econPlayer.m_iEventTurn)
	print("Event Malus:", econPlayer:GetEventMalus())
	print("-----------------------------")
	print("-----------------------------")
end
--------------------------------------------------------------
function OnPlayerDoTurn(playerID)
	if (playerID == 63) then
		local startTime = os.clock()
		local globalIndex = {}
		for _,econPlayer in pairs(g_EconPlayers) do
			if econPlayer:IsActive() then
				if econPlayer:IsAIPlayer() then
					econPlayer:AIDoFiscal()
					econPlayer:AIDoPolicy()
				end
				econPlayer:UpdateGlobal(true)
				insert(globalIndex, econPlayer:GetGrowthRate())
			end
		end

		local fGlobalIndex = round(average(globalIndex), 2)
		gT.g_GlobalEconomicIndex = fGlobalIndex
		DoGlobalEvent()

		local saveTime = os.clock() - startTime
		print("Turn ".. Game.GetGameTurn() .. " processing time:" .. saveTime)
	end
end
--------------------------------------------------------------
function OnTeamSetEra(iTeamID, iEra)
	for _,player in pairs(g_EconPlayers) do
		if (player.m_TeamID == iTeamID) then
			 player:UpdateEraEnables(iEra)
			 if (iEra > currentEra) then
				currentEra = iEra
			 end
			 break
		end
	end
end
--------------------------------------------------------------
function OnEraChanged(iEra, iPlayer)
	for _,player in pairs(g_EconPlayers) do
		if (player.m_PlayerID == iPlayer) then
			 player:UpdateEraEnables(iEra)
			  if (iEra > currentEra) then
				currentEra = iEra
			 end
			 break
		end
	end
end
--------------------------------------------------------------
function OnWarStateChanged(iTeamID, iOtherTeamID, bWar)
	for _,player in pairs(g_EconPlayers) do
		local teamID = player.m_TeamID
		if (teamID == iTeamID) or (teamID == iOtherTeamID) then
			 player:UpdateGlobal()
		end
	end
end
--------------------------------------------------------------
function OnPlayerPoliciesDirty(playerID, policyID)
	local econPlayer = g_EconPlayers[playerID]
	if econPlayer then
		econPlayer:UpdateGlobal()
	end
end
--------------------------------------------------------------
function OnUnitCreated(playerID, unitID)
	local econPlayer = g_EconPlayers[playerID]
	if econPlayer then
		local unit = Players[playerID]:GetUnitByID(unitID)
		if unit then 
			local iChange = unit:GetScrapGold()
			if unit:IsCombatUnit() then
				econPlayer:ChangeGovernmentSpending( PRODUCTION_MOD * iChange )
			else
				econPlayer:ChangeInvestmentSpending( PRODUCTION_MOD * iChange )
			end
			econPlayer:UpdateGlobal()
		end
	end
end
--------------------------------------------------------------
function OnBuildingComplete(playerID, cityID, buildingID, bGold, bFaithOrCulture)
	if bGold or bFaithOrCulture then
		local econPlayer = g_EconPlayers[playerID]
		if econPlayer then
			local buildingInfo = GameInfo.Buildings[buildingID]
			local iChange = Players[playerID]:GetCityByID(cityID):GetSellBuildingRefund(buildingID)
			iChange = round( (PRODUCTION_MOD * iChange) / PURCHASE_DIVISOR)
			if buildingInfo.NukeImmune or buildingInfo.NeverCapture then
				econPlayer:ChangeGovernmentSpending( iChange )
			else
				econPlayer:ChangeInvestmentSpending( iChange )
			end
			econPlayer:UpdateGlobal()
		end
	end
end
--------------------------------------------------------------------
function OnImprovementComplete(playerID, iX, iY, improvementID)
	local econPlayer = g_EconPlayers[playerID]
	if econPlayer then
		if (improvementID ~= -1) then
			local improvementInfo = GameInfo.Improvements[improvementID]
			local iChange = up(improvementInfo.PillageGold / 3)
			iChange = (iChange > 0) and iChange or 3
			iChange = econPlayer:GetCurrentEraID() * iChange
			if (improvementInfo.DefenseModifier > 0) or improvementInfo.CreatedByGreatPerson then
				econPlayer:ChangeGovernmentSpending( PRODUCTION_MOD * iChange )
			else
				econPlayer:ChangeInvestmentSpending( PRODUCTION_MOD * iChange )
			end
			econPlayer:UpdateGlobal()
		end
	end
end
--------------------------------------------------------------------
function OnCityFounded(playerID, x, y)
	local econPlayer = g_EconPlayers[playerID]
	if econPlayer then
		econPlayer:UpdateGlobal()
	end
end
--------------------------------------------------------------------
function OnCityCaptured (iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
    local newPlayer = g_EconPlayers[iNewOwner]
	if newPlayer then
		newPlayer:UpdateGlobal()
	end
	local oldPlayer = g_EconPlayers[iOldOwner]
	if oldPlayer then
		oldPlayer:UpdateGlobal()
	end
end
--------------------------------------------------------------
-- Initialize
--------------------------------------------------------------
function OnLoadScreenClose()
	for i = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local player = Players[i]
		if player and player:IsEverAlive() then
			if (g_EconPlayers[i] == nil) then
				g_EconPlayers[i] = {}
			end
			g_EconPlayers[i] = g_EconClass:new( i )

			if (player:GetCurrentEra() > currentEra) then
				currentEra = player:GetCurrentEra()
			end
		end
	end

	GameEvents.PlayerDoTurn.Add( OnPlayerDoTurn )
	GameEvents.CityCaptureComplete.Add(OnCityCaptured)
	GameEvents.PlayerCityFounded.Add(OnCityFounded)
	Events.WarStateChanged.Add( OnWarStateChanged )
	Events.SerialEventUnitCreated.Add(OnUnitCreated)
	Events.EventPoliciesDirty.Add(OnPlayerPoliciesDirty)
	
	if IsBNW then
		GameEvents.CityConstructed.Add(OnBuildingComplete)
		GameEvents.BuildFinished.Add( OnImprovementComplete )
		GameEvents.TeamSetEra.Add(OnTeamSetEra)
	else
		Events.SerialEventEraChanged.Add(OnEraChanged)
	end

	LuaEvents.Economics_UpdateTopPanel()
	print("Economics Mod Loaded...")
end
