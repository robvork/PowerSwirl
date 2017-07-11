IF OBJECT_ID('dbo.user_pause_state', 'U') IS NOT NULL
	DROP TABLE dbo.user_pause_state;
GO

CREATE TABLE dbo.user_pause_state
(
	user_sid SID NOT NULL,
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	step_num STEP NOT NULL
	PRIMARY KEY(user_sid)
);
GO