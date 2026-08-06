DECLARE @FormSection TABLE (
	SectionVersionId INT
	,[FormID] INT
	,[FormVersionId] INT
	,[DisplayOrder] INT
	,[Label] varchar(255)
	,[DisplayText] [varchar](max) NOT NULL
	,[SectionName] [varchar](64)
	,[SectionItemName] [varchar](64)
	,[FieldName] [varchar](max)
	,[Value] [nvarchar](max)
	,[QuestionOrder] INT
	,[Specification] [varchar](max)
	,[RowPos] [int]
	,[ColPos] [int]
)

Insert into @FormSection
EXEC [dbo].[spGetForm] 3691, 1,11

select * from @FormSection
SELECT * FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID('spGetForm'), 0) ;  
