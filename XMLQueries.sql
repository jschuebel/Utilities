WITH XMLNAMESPACES ('http://ACORD.org/Standards/Life/2' as ns1)
SELECT ParamValues.rw.value('.','varchar(50)') as id
FROM [eApp] CROSS APPLY [eAppData].nodes('/ns1:TXLife/ns1:TXLifeRequest/ns1:TransRefGUID') as ParamValues(rw)  


  WITH XMLNAMESPACES ('http://ACORD.org/Standards/Life/2' as MsBuild)
SELECT [eAppGUID],[UpdateDateTime],
	rw.value('(MsBuild:Party[@id=''Primary_Insured'']/MsBuild:Person/MsBuild:FirstName)[1]','varchar(50)') as FirstName,
	rw.value('(MsBuild:Party[@id=''Primary_Insured'']/MsBuild:Person/MsBuild:LastName)[1]','varchar(50)') as LastName,
	rw.value('(MsBuild:Party[@id=''Primary_Insured'']/MsBuild:GovtID)[1]','varchar(50)') as GovtIDSSN,
	rw.value('(MsBuild:Party[@id=''Agent_1'']/MsBuild:Person/MsBuild:LastName)[1]','varchar(50)') as AgentLastName,
	rw.value('(MsBuild:Party[@id=''Agent_1'']/MsBuild:Producer/MsBuild:CarrierAppointment/MsBuild:CompanyProducerID)[1]','varchar(50)') as CompanyProducerID_AgentID,
	rw.value('(MsBuild:Party[@id=''Agent_1'']/MsBuild:Producer/MsBuild:CarrierAppointment/MsBuild:OLifEExtension/MsBuild:StateLicID)[1]','varchar(50)') as StateLicID,
	rw.value('(MsBuild:Party[@id=''Primary_Insured'']/MsBuild:Address[@id=''PI_Address_Residence'']/MsBuild:AddressStateTC)[1]','varchar(5)') as PrimResState,
	rw.value('(MsBuild:Party[@id=''Primary_Insured'']/MsBuild:Address[@id=''PI_Address_Mailing'']/MsBuild:AddressStateTC)[1]','varchar(5)') as PrimMailState,
	rw.value('(MsBuild:Holding[@id=''Application_Holding'']/MsBuild:Policy/MsBuild:ApplicationInfo/MsBuild:SignatureInfo/MsBuild:SignatureDate)[1]','varchar(50)') as SignatureDate,
	rw.value('(MsBuild:Holding[@id=''Application_Holding'']/MsBuild:Policy/MsBuild:PaymentMethod)[1]','varchar(50)') as PaymentMethod,
	rw.value('(MsBuild:Holding[@id=''Application_Holding'']/MsBuild:Policy/MsBuild:ProductCode)[1]','varchar(50)') as ProductCode,
	rw.value('(MsBuild:Holding[@id=''Banking_Holding'']/MsBuild:Banking/MsBuild:RoutingNum)[1]','varchar(50)') as RoutingNum
FROM (
	select XI.[eAppGUID],XI.[UpdateDateTime], XI.xm
	FROM (
		SELECT [eAppGUID], [UpdateDateTime], CAST([eAppData] as XML) xm
		FROM [eApp]
	) AS XI
) AS XO  CROSS APPLY XO.xm.nodes('//MsBuild:TXLife/MsBuild:TXLifeRequest/MsBuild:OLifE') as ParamValues(rw)  
order by [UpdateDateTime] desc


SELECT *
FROM [ExceptionLog]
WHERE ErrorMessageXML.exist('Error/FranchiseID[.=500]')=1


SELECT pk, xCol
FROM   docs
WHERE  xCol.exist ('/book[@genre = "security"]') = 1


[ExceptionLogID]
      ,[DateCreated]
      ,[DateSubmitted]
      ,[ApplicationID]
      ,[ErrorSeverity]
      ,[ErrorMessage]
      ,[ErrorCode]
      ,[SendAlertEmail]
      ,[AltEmailAddress]


<Error><FranchiseID>500</FranchiseID><ErrorCode>999</ErrorCode><ErrorMessage>Epic fail</ErrorMessage></Error>






DECLARE @Assignments xml
set @Assignments='<Recs><assn id="282746"  /><assn id="347681"  /><assn id="528932"  /></Recs>'
SELECT ParamValues.rw.value('@id','int')
FROM @Assignments.nodes('/Recs/assn') as ParamValues(rw)  

DECLARE @rws xml
set @rws= '<EmpNum><row>nrp0215793</row><row>0130914</row><row>0210695</row><row>blblabla</row></EmpNum>'
SELECT ParamValues.rw.value('.','varchar(50)') as id
FROM @rws.nodes('/EmpNum/row') as ParamValues(rw)  


declare	@Forecasts xml
set @Forecasts='<Recs><update ContractID="67"  ProgramID="164"  BlockForecast="True"  /><update ProgramID="21"  BlockForecast="True"  /></Recs>'

SELECT ParamValues.rw.value('@ProgramID','int') as ProgramID
		,ParamValues.rw.value('@ContractID','int') as ContractID
		,ParamValues.rw.value('@BlockForecast','bit') as BlockForecast
FROM @Forecasts.nodes('/Recs/update') as ParamValues(rw)  
WHERE ParamValues.rw.value('@ContractID','int') IS NOT NULL


declare @Loadings xml
SET @Loadings ='<Loading><Load dat="6/1/2008" val="1" /><Load dat="7/1/2008" val="1" /><Load dat="8/1/2008" val="1" /><Load dat="9/1/2008" val="1" /></Loading>'
SELECT ParamValues.rw.value('@dat','datetime') as LoadDate,ParamValues.rw.value('@val','decimal(10,1)') as LoadValue
FROM @Loadings.nodes('/Loading/Load') as ParamValues(rw)  


RAISERROR(N'%s : Already Exists for OrgID=%d.',
	10, -- Severity.
	1, -- State.
	@OrgName,
	@OrganizationID); -- Second substitution argument.


declare	@PwinPgos xml
set @PwinPgos='<Recs><update PwinPgo="910"  ContractID="1862"  ProgramID="1344"  Pwin="0.80"  Pgo="1.00"  /><update PwinPgo="384"  ContractID="1922"  ProgramID="1477" Pwin="0.80"     Pgo="1.00"  /><update PwinPgo="1865"  ContractID="11954"  ProgramID="4516"  Pwin="1.0"  /></Recs>'
SELECT ParamValues.rw.value('@PwinPgo','int') as PwinPgo
	,ParamValues.rw.value('@ContractID','int') as ContractID
	,ParamValues.rw.value('@ProgramID','int') as ProgramID
	,ParamValues.rw.value('@Pwin','float') as Pwin
	,ParamValues.rw.value('@Pgo','float') as Pgo
FROM @PwinPgos.nodes('/Recs/update') as ParamValues(rw)  
--		WHERE ParamValues.rw.value('@ContractID','int') IS NOT NULL


declare	@Assignments xml
set @Assignments='<Recs><insert id="282746"  ContractId="11954"  /><insert id="444687"  ContractId="11954"  /><insert id="347681"  ContractId="11954"  /><insert id="225759"  ContractId="11954"  /><insert id="536212"  ContractId="11954"  /><insert id="529537"  ContractId="11954"  /><insert id="492523"  ContractId="11954"  /><insert id="314721"  ContractId="11954"  /><insert id="298810"  ContractId="11954"  /><insert PeopleId="8230"  ContractId="11954"  /></Recs>'
--set @Assignments='<Recs><insert id="461724"  FundingTypeId="3"  ApexProgramId="48724"  /></Recs>'

SELECT ParamValues.rw.value('@id','int') as AssignmentID
	,ParamValues.rw.value('@PeopleId','int') as PeopleId
	,ParamValues.rw.value('@Task','varchar(100)') as AssignmentTask
	,ParamValues.rw.value('@FundingTypeId','int') as FundingTypeId
	,ParamValues.rw.value('@ProgramId','int') as ProgramID
	,ParamValues.rw.value('@ContractId','int') as ContractID
	,ParamValues.rw.value('@ApexProgramId','int') as FK_nlProgramIDAPEX
FROM @Assignments.nodes('/Recs/insert') as ParamValues(rw)  


