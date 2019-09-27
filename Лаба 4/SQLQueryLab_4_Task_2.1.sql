use AdventureWorks2012;
GO

/*Создайте представление VIEW,
отображающее данные из таблиц Person.CountryRegion
и Sales.SalesTerritory.*/
CREATE VIEW [dbo].[RegionSales] WITH SCHEMABINDING
AS
SELECT [SalesTerritory].[TerritoryID] as [TerrID], [SalesTerritory].[Name] as [TerrName],
	   [SalesTerritory].[Group] as [Group], [SalesTerritory].[SalesYTD] as [SalesYTD],
	   [SalesTerritory].[SalesLastYear] as [SalesLastYear], [SalesTerritory].[CostYTD] as [CostYTD],
	   [SalesTerritory].[CostLastYear] as [CostLastYear], [SalesTerritory].[rowguid] as [Guid],
	   [SalesTerritory].[ModifiedDate] as [ModDate],
	   [CountryRegion].[CountryRegionCode] as [RegionCode], [CountryRegion].[Name] as [RegionName]
FROM [Sales].[SalesTerritory]
JOIN [Person].[CountryRegion]
ON [SalesTerritory].[CountryRegionCode] = [CountryRegion].[CountryRegionCode]
GO
/*Создайте уникальный
кластерный индекс в представлении по полю TerritoryID.*/
CREATE UNIQUE CLUSTERED INDEX [idx_RegionSales] ON
[dbo].[RegionSales]([TerrID]);
GO

/*Создайте один INSTEAD OF триггер для представления
на три операции INSERT, UPDATE, DELETE.
Триггер должен выполнять соответствующие операции
в таблицах Person.CountryRegion и Sales.SalesTerritory.*/
CREATE TRIGGER [dbo].[RegionSalesTrigger]
ON [dbo].[RegionSales]
INSTEAD OF DELETE, UPDATE, INSERT
AS
BEGIN
    /*UPDATE*/
	IF EXISTS(SELECT * FROM [inserted]) and EXISTS (SELECT * FROM [deleted])
	BEGIN
		DELETE FROM [Sales].[SalesTerritory]
		FROM [Sales].[SalesTerritory]
		INNER JOIN [deleted]
		ON [SalesTerritory].[TerritoryID] = [deleted].[TerrID];


		DELETE FROM [Person].[CountryRegion]
		FROM [Person].[CountryRegion]
		INNER JOIN [deleted]
		ON [CountryRegion].[CountryRegionCode] = [deleted].[RegionCode];

		INSERT INTO [Person].[CountryRegion]
		SELECT [RegionCode], [RegionName], GETDATE()
		FROM [inserted]

		 
		INSERT INTO [Sales].[SalesTerritory]
		SELECt [TerrName], [RegionCode], [Group], [SalesYTD],
			   [SalesLastYear], [CostYTD], [CostLastYear], NEWID(), GETDATE()
		FROM [inserted];
	END
	/*INSERT*/
	IF EXISTS(SELECT * FROM [inserted]) and NOT EXISTS (SELECT * FROM [deleted])
	BEGIN
		INSERT INTO [Person].[CountryRegion]
		SELECT [RegionCode], [RegionName], GETDATE()
		FROM [inserted];

		INSERT INTO [Sales].[SalesTerritory]
		SELECT [TerrName], [RegionCode], [Group], [SalesYTD],
			   [SalesLastYear], [CostYTD], [CostLastYear], NEWID(), GETDATE()
		FROM [inserted];

	END
	/*DELETE*/
	IF NOT EXISTS(SELECT * FROM [inserted]) and EXISTS (SELECT * FROM [deleted])
	BEGIN	
		DELETE FROM [Sales].[SalesTerritory]
		FROM [Sales].[SalesTerritory]
		INNER JOIN [deleted]
		ON [SalesTerritory].[TerritoryID] = [deleted].[TerrID];

		DELETE FROM [Person].[CountryRegion]
		FROM [Person].[CountryRegion]
		INNER JOIN [deleted]
		ON [CountryRegion].[CountryRegionCode] = [deleted].[RegionCode];

	END
END

/*Вставьте новую строку в представление,
указав новые данные для CountryRegion и SalesTerritory.
Триггер должен добавить новые строки в таблицы
Person.CountryRegion и Sales.SalesTerritory.
Обновите вставленные строки через представление.
Удалите строки.*/
INSERT INTO [dbo].[RegionSales]([TerrName], [Group], [SalesYTD], [SalesLastYear], [CostYTD], [CostLastYear], [RegionCode], [RegionName])
VALUES('HUU', 'HG Group', 245, 245, 2, 56, 'yy', 'Tyyyr' );
SELECT * FROM [Person].[CountryRegion]
SELECT * FROm [Sales].[SalesTerritory]
GO

UPDATE [dbo].[RegionSales]
SET [RegionName] = 'CHERVENSK'
WHERE [RegionCode] = 'yy';
GO

DELETE FROM [dbo].[RegionSales]
WHERE [RegionCode] = 'yy';
GO