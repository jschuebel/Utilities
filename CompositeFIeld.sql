CREATE TABLE [base].[LookUp](
       [LookUpID] [int] NOT NULL,
       [DOB] [date] NULL,
       [FirstName] [varchar](50) NOT NULL,
       [LastName] [varchar](50) NOT NULL,
       [SearchFld]  AS (CONVERT([nvarchar](4000),upper((case when [FirstName] IS NOT NULL then ltrim(rtrim([FirstName]))+' ' else '' end+case when [LastName] IS NOT NULL then ltrim(rtrim([LastName]))+' ' else '' end)+case when [DOB] IS NOT NULL then CONVERT([nvarchar](10),[DOB],(101))+' ' else '' end),(0))) PERSISTED,
CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED
(
       [LookUpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
