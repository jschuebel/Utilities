SELECT addr.[AddressID], subset.*
  FROM [dbo].[Address] addr
  CROSS APPLY (
                                SELECT [AddressID]
                                                  ,[AddressTypeID]
                                                                ,ROW_NUMBER() OVER (PARTITION BY [AddressTypeID] ORDER BY [AddressID] desc) AS Rank
                                  FROM [dbo].[Address] addrs
                                  WHERE addrs.[FKID]=addr.[FKID]
  ) subset
  where subset.Rank< 4