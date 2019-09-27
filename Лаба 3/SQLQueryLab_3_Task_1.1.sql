use AdventureWorks2012;
GO

/* �������� � ������� dbo.Address ���� PersonName ���� nvarchar ������������ 100 ��������;*/
ALTER TABLE [dbo].[Address]
ADD [PersonName] NVARCHAR(100) NULL;
GO
/*�������� ��������� ���������� � ����� �� ���������� ��� dbo.Address*/
DECLARE @TABLE_VARIABLE TABLE
(
	[AddressID] INT NOT NULL,
	[AddressLine1] NVARCHAR(60) NOT NULL,
	[AddressLine2] NVARCHAR(60) NOT NULL,
	[City] NVARCHAR(30) NOT NULL,
	[StateProvinceID] INT NOT NULL,
	[PostalCode] NVARCHAR(15) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[ID] INT NOT NULL,
	[PersonName] NVARCHAR(100) NULL
)

/*��������� �� ������� �� dbo.Address, ��� StateProvinceID = 79*/
INSERT INTO @TABLE_VARIABLE
SELECT *
FROM [dbo].[Address]
WHERE [dbo].[Address].[StateProvinceID] = 79;


/*���� AddressLine2 ��������� ���������� �� CountryRegionCode ������� Person.CountryRegion,
Name ������� Person.StateProvince � City �� Address. ��������� �������� ��������;*/
UPDATE @TABLE_VARIABLE
SET [AddressLine2] = [VAL]
FROM @TABLE_VARIABLE AS [TV]
INNER JOIN
  (SELECT ([CountryRegion].[CountryRegionCode] + ',' + [StateProvince].[Name] + ',' + [Address].[City]) AS [VAL],
          [AddressID]
   FROM [dbo].[Address]
   JOIN [Person].[StateProvince] ON [StateProvince].[StateProvinceID] = [Address].[StateProvinceID]
   JOIN [Person].[CountryRegion] ON [StateProvince].[CountryRegionCode] = [CountryRegion].[CountryRegionCode]
   WHERE [Address].[StateProvinceID] = 79) AS [SELECTED] ON [TV].[AddressID] = [SELECTED].[AddressID];

/* �������� ���� AddressLine2 � dbo.Address ������� �� ��������� ����������.*/
UPDATE [dbo].[Address]
SET [AddressLine2] = [VAL]
FROM [dbo].[Address] AS [A]
INNER JOIN
  (SELECT ([AddressLine2]) AS [VAL],
          [AddressID]
   FROM @TABLE_VARIABLE) AS [SELECTED] ON [A].[AddressID] = [SELECTED].[AddressID];

/*����� �������� ������ � ���� PersonName ������� �� Person.Person, �������� �������� ����� FirstName � LastName;*/
UPDATE [dbo].[Address]
SET [PersonName] = [FULL_NAME]
FROM [dbo].[Address] AS [A]
INNER JOIN
  (SELECT ([FirstName] + ' ' + [LastName]) AS [FULL_NAME],
          [Address].[AddressID]
   FROM [Person].[Person]
   JOIN [Person].[BusinessEntityAddress] ON [Person].[BusinessEntityID] = [BusinessEntityAddress].[BusinessEntityID]
   JOIN [Person].[Address] ON [Address].[AddressID] = [BusinessEntityAddress].[AddressID]
   WHERE [Address].[StateProvinceID] = 79) AS [SELECTED] ON [A].[AddressID] = [SELECTED].[AddressID];
GO

/*������� ������ �� dbo.Address, ������� ��������� � ���� �Main Office� �� ������� Person.AddressType;*/
DELETE [dbo].[Address]
WHERE [AddressID] IN
    (SELECT [BusinessEntityAddress].[AddressID]
     FROM [Person].[BusinessEntityAddress]
     JOIN [Person].[AddressType] ON [BusinessEntityAddress].[AddressTypeID] = [AddressType].[AddressTypeID]
     WHERE [BusinessEntityAddress].[AddressTypeID] =
         (SELECT [AddressTypeID]
          FROM [Person].[AddressType]
          WHERE [Name] = 'Main Office'
          GROUP BY [AddressTypeID]));
GO
/*������� ���� PersonName �� �������*/
ALTER TABLE [dbo].[Address]
DROP COLUMN [PersonName];
GO
/*������� ��� ��������� ����������� � �������� �� ���������;*/
ALTER TABLE [dbo].[Address]   
DROP CONSTRAINT [StateProvinceID_Validator];
GO
ALTER TABLE [dbo].[Address]
DROP CONSTRAINT [AddressLine2_DEFAULT];
GO