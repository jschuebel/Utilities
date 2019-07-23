/* =============================================
-- Author:		jschuebel
-- ALTER date: 07/19/07
-- Description:	Run queries for 2,3,4 type orgs to generate a xref of the population
	
	OrganizationTypeID	OrganizationTypeDesc
	1					Base
	2					Combined
	3					Query
	4					Aggregate

	Conversion failed when converting the varchar value '0E-3' to data type int.

	By			Date		Description
 =============================================*/
create PROCEDURE [dbo].[usp_xrefOtherOrganizationJob]
AS

BEGIN
	DECLARE @OrgID as int
		,@OrgTypeID int
		,@tsqlex varchar(max)

		DECLARE @CNT AS INT
		DECLARE @TMPCNT AS INT
		DECLARE @ErrorTmp AS INT

		SET @CNT=0
		SET @TMPCNT=100
		SET @ErrorTmp=0
			
	--select @OrgID=5651, @OrgTypeID=3
		select 'Total Recs=' + cast(count(o.OrganizationId) as varchar)
		from tblOrganizations o
		where o.OrganizationTypeId in (2,3,4)


	DECLARE cFindSponsor CURSOR LOCAL FOR
		select o.OrganizationId, o.OrganizationTypeId
		from tblOrganizations o
		where o.OrganizationTypeId in (2,3,4)
	--	where o.OrganizationId=5525


		OPEN cFindSponsor
		FETCH cFindSponsor 
		INTO @OrgID, @OrgTypeID

		WHILE (@@FETCH_STATUS=0) 
		BEGIN
			SET @CNT=@CNT + 1
			IF @CNT=@TMPCNT
			BEGIN
				SET @TMPCNT=@CNT+100
				select cast( @CNT as varchar) + ' @OrgID=' + cast( @OrgID as varchar) + '  @OrgTypeID=' + cast(@OrgTypeID as varchar)
			END


			  -- Get the Org's Population 'Base','Aggregate' 
			  IF @OrgTypeID = 1 OR @OrgTypeID=4
			  BEGIN
				INSERT INTO [xrefOtherOrganization]
						   ([ParentOrganizationId]
						   ,[ParentOrganizationTypeId]
						   ,[PeopleID]
						   ,[PeopleTypeID]
						   ,[OrganizationId]
						   ,[OrganizationTypeId]
						   ,[PeopleDeleted])
				SELECT DISTINCT @OrgID ParentOrg, @OrgTypeID ParentOrgType, t1.PeopleID, t3.PeopleTypeID
						, t1.OrganizationID,  t2.OrganizationTypeId, t3.PeopleDeleted
				FROM
				tblBaseOrgPopulation t1
					LEFT JOIN tblOrganizations t2 ON t1.OrganizationID = t2.OrganizationID
					LEFT JOIN tblPeople t3 ON t1.PeopleID = t3.PeopleID
					inner JOIN tblPeopleTypes t4 ON t3.PeopleTypeID = t4.PeopleTypeID
				WHERE 
					t2.OrganizationID = @OrgID
			  END
			  ELSE IF @OrgTypeID = 2 --'Combined'
			  BEGIN
				-- Get Combo OrgPopulation Info
				DECLARE @BaseOrgIDs as varchar(max)
				exec spGetStringOfComboOrgBaseOrgIDs @OrgID, @BaseOrgIDs OUTPUT
				IF LEN(@BaseOrgIDs) > 0
				BEGIN
					 set @tsqlex= 
						'
						INSERT INTO [xrefOtherOrganization]
								   ([ParentOrganizationId]
								   ,[ParentOrganizationTypeId]
								   ,[PeopleID]
								   ,[PeopleTypeID]
								   ,[OrganizationId]
								   ,[OrganizationTypeId]
								   ,[PeopleDeleted])
						SELECT ' + cast(@OrgID as varchar) + ' ParentOrg, ' + cast(@OrgTypeID as varchar) + ' ParentOrgType, t1.PeopleID, t3.PeopleTypeID
								, t2.OrganizationID,  t2.OrganizationTypeId, t3.PeopleDeleted
						FROM tblBaseOrgPopulation t1
							LEFT JOIN tblOrganizations t2 ON t1.OrganizationID = t2.OrganizationID
							LEFT JOIN tblPeople t3 ON t1.PeopleID = t3.PeopleID
							inner JOIN tblPeopleTypes t4 ON t3.PeopleTypeID = t4.PeopleTypeID
						WHERE 
						t2.OrganizationID IN (' +  @BaseOrgIDs + ')'         

						BEGIN TRY
							EXEC (@tsqlex)
						END TRY
						BEGIN CATCH
							INSERT INTO [tblOtherOrganizationErrors]
									   ([ParentOrganizationId]
									   ,[ParentOrganizationTypeId]
									   ,[ErrorNumber]
									   ,[ErrorMessage])
							SELECT @OrgID ParentOrg, @OrgTypeID ParentOrgType,
								ERROR_NUMBER() as ErrorNumber,
								ERROR_MESSAGE() as ErrorMessage;
						END CATCH;
				END
			  END
			  ELSE IF @OrgTypeID = 3 --'Query'
			  BEGIN
				-- Get Query OrgPopulation Info
				DECLARE @WhereClause as varchar(max)
				exec spGetQueryOrgPopWhereClause @OrgID, @WhereClause OUTPUT
			 --   select @WhereClause 
				IF @WhereClause is not null
				BEGIN
				 set @tsqlex= '
						INSERT INTO [xrefOtherOrganization]
								   ([ParentOrganizationId]
								   ,[ParentOrganizationTypeId]
								   ,[PeopleID]
								   ,[PeopleTypeID]
								   ,[OrganizationId]
								   ,[OrganizationTypeId]
								   ,[PeopleDeleted])
						SELECT ' + cast(@OrgID as varchar) + ' ParentOrg, ' + cast(@OrgTypeID as varchar) + ' ParentOrgType,	t1.PeopleID, t1.PeopleTypeID, t2.OrganizationID,t3.OrganizationTypeId,t1.PeopleDeleted
						FROM tblPeople t1
							LEFT JOIN tblBaseOrgPopulation t2 ON t1.PeopleID = t2.PeopleID
							LEFT JOIN tblOrganizations t3 ON t2.OrganizationID = t3.OrganizationID
							LEFT JOIN tblDisciplines t5 ON t1.DisciplineID = t5.DisciplineID
							LEFT JOIN tblAssignments t6 ON t1.PeopleID = t6.PeopleID AND t2.OrganizationID = t6.OrganizationID
							LEFT JOIN tblContracts t7 ON t6.ContractID = t7.ContractID
							LEFT JOIN tblPrograms t8 ON ISNULL( t7.ProgramID, t6.ProgramID ) = t8.ProgramID
							LEFT JOIN tblFundingTypes t9 ON t6.FundingTypeID = t9.FundingTypeID
							LEFT JOIN tblPeopleTypes t10 ON t1.PeopleTypeID = t10.PeopleTypeID
						WHERE 
						((PeopleDeleted=1 AND t2.OrganizationID IS NOT NULL) OR PeopleDeleted <> 1) AND ' +  @WhereClause

		--	select @tsqlex
					BEGIN TRY
						EXEC (@tsqlex)
					END TRY
					BEGIN CATCH
						INSERT INTO [tblOtherOrganizationErrors]
								   ([ParentOrganizationId]
								   ,[ParentOrganizationTypeId]
								   ,[ErrorNumber]
								   ,[ErrorMessage])
						SELECT @OrgID ParentOrg, @OrgTypeID ParentOrgType,
							ERROR_NUMBER() as ErrorNumber,
							ERROR_MESSAGE() as ErrorMessage;
					END CATCH;
				END
			  END


		FETCH cFindSponsor 
		INTO @OrgID, @OrgTypeID

		END
		
		CLOSE cFindSponsor
		DEALLOCATE cFindSponsor
	/*
	select * from xrefOtherOrganization --where OrganizationID=5525
	truncate table xrefOtherOrganization
	select * from tblPeopleTypes

	and [PeopleTypeID]<> 5

	select [PeopleTypeID], count(*)
	 from xrefOtherOrganization
	group by PeopleTypeID
	SELECT 
		  [PeopleID]
		  ,[PeopleTypeID]
		  ,[PeopleDeleted]
	  FROM [eStaffBeta].[dbo].[xrefOtherOrganization]
	where [ParentOrganizationId]=67 --@OrgID
	and [PeopleTypeID]= 5
	11383+62
	SELECT count(distinct [PeopleID])
	  FROM [eStaffBeta].[dbo].[xrefOtherOrganization]
	where [ParentOrganizationId]=67 --@OrgID
	and [PeopleTypeID] not in (4,5)

	SELECT 
		  count([PeopleID])
	--      ,[PeopleTypeID]
		  --,[PeopleDeleted]
	  FROM [eStaffBeta].[dbo].[xrefOtherOrganization]
	where [ParentOrganizationId]=67 --@OrgID
	and [PeopleTypeID]<> 5
	group by PeopleTypeID

	PeopleTypeDesc	NumPeople
	ASL	62
	Contractor	7141
	Employee	85961
	SYSTEM	1
	TBD	2769
	Contractor_Deleted	67
	Employee_Deleted	338
	TBD_Deleted	24

	PeopleTypeID	PeopleTypeDesc
	5	ASL
	2	Contractor
	1	Employee
	4	SYSTEM
	3	TBD
	*/
END

