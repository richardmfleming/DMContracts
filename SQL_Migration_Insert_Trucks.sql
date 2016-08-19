/**********************************************************************/
/***  Migrate Trucks										    	***/
/***  Created by RB May 2016								    	***/
/***                                                                ***/
/***  Insert imported Trucks data from FOPSQL01.tfm.Lorries			***/
/***	into TRUCKS tables											***/
/***                                                                ***/
/***	Last modified												***/
/***                                                                ***/
/**********************************************************************/

USE wts_coillte

DECLARE @ID	varchar(10)
DECLARE @SQL varchar(1000)

-- Get the Next ID to use for PARTY
SELECT @ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'TRUCKS';    

-- Insert Trucks

-- First create a temp for trucks table with populated id
CREATE TABLE #Trucks (
--	TruckID		int	IDENTITY (1,1),		-- Hard coded starting value; should be picked up from NEXT_SEQ table.
	TruckReg	varchar(15),
	HaulierCode	varchar(5),
	DeletedInd	varchar(3),
	PartyID		numeric(10)
	)

-- Add an identity column that has the seed as @ID
SELECT  @SQL = 'ALTER TABLE #Trucks ADD TruckID int IDENTITY(' + @ID + ' ,1)'
Exec (@SQL) 
-- test - SELECT @SQL

INSERT INTO #Trucks
  SELECT	LORRY_REG,
			HAULIER_CODE,
			'No',
			NULL		--	Default value for PartyID
	FROM [FOPSQL01].[tfm].[dbo].[Lorries]

-- Delete any values that are already in Trucks
DELETE FROM  #Trucks
  WHERE TruckReg  IN (
						  SELECT TRUCK_LICENSE_NUM collate SQL_Latin1_General_CP1_CI_AS
							FROM [wts_coillte].[wts_coillte].[TRUCKS]
					    )

-- Update the Party ID for trucks 
UPDATE #Trucks
  SET PartyID = [wts_coillte].[PARTY].[PARTY_ID]
    FROM #Trucks
	INNER JOIN [wts_coillte].[PARTY] 
	ON #Trucks.HaulierCode collate SQL_Latin1_General_CP1_CI_AS = [wts_coillte].[PARTY].[COMMENTS] collate SQL_Latin1_General_CP1_CI_AS

--Test  
--select * from #Trucks

-- Insert Trucks table
INSERT INTO [wts_coillte].[wts_coillte].[TRUCKS]
  SELECT	trk.TruckID,
			trk.PartyID,
			trk.TruckID,
			lor.BANNED_FLAG,
			'Lorry',
			CASE lor.LORRY_TYPE	-- Transform Lorry type to correct code in Cengea
				WHEN 1 THEN 'R'
				WHEN 2 THEN 'RT'
				WHEN 3 THEN 'A'
				ELSE ''
			END,
			trk.TruckReg,
			lor.NO_OF_AXLES,
			lor.EST_LORRY_WEIGHT,
			'kg',
			0,
			0,
			lor.MAX_LEGAL_WEIGHT,
			't',
			lor.HAULIER_CODE,
			trk.DeletedInd
	FROM	#Trucks AS trk
	INNER JOIN [FOPSQL01].[tfm].[dbo].[Lorries]  AS lor 
	ON lor.LORRY_REG collate SQL_Latin1_General_CP1_CI_AS = trk.TruckReg collate SQL_Latin1_General_CP1_CI_AS 
	WHERE trk.PartyID IS NOT NULL



-- Get the Next ID to use for Lorry
SELECT @ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_LORRY';    

-- Create a temp table for SD_LORRY
CREATE TABLE #SD_LORRY (
--	LorryID				int	IDENTITY (15,1),		-- Hard coded starting value; should be picked up from NEXT_SEQ table.
	HaulierID			numeric(10,0),
	LorryRegistration	varchar(15),
	LorryType			varchar(3),
	NumAxles			numeric(10,0),
	Crane				varchar(3),
	MaxLegalWeight		numeric(5,2),
	TareWeight			numeric(5,2),
	OnHaulageLicense	varchar(3),
	DefaultDriver		varchar(20),
	KeyFobID			int,
	MaxTrpPerLorry		numeric(6,0),
	Suspended			varchar(3),
	ActiveInd			varchar(3),
	ICTSActivated		varchar(3),
	PartyID				numeric(10,0)
	)

-- Add an identity column that has the seed as @ID
SELECT  @SQL = 'ALTER TABLE #SD_LORRY ADD LorryID int IDENTITY(' + @ID + ' ,1)'
Exec (@SQL) 
-- test - SELECT @SQL

INSERT INTO #SD_LORRY
  SELECT	sdh.HAULIER_ID,			-- Not all trucks are connected to Hauliers
			trk.TRUCK_LICENSE_NUM,
			trk.TRUCK_TYPE_CODE,
			trk.TRUCK_AXLES,
			'N',					-- Default Crane
			trk.TRUCK_CAPACITY,
			0,						-- Default Tare Weight
			'Y',					-- Default OnHaulageLicense value
			'',						-- Default Driver
			kfb.KEYFOB_ID,			-- Not all trucks are connected to KeyFobs
			100000,					-- Default Max Trip Per lorry
			NULL,					-- Default Suspended
			'Yes',					-- Default Active Indicator
			'Yes',					-- Default ICTS Activated
			trk.PARTY_ID
	FROM [wts_coillte].[TRUCKS] AS trk
	LEFT JOIN [wts_coillte].[SD_HAULIER] AS sdh ON sdh.PARTY_ID = trk.PARTY_ID
	LEFT JOIN [wts_coillte].[SD_KEYFOB]  AS kfb ON kfb.LORRY_REGISTRATION = trk.TRUCK_LICENSE_NUM

-- Test
Select * from #SD_LORRY

-- Insert into SD_LORRY table
INSERT INTO [wts_coillte].[wts_coillte].[SD_LORRY]
  SELECT
	sdl.LorryID,
	sdl.HaulierID,
	sdl.LorryRegistration,
	sdl.LorryType,
	sdl.NumAxles,
	sdl.Crane,
	sdl.MaxLegalWeight,
	sdl.TareWeight,
	sdl.OnHaulageLicense,
	sdl.DefaultDriver,
	sdl.KeyFobID,
	sdl.MaxTrpPerLorry,
	sdl.Suspended,
	sdl.ActiveInd,
	sdl.ICTSActivated,
	sdl.PartyID
	FROM #SD_LORRY AS sdl


---- Update the next_seq table for Trucks
UPDATE [wts_coillte].[NEXT_SEQ]
  SET NEXT_ID = (
					SELECT MAX (trk.TRUCK_ID) + 1
					FROM [wts_coillte].[wts_coillte].[TRUCKS] AS trk
				)
	WHERE KEYWORD = 'TRUCKS'

---- Update the next_seq table for SD_LORRY
UPDATE [wts_coillte].[NEXT_SEQ]
  SET NEXT_ID = (
					SELECT MAX (sdl.LORRY_ID) + 1
					FROM [wts_coillte].[SD_LORRY] AS sdl
				)
	WHERE KEYWORD = 'SD_LORRY'

-- Drop temp tables
 DROP TABLE #Trucks  
 DROP TABLE #SD_LORRY


-- test
--SELECT * FROM [wts_coillte].[wts_coillte].[TRUCKS]
--Select * from [wts_coillte].[SD_LORRY]

