SELECT [HumanResources].[Employee].[BusinessEntityID],
       [OrganizationLevel],
       [JobTitle],
       [JobCandidateID],
       [Resume]
FROM [HumanResources].[Employee]
JOIN [HumanResources].[JobCandidate] ON [Employee].[BusinessEntityID] = [JobCandidate].[BusinessEntityID]
WHERE [JobCandidate].[Resume] IS NOT NULL;