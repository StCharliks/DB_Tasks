use AdventureWorks2012;
/*создайте таблицу dbo.Address с такой же структурой как Person.Address,
кроме полей geography, uniqueidentifier, не включа€ индексы, ограничени€ и триггеры;*/

CREATE TABLE [dbo].[Address](
	[AddressID] INT NOT NULL,
	[AddressLine1] NVARCHAR(60) NOT NULL,
	[AddressLine2] NVARCHAR(60) NULL,
	[City] NVARCHAR(30) NOT NULL,
	[StateProvinceID] INT NOT NULL,
	[PostalCode] NVARCHAR(15) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	FOREIGN KEY ([StateProvinceID]) REFERENCES [Person].[StateProvince] ([StateProvinceID])
);
GO

/*использу€ инструкцию ALTER TABLE,
добавьте в таблицу dbo.Address новое поле ID
с типом данных INT, имеющее свойство identity
с начальным значением 1 и приращением 1.
—оздайте дл€ нового пол€ ID ограничение UNIQUE;*/
ALTER TABLE [dbo].[Address]
ADD [ID] INT IDENTITY(1,1) UNIQUE NOT NULL;
GO
/*использу€ инструкцию ALTER TABLE,
создайте дл€ таблицы dbo.Address ограничение
дл€ пол€ StateProvinceID, чтобы заполнить его
можно было только нечетными числами;*/
ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [StateProvinceID_Validator] CHECK([StateProvinceID] % 2 = 1);
GO
/* использу€ инструкцию ALTER TABLE,
создайте дл€ таблицы dbo.Address ограничение
DEFAULT дл€ пол€ AddressLine2, задайте значение
по умолчанию СUnknownТ*/
ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [AddressLine2_DEFAULT]
DEFAULT 'Unknown' FOR [AddressLine2]
GO

/*заполните новую таблицу данными из Person.Address.
¬ыберите дл€ вставки только те адреса, где значение
пол€ Name из таблицы CountryRegion начинаетс€ на букву СаТ.
“акже исключите данные, где StateProvinceID содержит четные числа.
«аполните поле AddressLine2 значени€ми по умолчанию;*/
INSERT INTO [dbo].[Address]([AddressID], [AddressLine1], [City], [StateProvinceID], [PostalCode], [ModifiedDate])
SELECT [AddressID],
       [AddressLine1],
       [City],
       [Address].[StateProvinceID],
       [PostalCode],
       [Person].[Address].[ModifiedDate]
FROM ([Person].[Address]
      JOIN [Person].[StateProvince] ON [Person].[Address].[StateProvinceID] = [Person].[StateProvince].[StateProvinceID])
JOIN [Person].[CountryRegion] ON [Person].[CountryRegion].[CountryRegionCode] = [Person].[StateProvince].[CountryRegionCode]
WHERE ([Person].[StateProvince].[StateProvinceID] % 2 = 1
       AND [Person].[CountryRegion].[Name] LIKE 'U%');
GO
/*измените поле AddressLine2, запретив вставку null значений.*/
ALTER TABLE [dbo].[Address]
ALTER COLUMN [AddressLine2] NVARCHAR(60) NOT NULL;
GO