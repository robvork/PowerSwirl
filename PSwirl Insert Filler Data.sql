DROP PROCEDURE IF EXISTS dbo.p_get_samples;
GO

CREATE PROCEDURE dbo.p_get_samples
(
	  @as_sample_table SYSNAME
	/*
		Table with following schema:
		(
			obj_type TINYINT NOT NULL -- the type of sample (corresponds to e.g. course, lesson, step)
			obj_sid BIGINT NOT NULL -- the unique identifier of the object being sampled for
			min_val BIGINT NOT NULL -- the minimum value the sample can take
			max_val BIGINT NOT NULL -- the maximum value the sample can take
			sample_val BIGINT NULL -- the randomly sampled value (use seed if you want repeatability)
			PRIMARY KEY(obj_type, obj_sid) -- each combination of obj_type and obj_sid gets a unique sample
		)
	*/
	, @ai_obj_type TINYINT
	, @ai_debug_level INT 
)
AS
BEGIN
	DECLARE @ls_sql NVARCHAR(MAX);
	DECLARE @ls_params NVARCHAR(MAX); 

	SET @ls_sql = 
	CONCAT 
	(
	 N'UPDATE ', @as_sample_table, N' 
	   SET sample_val = min_val + (max_val - min_val) * RAND() + 1
	   WHERE obj_type = ', @ai_obj_type, N'
	   ;
	  ' 
	);

	EXEC(@ls_sql);

	IF @ai_debug_level > 1
	BEGIN
		SET @ls_sql = CONCAT(N'SELECT obj_type, obj_sid, min_val, max_val, sample_val FROM ', @as_sample_table);
		EXEC(@ls_sql);
	END;
END
GO

CREATE PROCEDURE dbo.p_insert_filler_data
(
	@ai_min_courses BIGINT
,	@ai_max_courses BIGINT
,	@ai_min_lessons_per_course BIGINT
,	@ai_max_lessons_per_course BIGINT
,	@ai_min_steps_per_lesson BIGINT
,	@ai_max_steps_per_lesson BIGINT
,	@ai_min_users BIGINT
,	@ai_max_users BIGINT
)
AS
BEGIN
	DROP TABLE IF EXISTS #sample; 

	CREATE TABLE #sample
	(
		obj_type TINYINT NOT NULL
	,	obj_sid BIGINT NOT NULL
	,	min_val BIGINT NOT NULL
	,	max_val BIGINT NOT NULL
	,	sample_val BIGINT NULL
	,	PRIMARY KEY(obj_type, obj_sid)
	);

	DROP TABLE IF EXISTS #obj_type; 

	CREATE TABLE #obj_type
	(
		obj_type TINYINT NOT NULL
	,	obj_descr NVARCHAR(100) NOT NULL
	,	PRIMARY KEY(obj_type)
	)

	CREATE TABLE #course_to_lesson_map
	(
		course_sid 
	);

	INSERT INTO #obj_type
	VALUES
	 (1, N'Course' )
	,(2, N'Lesson' )
	,(3, N'Step'   )



END;	



INSERT INTO dbo.course_hdr(course_sid, course_id)
SELECT nums.n, 'Course ' + CONVERT(VARCHAR(5), nums.n) 
FROM dbo.Nums AS nums
WHERE nums.n <= 4;

INSERT INTO dbo.course_dtl
	   (course_sid, 
	    lesson_sid)
VALUES (1, 1), 
	   (2, 1), 
	   (3, 1),
	   (4, 1),
	   (4, 2);

INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
SELECT course_sid, ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid),
		 'Course ' + CONVERT(VARCHAR(5), course_sid) +
		 ' Lesson ' + CONVERT(VARCHAR(5), ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid))
FROM dbo.course_dtl;

INSERT INTO dbo.lesson_dtl
		(
			course_sid,  lesson_sid, step_num, step_prompt, 
			requires_input_flag, execute_code_flag, store_var_flag, 
			solution, variable
		)
SELECT C.course_sid, 
	   C.lesson_sid, 
	   nums.n,
		'C' + CONVERT(VARCHAR(5), C.course_sid)
		+ ' L' + CONVERT(VARCHAR(5), C.lesson_sid) 
		+ ' S' + CONVERT(VARCHAR(5), nums.n) ,
		0,
		0,
		0,
		NULL,
		NULL
FROM dbo.course_dtl AS C
	CROSS APPLY 
		(
			SELECT n 
			FROM dbo.Nums
			WHERE n <= ABS(CHECKSUM(NEWID())) % 15 + 5
		) AS nums




SELECT * FROM dbo.course_hdr;
SELECT * FROM dbo.course_dtl;
SELECT * FROM dbo.lesson_hdr;
SELECT * FROM dbo.lesson_dtl;

BEGIN TRAN
DELETE FROM dbo.user_hdr;
SELECT * FROM dbo.user_hdr;
SELECT * FROM dbo.user_course
ROLLBACK TRAN

INSERT INTO dbo.user_hdr(user_id) 
VALUES ('Rob'), ('Jim')

DELETE FROM user_pause_state

SELECT * FROM dbo.user_hdr

SELECT * FROM dbo.user_course
SELECT * FROM dbo.lesson_dtl

SET FMTONLY ON;
SELECT * FROM dbo.lesson_dtl
SET FMTONLY OFF;

SELECT * FROM dbo.user_pause_state