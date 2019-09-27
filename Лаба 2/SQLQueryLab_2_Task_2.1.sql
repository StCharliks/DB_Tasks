use AdventureWorks2012;
/*�������� ������� dbo.Address � ����� �� ���������� ��� Person.Address,
����� ����� geography, uniqueidentifier, �� ������� �������, ����������� � ��������;*/

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

/*��������� ���������� ALTER TABLE,
�������� � ������� dbo.Address ����� ���� ID
� ����� ������ INT, ������� �������� identity
� ��������� ��������� 1 � ����������� 1.
�������� ��� ������ ���� ID ����������� UNIQUE;*/
ALTER TABLE [dbo].[Address]
ADD [ID] INT IDENTITY(1,1) UNIQUE NOT NULL;
GO
/*��������� ���������� ALTER TABLE,
�������� ��� ������� dbo.Address �����������
��� ���� StateProvinceID, ����� ��������� ���
����� ���� ������ ��������� �������;*/
ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [StateProvinceID_Validator] CHECK([StateProvinceID] % 2 = 1);
GO
/* ��������� ���������� ALTER TABLE,
�������� ��� ������� dbo.Address �����������
DEFAULT ��� ���� AddressLine2, ������� ��������
�� ��������� �Unknown�*/
ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [AddressLine2_DEFAULT]
DEFAULT 'Unknown' FOR [AddressLine2]
GO

/*��������� ����� ������� ������� �� Person.Address.
�������� ��� ������� ������ �� ������, ��� ��������
���� Name �� ������� CountryRegion ���������� �� ����� ���.
����� ��������� ������, ��� StateProvinceID �������� ������ �����.
��������� ���� AddressLine2 ���������� �� ���������;*/
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
/*�������� ���� AddressLine2, �������� ������� null ��������.*/
ALTER TABLE [dbo].[Address]
ALTER COLUMN [AddressLine2] NVARCHAR(60) NOT NULL;
GO