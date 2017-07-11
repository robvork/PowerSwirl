IF OBJECT_ID('dbo.course_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.course_hdr;
GO

CREATE TABLE dbo.course_hdr
(
	course_sid SID,
	course_id ID
);
GO