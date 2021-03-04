;WITH cte AS
(
   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY Createdate DESC) AS rankv
   FROM Events
)
SELECT c.*
FROM [personal].[dbo].[General] g
left outer join cte c on c.UserID=g.id
WHERE rankv = 1
