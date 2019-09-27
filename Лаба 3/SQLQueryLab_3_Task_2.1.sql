IF OBJECT_ID(N'tempdb..#Address', N'U') IS NOT NULL   
DROP TABLE #Address;  
GO  

use AdventureWorks2012;
/*a) ��������� ���, ��������� �� ������ ������� ������
������������ ������. �������� � ������� dbo.Address
���� AccountNumber NVARCHAR(15) � MaxPrice MONEY.
����� �������� � ������� ����������� ���� AccountID,
������� ����� ��������� � �������� � ���� AccountNumber
��������� �ID�.*/
ALTER TABLE [dbo].[Address]
ADD [AccountNumber] NVARCHAR(15) NULL,
    [MaxPrice] MONEY NULL,
	[AccountID] AS ('ID_' + [AccountNumber]);
GO
/*b) �������� ��������� ������� #Address,
� ��������� ������ �� ���� ID.
��������� ������� ������ �������� ��� ����
������� dbo.Address �� ����������� ���� AccountID.*/
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
/*c) ��������� ��������� ������� ������� �� dbo.Address.
���� AccountNumber ��������� ������� �� ������� Purchasing.Vendor.
���������� ������������ ���� �������� (StandardPrice),
������������� ������ ���������� (BusinessEntityID) � �������
Purchasing.ProductVendor � ��������� ����� ���������� ���� MaxPrice.
������� ������������ ���� ����������� � Common Table Expression (CTE).*/
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
/*d) ������� �� ������� dbo.Address ���� ������ (��� ID = 293)*/
DELETE FROM #Address
WHERE #Address.[ID] = 293;
GO
/*e) �������� Merge ���������, ������������ dbo.Address ��� target,
� ��������� ������� ��� source. ��� ����� target � source ����������� ID.
�������� ���� AccountNumber � MaxPrice, ���� ������ ������������ � source � target
. ���� ������ ������������ �� ��������� �������, �� �� ���������� � target,
�������� ������ � dbo.Address. ���� � dbo.Address ������������ ����� ������,
������� �� ���������� �� ��������� �������, ������� ������ �� dbo.Address.*/

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