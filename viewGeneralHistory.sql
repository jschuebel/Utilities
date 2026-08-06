ALTER VIEW [dbo].[viewGeneralHistory]
AS

WITH cte
AS
(
SELECT [id]
	,[Name]
	,[DOB]
	,[E-Mail]
	,[Home Phone]
	,[Mobile]
      ,[Work]
	  ,[AddressID]
      ,[createdate]
      ,[SysStartTime] UpdatedOn
      ,[SysEndTime],

      LAG(SysStartTime) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_UpdatedOn,
      LAG([AddressID]) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_AddressID,
      LAG(Name) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_Name,
      LAG(DOB) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_DOB,
      LAG([E-Mail]) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_E_Mail,
--      LAG(Name) OVER(PARTITION BY NameTableID ORDER BY SysEndTime) AS prev_Name,
      LAG(Work) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_Work,
      LAG([Home Phone]) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_Home_Phone,
      LAG([Mobile]) OVER(PARTITION BY ID ORDER BY SysEndTime) AS prev_Mobile
	  
	  
  FROM (
	  SELECT gen.[id]
		  ,[Name]
		  ,[Home Phone]
		  ,[Work]
		  ,[Pager]
		  ,[Fax]
		  ,[Mobile]
		  ,[E-Mail]
		  ,[Address ID] AddressID
		  ,[BirthdayAlert]
	      ,evt.[Date] DOB
		  ,gen.[createdate]
		  ,gen.[SysStartTime]
		  ,gen.[SysEndTime]
	  FROM [Personal].[dbo].[General] gen
		left outer join [personal].[dbo].[Events] evt (nolock) on evt.UserID=gen.[id] and evt.[TopicID]=1 --birthday
	  union all
	  SELECT gen.[id]
		  ,[Name]
		  ,[Home Phone]
		  ,[Work]
		  ,[Pager]
		  ,[Fax]
		  ,[Mobile]
		  ,[E-Mail]
		  ,[Address ID] AddressID
		  ,[BirthdayAlert]
	      ,evt.[Date] DOB
		  ,gen.[createdate]
		  ,gen.[SysStartTime]
		  ,gen.[SysEndTime]
	 FROM [Personal].[history].[General] gen
		left outer join [personal].[dbo].[Events] evt (nolock) on evt.UserID=gen.[id] and evt.[TopicID]=1 --birthday
	  union all
	  SELECT gen.[id]
		  ,[Name]
		  ,[Home Phone]
		  ,[Work]
		  ,[Pager]
		  ,[Fax]
		  ,[Mobile]
		  ,[E-Mail]
		  ,[Address ID] AddressID
		  ,[BirthdayAlert]
	      ,evt.[Date] DOB
		  ,gen.[createdate]
		  ,gen.[SysStartTime]
		  ,gen.[SysEndTime]
	 FROM [personal].[history].[Events] evt (nolock)
		left outer join [Personal].[dbo].[General] gen (nolock) on evt.UserID=gen.[id] and evt.[TopicID]=1 --birthday
	 ) as XDAT
)

--select * from cte where [ID]=10 --24 --128

SELECT
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID,
       cte.id PersonID,
	   gen.Name,
       cte.UpdatedOn,
       ca.field_name AS [FieldName],
       IIF (cte.prev_UpdatedOn IS NULL,'[N/A]', ca.prev_value) AS [PreviousValue],  -- use N/A for previous values of first record.
       ca.curr_value AS [NewValue]--,
       --cte.UpdatedBy
FROM cte
LEFT OUTER JOIN [Personal].[dbo].[General] gen (nolock) on gen.id=cte.id
LEFT OUTER JOIN [Personal].[dbo].[Addresses] ad ON ad.id=cte.AddressID
LEFT OUTER JOIN [Personal].[dbo].[Addresses] prev_ad ON prev_ad.id=cte.prev_AddressID
CROSS APPLY
(
       VALUES
       ('Name', CONVERT(VARCHAR(4000), cte.Name),CONVERT(VARCHAR(4000), cte.prev_Name)),
       ('DOB', CONVERT(VARCHAR(4000), cte.DOB),CONVERT(VARCHAR(4000), cte.prev_DOB)),
       ('E-Mail', CONVERT(VARCHAR(4000), cte.[E-Mail]),CONVERT(VARCHAR(4000), cte.prev_E_Mail)),
       ('Address', CONVERT(VARCHAR(4000), ad.Address),CONVERT(VARCHAR(4000), prev_ad.Address)),
       ('City', CONVERT(VARCHAR(4000), ad.City),CONVERT(VARCHAR(4000), prev_ad.City)),
       ('State', CONVERT(VARCHAR(4000), ad.State),CONVERT(VARCHAR(4000), prev_ad.State)),
       ('Zip', CONVERT(VARCHAR(4000), ad.Zip),CONVERT(VARCHAR(4000), prev_ad.Zip)),
       ('Home', CONVERT(VARCHAR(4000), cte.[Home Phone]),CONVERT(VARCHAR(4000), cte.prev_Home_Phone)),
       ('Mobile', CONVERT(VARCHAR(4000), cte.Mobile),CONVERT(VARCHAR(4000), cte.prev_Mobile)),
       ('work', CONVERT(VARCHAR(4000), cte.Work),CONVERT(VARCHAR(4000), cte.prev_Work))
) ca(field_name, curr_value, prev_value)

WHERE EXISTS(SELECT ca.curr_value EXCEPT SELECT ca.prev_value)       --Show only field value differences. (based on string representation)
   AND prev_UpdatedOn IS NOT NULL                                                 --Change to OR and IS NULL to Force all values for first record to be shown.
