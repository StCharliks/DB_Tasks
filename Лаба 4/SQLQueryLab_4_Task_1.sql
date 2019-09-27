use AdventureWorks2012;
GO

/*a) Создайте таблицу Person.CountryRegionHst,
которая будет хранить информацию об изменениях
в таблице Person.CountryRegion.*/
CREATE TABLE [Person].[CountryRegionHst](
	[ID] INT IDENTITY(1,1) NOT NULL,
	[Action] VARCHAR(15) NOT NULL,
	[ModifiedDate] DATETIME NOT NULL,
	[SourceID] NVARCHAR(3) NOT NULL,
	[UserName] VARCHAR(MAX) NOT NULL,
	[OldCountryRegionCode] NVARCHAR(3) NULL,
	[OldName] NVARCHAR(50) NULL,
	[OldModifiedDate] DATETIME NULL,
	[NewCountryRegionCode] NVARCHAR(3) NULL,
	[NewName] NVARCHAR(50) NULL,
	[NewModifiedDate] DATETIME NULL,
)
GO

/*b) Создайте три AFTER триггера для трех
операций INSERT, UPDATE, DELETE для таблицы
Person.CountryRegion. Каждый триггер должен
заполнять таблицу Person.CountryRegionHst с 
указанием типа операции в поле Action.*/
CREATE TRIGGER CountryRegion_AFTER_INSERT
ON [Person].[CountryRegion]
AFTER INSERT AS
BEGIN
	DECLARE @ID NVARCHAR(3)
	DECLARE @Name NVARCHAR(50)
	DECLARE @ModDate DATETIME

	SELECT @ID = (SELECT [CountryRegionCode] FROM inserted)
	SELECT @Name = (SELECT [Name] FROM inserted)
	SELECT @ModDate = (SELECT [ModifiedDate] FROM inserted)

	INSERT INTO [Person].[CountryRegionHst]([Action],
	[ModifiedDate],
	[SourceID],
	[UserName],
	[OldCountryRegionCode],
	[OldName],
	[OldModifiedDate],
	[NewCountryRegionCode],
	[NewName],
	[NewModifiedDate])
	VALUES('INSERT', GETDATE(), @ID, USER_NAME(), NULL, NULL, NULL, @ID, @Name, @ModDate)
END
GO

CREATE TRIGGER CountryRegion_AFTER_DELETE
ON [Person].[CountryRegion]
AFTER DELETE AS
BEGIN
	DECLARE @ID NVARCHAR(3)
	DECLARE @Name NVARCHAR(50)
	DECLARE @ModDate DATETIME

	SELECT @ID = (SELECT [CountryRegionCode] FROM deleted)
	SELECT @Name = (SELECT [Name] FROM deleted)
	SELECT @ModDate = (SELECT [ModifiedDate] FROM deleted)

	INSERT INTO [Person].[CountryRegionHst]([Action],
	[ModifiedDate],
	[SourceID],
	[UserName],
	[OldCountryRegionCode],
	[OldName],
	[OldModifiedDate],
	[NewCountryRegionCode],
	[NewName],
	[NewModifiedDate])
	VALUES('DELETE', GETDATE(), @ID, USER_NAME(), @ID, @Name, @ModDate, NULL, NULL, NULL)
END
GO

CREATE TRIGGER CountryRegion_AFTER_UPDATE
ON [Person].[CountryRegion]
AFTER UPDATE AS
BEGIN
	DECLARE @OLD_ID NVARCHAR(3)
	DECLARE @OLD_Name NVARCHAR(50)
	DECLARE @OLD_ModDate DATETIME

	DECLARE @NEW_ID NVARCHAR(3)
	DECLARE @NEW_Name NVARCHAR(50)
	DECLARE @NEW_ModDate DATETIME

	SELECT @OLD_ID = (SELECT [CountryRegionCode] FROM deleted)
	SELECT @OLD_Name = (SELECT [Name] FROM deleted)
	SELECT @OLD_ModDate = (SELECT [ModifiedDate] FROM deleted)

	SELECT @NEW_ID = (SELECT [CountryRegionCode] FROM inserted)
	SELECT @NEW_Name = (SELECT [Name] FROM inserted)
	SELECT @NEW_ModDate = (SELECT [ModifiedDate] FROM inserted)

	INSERT INTO [Person].[CountryRegionHst]([Action],
	[ModifiedDate],
	[SourceID],
	[UserName],
	[OldCountryRegionCode],
	[OldName],
	[OldModifiedDate],
	[NewCountryRegionCode],
	[NewName],
	[NewModifiedDate])
	VALUES('UPDATE', GETDATE(), @OLD_ID, USER_NAME(), @OLD_ID, @OLD_Name, @OLD_ModDate, @NEW_ID, @NEW_Name, @NEW_ModDate)
END
GO

INSERT INTO [Person].[CountryRegion]([CountryRegionCode],[Name], [ModifiedDate])
VALUES('DDW','DDdsf', GETDATE());
GO

UPDATE [Person].[CountryRegion]
SET [ModifiedDate] = GETDATE()
WHERE [CountryRegion].[Name] = 'DDdsf';
GO

DELETE FROM [Person].[CountryRegion]
WHERE [CountryRegion].[Name] = 'DDdsf';
GO


/*c) Создайте представление VIEW, отображающее все поля таблицы
Person.CountryRegion. Сделайте невозможным просмотр исходного кода
представления.*/
CREATE VIEW [CountryRegionList]
WITH ENCRYPTION
AS
SELECT [CountryRegionCode] AS CountryCode, [Name] AS RegionName, [ModifiedDate] AS LastMod FROM [Person].[CountryRegion]
GO

/* Вставьте новую строку в Person.CountryRegion через представление.
Обновите вставленную строку. Удалите вставленную строку.
Убедитесь, что все три операции отображены в Person.CountryRegionHst.*/
INSERT INTO [CountryRegionList]([CountryCode],[RegionName], [LastMod])
VALUES('DDA','DDdsfs', GETDATE());
GO

UPDATE [CountryRegionList]
SET [LastMod] = GETDATE()
WHERE [CountryRegionList].[RegionName] = 'DDdsfs';
GO

DELETE FROM [CountryRegionList]
WHERE [CountryRegionList].[RegionName] = 'DDdsfs';
GO

SELECT * FROM [Person].[CountryRegionHst];