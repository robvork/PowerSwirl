IF OBJECT_ID('dbo.user_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.user_hdr;
GO

CREATE TABLE dbo.user_hdr
(
	user_sid SID NOT NULL,
	user_id ID NOT NULL
);
GO