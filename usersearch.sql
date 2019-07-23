SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
-- Author:		jschuebel
-- ALTER date: 05/31/06

DECLARE @pagecount int
--exec usp_GetAllUserInfo @xml='<filters name="j" bhomephone="972" fbdate="5/6/64" ></filters>'
exec usp_GetAllUserInfo @xml='<filters SortOrder="name" sortDir="0" currentPage="1" pageSize="20"></filters>'
			,@SortOrder=null
			,@sortDir=null
			,@currentPage=null
			,@pageSize=null
			,@intRecordCount=@pagecount	OUTPUT
	select @pagecount

-- Description:	Paging Listing Items
	By			Date		Description
 =============================================*/

ALTER procedure [dbo].[usp_GetAllUserInfo] 
(	@xml xml,
	@SortOrder varchar(64)='Name',
	@sortDir int,			/* 0=ASC, 1=DESC */
	@currentPage int=1,     /* current page is 1 to 1 with page : page 2 = 2* pagesize */
	@pageSize int=20
	,@intRecordCount		int = 1 OUTPUT
)
as

DECLARE @name varchar(50),@homephone varchar(50), @bdate datetime,
	@iSortOrder varchar(64),
	@isortDir int,			/* 0=ASC, 1=DESC */
	@icurrentPage int=1,     /* current page is 1 to 1 with page : page 2 = 2* pagesize */
	@ipageSize int=20
declare	@sfld int

/*	
DECLARE @xml xml
SELECT 	@xml='<filters dname="j" dhomephone="972" dbdate="5/6/64" ></filters>'

declare	@SortOrder varchar(64),
	@sortDir int,
	@currentPage int,
	@pageSize int,
	@intRecordCount int


select	
	@currentPage=5,@sortDir=0, @pageSize=10,	@SortOrder='BDate'
*/

  SELECT @sfld=CASE WHEN @iSortOrder='BDate' THEN 1
                        WHEN @iSortOrder='Name' THEN 2
                        WHEN @iSortOrder='OrgType' THEN 3
                        WHEN @iSortOrder='EmployeeNumber' THEN 4
                        WHEN @iSortOrder='FullName' THEN 5
                        WHEN @iSortOrder='PhoneNumber' THEN 6
                        WHEN @iSortOrder='EmailAddress' THEN 7
                        WHEN @iSortOrder='OrgSize' THEN 8
					ELSE 2
    END
--select 'sort=' + @SortOrder + ' fld=' + cast(@sfld as varchar)
    IF @iSortDir=1 SET @sfld=@sfld * -1
--select '@SortDir=' + cast(@sfld as varchar)

SELECT @name=ParamValues.rw.value('@name','varchar(64)'),
	@homephone=ParamValues.rw.value('@homephone','varchar(14)'),
	@bdate=ParamValues.rw.value('@bdate','datetime'),
	@iSortOrder=ParamValues.rw.value('@SortOrder','varchar(64)'),
	@isortDir=ParamValues.rw.value('@sortDir','int'),
	@icurrentPage=ParamValues.rw.value('@currentPage','int'),
	@ipageSize=ParamValues.rw.value('@pageSize','int')
FROM @xml.nodes('/filters') as ParamValues(rw)  

--select 'name=', @name, 'phone=', @homephone
--select '@iSortOrder=', @iSortOrder, '  @isortDir=', @isortDir, '  @icurrentPage=', @icurrentPage, '  @ipageSize=', @ipageSize


if @name is not null set @name='%'+ @name + '%'
if @homephone is not null set @homephone='%'+ @homephone + '%'

SELECT @intRecordCount=COUNT(*)
FROM General gen
left outer join Events evt on evt.UserID=gen.id and evt.topicid=1
left outer join Addresses addr on addr.id=gen.[Address ID]
where ((@name is null) OR (@name is not null AND name like @name)) AND
	((@homephone is null) OR (@homephone is not null AND [Home Phone] like @homephone)) AND
	((@bdate is null) OR (@bdate is not null AND evt.Date >= @bdate AND evt.Date < DateAdd(d, 1,@bdate)))

	select * from (
		SELECT  gen.id
		,gen.Name
		,gen.[Home Phone]
		,gen.Work
		,gen.Mobile
		,gen.[E-Mail]
		,evt.Date bdate
		,addr.Address
		,addr.City
		,addr.State
		,addr.Zip
		,0 ModifiedFlag
		,ROW_NUMBER() OVER (ORDER BY 
            --handle date
            CASE    WHEN @sfld = 1 THEN evt.Date
            END ASC, 
            --varchar
            CASE    WHEN @sfld = 2 THEN Name 
            END ASC,
			---------- DESCENDING
			--handle int
			CASE    WHEN @sfld = -1 THEN evt.Date
			END DESC, 
			--varchar
				CASE    WHEN @sfld = -2 THEN Name 
	        END DESC) AS RowNumber
		FROM General gen
		left outer join Events evt on evt.UserID=gen.id and evt.topicid=1
		left outer join Addresses addr on addr.id=gen.[Address ID]
		where ((@name is null) OR (@name is not null AND name like @name)) AND
			((@homephone is null) OR (@homephone is not null AND [Home Phone] like @homephone)) AND
			((@bdate is null) OR (@bdate is not null AND evt.Date >= @bdate AND evt.Date < DateAdd(d, 1,@bdate)))

	) AS Data
	where RowNumber between (((@icurrentPage-1) * @ipageSize)+1) and (((@icurrentPage-1) * @ipageSize)+@ipageSize)
	ORDER BY RowNumber
	










