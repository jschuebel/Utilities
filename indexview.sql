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
------------------------------------------------------------------------------

CREATE VIEW ViewSearch WITH SCHEMABINDING AS

SELECT Persons.P_Id AS ID, Persons.LastName, Persons.FirstName, Orders.OrderNo

    FROM Persons

    INNER JOIN Orders ON Persons.P_Id=Orders.P_Id

GO

CREATE UNIQUE CLUSTERED INDEX IX_ViewSearch ON ViewSearch (ID)

 

--------------------------------------------------------

CREATE FUNCTION [dbo].[udf_Calc]

(

       @BeginDate date,

       @EndDate date

)

RETURNS SMALLINT  SCHEMABINDING

AS

BEGIN

DECLARE @age SMALLINT = 2

       return ( @age );

END