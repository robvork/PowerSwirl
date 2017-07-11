IF OBJECT_ID('dbo.user_course', 'U') IS NOT NULL
	DROP TABLE dbo.user_course;
GO

CREATE TABLE dbo.user_course
(
	user_sid SID NOT NULL,
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	step_num STEP NOT NULL DEFAULT(1),
	lesson_in_progress_flag FLAG NOT NULL DEFAULT(0),
	lesson_completed_flag FLAG NOT NULL DEFAULT(0)
	PRIMARY KEY(user_sid, course_sid, lesson_sid)
);