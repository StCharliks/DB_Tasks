SELECT [BusinessEntityID],
       [JobTitle],
       [Gender],
       (YEAR(GETDATE()) - YEAR([HireDate])) AS 'YearsWorked'
FROM [HumanResources].[Employee]
WHERE YEAR(GETDATE()) - YEAR([BirthDate]) > 65;
