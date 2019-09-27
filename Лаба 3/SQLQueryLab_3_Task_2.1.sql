IF OBJECT_ID(N'tempdb..#Address', N'U') IS NOT NULL   
DROP TABLE #Address;  
GO  

use AdventureWorks2012;
/*a) выполните код, созданный во втором задании второй
лабораторной работы. ƒобавьте в таблицу dbo.Address
пол€ AccountNumber NVARCHAR(15) и MaxPrice MONEY.
“акже создайте в таблице вычисл€емое поле AccountID,
которое будет добавл€ть к значению в поле AccountNumber
приставку СIDТ.*/
ALTER TABLE [dbo].[Address]
ADD [AccountNumber] NVARCHAR(15) NULL,
    [MaxPrice] MONEY NULL,
	[AccountID] AS ('ID_' + [AccountNumber]);
GO
/*b) создайте временную таблицу #Address,
с первичным ключом по полю ID.
¬ременна€ таблица должна включать все пол€
таблицы dbo.Address за исключением пол€ AccountID.*/
CREATE TABLE #Address(
	[AddressID] INT NOT NULL,
	[AddressLine1] NVARCHAR(60) NOT NULL,
	[AddressLine2] NVARCHAR(60) NULL,
	[City] NVARCHAR(30) NOT NULL,
	[StateProvinceID] INT NOT NULL,
	[PostalCode] NVARCHAR(15) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[ID] INT IDENTITY(1,1) UNIQUE NOT NULL,
	[AccountNumber] NVARCHAR(15) NULL,
    [MaxPrice] MONEY  NULL,
	FOREIGN KEY ([StateProvinceID]) REFERENCES [Person].[StateProvince] ([StateProvinceID])
)
GO
/*c) заполните временную таблицу данными из dbo.Address.
ѕоле AccountNumber заполните данными из таблицы Purchasing.Vendor.
ќпределите максимальную цену продукта (StandardPrice),
поставл€емого каждым постащиком (BusinessEntityID) в таблице
Purchasing.ProductVendor и заполните этими значени€ми поле MaxPrice.
ѕодсчет максимальной цены осуществите в Common Table Expression (CTE).*/
INSERT INTO #Address ([AddressID], [AddressLine1], [AddressLine2], [City], [StateProvinceID], [PostalCode], [ModifiedDate])
SELECT [AddressID],
       [AddressLine1],
       [AddressLine2],
       [City],
       [StateProvinceID],
       [PostalCode],
       [ModifiedDate]
FROM [dbo].[Address]
GO

UPDATE #Address
SET [AccountNumber] = [AccNum]
FROM #Address AS [Addr]
INNER JOIN
  (SELECT [TEMP].[AccNum],
          [TEMP].[AddrID]
   FROM
     (SELECT [BusinessEntityAddress].[AddressID] AS [AddrID],
             [Vendor].[AccountNumber] AS [AccNum]
      FROM Purchasing.Vendor
      JOIN [Person].[BusinessEntity] ON [Vendor].[BusinessEntityID] = [BusinessEntity].[BusinessEntityID]
      JOIN [Person].[BusinessEntityAddress] ON [BusinessEntityAddress].[BusinessEntityID] = [BusinessEntity].[BusinessEntityID]) AS [TEMP],
        [dbo].[Address]) AS [SELECTED] ON [Addr].[AddressID] = [SELECTED].[AddrID];
GO

WITH MAX_PRICE_STE(BEID, ACID, PRICE)
AS
(
SELECT [ID_MAX_PRICE].[BusinessEntityID] AS BEID,
       [Vendor].[AccountNumber] AS ACID,
       [ID_MAX_PRICE].MAX_PRICE AS PRICE
FROM
  (SELECT [Purchasing].[ProductVendor].[BusinessEntityID],
          MAX([Purchasing].[ProductVendor].[StandardPrice]) AS [MAX_PRICE]
   FROM [Purchasing].[ProductVendor]
   GROUP BY [ProductVendor].BusinessEntityID) AS ID_MAX_PRICE
JOIN [Purchasing].[Vendor] ON [Vendor].BusinessEntityID = [ID_MAX_PRICE].[BusinessEntityID]
WHERE [Vendor].[AccountNumber] IN
    (SELECT [AccountNumber] COLLATE SQL_Latin1_General_CP1_CI_AS
     FROM #Address) 
)

UPDATE #Address
SET [MaxPrice] = [PRICE]
FROM #Address
INNER JOIN [MAX_PRICE_STE] ON #Address.[AccountNumber] COLLATE SQL_Latin1_General_CP1_CI_AS = [MAX_PRICE_STE].[ACID] COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
/*d) удалите из таблицы dbo.Address одну строку (где ID = 293)*/
DELETE FROM #Address
WHERE #Address.[ID] = 293;
GO
/*e) напишите Merge выражение, использующее dbo.Address как target,
а временную таблицу как source. ƒл€ св€зи target и source используйте ID.
ќбновите пол€ AccountNumber и MaxPrice, если запись присутствует в source и target
. ≈сли строка присутствует во временной таблице, но не существует в target,
добавьте строку в dbo.Address. ≈сли в dbo.Address присутствует така€ строка,
которой не существует во временной таблице, удалите строку из dbo.Address.*/

SET IDENTITY_INSERT [dbo].[Address] ON; 
GO

MERGE [dbo].[Address] AS TARGET
USING(SELECT * FROM #Address) AS SOURCE
ON (TARGET.[ID] = SOURCE.[ID])
WHEN MATCHED THEN 
	UPDATE SET TARGET.[AccountNumber] = SOURCE.[AccountNumber],
			   TARGET.[MaxPrice] = SOURCE.[MaxPrice]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([AddressID], [AddressLine1],[AddressLine2],[City],[StateProvinceID],[PostalCode],[ModifiedDate],[ID],[AccountNumber],[MaxPrice])
	VALUES(SOURCE.[AddressID], SOURCE.[AddressLine1],SOURCE.[AddressLine2],SOURCE.[City], SOURCE.[StateProvinceID],SOURCE.[PostalCode],SOURCE.[ModifiedDate],SOURCE.[ID],SOURCE.[AccountNumber],SOURCE.[MaxPrice])
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
OUTPUT $action, inserted.*, deleted.*;