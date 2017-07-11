IF OBJECT_ID('dbo.lesson_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_hdr;
GO

CREATE TABLE dbo.lesson_hdr
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	lesson_id ID NOT NULL
	PRIMARY KEY(course_sid, lesson_sid)
);
GO
