use AdventureWorks2012;
GO

/* добавьте в таблицу dbo.Address поле PersonName типа nvarchar размерностью 100 символов;*/
ALTER TABLE [dbo].[Address]
ADD [PersonName] NVARCHAR(100) NULL;
GO
/*объявите табличную переменную с такой же структурой как dbo.Address*/
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

/*заполните ее данными из dbo.Address, где StateProvinceID = 79*/
INSERT INTO @TABLE_VARIABLE
SELECT *
FROM [dbo].[Address]
WHERE [dbo].[Address].[StateProvinceID] = 79;


/*Поле AddressLine2 заполните значениями из CountryRegionCode таблицы Person.CountryRegion,
Name таблицы Person.StateProvince и City из Address. Разделите значения запятыми;*/
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

/* обновите поле AddressLine2 в dbo.Address данными из табличной переменной.*/
UPDATE [dbo].[Address]
SET [AddressLine2] = [VAL]
FROM [dbo].[Address] AS [A]
INNER JOIN
  (SELECT ([AddressLine2]) AS [VAL],
          [AddressID]
   FROM @TABLE_VARIABLE) AS [SELECTED] ON [A].[AddressID] = [SELECTED].[AddressID];

/*Также обновите данные в поле PersonName данными из Person.Person, соединив значения полей FirstName и LastName;*/
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

/*удалите данные из dbo.Address, которые относятся к типу ‘Main Office’ из таблицы Person.AddressType;*/
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
/*удалите поле PersonName из таблицы*/
ALTER TABLE [dbo].[Address]
DROP COLUMN [PersonName];
GO
/*удалите все созданные ограничения и значения по умолчанию;*/
ALTER TABLE [dbo].[Address]   
DROP CONSTRAINT [StateProvinceID_Validator];
GO
ALTER TABLE [dbo].[Address]
DROP CONSTRAINT [AddressLine2_DEFAULT];
GO