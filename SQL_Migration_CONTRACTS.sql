/****************************************************************************************/
/* Migrate FIS Contracts to wts_coillte/TFM												*/
/*																						*/
/* FIS CONTRACT HEADS																	*/
/* FIS CONTRACT LINES																	*/
/*																						*/
/* Tables to update																		*/
/*																						*/
/* WTS_COILLTE.CONTRACTS						- Contract								*/
/* WTS_COILLTE.SD_CONTRACTS						- Contract Extension 					*/
/* WTS_COILLTE.SD_CCF_RCT_FORM					- Relevant Contract Tax Form			*/
/* WTS_COILLTE.SD_CCF_AWARD_APPROVAL			- Contract Approver						*/	
/* WTS_COILLTE.CONTRACT_ORG_SCOPE				- Contract Organisation Scope			*/
/* WTS_COILLTE.CONTRACTED_PARTY					- Contracted Party						*/
/* WTS_COILLTE.SD_TFM_ACTIVITY_CONTRACT_LINK											*/
/* WTS_COILLTE.SD_CONTRACT_ACTIVITY_LINE												*/
/* TFM.VMV_TFM_SILV_ACTIVITY															*/
/* WTS_COILLTE.SD_SIN							- Site Identification Number (SIN)      */
/* TFM.VMV_TFM_SILV_UNIT*																*/
/* WTS_COILLTE.SD_CONTRACT_BIDDING_SCHEDULE*											*/
/* WTS_COILLTE.SD_CONTRACT_REVIEW_STATUS_LOG*											*/
/*																						*/
/*	Entry Criteria																		*/
/*	Contract Status = A (Authorised), H (Hold), W (Work Recorded) or U (Unauthorised)	*/
/*	Analysis Code = ESTB (Establishment)												*/
/*	Expiry Date > Cutoff Date agreed with Finance										*/
/*	Contract Value - Contract Value Received > 0										*/		
/*																						*/
/*   *OPTIONAL																			*/
/*																						*/
/*																						*/
/*  RF July 2016											  							*/
/*																						*/
/*  Last modified				     													*/
/*																						*/
/*	Added Data Migration as Create User and Getdate() as Create Date					*/
/*	to SD_Contracts to be able to recognise which ones are added.						*/
/*	Added expiry date as entry criteria													*/
/*											RB 11-Jul-2016								*/
/*	Added filter for Tendered Establishment Contracts 'T/E1','T/E4','T/ES','T/GP'		*/
/*											RB 13-Jul-2016								*/
/*  Insert for WTS_COILLTE.CONTRACT_ORG_SCOPE											*/
/*											RB 15-Jul-2016								*/
/*  Divided Contract Value by 100 in SD_Contracts										*/
/*											RB 18-Jul-2016								*/
/*  Added filter for Maintenance Contracts 'T/MA'										*/
/*											RB 19-Jul-2016								*/
/*  Added filter for Roads Contracts 'ROAD'												*/
/*											RB 19-Jul-2016								*/
/*  Added filter for Haulage Contracts 'HAUL'											*/
/*											RB 19-Jul-2016								*/
/*  Added filter for Harvesting Contracts 'HARV'										*/
/*											RB 19-Jul-2016								*/
/*	Insert for SD_CCF_RCT_FORM															*/
/*											RB 21/07/2016								*/
/*	Modify Insert for SD_CCF_RCT_FORM												    */
/*											RF 04/08/2016								*/
/*	Insert for WTS_COILLTE.SD_SIN													    */
/*											RF 04/08/2016								*/
/*	Insert for WTS_COILLTE.SD_CCF_AWARD_APPROVAL									    */
/*											RF 10/08/2016								*/
/*																						*/
/*	Delete all migrated data in all contexts    									    */
/*											RF 17/08/2016								*/
/*																						*/
/*	To Do																				*/
/*			Contract Lines																*/
/****************************************************************************************/

USE wts_coillte
GO

-- Set up Temp Files with data drawn from FOPSQL01 FIS over Linked Server

IF OBJECT_ID('tempdb..#TEMP_CTRS') IS NOT NULL DROP TABLE #TEMP_CTRS
GO
IF OBJECT_ID('tempdb..#TEMP_CTR_INSURANCE_DETS') IS NOT NULL DROP TABLE #TEMP_CTR_INSURANCE_DETS
GO
IF OBJECT_ID('tempdb..#TEMP_CT_HEADS') IS NOT NULL DROP TABLE #TEMP_CT_HEADS
GO
IF OBJECT_ID('tempdb..#TEMP_CT_LINES') IS NOT NULL DROP TABLE #TEMP_CT_LINES
GO
IF OBJECT_ID('tempdb..#TEMP_CTR_ADDRESSES') IS NOT NULL DROP TABLE #TEMP_CTR_ADDRESSES
GO
IF OBJECT_ID('tempdb..#TEMP_CT_USERS') IS NOT NULL DROP TABLE #TEMP_CT_USERS
GO
IF OBJECT_ID('tempdb..#TEMP_HAUL_DESTS') IS NOT NULL DROP TABLE #TEMP_HAUL_DESTS
GO
IF OBJECT_ID('tempdb..#TEMP_SUB_OPERATIONS') IS NOT NULL DROP TABLE #TEMP_SUB_OPERATIONS
GO
IF OBJECT_ID('tempdb..#TEMP_OPERATIONS') IS NOT NULL DROP TABLE #TEMP_OPERATIONS
GO
IF OBJECT_ID('tempdb..#TEMP_AGRESSO_MRCTCONTRACT') IS NOT NULL DROP TABLE #TEMP_AGRESSO_MRCTCONTRACT
GO
IF OBJECT_ID('tempdb..#TEMP_APPROVER') IS NOT NULL DROP TABLE #TEMP_APPROVER
GO

-- FIS CTRS Temp Table
SELECT *
INTO #TEMP_CTRS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CTRS]') 
GO
-- FIS CTR_INSURANCE_DETS Temp Table
SELECT *
INTO #TEMP_CTR_INSURANCE_DETS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CTR_INSURANCE_DETS]') 
GO
-- FIS CT_HEADS Temp Table
SELECT *
INTO #TEMP_CT_HEADS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CT_HEADS]') 
GO
-- FIS CT_LINES Temp Table
SELECT *
INTO #TEMP_CT_LINES
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CT_LINES]') 
GO
-- FIS CTR_ADDRESSES Temp Table
SELECT *
INTO #TEMP_CTR_ADDRESSES
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CTR_ADDRESSES]') 
GO
-- FIS CT_USERS Temp Table
SELECT *
INTO #TEMP_CT_USERS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[CT_USERS]') 
GO
-- FIS HAUL_DESTS Temp Table
SELECT *
INTO #TEMP_HAUL_DESTS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[HAUL_DESTS]') 
GO
-- FIS SUB_OPERATIONS Temp Table
SELECT *
INTO #TEMP_SUB_OPERATIONS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[SUB_OPERATIONS]') 
GO
-- FIS OPERATIONS Temp Table
SELECT *
INTO #TEMP_OPERATIONS
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[OPERATIONS]') 
GO
-- FIS AGRESSO_MRCTCONTRACT Temp Table
SELECT *
INTO #TEMP_AGRESSO_MRCTCONTRACT
FROM
OPENQUERY([FOPSQL01],'SELECT * FROM [FIS].[dbo].[AGRESSO_MRCTCONTRACT]') 
GO
-- Approver Temp Table
CREATE TABLE #TEMP_APPROVER
  ( 
ORG_UNIT_ID	numeric(10,0),
DISPLAY_NAME VARCHAR(50),	
FIRST_NAME VARCHAR(20),
LAST_NAME VARCHAR(20),	
USERNAME VARCHAR(20)
  ) 

INSERT INTO #TEMP_APPROVER
(ORG_UNIT_ID,DISPLAY_NAME,FIRST_NAME,LAST_NAME,USERNAME)
VALUES
(100,	'GERARD BRITCHFIELD',	'GERARD',	'BRITCHFIELD',	'BRITCHFLD_G'),
(8,	'BERNARD BURKE',	'BERNARD',	'BURKE',	'BURKE_BJ'),
(100,	'MARK CARLIN',	'MARK',	'CARLIN',	'CARLIN_M'),
(7,	'PAT CARROLL',	'PAT',	'CARROLL',	'CARROLL_P'),
(3,	'NOEL CASSIDY',	'NOEL',	'CASSIDY',	'CASSIDY_N'),
(2,	'TONY CLARKE',	'TONY',	'CLARKE',	'CLARKE_T'),
(100,	'SEAMUS CORRY',	'SEAMUS',	'CORRY',	'CORRY_S'),
(100,	'FINDAN COX',	'FINDAN',	'COX',	'COX_F'),
(1,	'JIM CROWLEY',	'JIM',	'CROWLEY',	'CROWLEY_J'),
(5,	'CONOR DEVANE',	'CONOR',	'DEVANE',	'DEVANE_C'),
(100,	'DAVID FEENEY',	'DAVID',	'FEENEY',	'FEENEY_D'),
(4,	'GERRY GAVIN',	'GERRY',	'GAVIN',	'GAVIN_G'),
(100,	'EAMONN KEELY',	'EAMONN',	'KEELY',	'KEELY_E'),
(100,	'FERGAL LEAMY',	'FERGAL',	'LEAMY',	'LEAMY_F'),
(5,	'PETER MCGLOIN',	'PETER',	'MCGLOIN',	'MCGLOIN_P'),
(100,	'GERRY MURPHY',	'GERRY',	'MURPHY',	'MURPHY_G'),
(100,	'GERARD MURPHY',	'GERARD',	'MURPHY',	'MURPHY_GP'),
(1,	'JOHN O''CONNOR',	'JOHN',	'O''CONNOR',	'OCONNOR_JG'),
(1,	'JIM O''NEILL',	'JIM',	'O''NEILL',	'ONEILL_J'),
(100,	'JOHN O''SULLIVAN',	'JOHN',	'O''SULLIVAN',	'OSULLIVAN_J'),
(6,	'MICHAEL POWER',	'MICHAEL',	'POWER',	'POWER_M'),
(100,	'GERRY RIORDAN',	'GERRY',	'RIORDAN',	'RIORDAN_G'),
(1,	'PAT ROCHE',	'PAT',	'ROCHE',	'ROCHE_P'),
(4,	'PAUL RUANE',	'PAUL',	'RUANE',	'RUANE_PF'),
(100,	'NICK RYAN',	'NICK',	'RYAN',	'RYAN_N'),
(100,	'PJ TRAIT',	'PJ',	'TRAIT'	,'TRAIT_PJ'),
(8,	'IZABELLA WITKOWSKA',	'IZABELLA',	'WITKOWSKA', 'WITKOWSKA_I')

SELECT * FROM #TEMP_APPROVER
------------------------
-- Declaration Section
------------------------

DECLARE @NEXT_ID	numeric(10,0)


--------------------------------------------------------------------------------------------------------------------------------------
-- CONTRACTS
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- WTS_COILLTE.SD_SIN 
--
-- Do the Site Identification Number table first. Populate with all types 
-- of legacy contracts in scope
-------------------------------------------------------------------------------

DECLARE @NEXT_ID	numeric(10,0)

SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_SIN'

INSERT INTO WTS_COILLTE.SD_SIN		(
										SIN_ID,
										SIN,
										ORG_UNIT_ID,
										COUNTY
									 )

-------------------------------------------------------------------------
---  Test this SELECT statement before running the INSERT            ----
-------------------------------------------------------------------------

SELECT

MAX(SIN_ID) AS SIN_ID,
MAX(SIN_NUMBER) AS SIN_NUMBER,
100 AS ORG_UNIT_ID,
MAX(COUNTY) AS COUNTY

FROM

(
SELECT
ISNULL((@NEXT_ID - 1),1) + ROW_NUMBER() OVER(ORDER BY AG_MRCT.CONTRACT_ID) AS SIN_ID,
AG_MRCT.SIN_NUMBER, 
AG_MRCT.SITE_COUNTY AS COUNTY
  FROM #TEMP_CT_HEADS  AS cth
	JOIN #TEMP_AGRESSO_MRCTCONTRACT AS AG_MRCT
	ON cth.CT_NO = AG_MRCT.CONTRACT_ID
	WHERE LEN(AG_MRCT.SIN_NUMBER) > 1 
	AND cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS
) A

GROUP BY A.SIN_NUMBER

GO

-----------------------------
-- Update sequence numbers --
-----------------------------
UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SIN_ID) + 1
				FROM WTS_COILLTE.SD_SIN
			  )
WHERE KEYWORD = 'SD_SIN'

SELECT * FROM WTS_COILLTE.SD_SIN

--SELECT COUNT (*), SIN FROM WTS_COILLTE.SD_SIN GROUP BY SIN  --** Check for duplicates


-------------------------------------------------------------------------------
-- WTS_COILLTE.CONTRACTS 
-------------------------------------------------------------------------------
----------------------------------------------------

-- Begin Insert into CONTRACTS table

-- Get the Next ID to use for CONTRACTS
DECLARE @NEXT_ID	numeric(10,0)

SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'CONTRACTS'


INSERT INTO WTS_COILLTE.CONTRACTS
(
CONTRACT_ID,
CONTRACT_NUM,
CONTRACT_TYPE_CODE,
CREATE_DATE,
EXPIRY_DATE,
CONTRACT_STATUS_CODE,
CONTRACT_NOTES,
START_DATE_DESC,
CONTRACT_MANAGER_ID,
MAIN_PARTY_ID,
failed_condition,
contract_template,
user_name,
deleted
)
SELECT
(@NEXT_ID - 1) + ROW_NUMBER() OVER(ORDER BY cth.CT_NO) AS CONTRACT_ID,
--'L' + RIGHT(YEAR(cth.CT_DATE),2) + REPLICATE('0',5-LEN(ROW_NUMBER() OVER(ORDER BY cth.CT_NO))) + RTRIM(ROW_NUMBER() OVER(ORDER BY cth.CT_NO)) AS CONTRACT_NUM,
CAST(cth.CT_NO AS VARCHAR) AS CONTRACT_NUM,
'SILV' AS CONTRACT_TYPE_CODE,
cth.CT_DATE AS CREATE_DATE,
cth.CT_PLAN_END AS EXPIRY_DATE,
CASE cth.CT_STATUS 
WHEN 'H' THEN 'HOLD' 
WHEN 'U' THEN 'DRFT'
WHEN 'W' THEN 'ACC'
ELSE 'AC' END AS CONTRACT_STATUS_CODE,
cth.COMMENTS AS CONTRACT_NOTES,
CAST(DATEPART(YEAR, cth.CT_DATE) AS VARCHAR) AS START_DATE_DESC,
1034 AS CONTRACT_MANAGER_ID,   -- Seamus Corry
(SELECT TOP 1 PARTY_ID FROM WTS_COILLTE.PARTY PTY 
	WHERE PTY.CORPORATE_PARTY_NUMBER = cth.CTR_CODE COLLATE SQL_Latin1_General_CP1_CI_AS) AS MAIN_PARTY_ID,
'No' AS failed_condition,
'No' AS contract_template,
'DATA_MIGRATION' AS user_name,
'No' AS deleted
FROM #TEMP_CT_HEADS  AS cth
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

GO
-----------------------------
-- Update sequence numbers --
-----------------------------

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (CONTRACT_ID) + 1
				FROM [wts_coillte].[wts_coillte].[CONTRACTS]
			  )
WHERE KEYWORD = 'CONTRACTS'

SELECT * FROM WTS_COILLTE.CONTRACTS
------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- WTS_COILLTE.SD_CONTRACTS 
-------------------------------------------------------------------------------

INSERT INTO WTS_COILLTE.SD_CONTRACTS 
(
CONTRACT_ID,
PROCUREMENT_PACKAGE_ID,
RESOURCE_TYPE_ID,
WORK_PACKAGE_TYPE,
TAX_TYPE,
INSURANCE_TYPE,
--AWARD_DATE,
CONTRACT_VALUE,
TAX_VALUE,
VALUE_RECEIPTED,
ROS_NUMBER,
ROS_EXPIRY,
CONTRACT_STATUS_CODE,
--COMPLETION_DATE,
--CONTRACT_LINE_VALUE,
PROACTIS_CONTRACT_ID,
--CONTRACT_STATUS_UPDATE,
CREATE_USER,
CREATE_DATE,
MODIFY_USER,
MODIFY_DATE
--START_DATE_UPDATE,
--END_DATE_UPDATE
)
SELECT
(SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS CTRS 
  WHERE CTRS.CONTRACT_NUM = cth.CT_NO COLLATE SQL_Latin1_General_CP1_CI_AS) AS CONTRACT_ID,
NULL AS PROCUREMENT_PACKAGE_ID,
2 AS RESOURCE_TYPE_ID, -- contractor
'STC' AS WORK_PACKAGE_TYPE, -- from SD_D_TENDER_TYPE
'Relevant Contract Tax' AS TAX_TYPE,
CASE cth.CT_INS_TYPE
WHEN 'A' THEN 'CI'
WHEN 'S' THEN 'CONT'
WHEN 'N' THEN 'NR'
ELSE NULL END AS INSURANCE_TYPE, 
--AS AWARD_DATE,
cth.CT_VALUE / 100 AS CONTRACT_VALUE,
cth.CT_VAT_VALUE / 100 AS TAX_VALUE,
cth.CT_VALUE_RECEIVED / 100 AS VALUE_RECEIPTED,
AG_MRCT.RCT_CONTRACT AS ROS_NUMBER,
AG_MRCT.DATE_END AS ROS_EXPIRY,
CASE cth.CT_STATUS 
WHEN 'H' THEN 'HOLD' 
WHEN 'U' THEN 'DRFT'
WHEN 'W' THEN 'ACC'
ELSE 'AC' END AS CONTRACT_STATUS_CODE,
--AS COMPLETION_DATE,
--AS CONTRACT_LINE_VALUE,
cth.PROACTIS_CONTRACT_CODE AS PROACTIS_CONTRACT_ID,
--AS CONTRACT_STATUS_UPDATE,
'DATA_MIGRATION' AS CREATE_USER,
CAST(GETDATE() AS datetime2) AS CREATE_DATE,
'DATA_MIGRATION' AS MODIFY_USER,
CAST(GETDATE() AS datetime2) AS MODIFY_DATE
--AS START_DATE_UPDATE,
--AS END_DATE_UPDATE

 FROM #TEMP_CT_HEADS  AS cth
	LEFT JOIN #TEMP_AGRESSO_MRCTCONTRACT AS AG_MRCT
	ON cth.CT_NO = AG_MRCT.CONTRACT_ID
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

SELECT * FROM WTS_COILLTE.SD_CONTRACTS 

-----------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- WTS_COILLTE.SD_CCF_RCT_FORM    
-------------------------------------------------------------------------------

-- *Must have run WTS_COILLTE.SD_SIN above first
DECLARE @NEXT_ID	numeric(10,0)

SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_CCF_RCT_FORM'

INSERT INTO WTS_COILLTE.SD_CCF_RCT_FORM (
	[SD_CCF_RCT_FORM_ID],							-- [numeric](10, 0) NOT NULL,
	[CONTRACT_ID],									-- [numeric](10, 0) NOT NULL,
	[DECLARATION],									-- [numeric](1, 0) NULL,
	[RCT_SECTOR],									-- [varchar](5) NULL,
	[SUB_NOT_LABOUR_ONLY],							-- [numeric](1, 0) NULL,
	[SUB_MATERIALS],								-- [numeric](1, 0) NULL,
	[SUB_MACHINERY],								-- [numeric](1, 0) NULL,
	[SUB_HAS_OTHERS],								-- [numeric](1, 0) NULL,
	[SUB_CONTRACT_PYMT],							-- [numeric](1, 0) NULL,
	[SUB_PENSION_EX],								-- [numeric](1, 0) NULL,
	[SUB_OWN_TRANSPORT],							-- [numeric](1, 0) NULL,
	[SUB_AGREES_COST],								-- [numeric](1, 0) NULL,
	[SUB_OWN_INSURANCE],							-- [numeric](1, 0) NULL,
	[SUB_CHOOSE_METHOD],							-- [numeric](1, 0) NULL,
	[SUB_OWN_ACCOUNT],								-- [numeric](1, 0) NULL,
	[SUB_RISK_EXPOSED],								-- [numeric](1, 0) NULL,
	[SIN],											-- [numeric](10, 0) NULL
	[ADDRESS_LINE_1],								-- [varchar](250) NULL
	[ADDRESS_LINE_2],								-- [varchar](250) NULL
	[ADDRESS_LINE_3],								-- [varchar](250) NULL
	[COUNTY],										-- [varchar](5) NULL
	[EIRCODE]										-- [varchar](10) NULL
									)
SELECT
(@NEXT_ID - 1) + ROW_NUMBER() OVER(ORDER BY cth.CT_NO) AS SD_CCF_RCT_FORM_ID,
(SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS CTRS 
  WHERE CTRS.CONTRACT_NUM = cth.CT_NO COLLATE SQL_Latin1_General_CP1_CI_AS) AS CONTRACT_ID,
1 AS DECLARATION,
AG_MRCT.RCT_SECTOR AS RCT_SECTOR,
AG_MRCT.SUB_NOT_LABOUR_ONLY AS SUB_NOT_LABOUR_ONLY,
AG_MRCT.SUB_MATERIALS AS SUB_MATERIALS,
1 AS SUB_MACHINERY,
AG_MRCT.SUB_HAS_OTHERS AS SUB_HAS_OTHERS,
AG_MRCT.SUB_CONTRACT_PYMT AS SUB_CONTRACT_PYMT,
AG_MRCT.SUB_PENSION_EX AS SUB_PENSION_EX,
AG_MRCT.SUB_OWN_TRANSPORT AS SUB_OWN_TRANSPORT,
AG_MRCT.SUB_AGREES_COST AS SUB_AGREES_COST,
AG_MRCT.SUB_OWN_INSURANCE AS SUB_OWN_INSURANCE,
AG_MRCT.SUB_CHOOSE_METHOD AS SUB_CHOOSE_METHOD,
AG_MRCT.SUB_OWN_ACCOUNT AS SUB_OWN_ACCOUNT,
AG_MRCT.SUB_RISK_EXPOSED AS SUB_RISK_EXPOSED,
(SELECT SIN_ID FROM WTS_COILLTE.SD_SIN SD_SIN
	WHERE SD_SIN.SIN = AG_MRCT.SIN_NUMBER COLLATE SQL_Latin1_General_CP1_CI_AS) AS SIN,
AG_MRCT.SITE_ADDR1 AS ADDRESS_LINE_1,		-- Address 1
AG_MRCT.SITE_ADDR2 AS ADDRESS_LINE_2,		-- Address 2
AG_MRCT.SITE_ADDR3 AS ADDRESS_LINE_3,		-- Address 3
AG_MRCT.SITE_COUNTY AS COUNTY,		-- County
'DW' AS EIRCODE		-- Identify migrated rows
  FROM #TEMP_CT_HEADS  AS cth
	LEFT JOIN #TEMP_AGRESSO_MRCTCONTRACT AS AG_MRCT
	ON cth.CT_NO = AG_MRCT.CONTRACT_ID

   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

-----------------------------
-- Update sequence numbers --
-----------------------------


UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SD_CCF_RCT_FORM_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CCF_RCT_FORM]
			  )
WHERE KEYWORD = 'SD_CCF_RCT_FORM'

SELECT * FROM WTS_COILLTE.SD_CCF_RCT_FORM

-------------------------------------------------------------------------------
-- WTS_COILLTE.CONTRACT_ORG_SCOPE 
-------------------------------------------------------------------------------

DECLARE @NEXT_ID	numeric(10,0)

SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'CONTRACT_ORG_SCOPE'

INSERT INTO WTS_COILLTE.CONTRACT_ORG_SCOPE (
											[CONTRACT_ORG_SCOPE_ID],
											[CONTRACT_ID],
											[ORG_UNIT_ID]
										   )

-------------------------------------------------------------------------
---  Test this SELECT statement before running the INSERT            ----
--												RB 15/07/2016		-----
-------------------------------------------------------------------------

SELECT
(@NEXT_ID - 1) + ROW_NUMBER() OVER(ORDER BY cth.CT_NO),
(SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS CTRS 
  WHERE CTRS.CONTRACT_NUM = cth.CT_NO COLLATE SQL_Latin1_General_CP1_CI_AS) AS CONTRACT_ID,
ISNULL((SELECT TOP 1 ORG_UNIT_ID FROM wts_coillte.HUMAN_RESOURCE HR
WHERE HR.LAST_NAME = TA.LAST_NAME COLLATE Latin1_General_CI_AS AND HR.FIRST_NAME = TA.FIRST_NAME COLLATE Latin1_General_CI_AS), 100) AS ORG_UNIT_ID
  FROM #TEMP_CT_HEADS  AS cth
  LEFT JOIN #TEMP_APPROVER TA
  ON cth.CT_AUTHORIZER = TA.USERNAME COLLATE Latin1_General_CI_AS
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

-----------------------------
-- Update sequence numbers --
-----------------------------
UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (CONTRACT_ORG_SCOPE_ID) + 1
				FROM [wts_coillte].[wts_coillte].[CONTRACT_ORG_SCOPE]
			  )
WHERE KEYWORD = 'CONTRACT_ORG_SCOPE'

SELECT * FROM WTS_COILLTE.CONTRACT_ORG_SCOPE

----------------------------------------------------------------------------------------------------------------
-- WTS_COILLTE.SD_CCF_AWARD_APPROVAL 
--
--* Disable Trigger [wts_coillte].[SD_TRIG_APPROVE_ACTIVE] on this table first then enable it again after insert
-----------------------------------------------------------------------------------------------------------------
DECLARE @NEXT_ID	numeric(10,0)

SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_CCF_AWARD_APPROVAL'

INSERT INTO WTS_COILLTE.SD_CCF_AWARD_APPROVAL 
(
[SD_CCF_AWARD_APPROVAL_ID],
[CONTRACT_ID],
[BIDDING_RANKING],
[SUPPLIER_PERFORMANCE_SCORE],
[PANEL_ID_REFERENCE],
[ACTIVITY_MONITORING_SCORE],
[NOTES],
[APPROVAL_1_DATE],
[APPROVAL_2_DATE],
[SPS_ATTACHMENT],
--[APPROVER_1_ID],
--[APPROVER_2_ID],
--[APPROVER_1_ROLE_ID],
--[APPROVER_2_ROLE_ID],
[TENDER_PACKAGE_NUM]
)

-------------------------------------------------------------------------
---  Test this SELECT statement before running the INSERT            ----
-------------------------------------------------------------------------

SELECT
(@NEXT_ID - 1) + ROW_NUMBER() OVER(ORDER BY cth.CT_NO) AS SD_CCF_AWARD_APPROVAL_ID,
(SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS CTRS 
  WHERE CTRS.CONTRACT_NUM = cth.CT_NO COLLATE SQL_Latin1_General_CP1_CI_AS) AS CONTRACT_ID,

NULL AS BIDDING_RANKING,
NULL AS SUPPLIER_PERFORMANCE_SCORE,
NULL AS PANEL_ID_REFERENCE,
NULL AS ACTIVITY_MONITORING_SCORE,
'AUTHORIZER: ' + cth.CT_AUTHORIZER AS NOTES,
NULL AS APPROVAL_1_DATE,
NULL AS APPROVAL_2_DATE,
NULL AS SPS_ATTACHMENT,
--NULL AS APPROVER_1_ID,
--(SELECT TOP 1 HUMAN_RESOURCE_ID FROM wts_coillte.HUMAN_RESOURCE HR
--WHERE HR.LAST_NAME = TA.LAST_NAME COLLATE Latin1_General_CI_AS AND HR.FIRST_NAME = TA.FIRST_NAME COLLATE Latin1_General_CI_AS) AS APPROVER_1_ID,
--NULL AS APPROVER_2_ID,
--NULL AS APPROVER_1_ROLE_ID,
--NULL AS APPROVER_2_ROLE_ID,
cth.PACKAGE_NUMBER AS TENDER_PACKAGE_NUM

  FROM #TEMP_CT_HEADS  AS cth
  LEFT JOIN #TEMP_APPROVER TA
  ON cth.CT_AUTHORIZER = TA.USERNAME COLLATE Latin1_General_CI_AS
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

-----------------------------
-- Update sequence numbers --
-----------------------------
UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SD_CCF_AWARD_APPROVAL_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CCF_AWARD_APPROVAL]
			  )
WHERE KEYWORD = 'SD_CCF_AWARD_APPROVAL'

SELECT * FROM WTS_COILLTE.SD_CCF_AWARD_APPROVAL


--SELECT CT_AUTHORIZER, MAX(THL.mail) FROM #TEMP_CT_HEADS CTH
--LEFT JOIN TEMP_HR_LOOKUP THL
--ON THL.sAMAccountName = CTH.CT_AUTHORIZER COLLATE SQL_Latin1_General_CP1_CI_AS
--GROUP BY CT_AUTHORIZER
--ORDER BY MAX(THL.mail)


--------------------------------------------------------------------------------------------------------------------------------------
-- CONTRACT ACTIVITY LINES
--------------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- WTS_COILLTE.SD_CONTRACT_ACTIVITY_LINE
-------------------------------------------------------------------------------
----------------------------------------------------


-- Get the Next ID to use for CONTRACT_ACTIVITY_LINE


SELECT @NEXT_ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_CONTRACT_ACTIVITY_LINE'


INSERT INTO WTS_COILLTE.SD_CONTRACT_ACTIVITY_LINE
(
 [ACTIVITY_LINE_ID]
,[CONTRACT_ID]
,[TFMCONTEXTID]
,[OBJECTID]
,[ACTIVITY_TYPE]
,[ACTIVITY_TYPE_SUBTYPE]
,[AWARDED_QUANTITY]
,[AWARDED_UNIT_COST]
,[AWARDED_UOM]
,[AWARDED_TOTAL_COST]
,[POSTED_CWRS]
,[PENDING_CWRS]
,[VALUE_REMAINING]
,[ACTIVE_CONTRACT_FLAG]
,[AWARD_MANUAL_UPDATE_FLAG]
,[AVG_TREE]
)
SELECT
(@NEXT_ID - 1) + ROW_NUMBER() OVER(ORDER BY cth.CT_NO) AS CONTRACT_ID,
--'L' + RIGHT(YEAR(cth.CT_DATE),2) + REPLICATE('0',5-LEN(ROW_NUMBER() OVER(ORDER BY cth.CT_NO))) + RTRIM(ROW_NUMBER() OVER(ORDER BY cth.CT_NO)) AS CONTRACT_NUM,
CAST(cth.CT_NO AS VARCHAR) AS CONTRACT_NUM,

FROM #TEMP_CT_HEADS  AS cth
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS


-----------------------------
-- Update sequence numbers --
-----------------------------

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (ACTIVITY_LINE_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CONTRACT_ACTIVITY_LINE]
			  )
WHERE KEYWORD = 'SD_CONTRACT_ACTIVITY_LINE'

------------------------------------------------------------------------


------------------------------------------------------------------------
-- Delete migrated contracts data for all contexts
------------------------------------------------------------------------
-----------------------------------------
-- WTS_COILLTE.SD_CONTRACT_ACTIVITY_LINE Delete
-----------------------------------------

DELETE FROM WTS_COILLTE.SD_CONTRACT_ACTIVITY_LINE 
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (ACTIVITY_LINE_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CONTRACT_ACTIVITY_LINE]
			  )
WHERE KEYWORD = 'SD_CONTRACT_ACTIVITY_LINE'

------------------------------------------

-----------------------------------------
-- WTS_COILLTE.SD_CCF_AWARD_APPROVAL Delete
-----------------------------------------

DELETE FROM WTS_COILLTE.SD_CCF_AWARD_APPROVAL
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SD_CCF_AWARD_APPROVAL_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CCF_AWARD_APPROVAL]
			  )
WHERE KEYWORD = 'SD_CCF_AWARD_APPROVAL'

-----------------------------------------
-- WTS_COILLTE.CONTRACT_ORG_SCOPE Delete
-----------------------------------------

DELETE FROM WTS_COILLTE.CONTRACT_ORG_SCOPE
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (CONTRACT_ORG_SCOPE_ID) + 1
				FROM [wts_coillte].[wts_coillte].[CONTRACT_ORG_SCOPE]
			  )
WHERE KEYWORD = 'CONTRACT_ORG_SCOPE'


-----------------------------------------
-- WTS_COILLTE.SD_CCF_RCT_FORM Delete
-----------------------------------------

DELETE FROM WTS_COILLTE.SD_CCF_RCT_FORM
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SD_CCF_RCT_FORM_ID) + 1
				FROM [wts_coillte].[wts_coillte].[SD_CCF_RCT_FORM]
			  )
WHERE KEYWORD = 'SD_CCF_RCT_FORM'

-----------------------------------------
-- WTS_COILLTE.SD_CONTRACTS Delete
-----------------------------------------

DELETE FROM WTS_COILLTE.SD_CONTRACTS 
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')


-----------------------------------------
-- wts_coillte.CONTRACTED_PARTY Delete 
-----------------------------------------

DELETE FROM wts_coillte.CONTRACTED_PARTY 
WHERE CONTRACT_ID IN (SELECT CONTRACT_ID FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION')

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (CPARTY_ID) + 1
				FROM wts_coillte.CONTRACTED_PARTY
			  )
WHERE KEYWORD = 'CONTRACTED_PARTY'

SELECT * FROM wts_coillte.CONTRACTED_PARTY

-----------------------------------------
-- WTS_COILLTE.CONTRACTS Delete 
-----------------------------------------

DELETE FROM WTS_COILLTE.CONTRACTS WHERE user_name = 'DATA_MIGRATION'

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (CONTRACT_ID) + 1
				FROM [wts_coillte].[wts_coillte].[CONTRACTS]
			  )
WHERE KEYWORD = 'CONTRACTS'


SELECT * FROM WTS_COILLTE.CONTRACTS

-----------------------------------------
-- WTS_COILLTE.SD_SIN Delete 
-----------------------------------------

DELETE FROM WTS_COILLTE.SD_SIN WHERE SIN IN 
(SELECT AG_MRCT.SIN_NUMBER COLLATE SQL_Latin1_General_CP1_CI_AS
  FROM #TEMP_CT_HEADS  AS cth
	JOIN #TEMP_AGRESSO_MRCTCONTRACT AS AG_MRCT
	ON cth.CT_NO COLLATE SQL_Latin1_General_CP1_CI_AS = AG_MRCT.CONTRACT_ID 
	WHERE LEN(AG_MRCT.SIN_NUMBER) > 1 
	AND cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_PLAN_END >  '2016-08-15')		

UPDATE [wts_coillte].[NEXT_SEQ]
SET NEXT_ID = (
				SELECT MAX (SIN_ID) + 1
				FROM WTS_COILLTE.SD_SIN
			  )
WHERE KEYWORD = 'SD_SIN'
------------------------------------------------------------------------
-- End of Delete migrated contracts data for all contexts
------------------------------------------------------------------------





/*
*  Contract Header
*/

/* Columns in Contract Header query
   CTR_CODE, 
   CTR_NAME, 
   CT_NO, 
   CT_DATE, 
   CT_TYPE, 
   CT_ANAL_CODE, 
   CT_MANAGER, 
   LAST_GRN_DATE, 
   CT_VALUE, 
   CT_VALUE_RECEIVED, 
   CT_PAY_FREQUENCY, 
   CT_STATUS, 
   CT_STATUS_SHORT, 
   CT_SPECIFIC, 
   CT_SPECIFIC_DESC, 
   CT_AUTHORIZER, 
   CT_PLAN_END, 
   CT_INS_TYPE, 
   INSURANCE_EXPIRY_DATE, 
   INSURANCE_EXPIRED, 
   CT_TYPE_ABBREV, 
   CT_BALANCE, 
   AUTHORIZED_VALUE, 
   UNAUTHORIZED_VALUE
*/


-- Query FIS Contract Headers data source

   SELECT 
      cth.CTR_CODE, 
      
         (
            SELECT ctr.CTR_NAME
            FROM #TEMP_CTRS  AS ctr
            WHERE ctr.CTR_CODE = cth.CTR_CODE
         ) AS CTR_NAME, 
      cth.CT_NO, 
      cth.CT_DATE, 
      cth.CT_TYPE, 
      cth.CT_ANAL_CODE, 
      cth.CT_MANAGER, 
      cth.LAST_GRN_DATE, 
      cth.CT_VALUE / 100 AS CT_VALUE, 
      cth.CT_VALUE_RECEIVED / 100 AS CT_VALUE_RECEIVED, 
      cth.CT_PAY_FREQUENCY, 
      cth.CT_STATUS, 
      CASE cth.CT_STATUS
         WHEN 'G' THEN 'Gen''ed'
         WHEN 'U' THEN 'Unauth'
         WHEN 'A' THEN 'Auth''d'
         WHEN 'H' THEN 'Held'
         WHEN 'C' THEN 'Complt'
         WHEN 'X' THEN 'Cancld'
         WHEN 'W' THEN 'WrkRec'
         ELSE cth.CT_STATUS
      END AS CT_STATUS_SHORT, 
      cth.CT_SPECIFIC, 
      CASE cth.CT_SPECIFIC
         WHEN 'Y' THEN 'Spec'
         ELSE 'Unsp'
      END AS CT_SPECIFIC_DESC, 
      cth.CT_AUTHORIZER, 
      cth.CT_PLAN_END, 
      cth.CT_INS_TYPE, 
          (
            SELECT max(ctr.EXPIRY_DATE) AS expr
            FROM #TEMP_CTR_INSURANCE_DETS  AS ctr
            WHERE ctr.CTR_CODE = cth.CTR_CODE
         ) AS INSURANCE_EXPIRY_DATE, 
      CASE 
         WHEN cth.CT_INS_TYPE != 'S' THEN 'N'
         WHEN 
            (
               SELECT max(isnull(ctr.EXPIRY_DATE, '01-JAN-1900')) AS expr
               FROM #TEMP_CTR_INSURANCE_DETS  AS ctr
               WHERE cth.CTR_CODE = ctr.CTR_CODE
            ) < GETDATE() THEN 'Y'
         ELSE 'N'
      END AS INSURANCE_EXPIRED, 
      CASE cth.CT_TYPE
         WHEN 'C' THEN 'C2'
         WHEN 'G' THEN 'Gen.'
         WHEN 'P' THEN 'Prof'
         ELSE cth.CT_TYPE
      END AS CT_TYPE_ABBREV, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') IN ( 'A', 'H', 'W' ) AND isnull(cth.CT_VALUE, 0) > isnull(cth.CT_VALUE_RECEIVED, 0) 
			THEN isnull(cth.CT_VALUE, 0) - isnull(cth.CT_VALUE_RECEIVED, 0)
         ELSE 0
      END / 100 AS CT_BALANCE, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') NOT IN ( 'G', 'U', 'X' ) 
			THEN isnull(cth.CT_VALUE, 0)
         ELSE 0
      END / 100 AS AUTHORIZED_VALUE, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') IN ( 'G', 'U', 'X' ) 
			THEN isnull(cth.CT_VALUE, 0)
         ELSE 0
      END / 100 AS UNAUTHORIZED_VALUE
   FROM #TEMP_CT_HEADS  AS cth
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

GO



/*
*  Contract Lines  - use one field as an identifier of migrated data (RB)
*/

/* Columns in Contract Lines query
   CTR_CODE, 
   CT_NO, 
   CT_DATE, 
   CT_PLAN_START, 
   CT_PLAN_END, 
   CT_AUTHORIZER, 
   CT_MANAGER, 
   CT_ANAL_CODE, 
   LAST_GRN_DATE, 
   CT_VALUE, 
   CT_VALUE_RECEIVED, 
   CT_PRINTED, 
   CT_ISSUED, 
   SW_NOTIFIED, 
   NEAR_COMP_NOTIFIED, 
   CT_INS_CERT_PRINTED, 
   CT_INS_TYPE, 
   CT_TYPE, 
   CT_TYPE_ABBREV, 
   CT_STATUS, 
   CT_STATUS_SHORT, 
   CT_SPECIFIC, 
   CT_SPECIFIC_DESC, 
   CT_PAY_FREQUENCY, 
   CT_LINE_NO, 
   OP_CODE, 
   OP_NAME, 
   OP_SNAME, 
   SUB_OP_NO, 
   SUB_OP_NAME, 
   SUB_OP_SNAME, 
   CTL_STATUS, 
   FOREST_CODE, 
   TEAM_MEMBER, 
   CONTRACT_UNIT, 
   CT_QTY, 
   CT_PRICE, 
   CT_QTY_RECEIVED, 
   PLANTING_YEAR, 
   SPECIES_CODE, 
   HAUL_DEST, 
   HAUL_DEST_NAME, 
   VALUE_RECEIVED, 
   CTR_NAME, 
   CTR_TAX_REF, 
   NURSERY_LOCATION, 
   CTL_LOCATION_1, 
   CTL_LOCATION_DESC, 
   CT_BALANCE, 
   CTL_BALANCE_QTY, 
   CTL_BALANCE_VALUE, 
   CTL_VALUE, 
   CTR_ADDRESS_LINE_1, 
   CTR_ADDRESS_LINE_2, 
   CTR_ADDRESS_LINE_3, 
   CTR_ADDRESS_LINE_4, 
   CTR_ADDRESS_LINE_5, 
   CTR_ADDRESS_LINE_6, 
   AUTHORISER_REGION, 
   AUTHORISER_CT_LIMIT
   */

      SELECT 
      cth.CTR_CODE, 
      cth.CT_NO, 
      cth.CT_DATE, 
      cth.CT_PLAN_START, 
      cth.CT_PLAN_END, 
      cth.CT_AUTHORIZER, 
      cth.CT_MANAGER, 
      cth.CT_ANAL_CODE, 
      cth.LAST_GRN_DATE, 
      cth.CT_VALUE / 100 AS CT_VALUE, 
      cth.CT_VALUE_RECEIVED / 100 AS CT_VALUE_RECEIVED, 
      cth.CT_PRINTED, 
      cth.CT_ISSUED, 
      cth.SW_NOTIFIED, 
      cth.NEAR_COMP_NOTIFIED, 
      cth.CT_INS_CERT_PRINTED, 
      cth.CT_INS_TYPE, 
      cth.CT_TYPE, 
      CASE cth.CT_TYPE
         WHEN 'C' THEN 'C2'
         WHEN 'G' THEN 'Gen.'
         WHEN 'P' THEN 'Prof'
         ELSE cth.CT_TYPE
      END AS CT_TYPE_ABBREV, 
      cth.CT_STATUS, 
      CASE cth.CT_STATUS
         WHEN 'G' THEN 'Gen''ed'
         WHEN 'U' THEN 'Unauth'
         WHEN 'A' THEN 'Auth''d'
         WHEN 'H' THEN 'Held'
         WHEN 'C' THEN 'Complt'
         WHEN 'X' THEN 'Cancld'
         WHEN 'W' THEN 'WrkRec'
         ELSE cth.CT_STATUS
      END AS CT_STATUS_SHORT, 
      cth.CT_SPECIFIC, 
      CASE cth.CT_SPECIFIC
         WHEN 'Y' THEN 'Spec'
         ELSE 'Unsp'
      END AS CT_SPECIFIC_DESC, 
      cth.CT_PAY_FREQUENCY, 
      ctl.CT_LINE_NO, 
      ctl.OP_CODE, 
      
         (
            SELECT op.OP_NAME
            FROM #TEMP_OPERATIONS  AS op
            WHERE ctl.OP_CODE IS NOT NULL AND op.OP_CODE = ctl.OP_CODE
         ) AS OP_NAME, 
      
         (
            SELECT op.OP_SNAME
            FROM #TEMP_OPERATIONS  AS op
            WHERE ctl.OP_CODE IS NOT NULL AND op.OP_CODE = ctl.OP_CODE
         ) AS OP_SNAME, 
      ctl.SUB_OP_NO, 
      
         (
            SELECT sop.SUB_OP_NAME
            FROM #TEMP_SUB_OPERATIONS  AS sop
            WHERE 
               ctl.OP_CODE IS NOT NULL AND 
               ctl.SUB_OP_NO IS NOT NULL AND 
               sop.OP_CODE = ctl.OP_CODE AND 
               sop.SUB_OP_NO = ctl.SUB_OP_NO
         ) AS SUB_OP_NAME, 
      
         (
            SELECT sop.SUB_OP_SNAME
            FROM #TEMP_SUB_OPERATIONS  AS sop
            WHERE 
               ctl.OP_CODE IS NOT NULL AND 
               ctl.SUB_OP_NO IS NOT NULL AND 
               sop.OP_CODE = ctl.OP_CODE AND 
               sop.SUB_OP_NO = ctl.SUB_OP_NO
         ) AS SUB_OP_SNAME, 
      ctl.CTL_STATUS, 
      ctl.FOREST_CODE, 
      ctl.TEAM_MEMBER, 
      ctl.CONTRACT_UNIT, 
      ctl.CT_QTY / 1000 AS CT_QTY, 
      ctl.CT_PRICE / 10000 AS CT_PRICE, 
      ctl.CT_QTY_RECEIVED / 1000 AS CT_QTY_RECEIVED, 
      ctl.PLANTING_YEAR, 
      ctl.SPECIES_CODE, 
      ctl.HAUL_DEST, 
      
         (
            SELECT hd.HAUL_DEST_NAME
            FROM #TEMP_HAUL_DESTS  AS hd
            WHERE ctl.HAUL_DEST IS NOT NULL AND hd.HAUL_DEST = ctl.HAUL_DEST
         ) AS HAUL_DEST_NAME, 
      ctl.VALUE_RECEIVED / 100 AS VALUE_RECEIVED, 
      ctr.CTR_NAME, 
      ctr.CTR_TAX_REF, 
      ISNULL(CAST(ctl.PLANTING_YEAR as nvarchar), '') + ' ' + ISNULL(ltrim(rtrim(ctl.SPECIES_CODE)), '') AS NURSERY_LOCATION, 
      CASE 
         WHEN rtrim(ltrim(ctl.WR_LOCATION)) IS NOT NULL AND isnull(ctl.WR_LOC_TYPE, ' ') IN ( 'S', 'R' ) THEN ISNULL(substring(ctl.WR_LOCATION, 1, 4), '') + '-' + ISNULL(substring(ctl.WR_LOCATION, 5, 6), '')
         WHEN rtrim(ltrim(ctl.WR_LOCATION)) IS NOT NULL THEN ctl.WR_LOCATION
         WHEN isnull(CAST(ctl.PLANTING_YEAR as nvarchar), 0) <> 0 OR ltrim(rtrim(ctl.SPECIES_CODE)) IS NOT NULL THEN ISNULL(CAST(ctl.PLANTING_YEAR as nvarchar), '') + ' ' + ISNULL(ltrim(rtrim(ctl.SPECIES_CODE)), '')
         ELSE ' '
      END AS CTL_LOCATION_1, 
      CASE 
         WHEN rtrim(ltrim(ctl.WR_LOCATION)) IS NOT NULL AND isnull(ctl.WR_LOC_TYPE, ' ') IN ( 'S', 'R' ) THEN ISNULL(substring(ctl.WR_LOCATION, 1, 4), '') + '-' + ISNULL(substring(ctl.WR_LOCATION, 5, 6), '')
         ELSE ctl.WR_LOCATION
      END AS CTL_LOCATION_DESC, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') IN ( 'A', 'H', 'W' ) AND isnull(cth.CT_VALUE, 0) > isnull(cth.CT_VALUE_RECEIVED, 0) THEN isnull(cth.CT_VALUE, 0) - isnull(cth.CT_VALUE_RECEIVED, 0)
         ELSE 0
      END / 100 AS CT_BALANCE, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') IN ( 'A', 'H', 'W' ) AND isnull(ctl.CT_QTY, 0) > isnull(ctl.CT_QTY_RECEIVED, 0) THEN isnull(ctl.CT_QTY, 0) - isnull(ctl.CT_QTY_RECEIVED, 0)
         ELSE 0
      END / 1000 AS CTL_BALANCE_QTY, 
      CASE 
         WHEN isnull(cth.CT_STATUS, ' ') IN ( 'A', 'H', 'W' ) AND isnull(ctl.CT_QTY, 0) > isnull(ctl.CT_QTY_RECEIVED, 0) THEN (isnull(ctl.CT_QTY, 0) - isnull(ctl.CT_QTY_RECEIVED, 0)) * isnull(ctl.CT_PRICE, 0) / 100000
         ELSE 0
      END / 100 AS CTL_BALANCE_VALUE, 
      isnull(ctl.CT_QTY, 0) * isnull(ctl.CT_PRICE, 0) / 10000000 AS CTL_VALUE, 
      cta.CTR_ADDRESS_LINE_1, 
      cta.CTR_ADDRESS_LINE_2, 
      cta.CTR_ADDRESS_LINE_3, 
      cta.CTR_ADDRESS_LINE_4, 
      cta.CTR_ADDRESS_LINE_5, 
      cta.CTR_ADDRESS_LINE_6, 
      auth.DIVISION_CODE AS AUTHORISER_REGION, 
      auth.CT_LIMIT AS AUTHORISER_CT_LIMIT
   FROM 
      #TEMP_CT_HEADS  AS cth 
         LEFT OUTER JOIN #TEMP_CT_LINES  AS ctl 
         ON ctl.CT_NO = cth.CT_NO 
         LEFT OUTER JOIN #TEMP_CTRS  AS ctr 
         ON ctr.CTR_CODE = cth.CTR_CODE 
         LEFT OUTER JOIN #TEMP_CTR_ADDRESSES  AS cta 
         ON cta.CTR_CODE = ctr.CTR_CODE 
         LEFT OUTER JOIN #TEMP_CT_USERS  AS auth 
         ON auth.USERNAME = cth.CT_AUTHORIZER
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS


AND cth.CT_NO = 'K1201265'
ORDER BY ctl.CT_LINE_NO
---------------------------------------------------------------------------------------------------------------------------------------------

SELECT OP_CODE, OP_NAME, SUB_OP_NO, SUB_OP_NAME FROM 
(
      SELECT 
 
      ctl.OP_CODE, 
      
         (
            SELECT op.OP_NAME
            FROM #TEMP_OPERATIONS  AS op
            WHERE ctl.OP_CODE IS NOT NULL AND op.OP_CODE = ctl.OP_CODE
         ) AS OP_NAME, 
      
         (
            SELECT op.OP_SNAME
            FROM #TEMP_OPERATIONS  AS op
            WHERE ctl.OP_CODE IS NOT NULL AND op.OP_CODE = ctl.OP_CODE
         ) AS OP_SNAME, 
      ctl.SUB_OP_NO, 
      
         (
            SELECT sop.SUB_OP_NAME
            FROM #TEMP_SUB_OPERATIONS  AS sop
            WHERE 
               ctl.OP_CODE IS NOT NULL AND 
               ctl.SUB_OP_NO IS NOT NULL AND 
               sop.OP_CODE = ctl.OP_CODE AND 
               sop.SUB_OP_NO = ctl.SUB_OP_NO
         ) AS SUB_OP_NAME, 
      
         (
            SELECT sop.SUB_OP_SNAME
            FROM #TEMP_SUB_OPERATIONS  AS sop
            WHERE 
               ctl.OP_CODE IS NOT NULL AND 
               ctl.SUB_OP_NO IS NOT NULL AND 
               sop.OP_CODE = ctl.OP_CODE AND 
               sop.SUB_OP_NO = ctl.SUB_OP_NO
         ) AS SUB_OP_SNAME
      
   FROM 
      #TEMP_CT_HEADS  AS cth 
         LEFT OUTER JOIN #TEMP_CT_LINES  AS ctl 
         ON ctl.CT_NO = cth.CT_NO 
         LEFT OUTER JOIN #TEMP_CTRS  AS ctr 
         ON ctr.CTR_CODE = cth.CTR_CODE 
         LEFT OUTER JOIN #TEMP_CTR_ADDRESSES  AS cta 
         ON cta.CTR_CODE = ctr.CTR_CODE 
         LEFT OUTER JOIN #TEMP_CT_USERS  AS auth 
         ON auth.USERNAME = cth.CT_AUTHORIZER
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
--	AND cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
--	AND cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
--	AND cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
--	AND cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
--	AND cth.CT_ANAL_CODE = 'HARV'								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS
) A

GROUP BY OP_CODE, OP_NAME, SUB_OP_NO, SUB_OP_NAME
ORDER BY OP_CODE, OP_NAME, SUB_OP_NO, SUB_OP_NAME


SELECT cth.CT_AUTHORIZER
FROM #TEMP_CT_HEADS  AS cth
   -- CONTRACT CRITERIA
   WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND (cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
	OR cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
	OR cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
	OR cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
	OR cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
	OR cth.CT_ANAL_CODE = 'HARV')								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS

GROUP BY cth.CT_AUTHORIZER

SELECT cth.CT_AUTHORIZER, CT_STATUS
FROM #TEMP_CT_HEADS  AS cth
WHERE cth.CT_STATUS IN ('A', 'H', 'W', 'U')
	AND (cth.CT_ANAL_CODE = 'ESTB'								-- Use for Establishment Contracts
	OR cth.CT_ANAL_CODE IN ('T/E1','T/E4','T/ES','T/GP')		-- Use for Tendered Establishment Contracts
	OR cth.CT_ANAL_CODE = 'T/MA'								-- Use for Tendered Maintenance Contracts
	OR cth.CT_ANAL_CODE = 'ROAD'								-- Use for Road Contracts
	OR cth.CT_ANAL_CODE = 'HAUL'								-- Use for Haulage Contracts
	OR cth.CT_ANAL_CODE = 'HARV')								-- Use for Harvesting Contracts
	AND cth.CT_PLAN_END >  '2016-08-15'							-- Cutoff Date to be agreed with Finance for expiry of contracts in FIS
	AND LEN(cth.CT_AUTHORIZER) > 2


