/*—оздайте хранимую процедуру,
котора€ будет возвращать сводную таблицу
(оператор PIVOT), отображающую данные о
суммарном количестве заказанных продуктов
(Production.WorkOrder.OrderQty) за определенный
мес€ц (DueDate). ¬ывести информацию необходимо дл€
каждого года. —писок мес€цев передайте в процедуру
через входной параметр.*/


/*SELECT <non-pivoted column>,  
    [first pivoted column] AS <column name>,  
    [second pivoted column] AS <column name>,  
    ...  
    [last pivoted column] AS <column name>  
FROM  
    (<SELECT query that produces the data>)   
    AS <alias for the source query>  
PIVOT  
(  
    <aggregation function>(<column being aggregated>)  
FOR   
[<column that contains the values that will become column headers>]   
    IN ( [first pivoted column], [second pivoted column],  
    ... [last pivoted column])  
) AS <alias for the pivot table>  
<optional ORDER BY clause>;  */
CREATE PROCEDURE [dbo].[ProductOrdersSummary]
				 @Months NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @QtyDateTable TABLE(
		[OrderID] INT NOT NULL,
		[Qte] INT NOT NULL,
		[Month] VARCHAR(20) NOT NULL,
		[Year] INT NOT NULL
		)

		INSERT INTO @QtyDateTable
		SELECT [WorkOrder].[WorkOrderID], [WorkOrder].[OrderQty], DATENAME(mm,[WorkOrder].[DueDate]), YEAR([WorkOrder].[DueDate]) FROM [Production].[WorkOrder];


		DECLARE @Query NVARCHAR(MAX)

		SET @Query = N'SELECT [Year],'+ @Months +'
						FROM   
						(SELECT [Qte], [Year], [Month]  
						FROM #QtyDateTable) p  
						PIVOT  
						(  
						COUNT ([Qte])  
						FOR [Month] IN  
						( ' + @Months +' )  
						) AS pvt  
						ORDER BY [pvt].[Year];'

		EXEC(@Query);
	END TRY
	BEGIN CATCH
		SELECT  
		ERROR_NUMBER() AS ErrorNumber  
		,ERROR_SEVERITY() AS ErrorSeverity  
		,ERROR_STATE() AS ErrorState  
		,ERROR_PROCEDURE() AS ErrorProcedure  
		,ERROR_LINE() AS ErrorLine  
		,ERROR_MESSAGE() AS ErrorMessage;  
	END CATCH
END
GO

EXEC [dbo].[ProductOrdersSummary]'[December],[January],[July], [March]'