IF OBJECT_ID('dbo.course_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.course_dtl;
GO

CREATE TABLE dbo.course_dtl
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL
	PRIMARY KEY(course_sid, lesson_sid)
);
GO