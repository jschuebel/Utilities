/****** Object:  UserDefinedFunction [dbo].[GetQueryOrgPopWhereClause]    Script Date: 01/29/2009 13:55:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


-- Given and OrgID ALTER  the WHERE Clause for defining the query orgs population
-- 1=Program, 2=Contract, <defaults to People>
--DROP FUNCTION dbo.GetQueryOrgPopWhereClause
CREATE  FUNCTION [dbo].[GetQueryOrgPopWhereClause] ( @OrganizationID int, @CentricType int = NULL )
--CREATE FUNCTION dbo.GetQueryOrgPopWhereClause ( @OrganizationID int, @CentricType int )
RETURNS varchar(8000)
AS
BEGIN
  DECLARE @WhereClause as varchar(8000)
  DECLARE @OrgPopGroups table (
    QueryOrgPopulationID int,
    QueryComparisonID int,
    Src varchar(400),
    Op varchar(400),
    Cmp varchar(6000),
    SrcDataType varchar(400),
    CmpDataType varchar(400),
    CompSQL varchar(100),
    GroupCompSQL varchar(100)
  )

  INSERT @OrgPopGroups
  SELECT 
    t1.QueryOrgPopulationID,
    t2.QueryComparisonID,
    t3.ParamColName AS Src, 
    t8.CompOperatorSQL AS Op,
    CASE WHEN t5.CompareTypeDesc = 'Param to Param' THEN t4.ParamColName ELSE '''' + LTRIM(RTRIM(REPLACE(t2.CmpValue, '''', ''''''))) + '''' END AS Cmp, 
    t3.ParamDataType AS SrcDataType,
    CASE WHEN t5.CompareTypeDesc = 'Param to Param' THEN t4.ParamDataType ELSE t3.ParamDataType END AS CmpDataType, 
    t6.ComparisonTypeSQL AS CompSQL, 
    t7.ComparisonTypeSQL AS GroupCompSQL
  FROM
    tblQueryOrgPopulation t1
    RIGHT JOIN tblQueryComparisons t2 ON t1.QueryOrgPopulationID = t2.QueryOrgPopulationID
    LEFT JOIN tblCompareParameters t3 ON t2.SrcParamID = t3.ParameterID
    LEFT JOIN tblCompareParameters t4 ON t2.CmpParamID = t4.ParameterID
    LEFT JOIN tblCompareTypes t5 ON t2.CompareTypeID = t5.CompareTypeID
    LEFT JOIN tblComparisonTypes t6 ON t2.ComparisonTypeID = t6.ComparisonTypeID
    LEFT JOIN tblComparisonTypes t7 ON t1.QOrgPopCompTypeID = t7.ComparisonTypeID
    LEFT JOIN tblComparisonOperators t8 ON t2.CompOperatorID = t8.CompOperatorID
  WHERE t1.OrganizationID = @OrganizationID
    AND CASE WHEN @CentricType IN (1,2) THEN CASE WHEN (t3.ParamCentricType = @CentricType) THEN 1 ELSE 0 END ELSE 1 END = 1
  ORDER BY 
    t7.ComparisonTypeSQL, t1.QueryOrgPopulationID, t2.ComparisonTypeID, t2.SrcParamID
  
  -- For each OrgPopGroup
  DECLARE @QueryComparisonID as int
  DECLARE @QOrgPopID as int
  DECLARE @PrevQOrgPopID as int
  DECLARE @GroupCompSQL as varchar(50)
  DECLARE @PrevGroupCompSQL as varchar(50)
  DECLARE @CompSQL as varchar(50)
  DECLARE @PrevCompSQL as varchar(50)
  DECLARE @SrcColName as varchar(50)
  DECLARE @PrevSrcColName as varchar(50)
  DECLARE @SrcDataType as varchar(50)
  DECLARE @CmpDataType as varchar(50)
  
  -- Initialize variables
  SET @WhereClause = ' ( ('
  SELECT TOP 1 
    @QueryComparisonID = QueryComparisonID,
    @QOrgPopID = QueryOrgPopulationID, 
    @SrcColName = Src,
    @GroupCompSQL = GroupCompSQL, @CompSQL = CompSQL 
  FROM @OrgPopGroups
  
  WHILE EXISTS (SELECT TOP 1 * FROM @OrgPopGroups)
  BEGIN
  --  SET @WhereClause = @WhereClause + ' ('
    
    -- Check if Operator is "IS NULL" or "IS NOT NULL"
    IF EXISTS(
      SELECT * FROM @OrgPopGroups
      WHERE QueryComparisonID = @QueryComparisonID
        AND ((Op LIKE 'IS NULL') OR (Op LIKE 'IS NOT NULL'))
    )
    BEGIN
      SELECT 
        @WhereClause = @WhereClause + Src + ' ' + Op + ' '
      FROM @OrgPopGroups
      WHERE QueryComparisonID = @QueryComparisonID
    END
    ELSE
    BEGIN
      -- Check if data types match
      IF EXISTS (SELECT * FROM @OrgPopGroups WHERE QueryOrgPopulationID = @QOrgPopID AND SrcDataType = CmpDataType)
      BEGIN 
        IF EXISTS (SELECT * FROM @OrgPopGroups WHERE QueryComparisonID = @QueryComparisonID AND Op LIKE '%LIKE%')
        BEGIN
          SELECT 
            @WhereClause = @WhereClause + Src + ' ' + Op + ' ( CONVERT(' + CmpDataType + ', ' + REPLACE(REPLACE(Cmp, '*', '%'), '$', '_') + ') + ''%'')'        
          FROM @OrgPopGroups
          WHERE QueryComparisonID = @QueryComparisonID
        END
        ELSE
        BEGIN
          SELECT 
            @WhereClause = @WhereClause + Src + ' ' + Op + ' CONVERT(' + CmpDataType + ', ' + Cmp + ')'
          FROM @OrgPopGroups
          WHERE QueryComparisonID = @QueryComparisonID
        END
      END 
      ELSE
      BEGIN 
        SELECT 
          @WhereClause = @WhereClause + ' CONVERT(' + SrcDataType + ', ' + Src + ') ' + Op + ' CONVERT(' + SrcDataType + ', ' + Cmp + ')'
        FROM @OrgPopGroups
        WHERE QueryComparisonID = @QueryComparisonID
      END 
    END
  
    DELETE @OrgPopGroups WHERE QueryComparisonID = @QueryComparisonID  
    -- Store current Group and Comp SQL variables
    SELECT @PrevQOrgPopID = @QOrgPopID, @PrevGroupCompSQL = @GroupCompSQL, @PrevCompSQL = @CompSQL, @PrevSrcColName = @SrcColName
    -- Get the next comparisons info
    SELECT TOP 1 
      @QueryComparisonID = QueryComparisonID,
      @QOrgPopID = QueryOrgPopulationID, 
      @SrcColName = Src,
      @GroupCompSQL = GroupCompSQL, @CompSQL = CompSQL
    FROM @OrgPopGroups
  
--    PRINT CAST(@QOrgPopID AS varchar(300)) + ', ' + CAST(@QueryComparisonID AS varchar(300)) + ', ' + @SrcColName + ', ' + @PrevSrcColName + ', ' + @GroupCompSQL + ', ' + @PrevGroupCompSQL + ', ' + @CompSQL + ', ' + @PrevCompSQL
  
    IF EXISTS (SELECT TOP 1 * FROM @OrgPopGroups)
    BEGIN
      -- Set Group Compare end tag
      IF @PrevQOrgPopID <> @QOrgPopID
      BEGIN
        IF @PrevGroupCompSQL = 'OR' OR @GroupCompSQL = 'OR'
          SET @WhereClause = @WhereClause + ') ) OR ( ('
        ELSE 
          SET @WhereClause = @WhereClause + ') ) ' + @PrevGroupCompSQL + ' ( ('      
      END
      ELSE IF @PrevSrcColName = @SrcColName -- Set Compare end tag
        SET @WhereClause = @WhereClause + ' OR '
      ELSE IF @PrevCompSQL = 'OR' OR @CompSQL = 'OR'
        SET @WhereClause = @WhereClause + ') OR ('
      ELSE 
        SET @WhereClause = @WhereClause + ' ) ' + @PrevCompSQL + ' ('
    END
  
  --  SELECT * FROM #OrgPopGroups
  END
--  DROP TABLE @OrgPopGroups
  --PRINT LEN(@WhereClause)
  IF LEN(@WhereClause) < 7
    SET @WhereClause = ''
  ELSE
    SET @WhereClause = @WhereClause + ') )'

--  SELECT  @WhereClause
 
  RETURN( @WhereClause )

END




GO
/****** Object:  UserDefinedFunction [dbo].[ToFiscalDate]    Script Date: 01/29/2009 13:55:57 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


-- Return the FiscalDate associated with the given date
-- DROP FUNCTION dbo.ToFiscalDate(
-- CREATE FUNCTION dbo.ToFiscalDate(
 CREATE FUNCTION [dbo].[ToFiscalDate](
  @Date AS datetime
)
RETURNS datetime
AS
BEGIN
  -- SELECT dbo.ToFiscalDate( GetDate() )
  DECLARE @FiscalDate AS datetime 

  SELECT @FiscalDate = Convert(datetime, CAST( StartMonth AS varchar ) + '/1/' + CAST( YEAR(@Date) AS varchar) ) 
  FROM
    tblFiscalDates
  WHERE
    @Date BETWEEN StartDate AND EndDate

  RETURN @FiscalDate
END




GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetPeopleRoles]    Script Date: 01/29/2009 13:55:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[udf_GetPeopleRoles](@peopleid int)
RETURNS VARCHAR(4000) AS

BEGIN
   DECLARE @Roles varchar(4000)
   SELECT @Roles = COALESCE(@Roles + ', ', '') + (Select RightDesc from tblRights r where r.RightID=ur.RightID)
	from tblUserRights ur
   WHERE peopleid = @peopleid

   RETURN @Roles
END



/****** Object:  UserDefinedFunction [dbo].[GetComboOrgBaseOrgIDs]    Script Date: 01/29/2009 13:56:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO



-- GET BASE ORG IDs FROM A GIVEN COMBO ORG ID
-- DROP FUNCTION dbo.GetComboOrgBaseOrgIDs
CREATE FUNCTION [dbo].[GetComboOrgBaseOrgIDs] (
-- ALTER FUNCTION dbo.GetComboOrgBaseOrgIDs (
  @ComboOrgID as int
)
RETURNS @OrganizationIDs table( OrganizationID int )
AS
BEGIN
  -- Declare and Set Local Variables
  DECLARE @CurComboOrgID as int
  DECLARE @BaseOrgTypeID as int
  DECLARE @ComboOrgTypeID as int
  SELECT @BaseOrgTypeID = OrganizationTypeID FROM tblOrganizationTypes WHERE OrganizationTypeDesc LIKE 'Base%'
  SELECT @ComboOrgTypeID = OrganizationTypeID FROM tblOrganizationTypes WHERE OrganizationTypeDesc LIKE 'Comb%'

  DECLARE @MemberOrgs table (
    MemberOrgID int,
    OrganizationTypeID int,
    Visited bit
  )

  -- Initialize the Member Organization temp table
  INSERT @MemberOrgs
  SELECT t1.MemberOrgID, t2.OrganizationTypeID, 0 AS Visited
  FROM 
    tblComboOrgPopulation t1
    LEFT JOIN tblOrganizations t2 ON t1.MemberOrgID = t2.OrganizationID
  WHERE t1.OrganizationID = @ComboOrgID
  
  -- SET the Current Combo Org ID variable
  SELECT TOP 1 @CurComboOrgID = MemberOrgID FROM @MemberOrgs WHERE OrganizationTypeID = @ComboOrgTypeID AND Visited = 0
  -- Loop through all unvisited combo orgs and get their member orgs
  WHILE @@ROWCOUNT > 0
  BEGIN
    -- Add the Combo Org's member orgs
    INSERT @MemberOrgs
    SELECT t1.MemberOrgID, t2.OrganizationTypeID, 0 AS Visited
    FROM 
      tblComboOrgPopulation t1
      LEFT JOIN tblOrganizations t2 ON t1.MemberOrgID = t2.OrganizationID
    WHERE t1.OrganizationID = @CurComboOrgID AND t1.MemberOrgID NOT IN (SELECT MemberOrgID FROM @MemberOrgs)
  
    -- Mark Current Member Org as Visited  
    UPDATE @MemberOrgs SET Visited = 1 WHERE MemberOrgID = @CurComboOrgID
  
    -- Get the next Combo Member Org
    SELECT TOP 1 @CurComboOrgID = MemberOrgID FROM @MemberOrgs WHERE OrganizationTypeID = @ComboOrgTypeID AND Visited = 0
  END

  -- Return a table of all Member base orgs
  INSERT @OrganizationIDs 
  SELECT MemberOrgID FROM @MemberOrgs WHERE OrganizationTypeID = @BaseOrgTypeID
  RETURN
END





GO
/****** Object:  UserDefinedFunction [dbo].[GetOrgPopulationCCs]    Script Date: 01/29/2009 13:56:23 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO




--DROP FUNCTION dbo.GetOrgPopulationCCs
--ALTER  FUNCTION dbo.GetOrgPopulationCCs( @OrgID int )
CREATE  FUNCTION [dbo].[GetOrgPopulationCCs]( @OrgID int )
RETURNS @CCs TABLE (CC varchar(50))
AS
BEGIN
  DECLARE @OrgTypeDesc as varchar(50)

  -- Determine the organization type
  SELECT @OrgTypeDesc = OrganizationTypeDesc 
  FROM tblOrganizations t1 LEFT JOIN tblOrganizationTypes t2 ON t1.OrganizationTypeID = t2.OrganizationTypeID 
  WHERE t1.OrganizationID = @OrgID

  -- Get the Org's Population
  IF @OrgTypeDesc = 'Base'  OR @OrgTypeDesc='Aggregate'
  BEGIN
    INSERT @CCs
    -- Get Base OrgPopulation Info
    SELECT DISTINCT p.HomeSourceCode
    FROM
      tblBaseOrgPopulation t1
      LEFT JOIN tblPeople p ON t1.PeopleID = p.PeopleID
    WHERE 
      t1.OrganizationID = @OrgID
  END
  ELSE IF @OrgTypeDesc = 'Combined'
  BEGIN
    INSERT @CCs
    -- Get Combo OrgPopulation Info
    SELECT DISTINCT p.HomeSourceCode
    FROM
      GetComboOrgBaseOrgIDs(@OrgID) b
      LEFT JOIN tblBaseOrgPopulation t1 ON b.OrganizationID = t1.OrganizationID
      LEFT JOIN tblPeople p ON t1.PeopleID = p.PeopleID
  END
  ELSE IF @OrgTypeDesc = 'Query'
  BEGIN
    INSERT @CCs
    SELECT DISTINCT p.HomeSourceCode
    FROM
      GetQueryOrgPopulationPeople(@OrgID) op
      LEFT JOIN tblPeople p ON op.PeopleID = p.PeopleID
  END

  RETURN 
END






GO
/****** Object:  UserDefinedFunction [dbo].[GetOrgPopulationPeopleIDs]    Script Date: 01/29/2009 13:56:23 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--DROP FUNCTION GetOrgPopulationPeopleIDs
--CREATE FUNCTION GetOrgPopulationPeopleIDs( @OrgID int )
CREATE FUNCTION [dbo].[GetOrgPopulationPeopleIDs]( @OrgID int )
RETURNS @PeopleIDs TABLE (PeopleID int)
AS
BEGIN
  DECLARE @PeopleIDs_table table(PeopleID int)
  DECLARE @OrgTypeDesc as varchar(50)

  -- Determine the organization type
  SELECT @OrgTypeDesc = OrganizationTypeDesc 
  FROM tblOrganizations t1 LEFT JOIN tblOrganizationTypes t2 ON t1.OrganizationTypeID = t2.OrganizationTypeID 
  WHERE t1.OrganizationID = @OrgID

  -- Get the Org's Population
  IF @OrgTypeDesc = 'Base'  OR @OrgTypeDesc='Aggregate'
  BEGIN
    INSERT @PeopleIDs
    -- Get Base OrgPopulation Info
    SELECT DISTINCT t1.PeopleID
    FROM
      tblBaseOrgPopulation t1
    WHERE 
      t1.OrganizationID = @OrgID
  END
  ELSE IF @OrgTypeDesc = 'Combined'
  BEGIN
    INSERT @PeopleIDs
    -- Get Combo OrgPopulation Info
    SELECT DISTINCT t1.PeopleID
    FROM
      GetComboOrgBaseOrgIDs(@OrgID) b
      LEFT JOIN tblBaseOrgPopulation t1 ON b.OrganizationID = t1.OrganizationID
  END
  ELSE IF @OrgTypeDesc = 'Query'
  BEGIN
    INSERT @PeopleIDs
    SELECT DISTINCT op.PeopleID
    FROM
      GetQueryOrgPopulationPeople(@OrgID) op
  END

  RETURN 
END



GO
/****** Object:  UserDefinedFunction [dbo].[GetQueryOrgPopulationPeople]    Script Date: 01/29/2009 13:56:24 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO



-- GET People Population for a Query Org
--DROP FUNCTION dbo.GetQueryOrgPopulationPeople
CREATE    FUNCTION [dbo].[GetQueryOrgPopulationPeople]( @OrganizationID int )
--CREATE FUNCTION dbo.GetQueryOrgPopulationPeople( @OrganizationID int )
RETURNS @PeopleIDs TABLE (PeopleID int)
AS
BEGIN
/*

SELECT DISTINCT p.HomeSourceCode
FROM
  GetQueryOrgPopulationPeople(314) op
  LEFT JOIN tblPeople p ON op.PeopleID = p.PeopleID

  
*/
  DECLARE @PeopleIDs_table table(PeopleID int)
  DECLARE @PeopleID int
  DECLARE @MyCursor CURSOR

  DECLARE @SQL varchar(8000)
  DECLARE @WhereClause varchar(8000)
  SET @WhereClause = dbo.GetQueryOrgPopWhereClause( @OrganizationID, null )

  SELECT @SQL = 'SELECT TOP 40 PeopleID FROM tblPeople'
  exec sp_executesql  @SQL 


  SET @MyCursor = CURSOR
  FORWARD_ONLY STATIC FOR
/*
  SELECT a.PeopleID FROM OPENROWSET('SQLOLEDB','SERVER=cmck-sqlprdc001,1203;Database=eStaff_test;Trusted_Connection=yes;', 
    'SELECT DISTINCT t1.PeopleID
      FROM
        tblPeople t1
        LEFT JOIN tblBaseOrgPopulation t2 ON t1.PeopleID = t2.PeopleID
        LEFT JOIN tblOrganizations t3 ON t2.OrganizationID = t3.OrganizationID
        LEFT JOIN tblDisciplines t5 ON t1.DisciplineID = t5.DisciplineID
        LEFT JOIN tblAssignments t6 ON t1.PeopleID = t6.PeopleID AND t3.OrganizationID = t6.OrganizationID
        LEFT JOIN tblContracts t7 ON t6.ContractID = t7.ContractID
        LEFT JOIN tblPrograms t8 ON ISNULL( t7.ProgramID, t6.ProgramID ) = t8.ProgramID
        LEFT JOIN tblFundingTypes t9 ON t6.FundingTypeID = t9.FundingTypeID
        LEFT JOIN tblPeopleTypes t10 ON t1.PeopleTypeID = t10.PeopleTypeID
      WHERE 
        ((PeopleDeleted=1 AND t2.OrganizationID IS NOT NULL) OR PeopleDeleted <> 1) AND ' &  @WhereClause & '   '
  ) AS a
*/
  SELECT TOP 40 PeopleID FROM tblPeople

  OPEN @MyCursor


  
--  exec spGetQueryOrgPopulationPeople @OrganizationID, @PeopleIDs_cursor = @MyCursor OUTPUT

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    FETCH NEXT FROM @MyCursor
    INTO @PeopleID
--    PRINT @PeopleID
    INSERT @PeopleIDs_table SELECT @PeopleID

  END
  CLOSE @MyCursor
  DEALLOCATE @MyCursor
    
  INSERT @PeopleIDs SELECT PeopleID FROM @PeopleIDs_table

  RETURN 
END




