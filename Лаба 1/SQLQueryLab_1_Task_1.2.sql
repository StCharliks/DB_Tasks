USE master;
GO

BACKUP DATABASE [NewDatabase]
	TO DISK = 'C:\\Users\\Public\backup.bak'
	WITH FORMAT,
	DESCRIPTION = 'Test Backup',
	NAME = 'OstapBackup';
GO

DROP DATABASE [NewDatabase];
GO

RESTORE DATABASE [NewDatabase]
	FROM DISK = 'C:\\Users\\Public\backup.bak';
GO