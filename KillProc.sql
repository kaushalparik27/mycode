/*
 The sproc receives database name as argumemt and kills all processes that is being used along with that database. 
 It can be useful when needed to restore a database while working on it
*/
-- usp_KillProc 'Case1'
CREATE PROC usp_KillProc
	@DBName VARCHAR(100)
AS
BEGIN
	DECLARE @Table TABLE(
			SPID INT,
			Status VARCHAR(MAX),
			LOGIN VARCHAR(MAX),
			HostName VARCHAR(MAX),
			BlkBy VARCHAR(MAX),
			DBName VARCHAR(MAX),
			Command VARCHAR(MAX),
			CPUTime INT,
			DiskIO INT,
			LastBatch VARCHAR(MAX),
			ProgramName VARCHAR(MAX),
			SPID_1 INT,
			REQUESTID INT)
	DECLARE @SpId TABLE(
			ID INT Primary Key IDENTITY(1,1),
			SPID INT)
	DECLARE @RecCnt INT = 0
	DECLARE @RunCnt INT = 1
	DECLARE @ProcToKill INT = 0

	INSERT INTO @Table EXEC sp_who2
	INSERT INTO @SpId SELECT SPID FROM @Table WHERE DBName = @DBName
	SET @RecCnt = SCOPE_IDENTITY()
	WHILE @RunCnt <= @RecCnt
	BEGIN
		SELECT @ProcToKill = SPID FROM @SpId WHERE ID = @RunCnt
		EXEC('KILL ' + @ProcToKill)
		Print 'Killed Process ' + CAST(@ProcToKill AS VARCHAR(100))
		SET @RunCnt = @RunCnt + 1
	END
END
