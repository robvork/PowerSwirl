-- ================================
-- Create User-defined Data Type
-- ================================
USE PowerSwirl  
GO

IF OBJECT_ID('dbo.course_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.course_hdr; 

IF OBJECT_ID('dbo.course_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.course_dtl; 

IF OBJECT_ID('dbo.lesson_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_hdr; 

IF OBJECT_ID('dbo.lesson_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_dtl;

IF TYPE_ID('dbo.step') IS NOT NULL
	DROP TYPE dbo.step;
GO

CREATE TYPE dbo.STEP
FROM INT
NOT NULL;

IF TYPE_ID('dbo.SID') IS NOT NULL
	DROP TYPE dbo.SID;
GO

CREATE TYPE dbo.SID
FROM INT
NOT NULL;

IF TYPE_ID('dbo.FLAG') IS NOT NULL
	DROP TYPE dbo.FLAG;
GO

CREATE TYPE dbo.FLAG
FROM BIT
NOT NULL;


IF TYPE_ID('dbo.PROMPT') IS NOT NULL
	DROP TYPE dbo.PROMPT;
GO

CREATE TYPE dbo.PROMPT
FROM NVARCHAR(1000)
NOT NULL;

IF TYPE_ID('dbo.MC_SOLN') IS NOT NULL
	DROP TYPE dbo.MC_SOLN;
GO

CREATE TYPE dbo.MC_SOLN
FROM NCHAR(1)
NOT NULL;

IF TYPE_ID('dbo.ID') IS NOT NULL
	DROP TYPE dbo.ID;
GO

CREATE TYPE dbo.ID
FROM NVARCHAR(200)
NOT NULL;

IF TYPE_ID('dbo.variable') IS NOT NULL
	DROP TYPE dbo.variable;
GO

CREATE TYPE dbo.variable 
FROM NVARCHAR(100)
NOT NULL;
