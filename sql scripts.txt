ALTER TRIGGER [dbo].[UpdateCurrentAddress] ON [dbo].[PreviousAddresses] 
FOR INSERT, UPDATE, DELETE
AS
-- Check to see if there was an insert/update or a deletion.
IF (SELECT COUNT(*) FROM inserted) >= 1
BEGIN
    IF (SELECT CountryID FROM inserted) <> 181

...moar...");
END


--Creating a simple nonclustered composite index
IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_SalesPerson_SalesQuota_SalesYTD')
    DROP INDEX IX_SalesPerson_SalesQuota_SalesYTD ON Sales.SalesPerson ;
GO
CREATE NONCLUSTERED INDEX IX_SalesPerson_SalesQuota_SalesYTD
    ON Sales.SalesPerson (SalesQuota, SalesYTD);
    
-- Creating a unique nonclustered index    
IF EXISTS (SELECT name from sys.indexes
            WHERE name = N'AK_UnitMeasure_Name')
    DROP INDEX AK_UnitMeasure_Name ON Production.UnitMeasure;
GO
CREATE UNIQUE INDEX AK_UnitMeasure_Name 
    ON Production.UnitMeasure(Name);