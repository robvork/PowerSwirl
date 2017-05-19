DROP PROCEDURE IF EXISTS dbo.p_insert_filler_data;
GO

CREATE PROCEDURE dbo.p_insert_filler_data
(
	@ai_min_courses BIGINT = 1
,	@ai_max_courses BIGINT = 1
,	@ai_min_lessons_per_course BIGINT = 1
,	@ai_max_lessons_per_course BIGINT = 1
,	@ai_min_steps_per_lesson BIGINT = 1 
,	@ai_max_steps_per_lesson BIGINT = 1 
,	@ai_min_users BIGINT = 1 
,	@ai_max_users BIGINT = 1 
,	@ai_debug_level INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
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

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample_type';
		SELECT * FROM #sample_type; 
	END;

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
	,	@ai_sample_type_sid = @li_sample_type_sid_course_count
	,   @ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ number of courses sampled';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_course_count; 
	END;	

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

	/******************************************************************************
	For each new course, sample a number of lessons
	******************************************************************************/
	INSERT INTO #sample 
	(
		sample_type_sid 
	,	sample_sid
	,	min_val 
	,	max_val
	)
	SELECT
		@li_sample_type_sid_lesson_count_by_course
	,	n
	,	@ai_min_lessons_per_course
	,	@ai_max_lessons_per_course
	FROM dbo.GetNums(1, (SELECT COUNT(*) FROM #course_hdr))
	;

	EXECUTE dbo.p_get_samples 
		@as_sample_table = @ls_sample_table_name
	,	@ai_sample_type_sid = @li_sample_type_sid_lesson_count_by_course
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ number of lessons sampled';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_lesson_count_by_course; 
	END;	

	/******************************************************************************
	For each lesson count sampled, create the new lessons
	******************************************************************************/

	INSERT INTO #lesson_hdr 
	(
		course_sid 
	,	lesson_sid
	,	lesson_id 
	)
	SELECT 
		course_sid 
	,	n
	,	CONCAT(N'C', course_sid, N'L', n)
	FROM #course_hdr AS CH
	INNER JOIN #sample AS S
		ON CH.course_sid = S.sample_sid
		   AND 
		   S.sample_type_sid = @li_sample_type_sid_lesson_count_by_course
	CROSS APPLY dbo.GetNums(1, S.sample_val)
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#lesson_hdr';
		SELECT * FROM #lesson_hdr;
	END;
	
	INSERT INTO #course_dtl
	(
		course_sid
	,	lesson_sid 
	)
	SELECT 
		course_sid 
	,	lesson_sid 
	FROM #lesson_hdr

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#course_dtl';
		SELECT * FROM #course_dtl;
	END;


	/*
		Sample number of courses C with min_C and max_C
		For each course, sample a number of lessons L with min_L and max_L
		For each lesson, sample a number of steps S with min_S and max_S
	*/
END;	
GO

EXEC dbo.p_insert_filler_data 
	@ai_debug_level = 2
,	@ai_min_courses = 3
,	@ai_min_lessons_per_course = 2
,	@ai_max_lessons_per_course = 5
,	@ai_max_courses = 8; 

