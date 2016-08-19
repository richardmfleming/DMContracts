/**********************************************************************/
/***  Migrate Key fobs										    	***/
/***  Created by RB May 2016								    	***/
/***                                                                ***/
/***  Insert imported Key fobs data in FOPSQL01.tfm.Key_Fobs		***/
/***	into SD_KEYFOB table										***/
/***                                                                ***/
/***	Run Trucks first											***/
/***	Last modified												***/
/***		Added a comment to test GITHUB							***/
/***                                                                ***/
/**********************************************************************/

USE wts_coillte

IF OBJECT_ID('tempdb..#TEMP_CTRS') IS NOT NULL DROP TABLE #KeyFobs 

DECLARE @ID	varchar(10)
DECLARE @SQL varchar(1000)

-- Get the Next ID to use for KEYFOB
SELECT @ID = NEXT_ID          
FROM [wts_coillte].[NEXT_SEQ]         
WHERE KEYWORD = 'SD_KEYFOB';    

-- Insert Key Fobs

-- First create a temp table with populated id
CREATE TABLE #KeyFobs (
--	KeyFobID	int	IDENTITY (11,1),   -- hardcoded start ID; shouls come from Next_SEQ table
	Key_Fob_No	varchar(10),
	ActiveInd	varchar(3), 
	LorryReg	varchar(20) 
	)

-- Add an identity column that has the seed as @ID
SELECT  @SQL = 'ALTER TABLE #KeyFobs ADD KeyFobID int IDENTITY(' + @ID + ' ,1)'
Exec (@SQL) 
-- test - SELECT @SQL

INSERT INTO #KeyFobs 
  SELECT	KEY_FOB_NO,
			'Yes',
			[LORRY_REG]
	FROM [FOPSQL01].[tfm].[dbo].[Key_Fobs]

--Test  
--select * from #key_fobs_hold

-- Delete any values that are already in SD_KEYFOB
DELETE FROM  [wts_coillte].[wts_coillte].[SD_KEYFOB]
  WHERE KEYFOB_NO IN (
						SELECT Key_Fob_No collate SQL_Latin1_General_CP1_CI_AS
						  FROM #KeyFobs 
					  )


-- Insert into key_fobs table
INSERT INTO [wts_coillte].[wts_coillte].[SD_KEYFOB]
  SELECT	KeyFobID, 
			Key_Fob_No,
			ActiveInd,
			LorryReg,
			NULL
	FROM	#KeyFobs 

-- Update the Lorry ID
UPDATE [wts_coillte].[SD_KEYFOB]
  SET [wts_coillte].[SD_KEYFOB].[LORRY_ID] = [wts_coillte].SD_LORRY.LORRY_ID
    FROM [wts_coillte].[SD_KEYFOB]
	INNER JOIN [wts_coillte].SD_LORRY
	ON [wts_coillte].[SD_KEYFOB].[LORRY_REGISTRATION] collate SQL_Latin1_General_CP1_CI_AS = [wts_coillte].SD_LORRY.LORRY_REGISTRATION collate SQL_Latin1_General_CP1_CI_AS

UPDATE [wts_coillte].[NEXT_SEQ]
  SET NEXT_ID =  (
					SELECT MAX (kfh.id) + 1
					FROM #KeyFobs AS kfh
				)
	WHERE KEYWORD = 'SD_KEYFOB'

-- test
--SELECT * FROM [wts_coillte].[wts_coillte].[SD_KEYFOB]

