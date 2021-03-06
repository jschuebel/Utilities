SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetLoadingCompositeQuery]
	@orgID int,
	@orgType varchar(50),
	@startDate datetime,
	@duration int,
	@lowerLimit varchar(10),
	@upperLimit varchar(10),
	@selectStmt varchar(MAX),
	@fundingClause varchar(MAX),
	@filterString varchar(MAX),
	@sortBy varchar(MAX),
	@currentPage int,     /* current page is 1 to 1 with page : page 2 = 2* pagesize */
	@pageSize int
AS
BEGIN
/*
select	
	@orgID=67,
	@orgType='Query',
	@startDate='6/1/08',
	@duration=12,
	@lowerLimit='1.0',
	@upperLimit='1.0',
	@selectStmt='Select ',
	@fundingClause='Where tblFundingTypes.FundingTypeAbrv in (''F'',''P'',''NB'',''NS'',''NI'',''i'',''X'')',
	@filterString='',
	@sortBy='EmployeeName ASC'
*/
	declare @sqlStmt varchar(MAX)
	declare @monthClause varchar(MAX)
	declare @underClause varchar(MAX)
	declare @overClause varchar(MAX)
	declare @fromClause varchar(MAX)
	declare @filterBy varchar(MAX)
	
	set @monthClause = ''
	set @underClause = ''
	set @overClause = ''
	set @fromClause = ''
	set @filterBy = ''

	-- Execute this store procedure to generate the following clauses for the query
	-- 1. A clause to get each loading month info the user requested
	-- 2. A clause to calculate the total number of months under the specified limit
	-- 3. A clause to calculate the total number of months over the specified limit
	exec spGetLoadingMonthClause @startDate, @duration, @lowerLimit, @upperLimit, @monthClause OUTPUT, @underClause OUTPUT, @overClause OUTPUT

	-- Execute this store procedure to generate a clause of which tables to query from
--	exec spGetOrgPopFromClause @orgID, @orgType, @fundingClause, @fromClause OUTPUT
	exec usp_GetOrgPopFromClause @orgID, @orgType, @fundingClause, @fromClause OUTPUT

	-- Build a clause that will filter the query for just what the user wants
	if (@filterString = '') begin
		if (@orgType = 'Base') begin
			set @filterBy = 'Where tblBaseOrgPopulation.OrganizationID = ' + CAST(@orgID as varchar) + ' '
		end
		else if (@orgType = 'Combined') begin
			set @filterBy = ''
		end
		else if (@orgType = 'Aggregate') begin
			set @filterBy = 'Where tblBaseOrgPopulation.OrganizationID = ' + CAST(@orgID as varchar) + 
				' And tblPeopleTypes.PeopleTypeDesc = ''ASL'' '
		end
		else begin
			set @filterBy = ''
		end
	end
	else begin
		if (@orgType = 'Base') begin
			set @filterBy = 'Where ' + @filterString + ' And tblBaseOrgPopulation.OrganizationID = ' + 
				CAST(@orgID as varchar) + ' '
		end
		else if (@orgType = 'Combined') begin
			set @filterBy = 'Where ' + @filterString + ' ' 
		end
		else if (@orgType = 'Aggregate') begin
			set @filterBy = 'Where ' + @filterString + ' And tblBaseOrgPopulation.OrganizationID = ' + 
				CAST(@orgID as varchar) + ' And tblPeopleTypes.PeopleTypeDesc = ''ASL'' '
		end
		else begin
			set @filterBy = ' Where ' + @filterString + ' '
		end
	end

	-- Build the sql statement needed gather the loading information requested by the user
--	set @sqlStmt = (@selectStmt + ' 
	set @sqlStmt = ('select  
	tblPeople.PeopleId As PersonPopulationID, 
	tblPeople.PeopleId, 
	tblPeople.EmployeeNumber As EmployeeId, 
	tblPeople.FullName As EmployeeName, 
	tblDisciplines.DisciplineDesc As Discipline, 
	tblPeople.HomeSourceCode As HCC, 
	tblPeople.WorkSourceCode As WCC, 
	tblPeople.PeopleDeleted As EmployeeDeleted, ' +
	@monthClause + 
	@underClause +
	@overClause +
	@fromClause +
	@filterBy + ' 
	Group By
		tblPeople.PeopleID,
		tblPeople.EmployeeNumber,
		tblPeople.FullName,
		tblDisciplines.DisciplineDesc,
		tblPeople.HomeSourceCode,
		tblPeople.WorkSourceCode,
		tblPeople.PeopleDeleted 
	Order By ' + @sortBy)

	-- this is just for debugging purposes (to print the sql stmt)
	--select @sqlStmt

CREATE TABLE #tblDisciplines(
	Rank [int] IDENTITY(1,1) NOT NULL,
	PersonPopulationID int NULL,
	[PeopleID] [int] NULL,
	[EmployeeId] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](255) NULL,
	[Discipline] [varchar](50) NULL,
	[HCC] [nvarchar](255) NULL,
	[WCC] [nvarchar](255) NULL,
	[EmployeeDeleted] [bit] NULL,
	[Mo1] decimal(10,1)  NULL,
	[Mo2] decimal(10,1)  NULL,
	[Mo3] decimal(10,1)  NULL,
	[Mo4] decimal(10,1)  NULL,
	[Mo5] decimal(10,1)  NULL,
	[Mo6] decimal(10,1)  NULL,
	[Mo7] decimal(10,1)  NULL,
	[Mo8] decimal(10,1)  NULL,
	[Mo9] decimal(10,1)  NULL,
	[Mo10] decimal(10,1)  NULL,
	[Mo11] decimal(10,1)  NULL,
	[Mo12] decimal(10,1)  NULL,
	[Mo13] decimal(10,1)  NULL,
	[Mo14] decimal(10,1)  NULL,
	[Mo15] decimal(10,1)  NULL,
	[Mo16] decimal(10,1)  NULL,
	[Mo17] decimal(10,1)  NULL,
	[Mo18] decimal(10,1)  NULL,
	[Mo19] decimal(10,1)  NULL,
	[Mo20] decimal(10,1)  NULL,
	[Mo21] decimal(10,1)  NULL,
	[Mo22] decimal(10,1)  NULL,
	[Mo23] decimal(10,1)  NULL,
	[Mo24] decimal(10,1)  NULL,
	[UndertheLimit] decimal(10,1)  NULL,
	[OvertheLimit] decimal(10,1)  NULL
)
	-- need to do this to run the query and get your result set 
	exec('INSERT INTO #tblDisciplines (PersonPopulationID,PeopleID,EmployeeId,EmployeeName,Discipline,HCC,WCC,EmployeeDeleted,[Mo1],[Mo2],[Mo3],[Mo4],[Mo5],[Mo6],[Mo7],[Mo8],[Mo9],[Mo10],[Mo11],[Mo12],[Mo13],[Mo14],[Mo15],[Mo16],[Mo17],[Mo18],[Mo19],[Mo20],[Mo21],[Mo22],[Mo23],[Mo24],[UndertheLimit],[OvertheLimit])' + @sqlStmt)

	select count(1) from #tblDisciplines

	select 
		CAST(SUM([Mo1]) As decimal(10,1)),	SUM([Mo2]),	SUM([Mo3]),	SUM([Mo4]),	SUM([Mo5]),	SUM([Mo6]),	SUM([Mo7]),	SUM([Mo8]),
		SUM([Mo9]),	SUM([Mo10]),	SUM([Mo11]),	SUM([Mo12]),	SUM([Mo13]),	SUM([Mo14]),
		SUM([Mo15]),	SUM([Mo16]),	SUM([Mo17]),	SUM([Mo18]),	SUM([Mo19]),	SUM([Mo20]),
		SUM([Mo21]),	SUM([Mo22]),	SUM([Mo23]),	SUM([Mo24])
	from #tblDisciplines

	select PersonPopulationID,[PeopleID],[EmployeeId],EmployeeName,[Discipline],[HCC]
		,[WCC],[EmployeeDeleted],[Mo1],[Mo2],[Mo3],[Mo4],[Mo5],[Mo6],[Mo7],[Mo8],[Mo9],[Mo10]
		,[Mo11],[Mo12],[Mo13],[Mo14],[Mo15],[Mo16],[Mo17],[Mo18],[Mo19],[Mo20],[Mo21],[Mo22],[Mo23],[Mo24]
		,[UndertheLimit],[OvertheLimit]
	from #tblDisciplines
	where rank between (((@currentPage-1) * @pageSize)+1) and (((@currentPage-1) * @pageSize)+@pageSize)

END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetOrganizationsProtoType]    Script Date: 07/03/2008 19:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
-- Author:		jschuebel
-- ALTER date: 07/19/07
-- Description:	Filtering Issue Tracking
--	Usage: 	
	DECLARE @pagecount int
	exec usp_GetOrganizationsProtoType 
		@orgID=null
		,@orgName=null
		,@orgType='Base'
		,@EmpId=null
		,@coordinator=null
		,@phone=null
		,@email=null
		,@SortOrder='EmployeeNumber'
		,@sortDir=0
		,@currentPage=1
		,@pageSize=100
		,@intRecordCount=@pagecount	OUTPUT
	select @pagecount

	By			Date		Description
 =============================================*/
create PROCEDURE [dbo].[usp_GetOrganizationsProtoType]
	@orgID int=null,
	@orgName varchar(100)=null,
	@orgType [varchar](50)=null,
	@EmpId varchar(50)=null,
	@coordinator varchar(255)=null,
	@phone varchar(50)=null,
	@email varchar(255)=null,
	@SortOrder varchar(64)='FullName',
	@sortDir int,			/* 0=ASC, 1=DESC */
	@currentPage int=1,     /* current page is 1 to 1 with page : page 2 = 2* pagesize */
	@pageSize int=20
	,@intRecordCount		int = 1 OUTPUT
AS

BEGIN
declare	@sfld int
/*
declare	@orgID int,
	@orgName varchar(100),
	@orgType [varchar](50),
	@EmpId varchar(50),
	@coordinator varchar(255),
	@phone varchar(50),
	@email varchar(255),
	@SortOrder varchar(64),
	@sortDir int,
	@currentPage int,
	@pageSize int,
	@intRecordCount int


select	
	@currentPage=1,@sortDir=0,@coordinator='Simpson, William D',
	@pageSize=100,	@SortOrder='OrgSize'
*/

   SELECT @sfld=CASE WHEN @SortOrder='OrganizationId' THEN 1
                        WHEN @SortOrder='OrgName' THEN 2
                        WHEN @SortOrder='OrgType' THEN 3
                        WHEN @SortOrder='EmployeeNumber' THEN 4
                        WHEN @SortOrder='FullName' THEN 5
                        WHEN @SortOrder='PhoneNumber' THEN 6
                        WHEN @SortOrder='EmailAddress' THEN 7
                        WHEN @SortOrder='OrgSize' THEN 8
					ELSE 2
    END
--select 'sort=' + @SortOrder + ' fld=' + cast(@sfld as varchar)
    IF @SortDir=1 SET @sfld=@sfld * -1
--select '@SortDir=' + cast(@sfld as varchar)



	if @orgName is not null set @orgName = @orgName + '%'
	if @EmpId is not null set @EmpId = @EmpId + '%'
	if @email is not null set @email = @email + '%'
	if @phone is not null set @phone = @phone + '%'
	if @coordinator is not null set @coordinator = @coordinator + '%'


	select @intRecordCount=count(1)
		FROM tblOrganizations Org 
			LEFT OUTER JOIN tblPeople Mgr ON Org.OrgManagerID = Mgr.PeopleID
			LEFT OUTER JOIN tblPeople Ctr ON Org.OrgCreatorID = Ctr.PeopleID
			LEFT OUTER JOIN tblPeople Etr ON Org.OrgEditorID = Etr.PeopleID
			LEFT OUTER JOIN tblOrganizationTypes OrgType ON Org.OrganizationTypeID = OrgType.OrganizationTypeID
	WHERE ((@orgID is null) OR ((@orgID is not null) AND (Org.OrganizationID=@orgID))) AND 
		((@orgName is null) OR ((@orgName is not null) AND (Org.OrgName like @orgName))) AND 
		((@orgType is null) OR ((@orgType is not null) AND (OrgType.OrganizationTypeDesc=@orgType))) AND 
		((@EmpId is null) OR ((@EmpId is not null) AND (Mgr.EmployeeNumber like @EmpId))) AND 
		((@email is null) OR ((@email is not null) AND (Mgr.EmailAddress like @email))) AND 
		((@phone is null) OR ((@phone is not null) AND (Mgr.PhoneNumber like @phone))) AND 
		((@coordinator is null) OR ((@coordinator is not null) AND (Mgr.FullName like @coordinator)))

	--select @intRecordCount
	select * from (
	select
		Org.OrganizationID,
		Org.OrgName,
		OrgType.OrganizationTypeDesc,
		Mgr.EmployeeNumber AS EmployeeNumber,
		Mgr.FullName,
		Mgr.PhoneNumber,
		Mgr.EmailAddress,
		Mgr.PeopleDeleted AS OMDeleted,
		(CASE WHEN Org.OrganizationTypeID = 1 THEN Org.OrgSize ELSE (SELECT count(distinct [PeopleID]) FROM [xrefOtherOrganization] where [ParentOrganizationId]=Org.OrganizationID and [PeopleTypeID] not in (4,5))	END ) AS OrgSize,
		Ctr.EmployeeNumber AS OCreator,
		ROW_NUMBER() OVER (ORDER BY 
            --handle int
            CASE    WHEN @sfld = 1 THEN Org.OrganizationID
                    WHEN @sfld = 8 THEN OrgSize
            END ASC, 
            --varchar
            CASE    WHEN @sfld = 2 THEN OrgName 
                    WHEN @sfld = 3 THEN OrgType.OrganizationTypeDesc 
                    WHEN @sfld = 4 THEN Mgr.EmployeeNumber
                    WHEN @sfld = 5 THEN Mgr.FullName 
                    WHEN @sfld = 6 THEN Mgr.PhoneNumber 
                    WHEN @sfld = 7 THEN Mgr.EmailAddress 
            END ASC,
			---------- DESCENDING
			--handle int
			CASE    WHEN @sfld = -1 THEN Org.OrganizationID
					WHEN @sfld = -8 THEN OrgSize
			END DESC, 
			--varchar
				CASE    WHEN @sfld = -2 THEN OrgName 
						WHEN @sfld = -3 THEN OrgType.OrganizationTypeDesc 
						WHEN @sfld = -4 THEN Mgr.EmployeeNumber
						WHEN @sfld = -5 THEN Mgr.FullName 
						WHEN @sfld = -6 THEN Mgr.PhoneNumber 
						WHEN @sfld = -7 THEN Mgr.EmailAddress 
	        END DESC) AS RowNumber
	FROM tblOrganizations Org 
			LEFT OUTER JOIN tblPeople Mgr ON Org.OrgManagerID = Mgr.PeopleID
			LEFT OUTER JOIN tblPeople Ctr ON Org.OrgCreatorID = Ctr.PeopleID
			LEFT OUTER JOIN tblPeople Etr ON Org.OrgEditorID = Etr.PeopleID
			LEFT OUTER JOIN tblOrganizationTypes OrgType ON Org.OrganizationTypeID = OrgType.OrganizationTypeID
	WHERE ((@orgID is null) OR ((@orgID is not null) AND (Org.OrganizationID=@orgID))) AND 
		((@orgName is null) OR ((@orgName is not null) AND (Org.OrgName like @orgName))) AND 
		((@orgType is null) OR ((@orgType is not null) AND (OrgType.OrganizationTypeDesc=@orgType))) AND 
		((@EmpId is null) OR ((@EmpId is not null) AND (Mgr.EmployeeNumber like @EmpId))) AND 
		((@email is null) OR ((@email is not null) AND (Mgr.EmailAddress like @email))) AND 
		((@phone is null) OR ((@phone is not null) AND (Mgr.PhoneNumber like @phone))) AND 
		((@coordinator is null) OR ((@coordinator is not null) AND (Mgr.FullName like @coordinator)))
	) AS Data
	where RowNumber between (((@currentPage-1) * @pageSize)+1) and (((@currentPage-1) * @pageSize)+@pageSize)
	ORDER BY RowNumber


END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetOrganizationsProtoTypeOLD]    Script Date: 07/03/2008 19:17:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
-- Author:		jschuebel
-- ALTER date: 07/19/07
-- Description:	Filtering Issue Tracking
--	Usage: 	
	DECLARE @pagecount int
	exec usp_GetOrganizationsProtoType 
		@orgID=null
		,@orgName=null
		,@orgType='Base'
		,@EmpId=null
		,@coordinator=null
		,@phone=null
		,@email=null
		,@sortBy='EmployeeNumber DESC'
		,@currentPage=1
		,@pageSize=100
		,@intRecordCount=@pagecount	OUTPUT
	select @pagecount

	By			Date		Description
 =============================================*/
create PROCEDURE [dbo].[usp_GetOrganizationsProtoTypeOLD]
	@orgID int=null,
	@orgName varchar(100)=null,
	@orgType [varchar](50)=null,
	@EmpId varchar(50)=null,
	@coordinator varchar(255)=null,
	@phone varchar(50)=null,
	@email varchar(255)=null,
	@sortBy varchar(255)='FullName ASC',
	@currentPage int=1,     /* current page is 1 to 1 with page : page 2 = 2* pagesize */
	@pageSize int=20
	,@intRecordCount		int = 1 OUTPUT
AS

BEGIN
	declare @sqlStmt varchar(MAX)
	DECLARE @strWhere as varchar(MAX)
	DECLARE @strAnd as varchar(6)

/*
declare	@orgID int,
	@orgName varchar(100),
	@orgType [varchar](50),
	@EmpId varchar(50),
	@coordinator varchar(255),
	@phone varchar(50),
	@email varchar(255),
	@sortBy varchar(255),
	@currentPage int,
	@pageSize int,
	@intRecordCount int

select	
	@currentPage=0,
	@pageSize=0,	@sortBy='OMFullName ASC'
*/

--drop table #tblDisciplines

	SET @strWhere=''
	set @strAND=''

	if LEN(LTRIM(RTRIM(@sortBy)))=0
		SET @sortBy='FullName ASC'


	if @orgID is not null
	BEGIN
		 SET @strWhere=@strWhere  + @strAND +  ' Org.OrganizationID=' + cast(@orgID as varchar)
	END
	if len(@strWhere)>0
		set @strAND=' AND '

	if @orgName is not null
	BEGIN
		 SET @strWhere=@strWhere  + @strAND +  ' Org.OrgName like ''' + @orgName + '%''' 
	END
	if len(@strWhere)>0
		set @strAND=' AND '

	if @orgType is not null
	BEGIN
		 SET @strWhere=@strWhere  + @strAND +  ' OrgType.OrganizationTypeDesc=''' + @orgType + ''''
	END
	if len(@strWhere)>0
		set @strAND=' AND '

	if @EmpId is not null
	BEGIN
		 SET @strWhere=@strWhere  + @strAND +  ' (Mgr.EmployeeNumber like ''' + @EmpId + '%''' 
		 SET @strWhere=@strWhere  + 'OR Ctr.EmployeeNumber like ''' + @EmpId + '%''' 
		 SET @strWhere=@strWhere  + 'OR Etr.EmployeeNumber like ''' + @EmpId + '%'') ' 
	END
	if len(@strWhere)>0
		set @strAND=' AND '


	-- Build the sql statement needed gather the loading information requested by the user
	set @sqlStmt = 'select
			Org.OrganizationID,
			Org.OrgName,
			OrgType.OrganizationTypeDesc,
			Mgr.EmployeeNumber AS EmployeeNumber,
			Mgr.FullName,
			Mgr.PhoneNumber,
			Mgr.EmailAddress,
			Mgr.PeopleDeleted AS OMDeleted,
			(CASE WHEN Org.OrganizationTypeID = 1 THEN Org.OrgSize ELSE (SELECT count(distinct [PeopleID]) FROM [xrefOtherOrganization] where [ParentOrganizationId]=Org.OrganizationID and [PeopleTypeID] not in (4,5))	END ) AS OrgSize,
			Ctr.EmployeeNumber AS OCreator
			FROM tblOrganizations Org 
				LEFT OUTER JOIN tblPeople Mgr ON Org.OrgManagerID = Mgr.PeopleID
				LEFT OUTER JOIN tblPeople Ctr ON Org.OrgCreatorID = Ctr.PeopleID
				LEFT OUTER JOIN tblPeople Etr ON Org.OrgEditorID = Etr.PeopleID
				LEFT OUTER JOIN tblOrganizationTypes OrgType ON Org.OrganizationTypeID = OrgType.OrganizationTypeID '
	if len(@strWhere)>0
		set @sqlStmt = @sqlStmt + 'WHERE ' + @strWhere + ' Order By ' + @sortBy
	else
		set @sqlStmt = @sqlStmt + ' Order By ' + @sortBy


CREATE TABLE #tblDisciplines(
	Rank [int] IDENTITY(1,1) NOT NULL,
	OrganizationID [int],
	OrgName [nvarchar](255),
	OrganizationTypeDesc varchar(50),
	EmployeeNumber [nvarchar](50),
	FullName [nvarchar](255),
	PhoneNumber [nvarchar](255),
	EmailAddress [nvarchar](255),
	OMDeleted bit,
	OrgSize int,
	OCreator [nvarchar](50)
)


			
	-- need to do this to run the query and get your result set 
--	exec('INSERT INTO #tblDisciplines (OrganizationID, OrgName, OrganizationTypeDesc, EmployeeNumber, FullName, PhoneNumber, EmailAddress, OMDeleted,OrgSize,OLastViewed, Comments, OCreator, OCreatorFullName, ODateCreated,OEditor,OEditorFullName,ODateEdited)' + @sqlStmt)
	exec('INSERT INTO #tblDisciplines (OrganizationID, OrgName, OrganizationTypeDesc, EmployeeNumber, FullName, PhoneNumber, EmailAddress, OMDeleted,OrgSize, OCreator)' + @sqlStmt)

	select @intRecordCount=count(1) from #tblDisciplines

	select OrganizationID, OrgName, OrganizationTypeDesc OrganizationTypeDesc, EmployeeNumber, FullName, PhoneNumber, EmailAddress
		, OMDeleted,OrgSize, OCreator
	from #tblDisciplines

	where rank between (((@currentPage-1) * @pageSize)+1) and (((@currentPage-1) * @pageSize)+@pageSize)

END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetOrgManagePopulation]    Script Date: 07/03/2008 19:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[usp_GetOrgManagePopulation]
	@orgId	int = null,
	@sortOrder varchar(64) = 'FullName',
	@sortDir int = 0,
	@empId	varchar(50) = null,
	@empName varchar(100) = null,
	@discipline	int = null,
	@hcc varchar(100) = null,
	@wcc varchar(100) = null,
	@city varchar(50) = null,
	@state varchar(50) = null,
	@site varchar(255) = null,
	@currentPage int = 1,
	@pageSize int = 25,
	@recordCnt int = 0
AS
	begin
	
	declare @sfld int
	
   select @sfld = case when @sortOrder='empId' then 1
                       when @sortOrder='empName' then 2
                       when @sortOrder='discipline' then 3
                       when @sortOrder='hcc' then 4
                       when @sortOrder='wcc' then 5
                       when @sortOrder='city' then 6
                       when @sortOrder='state' then 7
                       when @sortOrder='site' then 8
				  else 2
    end
    

	if @sortDir = 1 set @sfld = @sfld * -1

	if @empId is not null set @empId = @empId + '%'
	if @empName is not null set @empName = @empName + '%'
	if @discipline is not null set @discipline = @discipline + '%'
	if @hcc is not null set @hcc = @hcc + '%'
	if @wcc is not null set @wcc = @wcc + '%'
	if @city is not null set @city = @city + '%'
	if @state is not null set @state = @state + '%'
	if @site is not null set @site = @site + '%'
	
	
	
	select @recordCnt = count(*)
	from tblBaseOrgPopulation bo 
	left join tblPeople p on bo.PeopleID = p.PeopleID 
	left join tblPeopleTypes pt on P.PeopleTypeID = pt.PeopleTypeID 
	left join tblDisciplines d on P.DisciplineID = d.DisciplineID 
	where ((@orgId is null) OR ((@orgId is not null) AND (bo.OrganizationID = @orgId))) AND 
		((@empId is null) OR ((@empId is not null) AND (p.employeeNumber like @empId))) AND 
		((@empName is null) OR ((@empName is not null) AND (p.fullName like @empName))) AND 
		((@discipline is null) OR ((@discipline is not null) AND (d.disciplineDesc like @discipline))) AND 
		((@hcc is null) OR ((@hcc is not null) AND (p.homeSourceCode like @hcc))) AND 
		((@wcc is null) OR ((@wcc is not null) AND (p.workSourceCode like @wcc))) AND 
		((@city is null) OR ((@city is not null) AND (p.city like @city))) AND
		((@state is null) OR ((@state is not null) AND (p.state like @state))) AND
		((@site is null) OR ((@site is not null) AND (p.site like @site)))


	select *
	from
	(
		select 
			bo.baseOrgPopulationID AS personPopulationID, p.peopleID AS peopleID, 
			p.employeeNumber AS pEmployeeNumber, p.fullName AS pFullName, d.disciplineDesc AS pFunctionalDept, 
			p.site AS PSite, p.homeSourceCode AS pHomeSourceCode, p.workSourceCode AS pWorkSourceCode, 
			bo.bOrgPopComments AS pComments, p.peopleDeleted AS pEmployeeDeleted, p.phoneNumber AS pPhoneNumber, 
			p.emailAddress AS pEmailAddress, pt.peopleTypeDesc, p.city, p.state, p.site,
			row_number() over(order by 
								case when @sfld = 1 then p.employeeNumber
								when @sfld = 2 then p.fullName
								when @sfld = 3 then d.disciplineDesc
								when @sfld = 4 then p.homeSourceCode
								when @sfld = 5 then p.workSourceCode
								when @sfld = 6 then p.city
								when @sfld = 7 then p.state
								when @sfld = 8 then p.site
								end ASC,
								
								case when @sfld = -1 then p.employeeNumber
								when @sfld = -2 then p.fullName
								when @sfld = -3 then d.disciplineDesc
								when @sfld = -4 then p.homeSourceCode
								when @sfld = -5 then p.workSourceCode
								when @sfld = -6 then p.city
								when @sfld = -7 then p.state
								when @sfld = -8 then p.site
								end DESC ) as rowNumber
								
		from tblBaseOrgPopulation bo
		left join tblPeople P on BO.PeopleID = P.PeopleID 
		left join tblPeopleTypes PT on P.PeopleTypeID = PT.PeopleTypeID 
		left join tblDisciplines D on P.DisciplineID = D.DisciplineID 
		where ((@orgId is null) OR ((@orgId is not null) AND (bo.OrganizationID = @orgId))) AND 
			((@empId is null) OR ((@empId is not null) AND (p.employeeNumber like @empId))) AND 
			((@empName is null) OR ((@empName is not null) AND (p.fullName like @empName))) AND 
			((@discipline is null) OR ((@discipline is not null) AND (d.disciplineDesc like @discipline))) AND 
			((@hcc is null) OR ((@hcc is not null) AND (p.homeSourceCode like @hcc))) AND 
			((@wcc is null) OR ((@wcc is not null) AND (p.workSourceCode like @wcc))) AND 
			((@city is null) OR ((@city is not null) AND (p.city like @city))) AND
			((@state is null) OR ((@state is not null) AND (p.state like @state))) AND
			((@site is null) OR ((@site is not null) AND (p.site like @site)))
	) as data
	where rowNumber between (((@currentPage-1) * @pageSize)+1) and (((@currentPage-1) * @pageSize)+@pageSize)
	order by rowNumber
	
END
GO
