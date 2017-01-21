USE PowerSwirl

IF OBJECT_ID('dbo.course_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.course_hdr;
GO

CREATE TABLE dbo.course_hdr
(
	course_sid SID,
	course_id ID
)

IF OBJECT_ID('dbo.course_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.course_dtl;
GO

CREATE TABLE dbo.course_dtl
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL
	PRIMARY KEY(course_sid, lesson_sid)
);

IF OBJECT_ID('dbo.lesson_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_hdr;

CREATE TABLE dbo.lesson_hdr
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	lesson_id ID NOT NULL
	PRIMARY KEY(course_sid, lesson_sid)
)

IF OBJECT_ID('dbo.lesson_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_dtl;
GO

CREATE TABLE dbo.lesson_dtl
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	step_num STEP NOT NULL,
	step_prompt PROMPT NOT NULL,
	requires_input_flag FLAG NOT NULL,
	execute_code_flag FLAG NOT NULL,
	store_var_flag FLAG NOT NULL,
	variable VARIABLE NULL,
	solution NVARCHAR(500) NULL,
	PRIMARY KEY(course_sid, lesson_sid, step_num)
);

IF OBJECT_ID('dbo.Nums', 'U') IS NOT NULL
	DROP TABLE dbo.Nums; 
GO

CREATE TABLE [dbo].[Nums](
	[n] [int] NOT NULL,
 CONSTRAINT [PK_Nums] PRIMARY KEY CLUSTERED 
(
	[n] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

IF OBJECT_ID('dbo.user_hdr', 'U') IS NOT NULL
	DROP TABLE dbo.user_hdr;
GO

CREATE TABLE dbo.user_hdr
(
	user_sid SID NOT NULL IDENTITY(1, 1),
	user_id ID NOT NULL
);

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

IF OBJECT_ID('dbo.next_sid', 'U') IS NOT NULL
	DROP TABLE dbo.next_sid;
GO

--CREATE TABLE dbo.next_sid

--INSERT INTO dbo.Nums
--SELECT n FROM TSQL2012.dbo.Nums;  


--INSERT INTO dbo.course_hdr(course_sid, course_id)
--SELECT nums.n, 'Course ' + CONVERT(VARCHAR(5), nums.n) 
--FROM dbo.Nums AS nums
--WHERE nums.n <= 4;

--INSERT INTO dbo.course_dtl
--	   (course_sid, 
--	    lesson_sid)
--VALUES (1, 1), 
--	   (2, 1), 
--	   (3, 1),
--	   (4, 1),
--	   (4, 2);



--INSERT INTO dbo.lesson_dtl
--		(
--			course_sid,  lesson_sid, step_num, step_prompt, 
--			requires_input_flag, execute_code_flag, store_var_flag, 
--			solution, variable
--		)
--SELECT C.course_sid, 
--	   C.lesson_sid, 
--	   nums.n,
--		'C' + CONVERT(VARCHAR(5), C.course_sid)
--		+ ' L' + CONVERT(VARCHAR(5), C.lesson_sid) 
--		+ ' S' + CONVERT(VARCHAR(5), nums.n) ,
--		0,
--		0,
--		0,
--		NULL,
--		NULL
--FROM dbo.course_dtl AS C
--	CROSS APPLY 
--		(
--			SELECT n 
--			FROM dbo.Nums
--			WHERE n <= ABS(CHECKSUM(NEWID())) % 15 + 5
--		) AS nums

--INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
--SELECT course_sid, ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid),
--		 'Course ' + CONVERT(VARCHAR(5), course_sid) +
--		 ' Lesson ' + CONVERT(VARCHAR(5), ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid))
--FROM dbo.course_dtl;


--SELECT * FROM dbo.course_hdr;
--SELECT * FROM dbo.course_dtl;
--SELECT * FROM dbo.lesson_hdr;
--SELECT * FROM dbo.lesson_dtl;


----ALTER TABLE dbo.course
----ADD CONSTRAINT fk_course_to_lesson
----FOREIGN KEY   (course_sid, lesson_sid, step_num) 
----	REFERENCES
----	dbo.lesson(course_sid, lesson_sid, step_num)

----SELECT * FROM dbo.lesson_dtl
----WHERE course_sid = 4 AND lesson_sid = 2;

----SELECT ABS(CHECKSUM(NEWID())) % 15 + 5

--BEGIN TRAN
--DELETE FROM dbo.user_hdr;
--SELECT * FROM dbo.user_hdr;
--SELECT * FROM dbo.user_course
--ROLLBACK TRAN

--INSERT INTO dbo.user_hdr(user_id) 
--VALUES ('Rob'), ('Jim')

--DELETE FROM user_pause_state

--SELECT * FROM dbo.user_hdr

--SELECT * FROM dbo.user_course
--SELECT * FROM dbo.lesson_dtl

--SET FMTONLY ON;
--SELECT * FROM dbo.lesson_dtl
--SET FMTONLY OFF;

--SELECT * FROM dbo.user_pause_state