ALTER PROCEDURE [dbo].[usp_Dev_CreateDataContract]
@TableName VARCHAR(50)
AS
BEGIN
	DECLARE @SchemaDetail TABLE (
		Id INT IDENTITY(1,1),
		ColName NVARCHAR(255),
		IsNullable BIT,
		IsIdentity BIT,
		ColType NVARCHAR(255))
	DECLARE @RowCnt INT
	DECLARE @Index INT
	DECLARE @DataContract VARCHAR(MAX)
	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
	
	SET @DataContract = ''
	SET @DataContract +='/// <summary>' + @NewLineChar
	SET @DataContract +='/// This table holds the records of ' + @TableName + ' details.' + @NewLineChar
	SET @DataContract +='/// </summary>' + @NewLineChar
	SET @DataContract +='[DataContract]' + @NewLineChar
	SET @DataContract +='public class ' + @TableName + 'DataContract' + @NewLineChar
	SET @DataContract +='{' + @NewLineChar
	SET @RowCnt = 0
	SET @Index = 0
	
	DECLARE @ColName NVARCHAR(255)
	DECLARE @IsNullable BIT
	DECLARE @IsIdentity BIT
	DECLARE @ColType NVARCHAR(255)
	DECLARE @Property NVARCHAR(255)
	
	INSERT INTO @SchemaDetail (	 ColName
								,IsNullable
								,IsIdentity
								,ColType)
	SELECT	 name
			,is_nullable
			,is_identity
			,TYPE_NAME(system_type_id) FROM sys.columns WHERE OBJECT_NAME(object_id) = @TableName
	
	Set @RowCnt = @@ROWCOUNT  
	Set @Index = 1
	WHILE @Index <= @RowCnt
	BEGIN
		SELECT 
				@ColName = ColName,
				@IsNullable = IsNullable,
				@IsIdentity = IsIdentity,
				@ColType = ColType 
		FROM @SchemaDetail WHERE Id = @Index
		SET @Property = ''
		
		SET @DataContract +='/// <summary>' + @NewLineChar
		IF ISNULL(@IsIdentity,0) = 1
			SET @DataContract +='///This field is primary key column of the table and will have auto-increment values via indentity insert.' + @NewLineChar
		ELSE
			SET @DataContract +='/// the field holds ' + @ColName + ' value' + @NewLineChar
		SET @DataContract +='/// </summary>' + @NewLineChar
		
		IF ISNULL(@IsNullable,0) = 0
			SET @DataContract +='[DataMember(IsRequired = true)]' + @NewLineChar
		ELSE
			SET @DataContract +='[DataMember(IsRequired = false)]' + @NewLineChar
		
		SET @Property = 'public '
		--print @ColType
		IF ISNULL(@IsNullable,0) = 0
			SET @Property += CASE @ColType WHEN 'bigint' THEN 'Int64' WHEN 'nvarchar' THEN 'string' WHEN 'datetime' THEN 'DateTime' WHEN 'bit' THEN 'bool' WHEN 'date' THEN 'DateTime' WHEN 'decimal' THEN 'Decimal' WHEN 'int' THEN 'Int32' WHEN 'tinyint' THEN 'Int32' WHEN 'smallint' THEN 'Int16' WHEN 'xml' THEN 'string' WHEN 'nchar' THEN 'string' WHEN 'varchar' THEN 'string'  WHEN 'time' THEN 'DateTime' END 
		ELSE
			SET @Property += CASE @ColType WHEN 'bigint' THEN 'Int64?' WHEN 'nvarchar' THEN 'string' WHEN 'datetime' THEN 'DateTime?' WHEN 'bit' THEN 'bool?' WHEN 'date' THEN 'DateTime?' WHEN 'decimal' THEN 'Decimal?' WHEN 'int' THEN 'Int32?' WHEN 'tinyint' THEN 'Int32?' WHEN 'smallint' THEN 'Int16?' WHEN 'xml' THEN 'string' WHEN 'nchar' THEN 'string' WHEN 'varchar' THEN 'string' WHEN 'time' THEN 'DateTime?' END 
		SET @Property += ' ' + @ColName
		SET @Property += '{ get; set; }'  + @NewLineChar + @NewLineChar
		SET @DataContract += @Property
		SET @Index = @Index + 1
		print @DataContract
		SET @DataContract = ''
	END
	SET @DataContract +='}' + @NewLineChar
	PRINT @DataContract
END
