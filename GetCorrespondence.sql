ALTER PROCEDURE [dbo].[GetCorrespondenceData]

    @Query varchar(MAX) = null,

    @xmlData xml = null OUTPUT

As

BEGIN

 

       -- SET NOCOUNT ON added to prevent extra result sets from

       -- interfering with SELECT statements.

       SET NOCOUNT ON;

 

       DECLARE @stringVar NVARCHAR(max)

       SET @stringVar = N'DECLARE @RESULTS XML; SET @RESULTS = (' + @Query + '); SELECT @xmlData=@RESULTS'; 

       EXEC dbo.sp_executesql @stringVar,

                       N'@xmlData xml OUTPUT',

                       @xmlData OUTPUT;

END