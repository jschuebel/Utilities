
selet * from ado.GetBranchByUserManager(1,34)

CREATE FUNCTION GetBranchByUserManager
(	@ManagerType int, @FK_User_Manager int )
RETURNS TABLE 
AS
RETURN 
(
	select *
	FROM [Branch] 
	WHERE @ManagerType = 0 AND (Branch.FK_User_AccountManager in (
						select rs.FK_User_ReportingManager  
						from ReportStructure rs 
						where FK_User=@FK_User_Manager))
	union all
	select *
	FROM [Branch] 
	WHERE @ManagerType=1 AND Branch.FK_User_TerritoryManager = @FK_User_Manager

)
GO
