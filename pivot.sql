
declare @lowerLimit varchar(24)
declare @upperLimit varchar(24)
declare @select varchar(max)
declare @mnths varchar(max)
declare @llmtmnths varchar(max)
declare @ulmtmnths varchar(max)
declare @StartDate datetime, @lpdte datetime,@edte datetime 

set @lowerLimit='1.0'
set @upperLimit='1.0'
set @StartDate='6/1/08'
select @mnths='', @llmtmnths='', @ulmtmnths=''
set @lpdte=@StartDate
set @edte=DATEADD(month, 11, @StartDate)
while @lpdte <= @edte 
begin 
	if len(@mnths)>0 set @mnths=@mnths + ','
	select @mnths=@mnths + '[' + Convert(varchar(10),@lpdte,101) + ']'

	if len(@llmtmnths)>0 set @llmtmnths=@llmtmnths + ' + '
	select @llmtmnths=@llmtmnths + 'case when ISNULL([' + Convert(varchar(10),@lpdte,101) + '],0.0)  < ' + @lowerLimit + ' then 1.0 else 0.0 end'

	if len(@ulmtmnths)>0 set @ulmtmnths=@ulmtmnths + ' + '
	select @ulmtmnths=@ulmtmnths + 'case when ISNULL([' + Convert(varchar(10),@lpdte,101) + '],0.0)  > ' + @upperLimit + ' then 1.0 else 0.0 end'

	set @lpdte=DATEADD(month,1 , @lpdte)
end 
SELECT @mnths
SELECT @llmtmnths
SELECT @ulmtmnths


SELECT *, CAST(
	case when ISNULL([06/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end +
	case when ISNULL([07/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end +
	case when ISNULL([08/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end +
	case when ISNULL([09/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([10/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([11/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([12/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([01/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([02/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([03/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([04/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end +
	case when ISNULL([05/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end as decimal(10,1)) as LowerLimit   
	,CAST(
		case when ISNULL([06/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([07/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([08/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([09/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([10/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([11/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([12/01/2008],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([01/01/2009],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([02/01/2009],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([03/01/2009],0.0)  > 1.0 then 1.0 else 0.0 end + case when ISNULL([04/01/2009],0.0)  > 1.0 then 1.0 else 0.0 end + 
		case when ISNULL([05/01/2009],0.0)  > 1.0 then 1.0 else 0.0 end as decimal(10,1)) as UpperLimit
FROM (select tblPeople.PeopleId As PersonPopulationID, tblPeople.PeopleId, tblPeople.EmployeeNumber As EmployeeId
		, tblPeople.FullName As EmployeeName
		, (Select DisciplineDesc 
			from tblDisciplines 
			where tblDisciplines.DisciplineID=tblPeople.DisciplineID) Discipline
		, tblPeople.HomeSourceCode As HCC, tblPeople.WorkSourceCode As WCC
		, tblPeople.PeopleDeleted As EmployeeDeleted
		,convert(varchar(10),LoadingDate,101) LoadingDate,       LoadingValue as Amount     
	From 
	(     
		SELECT distinct [PeopleID]  PeopleID     
		FROM [xrefOtherOrganization]
		where [ParentOrganizationId]=80    
	) xref    
	inner Join tblPeople On tblPeople.PeopleID = xref.PeopleID     
	Left Join tblBaseOrgPopulation On tblPeople.PeopleID = tblBaseOrgPopulation.PeopleID         
	Left Join tblAssignments On xref.PeopleID = tblAssignments.PeopleID      
		And tblBaseOrgPopulation.OrganizationID = tblAssignments.OrganizationID       
		AND tblAssignments.FundingTypeID in (1,2,3,4,5,6,7)    
	Left Join tblContracts On tblAssignments.ContractID = tblContracts.ContractID     
	Left Join tblPrograms On IsNull(tblContracts.ProgramID, tblAssignments.ProgramID) = tblPrograms.ProgramID     
	Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID      
		AND LoadingDate between '06/01/2008' and '05/01/2009'     ) as s   
PIVOT   (    SUM(Amount)    
	FOR [LoadingDate]     
	IN ([06/01/2008],[07/01/2008],[08/01/2008],[09/01/2008],[10/01/2008],[11/01/2008],[12/01/2008],[01/01/2009],[02/01/2009],[03/01/2009],[04/01/2009],[05/01/2009])   )   AS p
Order By EmployeeName ASC









/*
SELECT top 100 * FROM tblLoadings
/*
SELECT *
FROM 
(SELECT top 100
	year(LoadingDate) as [year], 
	left(datename(month,LoadingDate),3)as [month], 
	LoadingValue as Amount FROM tblLoadings
	) as s
 */

SELECT *
FROM (SELECT top 100
	year(LoadingDate) as [year], 
	left(datename(month,LoadingDate),3)as [month], 
	LoadingValue as Amount FROM tblLoadings
) as s
PIVOT
(
	SUM(Amount)
FOR [month]
IN (jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec)
)
AS p


SELECT *
FROM (SELECT
	tblLoadings.AssignmentID,
	year(LoadingDate) as [year], 
	left(datename(month,LoadingDate),3)as [month], 
	LoadingValue as Amount --FROM tblLoadings
	From tblAssignments
		Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID 
		where peopleid=9087
) as s
PIVOT
(
	SUM(Amount)
FOR [month]
IN (jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec)
)
AS p
--where p.year=2008

--2.4
	SELECT *
	FROM (SELECT
			fullname,
			tblLoadings.AssignmentID,
			year(LoadingDate) as [year], 
			left(datename(month,LoadingDate),3)as [month], 
			LoadingValue as Amount --FROM tblLoadings
			From tblBaseOrgPopulation    
				Left Join tblPeople On tblBaseOrgPopulation.PeopleID = tblPeople.PeopleID    
				left Join tblAssignments On tblBaseOrgPopulation.PeopleID = tblAssignments.PeopleID       
				Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID 
				Where tblBaseOrgPopulation.OrganizationID = 2572  
					and LoadingDate between '7/1/08' and '1/1/09'
			) as s
	PIVOT
	(
		SUM(Amount)
		FOR [month]
			IN ([08jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec)
	)
	AS p


SELECT *,
		isnull([07/01/2008],0)+isnull([08/01/2008],0)+isnull([09/01/2008],0)+isnull([10/01/2008],0)
	FROM (SELECT
			fullname,
			tblLoadings.AssignmentID,
			convert(varchar(10),LoadingDate,101) LoadingDate,  
			LoadingValue as Amount --FROM tblLoadings
			From tblBaseOrgPopulation    
				Left Join tblPeople On tblBaseOrgPopulation.PeopleID = tblPeople.PeopleID    
				left Join tblAssignments On tblBaseOrgPopulation.PeopleID = tblAssignments.PeopleID       
				Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID 
				Where tblBaseOrgPopulation.OrganizationID = 2572  
					and LoadingDate between '7/1/08' and '2/1/09'
			) as s
	PIVOT
	(
		SUM(Amount)
		FOR [LoadingDate]
			IN ([07/01/2008], [08/01/2008], [09/01/2008], [10/01/2008], [11/01/2008], [12/01/2008], [01/01/2009])
	)
	AS p
*/

declare @lowerLimit varchar(24)
declare @select varchar(max)
declare @mnths varchar(max)
declare @lmtmnths varchar(max)
declare @StartDate datetime, @lpdte datetime,@edte datetime 

set @lowerLimit='1.0'
set @StartDate='7/1/08'
select @mnths='', @lmtmnths=''
set @lpdte=@StartDate
set @edte=DATEADD(month, 11, @StartDate)
while @lpdte <= @edte 
begin 
	if len(@mnths)>0 set @mnths=@mnths + ','
	select @mnths=@mnths + '[' + Convert(varchar(10),@lpdte,101) + ']'

	if len(@lmtmnths)>0 set @lmtmnths=@lmtmnths + ' + '
	select @lmtmnths=@lmtmnths + 'case when ISNULL([' + Convert(varchar(10),@lpdte,101) + '],0.0)  < ' + @lowerLimit + ' then 1.0 else 0.0 end'

	set @lpdte=DATEADD(month,1 , @lpdte)
end 

set @select='
SELECT *, CAST(' + @lmtmnths + ' as decimal(10,1)) as Limit
	FROM (SELECT
			tblPeople.PeopleId As PersonPopulationID, 
			tblPeople.PeopleId, 
			tblPeople.EmployeeNumber As EmployeeId, 
			tblPeople.FullName As EmployeeName, 
			(Select DisciplineDesc from tblDisciplines where tblDisciplines.DisciplineID=tblPeople.DisciplineID) Discipline,
			tblPeople.HomeSourceCode As HCC, 
			tblPeople.WorkSourceCode As WCC, 
			tblPeople.PeopleDeleted As EmployeeDeleted,
			convert(varchar(10),LoadingDate,101) LoadingDate,  
			LoadingValue as Amount
			From tblBaseOrgPopulation    
				Left Join tblPeople On tblBaseOrgPopulation.PeopleID = tblPeople.PeopleID    
				left Join tblAssignments On tblBaseOrgPopulation.PeopleID = tblAssignments.PeopleID       
				Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID 
				Where tblBaseOrgPopulation.OrganizationID = 2572  
					and ISNULL(LoadingDate,''' + Convert(varchar(10),@StartDate,101) + ''') between ''' + Convert(varchar(10),@StartDate,101) + ''' and ''' + Convert(varchar(10),@edte,101) +'''
			) as s
	PIVOT
	(
		SUM(Amount)
		FOR [LoadingDate]
			IN (' + @mnths + ')
	)
	AS p'

select @select


SELECT *, CAST(
		case when ISNULL([07/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end +
		case when ISNULL([08/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + 
		case when ISNULL([09/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + 
		case when ISNULL([10/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([11/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([12/01/2008],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([01/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([02/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([03/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([04/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + case when ISNULL([05/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end + 
		case when ISNULL([06/01/2009],0.0)  < 1.0 then 1.0 else 0.0 end as decimal(10,1)) as Limit   
FROM (SELECT     tblPeople.PeopleId As PersonPopulationID,      tblPeople.PeopleId,      
			tblPeople.EmployeeNumber As EmployeeId,      tblPeople.FullName As EmployeeName,      
			(Select DisciplineDesc from tblDisciplines where tblDisciplines.DisciplineID=tblPeople.DisciplineID) Discipline,     
			tblPeople.HomeSourceCode As HCC,      tblPeople.WorkSourceCode As WCC,      
			tblPeople.PeopleDeleted As EmployeeDeleted,     
			convert(varchar(10),LoadingDate,101) LoadingDate,       LoadingValue as Amount     
		From tblBaseOrgPopulation          
			Left Join tblPeople On tblBaseOrgPopulation.PeopleID = tblPeople.PeopleID          
			left Join tblAssignments On tblBaseOrgPopulation.PeopleID = tblAssignments.PeopleID             
			Left Join tblLoadings On tblAssignments.AssignmentID = tblLoadings.AssignmentID       
		Where tblBaseOrgPopulation.OrganizationID = 2572         
			and ISNULL(LoadingDate,'07/01/2008') between '07/01/2008' and '06/01/2009'     ) as s   
PIVOT   (    SUM(Amount)    
	FOR [LoadingDate]     
	IN ([07/01/2008],[08/01/2008],[09/01/2008],[10/01/2008],[11/01/2008],[12/01/2008],[01/01/2009],[02/01/2009],[03/01/2009],[04/01/2009],[05/01/2009],[06/01/2009])   )   AS p

