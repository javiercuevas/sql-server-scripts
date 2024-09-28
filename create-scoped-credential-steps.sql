

------------------------------------------------------------------------------------
--Step 1: Cred
------------------------------------------------------------------------------------

--ALTER DATABASE SCOPED CREDENTIAL stwus2dwprodCredential  WITH IDENTITY = 'SHARED ACCESS SIGNATURE'  
--, SECRET = 'sp=racwd&st=2022-07-12T22:40:31Z&se=2023-07-13T06:40:31Z&spr=https&sv=2021-06-08&sr=c&sig=lV01CFLQPo%2FYbM50oNCF7yCC6%2BsJHYZ17x6Ed6YrgjA%3D'

--new
ALTER DATABASE SCOPED CREDENTIAL stwus2dwprodCredential  WITH IDENTITY = 'SHARED ACCESS SIGNATURE'  
, SECRET = 'sv=2021-06-08&ss=bfqt&srt=sco&sp=rwdlacupitfx&se=2024-07-14T01:35:46Z&st=2022-07-13T17:35:46Z&spr=https&sig=Gt6Ki1RmVtIYdbjXO9fyXBZakY1Qz3v7ZR%2FGuV%2BAvA4%3D'  

/*
CREATE DATABASE SCOPED CREDENTIAL stwus2dwprodCredential_test 
    WITH IDENTITY='SHARED ACCESS SIGNATURE' 
    , SECRET = 'sv=2021-06-08&sr=c&sig=%2BpFS5%2FMQKyIke4qrP%2BfOKPbrgcUtaUQvZ%2BWY%2FGSOdz0%3D' -- this is the shared access signature token
*/

/*
DROP DATABASE SCOPED CREDENTIAL stwus2dwprodCredential_test 
SELECT * FROM sys.database_scoped_credentials
*/


------------------------------------------------------------------------------------
--Step 2: Data Source
------------------------------------------------------------------------------------
CREATE EXTERNAL DATA SOURCE [ZuoraStage_Test] WITH (TYPE = HADOOP, LOCATION = N'wasbs://zuora@stscusdwprod.blob.core.windows.net', CREDENTIAL = [stwus2dwprodCredential_test])
GO

/*
ALTER EXTERNAL DATA SOURCE [InventoryStage_Test]
SET LOCATION = N'wasbs://inventory@stscusdwprod.blob.core.windows.net', CREDENTIAL = [stwus2dwprodCredential_test]
*/


------------------------------------------------------------------------------------
--Step 3:
------------------------------------------------------------------------------------

CREATE EXTERNAL TABLE [inventory].[auction123_test]
(
	[dlrID] [VARCHAR](255) NULL,
	[adID] [VARCHAR](255) NULL,
	[adStock] [VARCHAR](255) NULL,
	[adCondition] [VARCHAR](255) NULL,
	[adSection] [VARCHAR](255) NULL,
	[adMake] [VARCHAR](255) NULL,
	[adModel] [VARCHAR](255) NULL,
	[adSubModel] [VARCHAR](255) NULL,
	[adYear] [VARCHAR](255) NULL,
	[adEngine] [VARCHAR](255) NULL,
	[adTransmission] [VARCHAR](255) NULL,
	[adExterior] [VARCHAR](255) NULL,
	[adInterior] [VARCHAR](255) NULL,
	[adMiles] [VARCHAR](255) NULL,
	[adHeadline] [VARCHAR](255) NULL,
	[adText] [VARCHAR](MAX) NULL,
	[adPrice] [VARCHAR](255) NULL,
	[adPhone] [VARCHAR](255) NULL,
	[adPic1t] [VARCHAR](255) NULL,
	[adPic1] [VARCHAR](255) NULL,
	[adPic2] [VARCHAR](255) NULL,
	[adPic3] [VARCHAR](255) NULL,
	[adPic4] [VARCHAR](255) NULL,
	[adPic5] [VARCHAR](255) NULL,
	[adPic6] [VARCHAR](255) NULL,
	[adPic7] [VARCHAR](255) NULL,
	[adPic8] [VARCHAR](255) NULL,
	[adPic9] [VARCHAR](255) NULL,
	[adPic10] [VARCHAR](255) NULL,
	[adPic11] [VARCHAR](255) NULL,
	[adPic12] [VARCHAR](255) NULL,
	[adPic13] [VARCHAR](255) NULL,
	[adPic14] [VARCHAR](255) NULL,
	[adPic15] [VARCHAR](255) NULL,
	[adPic16] [VARCHAR](255) NULL,
	[adPic17] [VARCHAR](255) NULL,
	[adPic18] [VARCHAR](255) NULL,
	[adPic19] [VARCHAR](255) NULL,
	[adPic20] [VARCHAR](255) NULL,
	[adPic21] [VARCHAR](255) NULL,
	[adPic22] [VARCHAR](255) NULL,
	[adPic23] [VARCHAR](255) NULL,
	[adPic24] [VARCHAR](255) NULL,
	[adPic25] [VARCHAR](255) NULL,
	[adPic26] [VARCHAR](255) NULL,
	[dlrName] [VARCHAR](255) NULL,
	[dlrAddress] [VARCHAR](255) NULL,
	[dlrCity] [VARCHAR](255) NULL,
	[dlrState] [VARCHAR](255) NULL,
	[dlrZIP] [VARCHAR](255) NULL,
	[dlrEmail] [VARCHAR](255) NULL,
	[dlrURL] [VARCHAR](255) NULL,
	[dlrPhone] [VARCHAR](255) NULL,
	[adID2] [VARCHAR](255) NULL,
	[adGenericExteriorColor] [VARCHAR](255) NULL,
	[adInvoice] [VARCHAR](255) NULL,
	[adMSRP] [VARCHAR](255) NULL,
	[adModelCode] [VARCHAR](255) NULL,
	[adDateInStock] [VARCHAR](255) NULL,
	[adDoors] [VARCHAR](255) NULL,
	[adDriveType] [VARCHAR](255) NULL,
	[adFuelType] [VARCHAR](255) NULL,
	[adEPACity] [VARCHAR](255) NULL,
	[adEPAHighway] [VARCHAR](255) NULL
)
WITH (DATA_SOURCE = [InventoryStage_Test],LOCATION = N'auction123/auction123.txt',FILE_FORMAT = [ParquetFileFormat],REJECT_TYPE = VALUE,REJECT_VALUE = 0)



/*

SELECT TOP 10 * FROM Inventory.auction123

DROP EXTERNAL TABLE Inventory.auction123_test

*/





