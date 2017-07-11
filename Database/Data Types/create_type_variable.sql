IF TYPE_ID('dbo.variable') IS NOT NULL
	DROP TYPE dbo.variable;
GO

CREATE TYPE dbo.variable 
FROM NVARCHAR(100)
NOT NULL;