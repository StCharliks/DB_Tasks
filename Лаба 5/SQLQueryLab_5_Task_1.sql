use AdventureWorks2012;
GO
/*Создайте scalar-valued функцию,
которая будет принимать в качестве
входного параметра id подкатегории
для продукта (Production.ProductSubcategory.ProductSubcategoryID)
и возвращать количество продуктов указанной
подкатегории (Production.Product).*/

/*-- Transact-SQL Scalar Function Syntax  
CREATE [ OR ALTER ] FUNCTION [ schema_name. ] function_name   
( [ { @parameter_name [ AS ][ type_schema_name. ] parameter_data_type   
    [ = default ] [ READONLY ] }   
    [ ,...n ]  
  ]  
)  
RETURNS return_data_type  
    [ WITH <function_option> [ ,...n ] ]  
    [ AS ]  
    BEGIN   
        function_body   
        RETURN scalar_expression  
    END  
[ ; ]  */
CREATE FUNCTION [Production].GetProductCountById(@ID INT)
RETURNS INT
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @ResultCount INT;
	
	SET @ResultCount = (SELECT COUNT(*) FROM [Production].[Product]
					WHERE [Product].[ProductSubcategoryID] = @ID
					GROUP BY [Product].[ProductSubcategoryID]);

	IF (@ResultCount IS NULL)
		RETURN 0;

	RETURN @ResultCount;
END
go


/*use AdventureWorks2012;
IF OBJECT_ID (N'[Person].GetProductCountById', N'IF') IS NOT NULL  
-- deletes function  
    DROP FUNCTION [Person].GetProductCountById;  
GO*/  

SELECT [Production].GetProductCountById(235235) AS 'Count';
GO

/*Создайте inline table-valued функцию,
которая будет принимать в качестве входного параметра id
подкатегории для продукта (Production.ProductSubcategory.ProductSubcategoryID),
а возвращать список продуктов указанной подкатегории из Production.Product,
стоимость которых более 1000 (StandardCost).*/

/*-- Transact-SQL Inline Table-Valued Function Syntax   
CREATE [ OR ALTER ] FUNCTION [ schema_name. ] function_name   
( [ { @parameter_name [ AS ] [ type_schema_name. ] parameter_data_type   
    [ = default ] [ READONLY ] }   
    [ ,...n ]  
  ]  
)  
RETURNS TABLE  
    [ WITH <function_option> [ ,...n ] ]  
    [ AS ]  
    RETURN [ ( ] select_stmt [ ) ]  
[ ; ]  
  */

  CREATE FUNCTION [Production].[GetProductListByID](@ID INT)
  RETURNS TABLE
  AS
  RETURN
  (
	 SELECT * FROM [Production].[Product]
	 WHERE [Product].[ProductSubcategoryID] = @ID AND [Product].[StandardCost] > 1000
  );
  GO

 SELECT * FROM [Production].GetProductListByID(1);

 /*Вызовите функцию для каждой подкатегории, применив оператор CROSS APPLY. */
 SELECT * from [Production].[ProductSubcategory] as [SubCat]
	CROSS APPLY [Production].GetProductListByID([SubCat].[ProductSubcategoryID]) 
	ORDER BY [SubCat].[ProductSubcategoryID];
	/*А это часом не INNER JOIN?*/
GO
/*Вызовите функцию для каждой подкатегории, применив оператор OUTER APPLY*/
SELECT * from [Production].[ProductSubcategory] as [SubCat]
	OUTER APPLY [Production].GetProductListByID([SubCat].[ProductSubcategoryID]) 
	ORDER BY [SubCat].[ProductSubcategoryID]
	/*В предсказаниях Ванги было написано, что это OUTER JOIN*/
GO


/*Измените созданную inline table-valued функцию,
сделав ее multistatement table-valued
(предварительно сохранив для проверки код создания
inline table-valued функции).*/

/*CREATE [ OR ALTER ] FUNCTION [ schema_name. ] function_name   
( [ { @parameter_name [ AS ] [ type_schema_name. ] parameter_data_type   
    [ = default ] [READONLY] }   
    [ ,...n ]  
  ]  
)  
RETURNS @return_variable TABLE <table_type_definition>  
    [ WITH <function_option> [ ,...n ] ]  
    [ AS ]  
    BEGIN   
        function_body   
        RETURN  
    END  
[ ; ]  
  */
  CREATE FUNCTION [Production].GetProductListByID_Mult(@ID INT)
  RETURNS @ProductInfo TABLE(
	[ProductID] int PRIMARY KEY NOT NULL,
	[NAME] [dbo].[Name] NOT NULL,
	[ProductNumber] NVARCHAR(25) NOT NULL,
	[StandartCost] MONEY NOT NULL,
	[Weight] DECIMAL(8,2) NOT NULL
  )
  AS
  BEGIN
	INSERT @ProductInfo
	SELECT [Product].[ProductID], [Product].[Name], [Product].[ProductNumber], [Product].[StandardCost], [Product].[Weight]  FROM [Production].[Product]
	 WHERE [Product].[ProductSubcategoryID] = @ID AND [Product].[StandardCost] > 1000
	 RETURN
  END;
  GO 


  SELECT * FROM [Production].GetProductListByID_Mult(2);
  /*CREATE TABLE [Production].[Product](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL,
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) NULL,
	[Class] [nchar](2) NULL,
	[Style] [nchar](2) NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
	)*/