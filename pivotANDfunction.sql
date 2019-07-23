CREATE FUNCTION [dbo].[GetCompanyPivot]
(	@FK_Company int)
RETURNS TABLE 
AS
RETURN 
(
	SELECT (Select Name FROM Company WHERE PK_Company=@FK_Company) CompanyName, [NB], [Mail], [Pending], [Finalized]
	FROM
	(
		SELECT 'NB' QType, FK_Company
		FROM Application
		WHERE ISNULL(isDone,0)=0 AND FK_Company=@FK_Company AND FK_QueueType=1
		UNION ALL
		SELECT 'Mail', FK_Company
		FROM Application
		WHERE ISNULL(isDone,0)=0 AND FK_Company=@FK_Company AND FK_QueueType=2
		UNION ALL
		SELECT 'Pending' QType, FK_Company
		FROM Application
		WHERE ISNULL(isDone,0)=0 AND FK_Company=@FK_Company AND FK_QueueType=3
		UNION ALL
		SELECT 'Finalized', FK_Company
		FROM Application
		WHERE ISNULL(isDone,0)=0 AND FK_Company=@FK_Company AND FK_QueueType=4
	) AS SourceTable
	PIVOT
	(
		Count(QType)
		FOR QType IN ([NB], [Mail], [Pending], [Finalized])
	) AS PivotTable

)

GO
CREATE PROCEDURE [dbo].[usp_GetQueueTotals]
AS 

DECLARE @QueueTotals TABLE 
(
  CompanyName varchar(64), 
  NewBusiness int,
  Mail int,
  Pending int null,
  Finalized int null
)


INSERT INTO @QueueTotals (CompanyName, NewBusiness, Mail, Pending, Finalized)
select * from GetCompanyPivot(1)

INSERT INTO @QueueTotals (CompanyName, NewBusiness, Mail, Pending, Finalized)
select * from GetCompanyPivot(2)

INSERT INTO @QueueTotals (CompanyName, NewBusiness, Mail, Pending, Finalized)
select * from GetCompanyPivot(3)

INSERT INTO @QueueTotals (CompanyName, NewBusiness, Mail, Pending, Finalized)
select * from GetCompanyPivot(4)

select *, (NewBusiness+Mail+isnull(Pending,0)+isnull(Finalized,0)) Total
from @QueueTotals
	


GO
