USE PowerSwirl

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
	lesson_sid SID NOT NULL,
	step_num STEP NOT NULL DEFAULT(1),
	num_steps STEP NOT NULL,
	lesson_in_progress FLAG NOT NULL,
	lesson_completed FLAG NOT NULL
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
	requires_input FLAG NOT NULL,
	solution VARCHAR(100) NULL,
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

INSERT INTO dbo.Nums
SELECT n FROM TSQL2012.dbo.Nums;  


INSERT INTO dbo.course_hdr(course_sid, course_id)
SELECT nums.n, 'Course ' + CONVERT(VARCHAR(5), nums.n) 
FROM dbo.Nums AS nums
WHERE nums.n <= 4;

INSERT INTO dbo.course_dtl
	   (course_sid, lesson_sid, step_num, num_steps, lesson_in_progress, lesson_completed)
VALUES (1, 1, 1, 2, 0, 0), 
	   (2, 1, 1, 6, 0, 0), 
	   (3, 1, 3, 7, 1, 0),
	   (4, 1, 2, 2, 0, 1),
	   (4, 2, 1, 3, 0, 0);



INSERT INTO dbo.lesson_dtl
		(course_sid, lesson_sid, step_num, step_prompt, requires_input, solution)
SELECT C.course_sid, C.lesson_sid, nums.n,
		 'C' + CONVERT(VARCHAR(5), C.course_sid)
	   + ' L' + CONVERT(VARCHAR(5), C.lesson_sid) 
	   + ' S' + CONVERT(VARCHAR(5), nums.n) ,
	   0, NULL
FROM dbo.course_dtl AS C
	CROSS APPLY 
		(
			SELECT n 
			FROM dbo.Nums
			WHERE n <= C.num_steps
		) AS nums

INSERT INTO dbo.lesson_hdr
SELECT course_sid, ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid),
		 'Lesson ' + CONVERT(VARCHAR(5), ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid))
FROM dbo.course_dtl;


SELECT * FROM dbo.course_hdr;
SELECT * FROM dbo.course_dtl;
SELECT * FROM dbo.lesson_hdr;
SELECT * FROM dbo.lesson_dtl;


--ALTER TABLE dbo.course
--ADD CONSTRAINT fk_course_to_lesson
--FOREIGN KEY   (course_sid, lesson_sid, step_num) 
--	REFERENCES
--	dbo.lesson(course_sid, lesson_sid, step_num)
