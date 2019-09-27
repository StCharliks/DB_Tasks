use AdventureWorks2012;

SELECT [Department].[DepartmentID],
       [Name],
       [EmpCount]
FROM [HumanResources].[Department]
JOIN
  (SELECT [EmployeeDepartmentHistory].[DepartmentID],
          COUNT(*) AS 'EmpCount'
   FROM [HumanResources].[EmployeeDepartmentHistory]
   GROUP BY [EmployeeDepartmentHistory].[DepartmentID]) AS [DepatmentEmpCount] ON [Department].[DepartmentID] = [DepatmentEmpCount].[DepartmentID]
WHERE [EmpCount] > 10;