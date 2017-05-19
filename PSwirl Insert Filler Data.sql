DROP PROCEDURE IF EXISTS dbo.p_get_samples;
GO

CREATE PROCEDURE dbo.p_get_samples
(
	  @as_sample_table SYSNAME
	/*
		Table with following schema:
		(
			sample_type TINYINT NOT NULL -- the type of sample (corresponds to e.g. course, lesson, step)
			sample_sid BIGINT NOT NULL -- the unique identifier of the sampleect being sampled for
			min_val BIGINT NOT NULL -- the minimum value the sample can take
			max_val BIGINT NOT NULL -- the maximum value the sample can take
			sample_val BIGINT NULL -- the randomly sampled value (use seed if you want repeatability)
			PRIMARY KEY(sample_type, sample_sid) -- each combination of sample_type and sample_sid gets a unique sample
		)
	*/
	, @ai_sample_type TINYINT
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
	   WHERE sample_type = ', @ai_sample_type, N'
	   ;
	  ' 
	);

	EXEC(@ls_sql);

	IF @ai_debug_level > 1
	BEGIN
		SET @ls_sql = CONCAT(N'SELECT sample_type, sample_sid, min_val, max_val, sample_val FROM ', @as_sample_table);
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
,	@ai_debug_level INT
)
AS
BEGIN
	/******************************************************************************
	Declare local variables
	******************************************************************************/
	DECLARE @li_sample_type_sid_course_count TINYINT;
	DECLARE @li_sample_type_sid_lesson_count_by_course TINYINT;
	DECLARE @li_sample_type_sid_step_count_by_lesson TINYINT;
	DECLARE @li_sample_type_sid_user_count TINYINT;

	DECLARE @ls_sample_table_name SYSNAME;
	DECLARE @ls_curr_step NVARCHAR(100);

	/******************************************************************************
	Create temp tables
	******************************************************************************/
	BEGIN
	--SET @ls_curr_step = N'Creating temp tables';

	DROP TABLE IF EXISTS #sample; 

	CREATE TABLE #sample
	(
		sample_type_sid TINYINT NOT NULL
	,	sample_sid BIGINT NOT NULL
	,	min_val BIGINT NOT NULL
	,	max_val BIGINT NOT NULL
	,	sample_val BIGINT NULL
	,	PRIMARY KEY(sample_type_sid, sample_sid)
	);

	SET @ls_sample_table_name = N'#sample';

	DROP TABLE IF EXISTS #obj_type; 

	CREATE TABLE #sample_type
	(
		sample_type TINYINT NOT NULL
	,	sample_descr NVARCHAR(100) NOT NULL
	,	PRIMARY KEY(sample_type)
	)

	/*
		Create temp tables with identical schemas to those found in the database
	*/
	BEGIN
	SELECT TOP 0 * 
	INTO #course_hdr 
	FROM dbo.course_hdr;

	SELECT TOP 0 * 
	INTO #course_dtl 
	FROM dbo.course_dtl;

	SELECT TOP 0 * 
	INTO #lesson_hdr
	FROM dbo.lesson_hdr;

	SELECT TOP 0 * 
	INTO #lesson_dtl 
	FROM dbo.lesson_dtl;

	SELECT TOP 0 * 
	INTO #user_course
	FROM dbo.user_course;

	SELECT TOP 0 * 
	INTO #user_hdr
	FROM dbo.user_hdr;

	SELECT TOP 0 * 
	INTO #user_pause_state
	FROM dbo.user_pause_state;
	END
	END

	/******************************************************************************
	Insert object types 
	******************************************************************************/
	-- The sample for an object with object type o is used in the creation of objects of that type

	SET @li_sample_type_sid_course_count = 1;
	SET @li_sample_type_sid_lesson_count_by_course = 2;
	SET @li_sample_type_sid_step_count_by_lesson = 3;
	SET @li_sample_type_sid_user_count = 4;

	INSERT INTO #sample_type
	VALUES
	  (@li_sample_type_sid_course_count, N'Course Count')
	, (@li_sample_type_sid_lesson_count_by_course, N'Lesson Count By Course')
	, (@li_sample_type_sid_step_count_by_lesson, N'Step Count By Lesson')
	, (@li_sample_type_sid_user_count, N'User Count')
	;

	/******************************************************************************
	Sample number of courses
	******************************************************************************/
	INSERT INTO #sample
	(
		sample_type_sid
	,	sample_sid
	,	min_val
	,	max_val
	)
	VALUES			   
	(
		@li_sample_type_sid_course_count
	,	1
	,	@ai_min_courses
	,	@ai_max_courses
	)
	;

	EXECUTE dbo.p_get_samples 
		@as_sample_table = @ls_sample_table_name
	,	@ai_sample_type = @li_sample_type_sid_course_count
	,   @ai_debug_level = @ai_debug_level
	;

	/******************************************************************************
	Create sampled number of courses
	******************************************************************************/
	INSERT INTO #course_hdr(course_sid, course_id)
	SELECT n, CONCAT(N'C', n)
	FROM dbo.GetNums
	(
	   1
	,  (
		SELECT sample_val 
		FROM #sample 
		WHERE sample_type_sid = @li_sample_type_sid_course_count
	   )
	)

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#course_hdr';
		SELECT * FROM #course_hdr;
	END;


	/*
		Sample number of courses C with min_C and max_C
		For each course, sample a number of lessons L with min_L and max_L
		For each lesson, sample a number of steps S with min_S and max_S
	*/
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