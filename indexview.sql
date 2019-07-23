CREATE VIEW [dbo].[vwContractorCallExecuted] WITH SCHEMABINDING AS 
SELECT     FK_Branch, COUNT_BIG(*) AS Cnt
FROM         dbo.Contractor
WHERE     (CallExecuted = 1)
GO 





--If the view already existed we could use this to add SCHEMABINDING 
ALTER VIEW [dbo].[vwContractorCallExecuted] WITH SCHEMABINDING AS 
SELECT     FK_Branch, COUNT_BIG(*) AS Cnt
FROM         dbo.Contractor
WHERE     (CallExecuted = 1)
GROUP BY FK_Branch
