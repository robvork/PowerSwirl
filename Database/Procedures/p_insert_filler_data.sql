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
,	@af_probability_lesson_in_progress FLOAT = 0.5
,	@af_probability_lesson_completed FLOAT = 0.2
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
	DECLARE @li_sample_type_sid_lesson_in_progress_draw TINYINT;
	DECLARE @li_sample_type_sid_lesson_completed_draw TINYINT;
	DECLARE @li_sample_type_sid_step_num TINYINT;
	DECLARE @li_precedence_idx INT;
	DECLARE @li_num_tables_to_process INT;
	
	DECLARE @li_probability_lesson_completed_rounded TINYINT;
	DECLARE @li_probability_lesson_in_progress_rounded TINYINT;

	DECLARE @ls_sample_table_name SYSNAME;
	DECLARE @ls_curr_step NVARCHAR(100);
	DECLARE @ls_current_table_name SYSNAME;
	DECLARE @ls_sql NVARCHAR(MAX);

	/******************************************************************************
	Initialize local variables
	******************************************************************************/
	SET @li_probability_lesson_in_progress_rounded = CAST((@af_probability_lesson_in_progress * 100) AS INT);
	SET @li_probability_lesson_completed_rounded = CAST((@af_probability_lesson_completed * 100) AS INT);

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

		DROP TABLE IF EXISTS #course_to_sample;

		CREATE TABLE #course_to_sample
		(
			course_sid BIGINT
		,	sample_sid BIGINT
		,	PRIMARY KEY(course_sid)
		);

		DROP TABLE IF EXISTS #course_lesson_to_sample; 

		CREATE TABLE #course_lesson_to_sample
		(
			course_sid BIGINT 
		,	lesson_sid BIGINT
		,	sample_sid BIGINT
		,	PRIMARY KEY(course_sid, lesson_sid)
		);

		DROP TABLE IF EXISTS #course_lesson_user_to_sample; 

		CREATE TABLE #course_lesson_user_to_sample
		(
			course_sid BIGINT 
		,	lesson_sid BIGINT
		,	user_sid BIGINT
		,	sample_sid BIGINT
		,	PRIMARY KEY(course_sid, lesson_sid, user_sid)
		);

		DROP TABLE IF EXISTS #obj_type; 

		CREATE TABLE #sample_type
		(
			sample_type TINYINT NOT NULL
		,	sample_descr NVARCHAR(100) NOT NULL
		,	PRIMARY KEY(sample_type)
		);

		DROP TABLE IF EXISTS #target_table; 

		CREATE TABLE #table
		(
			precedence_rank INT PRIMARY KEY
		,	table_name SYSNAME 
		);

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
	Insert table names
	******************************************************************************/
	INSERT INTO #table 
	VALUES 
	  (1, N'course_hdr')
	, (2, N'lesson_hdr')
	, (3, N'user_hdr')
	, (4, N'lesson_dtl')
	, (5, N'course_dtl')
	, (6, N'user_course')
	;

	/******************************************************************************
	Insert object types 
	******************************************************************************/
	-- The sample for an object with object type o is used in the creation of objects of that type

	SET @li_sample_type_sid_course_count = 1;
	SET @li_sample_type_sid_lesson_count_by_course = 2;
	SET @li_sample_type_sid_step_count_by_lesson = 3;
	SET @li_sample_type_sid_user_count = 4;
	SET @li_sample_type_sid_lesson_in_progress_draw = 5; 
	SET @li_sample_type_sid_step_num = 6;
	SET @li_sample_type_sid_lesson_completed_draw = 7; 

	INSERT INTO #sample_type
	VALUES
	  (@li_sample_type_sid_course_count, N'Course Count')
	, (@li_sample_type_sid_lesson_count_by_course, N'Lesson Count By Course')
	, (@li_sample_type_sid_step_count_by_lesson, N'Step Count By Lesson')
	, (@li_sample_type_sid_user_count, N'User Count')
	, (@li_sample_type_sid_lesson_in_progress_draw, N'Lesson in Progress Draw')
	, (@li_sample_type_sid_step_num, N'Lesson Step Number')
	, (@li_sample_type_sid_lesson_completed_draw, N'Lesson Completed Draw')
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
	SELECT	n
	,		CONCAT(N'C', n)
	FROM dbo.fn_get_nums
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
	INSERT INTO 
		#course_to_sample
	(
		course_sid 
	,	sample_sid
	)
	SELECT
		course_sid
	,	ROW_NUMBER() OVER 
			(ORDER BY course_sid)
	FROM
		#course_hdr 
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#course_to_sample';
		SELECT 
			course_sid
		,	sample_sid 
		FROM 
			#course_to_sample
		;
	END;
	
	INSERT INTO 
		#sample 
	(
		sample_type_sid 
	,	sample_sid
	,	min_val 
	,	max_val
	)
	SELECT
		@li_sample_type_sid_lesson_count_by_course
	,	sample_sid 
	,	@ai_min_lessons_per_course
	,	@ai_max_lessons_per_course
	FROM 
		#course_to_sample
	;

	EXECUTE 
		dbo.p_get_samples 
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
	,	CONCAT(N'C', C2S.course_sid, N' L', n)
	FROM 
		#sample AS S
	INNER JOIN 
		#course_to_sample AS C2S
		ON S.sample_sid = C2S.sample_sid
		   AND 
		   S.sample_type_sid = @li_sample_type_sid_lesson_count_by_course
	CROSS APPLY 
		dbo.fn_get_nums(1, S.sample_val)
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
	
	/******************************************************************************
	For each new lesson, sample a number of steps
	******************************************************************************/
	INSERT INTO 
		#course_lesson_to_sample 
	(
		course_sid 
	,	lesson_sid 
	,	sample_sid 
	)
	SELECT 
		course_sid 
	,	lesson_sid 
	,	ROW_NUMBER() OVER (ORDER BY course_sid, lesson_sid)
	FROM #lesson_hdr
	;
	
	IF @ai_debug_level > 1
	BEGIN
		SELECT '#course_lesson_to_sample';
		SELECT 
			course_sid
		,	lesson_sid
		,	sample_sid 
		FROM 
			#course_lesson_to_sample
		;
	END;

	INSERT INTO 
		#sample 
	(
		sample_type_sid
	,	sample_sid
	,	min_val
	,	max_val 
	)
	SELECT
		@li_sample_type_sid_step_count_by_lesson
	,	sample_sid 
	,	@ai_min_steps_per_lesson
	,	@ai_max_steps_per_lesson
	FROM #course_lesson_to_sample
	;

	EXECUTE dbo.p_get_samples
		@as_sample_table = @ls_sample_table_name 
	,	@ai_sample_type_sid = @li_sample_type_sid_step_count_by_lesson
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ number of steps sampled';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_step_count_by_lesson; 
	END;	


	/******************************************************************************
	For each step count sampled, create the steps
	******************************************************************************/
	/*
		Since #sample does not contain any reference to course_sid and lesson_sid,
		and since we created one step count sample for each combination of course_sid
		and lesson_sid, we need a way to make the correspondence
		(course_sid, lesson_sid) -> <step_count>.

		We do this as follows:
		(course_sid, lesson_sid) -> sample_sid -> <step_count>, 
		where <step_count> is the value of column sample_val in #sample. 

		We do this by imposing an arbitrary row numbering on the collection 
		of (course_sid, lesson_sid) pairs sorting by course_sid, then lesson_sid,
		in ascending order for each column. It's intuitively true that the order
		doesn't matter here because each of the step counts is independent of all
		the others and the distribution is the same. 
	*/
	INSERT INTO #lesson_dtl
	(
		course_sid
	,	lesson_sid 
	,	step_num 
	,	step_prompt
	,	requires_solution
	,	requires_solution_execution
	,	requires_code_execution
	,	requires_set_variable
	,	requires_pause
	)
	SELECT 
		LH.course_sid 
	,	LH.lesson_sid 
	,	n
	,	CONCAT
		(
			N'C'
			, LH.course_sid
			, N' L'
			, LH.lesson_sid
			, N' S'
			, n
		) 
	,	0
	,	0
	,	0
	,	0
	,	0
	FROM #lesson_hdr AS LH
		INNER JOIN #course_lesson_to_sample AS CL2S
			ON LH.course_sid = CL2S.course_sid
			   AND
			   LH.lesson_sid = CL2S.lesson_sid
		INNER JOIN #sample AS S
			ON CL2S.sample_sid = S.sample_sid
			   AND 
			   S.sample_type_sid = @li_sample_type_sid_step_count_by_lesson
		CROSS APPLY dbo.fn_get_nums(1, S.sample_val)
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#lesson_dtl : values set';
		SELECT course_sid
		,	   lesson_sid
		,	   step_num
		,	   step_prompt 
		FROM #lesson_dtl;

		SELECT '#lesson_dtl : all values';
		SELECT * FROM #lesson_dtl;
	END;

	/******************************************************************************
	Sample a number of users
	******************************************************************************/
	INSERT INTO #sample 
	(
		 sample_type_sid
	,	 sample_sid
	,	 min_val 
	,	 max_val 
	)
	SELECT 
		 @li_sample_type_sid_user_count
	,	 1
	,	 @ai_min_users
	,	 @ai_max_users
	;

	EXECUTE dbo.p_get_samples
		@as_sample_table = @ls_sample_table_name 
	,	@ai_sample_type_sid = @li_sample_type_sid_user_count
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ number of users sampled';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_user_count; 
	END;	

	/******************************************************************************
	Create sampled number of users
	******************************************************************************/
	INSERT INTO #user_hdr
	(
		user_sid
	,	user_id
	)
	SELECT 
		n
	,	CONCAT(N'user', n)
	FROM dbo.fn_get_nums
	(
		1
	,	(
			SELECT sample_val 
			FROM #sample 
			WHERE sample_type_sid = @li_sample_type_sid_user_count
		)
	);

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#user_hdr'; 
		SELECT user_sid, user_id FROM #user_hdr
	END;

	/******************************************************************************
	For each combination of course, lesson, and user, 
	create a row in user_course with default values for flags
	******************************************************************************/
	INSERT INTO 
		#user_course
	(
		user_sid 
	,	course_sid
	,	lesson_sid 
	,	step_num 
	,	lesson_in_progress_flag
	,	lesson_completed_flag
	)
	SELECT 
		user_sid 
	,	course_sid 
	,	lesson_sid
	,	1
	,	0
	,	0
	FROM 
		#user_hdr
	CROSS JOIN 
		#lesson_hdr 
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#user_course';
		SELECT 
			user_sid
		,	course_sid 
		,	lesson_sid 
		,	step_num
		,	lesson_in_progress_flag 
		,	lesson_completed_flag 
		FROM 
			#user_course
		;
	END;

	/******************************************************************************
	For each user, course, and lesson, make a draw to determine whether
	that user is in progress for that course and lesson
	******************************************************************************/
	INSERT INTO 
		#course_lesson_user_to_sample
	(
		course_sid 
	,	lesson_sid 
	,	user_sid 
	,	sample_sid
	)
	SELECT 
		course_sid
	,	lesson_sid 
	,	user_sid 
	,	ROW_NUMBER() OVER 
			(
				ORDER BY 
					course_sid
				  , lesson_sid
				  , user_sid
			)
	FROM 
		#lesson_hdr
	CROSS JOIN 
		#user_hdr
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#course_lesson_user_to_sample';
		
		SELECT 
			course_sid 
		,	lesson_sid 
		,	user_sid 
		,	sample_sid 
		FROM 
			#course_lesson_user_to_sample
		;
	END;
	
	
	INSERT INTO #sample
	(
		sample_type_sid
	,	sample_sid 
	,	min_val
	,	max_val 
	)
	SELECT 
		@li_sample_type_sid_lesson_in_progress_draw
	,	sample_sid
	,	1
	,	100
	FROM #course_lesson_user_to_sample

	EXECUTE dbo.p_get_samples 
		@as_sample_table = @ls_sample_table_name 
	,	@ai_sample_type_sid = @li_sample_type_sid_lesson_in_progress_draw
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ lesson in progress draw made';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_lesson_in_progress_draw; 
	END;
	
	UPDATE #sample 
	SET sample_val = 
		CASE 
			WHEN sample_val <= @li_probability_lesson_in_progress_rounded
				THEN 1
			ELSE	
				0
		END
	,	min_val = 0
	,	max_val = 1
	WHERE sample_type_sid = @li_sample_type_sid_lesson_in_progress_draw	
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ draw converted to binary decision';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_lesson_in_progress_draw; 
	END;

	/******************************************************************************
	Update the lesson_in_progress flag accordingly
	******************************************************************************/
	UPDATE U 
	SET 
		U.lesson_in_progress_flag = S.sample_val
	FROM #user_course AS U
	INNER JOIN 
		#course_lesson_user_to_sample AS CLU2S
			ON 
			   U.user_sid = CLU2S.user_sid
				AND 
			   U.course_sid = CLU2S.course_sid 
			    AND
			   U.lesson_sid = CLU2S.lesson_sid
	INNER JOIN
		#sample AS S
			ON 
			   CLU2S.sample_sid = S.sample_sid
			    AND 
			   S.sample_type_sid = @li_sample_type_sid_lesson_in_progress_draw
	;

	IF @ai_debug_level > 0
	BEGIN
		SELECT '#user_course with lesson_in_progress updated';

		SELECT 
			course_sid 
		,	lesson_sid 
		,	user_sid 
		,	lesson_in_progress_flag
		FROM 
			#user_course
		;
	END;


	/******************************************************************************
	For each user, course, and lesson, if the previous draw determined that
	the user is in progress for that course and lesson, sample the step_num
	the user is on. Note that unlike the other sampled values in this procedure,
	the bounds are set on a per course/user basis. That is, different courses
	and lessons have different numbers of steps so we can't set a max value 
	uniformly (without compromising uniform sampling) 
	******************************************************************************/
	WITH course_lesson_bounds AS
	(
		SELECT course_sid 
		,	   lesson_sid
		,	   MIN(step_num) AS min_val
		,	   MAX(step_num) AS max_val 
		FROM #lesson_dtl 
		GROUP BY course_sid, lesson_sid 
	)
	INSERT INTO #sample 
	(
		sample_type_sid 
	,	sample_sid
	,	min_val 
	,	max_val 
	)
	SELECT 
		@li_sample_type_sid_step_num
	,	CLU2S.sample_sid 
	,	CLB.min_val
	,	CASE 
			-- If the course/lesson is not in progress, use an upper bound
			-- equal to the lower bound to force the lower bound as the sample
			WHEN UC.lesson_in_progress_flag = 0 
				THEN CLB.min_val
			ELSE 
				CLB.max_val
		END
	FROM 
		-- Use the same sample sids but for a different sample_type_sid
		#course_lesson_user_to_sample AS CLU2S
	INNER JOIN 
		-- Access #user_course to see if lesson is in progress
		#user_course AS UC
			ON 
				CLU2S.course_sid = UC.course_sid 
					AND
				CLU2S.lesson_sid = UC.lesson_sid
					AND
				CLU2S.user_sid = UC.user_sid
	INNER JOIN 
		-- Get step bounds by matching course and lesson (independent of user)
		course_lesson_bounds AS CLB
			ON 
				UC.course_sid = CLB.course_sid
					AND
				UC.lesson_sid = CLB.lesson_sid
	;

	EXECUTE dbo.p_get_samples
		@as_sample_table = @ls_sample_table_name 
	,	@ai_sample_type_sid = @li_sample_type_sid_step_num
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ step_num sampled for course/lesson/user combinations in
				#user_course that have lesson_in_progress = 1'
		;

		SELECT * 
		FROM #sample 
		WHERE sample_type_sid = @li_sample_type_sid_step_num
		;

	END;
	/******************************************************************************
	For each user, course, and lesson, make a draw to determine whether
	that user has previously completed that course and lesson
	******************************************************************************/
	INSERT INTO #sample
	(
		sample_type_sid
	,	sample_sid 
	,	min_val
	,	max_val 
	)
	SELECT 
		@li_sample_type_sid_lesson_completed_draw
	,	sample_sid
	,	1
	,	100
	FROM #course_lesson_user_to_sample

	EXECUTE dbo.p_get_samples 
		@as_sample_table = @ls_sample_table_name 
	,	@ai_sample_type_sid = @li_sample_type_sid_lesson_completed_draw
	,	@ai_debug_level = 0
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ lesson completed draw made';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_lesson_completed_draw; 
	END;
	
	UPDATE #sample 
	SET sample_val = 
		CASE 
			WHEN sample_val <= @li_probability_lesson_completed_rounded
				THEN 1
			ELSE	
				0
		END
	,	min_val = 0
	,	max_val = 1
	WHERE sample_type_sid = @li_sample_type_sid_lesson_completed_draw
	;

	IF @ai_debug_level > 1
	BEGIN
		SELECT '#sample w/ draw converted to binary decision';
		SELECT * FROM #sample WHERE sample_type_sid = @li_sample_type_sid_lesson_completed_draw; 
	END;

	/******************************************************************************
	Update the lesson_completed flag accordingly
	******************************************************************************/
	UPDATE U 
	SET 
		U.lesson_completed_flag = S.sample_val
	FROM #user_course AS U
	INNER JOIN 
		#course_lesson_user_to_sample AS CLU2S
			ON 
			   U.user_sid = CLU2S.user_sid
				AND 
			   U.course_sid = CLU2S.course_sid 
			    AND
			   U.lesson_sid = CLU2S.lesson_sid
	INNER JOIN
		#sample AS S
			ON 
			   CLU2S.sample_sid = S.sample_sid
			    AND 
			   S.sample_type_sid = @li_sample_type_sid_lesson_completed_draw 
	;

	IF @ai_debug_level > 0
	BEGIN
		SELECT '#user_course with lesson_completed updated';

		SELECT 
			course_sid 
		,	lesson_sid 
		,	user_sid 
		,	lesson_completed_flag
		FROM 
			#user_course
		;
	END;

	/******************************************************************************
	Insert all data
	******************************************************************************/
	SET @li_precedence_idx = 1;
	SET @li_num_tables_to_process = (SELECT COUNT(*) FROM #table);

	WHILE @li_precedence_idx <= @li_num_tables_to_process
	BEGIN
		SET @ls_current_table_name = 
		(
			SELECT table_name 
			FROM #table 
			WHERE precedence_rank = @li_precedence_idx
		);

		SET @ls_sql = 
		CONCAT 
		(
		   N'TRUNCATE TABLE ', @ls_current_table_name, N';
		   INSERT INTO dbo.', @ls_current_table_name, N'
		   SELECT * FROM #', @ls_current_table_name, N'
		   ;'
		);

		IF @ai_debug_level > 0
			PRINT CONCAT('DSQL: ', @ls_sql);

		EXEC(@ls_sql);

		IF @ai_debug_level > 1
		BEGIN
			SET @ls_sql = 
			CONCAT 
			(
				N'SELECT ''', @ls_current_table_name, N''';
				SELECT * FROM ', @ls_current_table_name, N';'
			);
		END;

		IF @ai_debug_level > 0
			PRINT CONCAT('DSQL: ', @ls_sql);

		EXEC(@ls_sql);


		SET @li_precedence_idx += 1;
	END;
	

END;	
GO