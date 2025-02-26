------------------------------------------------------------   
--Econ Policies
------------------------------------------------------------    
CREATE TABLE IF NOT EXISTS Econ_Policies 
( 
  ID integer primary key autoincrement,
  Type					TEXT not null unique,
  Description			text DEFAULT null,
  Help					text DEFAULT null,
  EraReq				text DEFAULT null,
  UnemploymentRate		integer DEFAULT 0,
  InterestRate			integer DEFAULT 0,
  DebtLimit				integer DEFAULT 0,
  DebtPayment			integer DEFAULT 0,
  ConsumerGDP			integer DEFAULT 0,
  ConsumerHappiness		integer DEFAULT 0,
  GovernmentGDP			integer DEFAULT 0,
  ConsumerToInvestment	integer DEFAULT 0,
  GovToInvestment		integer DEFAULT 0,
  GovToConsumer			integer DEFAULT 0,
  SpecialistInvest		integer DEFAULT 0,
  InvestmentGDP			integer DEFAULT 0,
  ImportGDP				integer DEFAULT 0,
  ExportGDP				integer DEFAULT 0,
  IncomeRevenue			integer DEFAULT 0,
  BusinessRevenue		integer DEFAULT 0,
  TradeRevenue			integer DEFAULT 0,
  PolicyExpense			integer DEFAULT 0,
  GovernmentExpense		integer DEFAULT 0,
  MilitaryExpense		integer DEFAULT 0,
  CityExpense			integer DEFAULT 0,
  PoliticalExpense		integer DEFAULT 0,
  IncomeTax				integer DEFAULT 0,
  BusinessTax			integer DEFAULT 0,
  TradeTax				integer DEFAULT 0,
  ImprovementTax		text DEFAULT null,
  TaxPerImproved		integer DEFAULT 0,
  OpenBorderGDP			integer DEFAULT 0,
  EnemyGDP				integer DEFAULT 0,
  AlliedMinorGDP		integer DEFAULT 0,
  Stability				boolean DEFAULT 0,
  NoTradeDeficit		boolean DEFAULT 0,
  NoTaxPenalty			boolean DEFAULT 0,
  BullMarket			boolean DEFAULT 0,
  DepressionChance		integer DEFAULT 0,
  AIWeight				integer DEFAULT 0
);

INSERT INTO Econ_Policies(Type,			Description,										Help,												EraReq,				UnemploymentRate,	InterestRate,	DebtLimit,	DebtPayment,	ConsumerGDP,	ConsumerHappiness,	GovernmentGDP,	GovToConsumer,	GovToInvestment,	ConsumerToInvestment,	InvestmentGDP,	SpecialistInvest,	ImportGDP,	ExportGDP,	IncomeRevenue,	BusinessRevenue,	TradeRevenue,	PolicyExpense,	GovernmentExpense,	MilitaryExpense,	CityExpense,	PoliticalExpense,	IncomeTax,	BusinessTax,	TradeTax,	ImprovementTax,				TaxPerImproved,	OpenBorderGDP,	EnemyGDP,	AlliedMinorGDP,	NoTradeDeficit,	NoTaxPenalty,	BullMarket,	Stability,	DepressionChance) 
SELECT 'ECON_POLICY_SLAVERY',			'TXT_KEY_POPUP_FA_ECON_POLICY_SLAVERY',				'TXT_KEY_POPUP_FA_ECON_POLICY_SLAVERY',				'ERA_CLASSICAL',	0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						0,				0,					0,			0,			-20,			0,					0,				0,				0,					0,					0,				0,					0,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				0,			1,			0 UNION ALL
SELECT 'ECON_POLICY_CURRENCY',			'TXT_KEY_POPUP_FA_ECON_POLICY_CURRENCY',			'TXT_KEY_POPUP_FA_ECON_POLICY_CURRENCY',			'ERA_CLASSICAL',	0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						0,				0,					0,			0,			0,				0,					0,				10,				0,					0,					0,				0,					0,			0,				0,			'IMPROVEMENT_MINE',			50,				0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_MANOR_SYSTEM',		'TXT_KEY_POPUP_FA_ECON_POLICY_MANOR_SYSTEM',		'TXT_KEY_POPUP_FA_ECON_POLICY_MANOR_SYSTEM',		'ERA_MEDIEVAL',		0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						0,				0,					0,			0,			0,				0,					0,				0,				0,					0,					-33,			50,					0,			0,				0,			'IMPROVEMENT_PLANTATION',	100,			0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_GUILD_SYSTEM',		'TXT_KEY_POPUP_FA_ECON_POLICY_GUILD_SYSTEM',		'TXT_KEY_POPUP_FA_ECON_POLICY_GUILD_SYSTEM',		'ERA_MEDIEVAL',		0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						0,				200,				0,			0,			0,				0,					0,				0,				0,					0,					5,				0,					0,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_LAISSEZ_FAIRE',		'TXT_KEY_POPUP_FA_ECON_POLICY_LAISSEZ_FAIRE',		'TXT_KEY_POPUP_FA_ECON_POLICY_LAISSEZ_FAIRE',		'ERA_RENAISSANCE',	0,					7,				0,			0,				0,				0,					-50,			0,				0,					0,						0,				0,					25,			25,			0,				0,					0,				0,				0,					0,					0,				0,					0,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_MERCANTILISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_MERCANTILISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_MERCANTILISM',		'ERA_RENAISSANCE',	0,					0,				0,			0,				0,				0,					10,				0,				0,					0,						0,				0,					0,			0,			0,				0,					-50,			0,				0,					0,					0,				0,					0,			0,				0,			'IMPROVEMENT_TRADING_POST',	150,			0,				0,			4,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_MARXISM',			'TXT_KEY_POPUP_FA_ECON_POLICY_MARXISM',				'TXT_KEY_POPUP_FA_ECON_POLICY_MARXISM',				'ERA_INDUSTRIAL',	0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						-25,			0,					0,			0,			0,				-10,				0,				-50,			0,					0,					0,				-85,				0,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_WAR_ECONOMY',		'TXT_KEY_POPUP_FA_ECON_POLICY_WAR_ECONOMY',			'TXT_KEY_POPUP_FA_ECON_POLICY_WAR_ECONOMY',			'ERA_INDUSTRIAL',	-10,				0,				0,			0,				-10,			0,					0,				0,				0,					0,						0,				0,					0,			0,			0,				0,					0,				0,				0,					-85,				0,				0,					0,			0,				0,			NULL,						0,				0,				5,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_KEYNESIANISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_KEYNESIANISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_KEYNESIANISM',		'ERA_MODERN',		-5,					0,				0,			0,				0,				0,					0,				50,				0,					0,						0,				0,					0,			0,			0,				0,					0,				0,				25,					0,					0,				0,					55,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_BANKING',			'TXT_KEY_POPUP_FA_ECON_POLICY_BANKING',				'TXT_KEY_POPUP_FA_ECON_POLICY_BANKING',				'ERA_MODERN',		0,					0,				0,			0,				0,				0,					0,				0,				0,					0,						0,				0,					0,			0,			0,				33,					0,				0,				0,					0,					0,				0,					0,			0,				0,			NULL,						0,				0,				0,			0,				0,				0,				1,			0,			-75 UNION ALL
SELECT 'ECON_POLICY_FREE_TRADE',		'TXT_KEY_POPUP_FA_ECON_POLICY_FREE_TRADE',			'TXT_KEY_POPUP_FA_ECON_POLICY_FREE_TRADE',			'ERA_MODERN',		6,					0,				0,			0,				0,				0,					0,				0,				10,					0,						0,				0,					0,			0,			0,				0,					0,				0,				0,					0,					0,				0,					0,			0,				0,			NULL,						0,				3,				0,			0,				1,				0,				0,			0,			0 UNION ALL
SELECT 'ECON_POLICY_MONETARISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_MONETARISM',			'TXT_KEY_POPUP_FA_ECON_POLICY_MONETARISM',			'ERA_POSTMODERN',	0,					5,				50,			0,				0,				0,					0,				0,				0,					15,						0,				0,					0,			0,			0,				0,					10,				0,				0,					0,					0,				0,					0,			12,				12,			NULL,						0,				0,				0,			0,				0,				0,				0,			0,			5 UNION ALL
SELECT 'ECON_POLICY_STATE_SOCIALISM',	'TXT_KEY_POPUP_FA_ECON_POLICY_STATE_SOCIALISM',		'TXT_KEY_POPUP_FA_ECON_POLICY_STATE_SOCIALISM',		'ERA_POSTMODERN',	0,					0,				0,			-50,			0,				33,					0,				0,				0,					0,						0,				0,					0,			0,			0,				0,					0,				33,				0,					0,					0,				0,					0,			0,				0,			NULL,						0,				0,				0,			0,				0,				1,				0,			0,			0;

------------------------------------------------------------    
--Font Textures
------------------------------------------------------------    
INSERT INTO IconFontTextures (IconFontTexture,	IconFontTextureFile)
SELECT 'ICON_FONT_TEXTURE_ECONOMICS',			'Econ_FontIcons';

INSERT INTO IconFontMapping (IconName,	IconFontTexture,					IconMapping)
SELECT 'ICON_ECONOMICS',				'ICON_FONT_TEXTURE_ECONOMICS',		1;

------------------------------------------------------------   
--JFD_TopPanelIncludes
------------------------------------------------------------    
CREATE TABLE IF NOT EXISTS JFD_TopPanelIncludes
( 
  FileName				text DEFAULT null
);

CREATE TABLE IF NOT EXISTS JFD_TopPanelAdditions
( 
  CivilizationType		text	REFERENCES Civilizations(Type)	DEFAULT null,
  YieldType				text	REFERENCES Yields(Type)			DEFAULT null,
  YieldSourceFunction	text									DEFAULT null,
  YieldSourceToolTip	text									DEFAULT null,
  MiscToolTipFunction	text									DEFAULT null
);

INSERT INTO JFD_TopPanelIncludes(FileName) 
SELECT 'Econ_Player.lua';

INSERT INTO JFD_TopPanelAdditions(CivilizationType,	YieldType,			YieldSourcefunction,			YieldSourceToolTip,						MiscToolTipFunction)
SELECT NULL,										'YIELD_CULTURE',	'GetCurrentPoliticalCapital',	'TXT_KEY_TP_FA_ECON_POLITICAL_CAPITAL',	'GetPoliticalCapitalTooltip' UNION ALL
SELECT NULL,										'YIELD_GOLD',		'GetCurrentRevenueTotal',		'TXT_KEY_TP_FA_ECON_TAX_REVENUE',		NULL UNION ALL
SELECT NULL,										'YIELD_GOLD',		'GetCurrentExpenseTotal',		'TXT_KEY_TP_FA_ECON_TAX_EXPENSE',		NULL;
