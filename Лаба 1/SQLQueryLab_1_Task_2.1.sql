USE [AdventureWorks2012];


SELECT [DepartmentID],
       [Name]
FROM [HumanResources].[Department]
WHERE Name LIKE 'F%e';