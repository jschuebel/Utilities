declare @agntno varchar(10), @Lvl int, @checkCnt int
select @agntno='88733', @Lvl=0

Declare @ReportsTo Table ( Agent_Number varchar(10), Lvl int, Processed bit Default(0)  )
insert into @ReportsTo (Agent_Number, Lvl) Values(@agntno, @Lvl)
--select * from @ReportsTo
WHILE (@agntno IS NOT NULL)
BEGIN

	insert into @ReportsTo (Agent_Number, Lvl)
	SELECT [Agent_Number], @Lvl+1
	  FROM [Cels].[dbo].[AgentHierarchyList]
	  where [Reports_To_Agent_Number] =  @agntno

	update 	@ReportsTo set Processed=1
	where Agent_Number=@agntno and Lvl=@Lvl and Processed<>1

	--only bump level if we've processed all for current level
	select @checkCnt=count(*) FROM @ReportsTo where Lvl=@Lvl and Processed<>1
	select 'lvl=' + cast(@Lvl as varchar) + '   chkcnt=' + cast(@checkCnt as varchar)
	if @checkCnt=0
	BEGIN
		set @Lvl=@Lvl+1
	select * from @ReportsTo
	END
	
	--Clear the temp variable
	SET @agntno=NULL
	--Grab the next permission record
	select top 1 @agntno=Agent_Number from @ReportsTo where Lvl=@Lvl and Processed<>1
END
select * from @ReportsTo
