IF TYPE_ID('dbo.FLAG') IS NOT NULL
	DROP TYPE dbo.FLAG;
GO

CREATE TYPE dbo.FLAG
FROM BIT
NOT NULL;