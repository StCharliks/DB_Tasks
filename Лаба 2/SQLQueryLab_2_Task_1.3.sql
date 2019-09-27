SELECT [Name],
       [HireDate],
       [SickLeaveHours],
       SUM([SickLeaveHours]) OVER(PARTITION BY [Temp].[Name]
                                  ORDER BY [Temp].[Name] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'CumSum'
FROM (
        (SELECT [Department].[DepartmentID],
                [BusinessEntityID],
                [Name]
         FROM [HumanResources].[Department]
         JOIN [HumanResources].[EmployeeDepartmentHistory] ON [Department].[DepartmentID] = [EmployeeDepartmentHistory].[DepartmentID]) AS [Temp]
      JOIN [HumanResources].[Employee] ON [Temp].[BusinessEntityID] = [Employee].[BusinessEntityID])
ORDER BY Name;