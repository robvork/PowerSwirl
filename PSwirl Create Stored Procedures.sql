IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_user') 
	DROP PROCEDURE dbo.p_get_user;
GO

CREATE PROCEDURE dbo.p_get_user
(
	  @ai_debug_level INT = 0
	, @as_user_id ID
)
AS
/*******************************************************************************
Procedure
p_get_user

Description 
Get user sid given a user id

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@as_user_id : ID of user

Output Parameter(s)
None

Result Set(s)
A one row user set containing the following attributes
user_sid : the sid of the user with ID @as_user_id. 
		   either created or retrieved
user_exists : a bit indicating whether the user already existed prior to the procedure call.
		1 => user existed and sid retrieved
		2 => user did not exist and sid generated from new user entry
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:24:45
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @li_user_sid AS SID;
	DECLARE @lb_user_exists AS BIT;
	SET @li_user_sid = 
	(
		SELECT [user_sid] 
		FROM dbo.user_hdr 
		WHERE [user_id] = @as_user_id
	);
	
	IF @li_user_sid IS NULL
	BEGIN
		SET @lb_user_exists = 0;

		INSERT INTO dbo.user_hdr([user_id])
		VALUES (@as_user_id)

		SET @li_user_sid = 
		(
			SELECT [user_sid]
			FROM dbo.user_hdr
			WHERE [user_id] = @as_user_id
		);
		;
	END
	ELSE
	BEGIN
		SET @lb_user_exists = 1;
	END

	SELECT	 @li_user_sid AS [user_sid]
		   , @lb_user_exists AS [user_exists]
	;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_courses') 
	DROP PROCEDURE dbo.p_get_courses;
GO

CREATE PROCEDURE dbo.p_get_courses
(
	@ai_debug_level INT = 0
)
AS
/*******************************************************************************
Procedure
p_get_courses

Description 
Get all courses available

--------------------------------Interface-----------------------------------------
Input Parameter(s)
None

Output Parameter(s)
None

Result Set(s)
Course list with following attributes
choice : a unique positive integer identifying each course
course_sid : the sid of the row's course
course_id : the id of the row's course
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:28:33
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	SELECT ROW_NUMBER() OVER (ORDER BY course_id) AS selection
		 , course_id
		 , course_sid 
	FROM dbo.course_hdr
	ORDER BY course_id
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lessons') 
	DROP PROCEDURE dbo.p_get_lessons;
GO

CREATE PROCEDURE dbo.p_get_lessons
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID = NULL
	, @as_course_id ID = NULL
)
AS
/*******************************************************************************
Procedure
p_get_lessons

Description 
Get lessons available for a given course

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_course_sid : sid of course selection

Output Parameter(s)
None

Result Set(s)
Lesson list with following attributes
choice : a unique positive integer identifying each lesson
lesson_sid : the sid of the row's lesson
lesson_id : the id of the row's lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:32:27
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	IF @ai_course_sid IS NULL
		SET @ai_course_sid = 
		(
			SELECT course_sid 
			FROM dbo.course_hdr 
			WHERE course_id = @as_course_id
		);

	SELECT ROW_NUMBER() OVER (PARTITION BY c_dtl.course_sid ORDER BY l_hdr.lesson_id) AS choice
		   , c_dtl.lesson_sid
		   , l_hdr.lesson_id
	FROM dbo.course_dtl AS c_dtl
		 INNER JOIN dbo.lesson_hdr AS l_hdr
			ON c_dtl.course_sid = l_hdr.course_sid
			   AND
			   c_dtl.lesson_sid = l_hdr.lesson_sid
	WHERE c_dtl.course_sid = @ai_course_sid
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lesson_content') 
	DROP PROCEDURE dbo.p_get_lesson_content;
GO

CREATE PROCEDURE dbo.p_get_lesson_content
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
)
AS
/*******************************************************************************
Procedure
p_get_lesson_content

Description 
Get all the content for a chosen course and lesson

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_course_sid : the sid of the chosen course
@ai_lesson_sid : the sid of the chosen lesson belonging to course @ai_course_sid

Output Parameter(s)
None

Result Set(s)
Lesson content list having the following attributes
step_num : a unique positive integer identifying a lesson step. 
		   the content of a lesson is presented by iterating through step_num 1 through step_num n,
		   where n is the number of steps for the lesson. 
step_prompt : the lesson step's prompt
requires_input : a bit indicating whether the step requires user input
	 1 => requires input
	 0 => no input required
execute_code : a bit indicating whether the step should execute code
	 1 => code execution required
	 0 => no code execution required
store_var : a bit indicating whether the code execution's results should be stored in a variable.
	 1 => execution results should be stored in a variable. if store_var = 1, execute_code = 1
	 0 => if execute_code = 1, code should be executed but not stored. 
		  if execute_code = 0, this is set to 0 by default but is not used
variable : the id of a variable where code execution results should be stored
		   this should be used only when execute_code = 1 and store_var = 1
solution : literal text or code to be executed for comparison to user's input.
		   this should be used only when requires_input = 1
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:36:26
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	SELECT 
		   step_num AS step_num
		  ,step_prompt AS step_prompt
		  ,requires_input_flag AS requires_input
		  ,execute_code_flag AS execute_code
		  ,store_var_flag AS store_var 
		  ,variable AS variable
		  ,solution AS solution
	FROM 
		  dbo.lesson_dtl 
	WHERE 
		  course_sid = @ai_course_sid
		  AND 
		  lesson_sid = @ai_lesson_sid
	ORDER BY 
		  step_num
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lesson_info') 
	DROP PROCEDURE dbo.p_get_lesson_info;
GO

CREATE PROCEDURE dbo.p_get_lesson_info
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
)
AS
/*******************************************************************************
Procedure
p_get_lesson_info

Description 
Get info for a given course and lesson
--------------------------------Interface-----------------------------------------
Input Parameter(s)
None

Output Parameter(s)
None

Result Set(s)
Lesson info having one row with the following attributes
course_id : id of course
lesson_id : id of lesson
num_steps : number of steps in the lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:48:21
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	SELECT   c_hdr.course_id
		   , l_hdr.lesson_id
		   ,
		   (  
				SELECT COUNT(*) 
				FROM dbo.lesson_dtl AS l_dtl
				WHERE l_dtl.course_sid = l_hdr.course_sid
					AND
					l_dtl.lesson_sid = l_hdr.lesson_sid
		   ) AS num_steps
	FROM 
		 dbo.lesson_hdr AS l_hdr
		 INNER JOIN 
		 dbo.course_hdr AS c_hdr
			ON l_hdr.course_sid = c_hdr.course_sid
	WHERE 
		  l_hdr.course_sid = @ai_course_sid
		  AND
		  l_hdr.lesson_sid = @ai_lesson_sid
	;
END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_in_progress') 
	DROP PROCEDURE dbo.p_set_lesson_in_progress;
GO

CREATE PROCEDURE dbo.p_set_lesson_in_progress
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
	, @ai_step_num STEP = 1
)
AS
/*******************************************************************************
Procedure
p_set_lesson_in_progress

Description 
Set a given course and lesson to in progress for a specified user. Record
the step the user is currently on for later retrieval. 
--------------------------------Interface-----------------------------------------
Input Parameter(s) 
@ai_lesson_sid : sid of lesson to set in progress
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose progress is being saved
@ai_step_num : the current step @ai_user_sid is on within @ai_course_sid, @ai_lesson_sid

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:51:24
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	UPDATE uc 
	SET   lesson_in_progress_flag = 1
		, step_num = @ai_step_num
	FROM dbo.user_course AS uc
	WHERE 
		  uc.course_sid = @ai_course_sid
		  AND 
		  uc.lesson_sid = @ai_lesson_sid
		  AND 
		  uc.[user_sid] = @ai_user_sid
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_complete') 
	DROP PROCEDURE dbo.p_set_lesson_complete;
GO

CREATE PROCEDURE dbo.p_set_lesson_complete
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
)
AS
/*******************************************************************************
Procedure
p_set_lesson_complete

Description 
Set a given course and lesson to complete for a specified user. 
This erases any in-progress data the user has for that lesson.
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_lesson_sid : sid of lesson to set to complete
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose (course, lesson) we are setting to complete

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:57:35
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	UPDATE uc 
	SET   lesson_in_progress_flag = 0
		, lesson_completed_flag = 1
		, step_num = 1
	FROM dbo.user_course AS uc
	WHERE 
		  uc.course_sid = @ai_course_sid
		  AND 
		  uc.lesson_sid = @ai_lesson_sid
		  AND 
		  uc.[user_sid] = @ai_user_sid
	;

	DELETE FROM ups 
	FROM dbo.user_pause_state AS ups
	WHERE	  
		  ups.course_sid = @ai_course_sid
		  AND 
		  ups.lesson_sid = @ai_lesson_sid
		  AND 
		  ups.[user_sid] = @ai_user_sid
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_paused') 
	DROP PROCEDURE dbo.p_set_lesson_paused;
GO

CREATE PROCEDURE dbo.p_set_lesson_paused
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
	, @ai_step_num SID
)
AS
/*******************************************************************************
Procedure
p_set_lesson_paused

Description 
Create temporary pause data for a user pausing a given lesson. A user
can have at most 1 paused lesson at any given time, though he or she 
may have several in progress courses. 

This procedure is the primary means for enabling the user to explore using code 
execution outside of the context of a lesson.
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_lesson_sid : sid of lesson to pause
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose lesson is being paused
@ai_step_num : step number of paused lesson

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 13:02:07
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DELETE FROM ups 
	FROM dbo.user_pause_state AS ups
	WHERE 
		ups.[user_sid] = @ai_user_sid
	;

	INSERT INTO dbo.user_pause_state
		(
			 [user_sid]
			,[course_sid]
			,[lesson_sid]
			,[step_num]
		)
	VALUES 
		(
			 @ai_user_sid
			,@ai_course_sid
			,@ai_lesson_sid
			,@ai_step_num
		)
	;

	UPDATE uc 
	SET	  step_num = @ai_step_num
		, lesson_in_progress_flag = 1
	FROM dbo.user_course AS uc
	WHERE 
		  uc.course_sid = @ai_course_sid
		  AND 
		  uc.lesson_sid = @ai_lesson_sid
		  AND 
		  uc.[user_sid] = @ai_user_sid
	;

	

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_pause_info') 
	DROP PROCEDURE dbo.p_get_pause_info;
GO

CREATE PROCEDURE dbo.p_get_pause_info
(
	  @ai_debug_level INT = 0
	, @ai_user_sid ID
)
AS
/*******************************************************************************
Procedure
p_get_pause_info

Description 
Get the lesson information necessary to resume a lesson
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_user_sid : the user sid of the user resuming the lesson

Output Parameter(s)
None

Result Set(s)
The user's pause info containing the following attributes
course_sid : course sid of paused lesson
lesson_sid : lesson sid of paused lesson
step_num : current step in paused lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 13:09:13
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	SELECT course_sid
		 , lesson_sid
		 , step_num 
	FROM dbo.user_pause_state
	WHERE 
		  [user_sid] = @ai_user_sid
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_delete_user_pause_info') 
	DROP PROCEDURE dbo.p_delete_user_pause_info;
GO

CREATE PROCEDURE dbo.p_delete_user_pause_info
(
	  @ai_debug_level INT = 0
	, @ai_user_sid SID
)
AS
/*******************************************************************************
Procedure
p_delete_user_pause_info

Description 
Deletes a user's pause info if it exists.
Will run successfully even when a user doesn't have any pause info to delete.
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_user_sid : the user sid of the user whose pause info we are to delete

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 13:09:13
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	DELETE FROM 
		 dbo.user_pause_state
	WHERE 
		 [user_sid] = @ai_user_sid
	;

END
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_create_new_lesson') 
	DROP PROCEDURE dbo.p_create_new_lesson;
GO

CREATE PROCEDURE dbo.p_create_new_lesson
(
	  @ai_debug_level INT = 0
	, @as_lesson_id ID
	, @as_course_id ID
	, @ab_overwrite_existing_lesson FLAG
	, @ab_create_new_course FLAG
)
AS
/*******************************************************************************
Procedure
p_create_new_lesson

Description 
Briefly describe procedure

--------------------------------Interface-----------------------------------------
Input Parameter(s)
 @as_lesson_id : id of lesson to add
 @as_course_id : course id associated with @as_lesson_id
 @ab_overwrite_existing_lesson : bit indicating whether to overwrite the existing lesson
	in the event that there is a prexisting lesson with lesson id @as_lesson_id 
	within course @as_course_id
	1 => Overwrite existing lesson
	0 => Do not overwrite lesson. Throw error if lesson already exists
 @ab_create_new_course : bit indicating whether to create a new course in the event that 
	there is no course with id @as_course_id. 
	1 => Create new course if course does not exist
	0 => Do not create new course. Throw error if course does not exist. 

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 14:18:07
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @ls_error_message AS NVARCHAR(MAX);
	DECLARE @lb_lesson_exists AS BIT;
	DECLARE @lb_course_exists AS BIT;
	DECLARE @li_lesson_sid AS SID;
	DECLARE @li_course_sid AS SID;

	SET @lb_course_exists = 
	(
		CASE 
			WHEN EXISTS 
			(
				SELECT * 
				FROM dbo.course_hdr 
				WHERE course_id = @as_course_id
			) 
				THEN 
						1
			ELSE 
						0
		END
	);

	IF @lb_course_exists = 0 
	BEGIN
		IF @ab_create_new_course = 1
		BEGIN
			SET @li_course_sid = 
			(
				SELECT ISNULL(MAX(course_sid), 0) + 1 
				FROM dbo.course_hdr
			); 
			
			INSERT INTO dbo.course_hdr
						(
						  course_sid
						 ,course_id
						)
						VALUES 
						(
						  @li_course_sid
						 ,@as_course_id
						)
			;
		END;
		ELSE
		BEGIN
			SET @ls_error_message = 'Course with id ''' 
								     + @as_course_id 
									 + ''' does not exist and procedure called with @ab_overwrite_existing_lesson = 0.' + NCHAR(13)
									 + 'Use an existing course or use @ab_overwrite_existing_lesson = 1';
			RAISERROR(@ls_error_message, 16, 1);
		END;
	END;
	ELSE
		SET @li_course_sid = 
		(
			SELECT course_sid 
			FROM dbo.course_hdr 
			WHERE course_id = @as_course_id
		);


	SET @lb_lesson_exists = 
	(
		CASE 
			WHEN EXISTS 
			(
				SELECT * 
				FROM dbo.lesson_hdr 
				WHERE  
					course_sid = @li_course_sid
					AND 
					lesson_id = @as_lesson_id
			) 
				THEN 
						1
			ELSE 
						0
		END
	);

	

	IF @lb_lesson_exists = 1
	BEGIN
		IF @ab_overwrite_existing_lesson = 1
		BEGIN
			SET @li_lesson_sid = 
			(
				SELECT lesson_sid 
				FROM dbo.lesson_hdr 
				WHERE lesson_id = @as_lesson_id
			); 
			
			DELETE FROM dbo.lesson_dtl
			WHERE	course_sid = @li_course_sid 
				AND lesson_sid = @li_lesson_sid
			;
		END
		ELSE
		BEGIN
			SET @ls_error_message = 'Lesson with id ''' 
								     + @as_lesson_id 
									 + ''' already exists within course ''' 
									 + @as_course_id 
									 + ''' and procedure called with @ab_overwrite_existing_lesson = 0. ' + NCHAR(13) 
									 + 'Choose unique lesson name or use @ab_overwrite_existing_lesson = 1'; 
			RAISERROR(@ls_error_message, 16, 1);
		END
	END
	ELSE
	BEGIN
		SET @li_lesson_sid = 
		(
			SELECT ISNULL(MAX(lesson_sid), 0) + 1
			FROM dbo.course_dtl
			WHERE course_sid = @li_course_sid
		);

		INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
		VALUES (@li_course_sid, @li_lesson_sid, @as_lesson_id) ;

		INSERT INTO dbo.course_dtl(course_sid, lesson_sid)
		VALUES (@li_course_sid, @li_lesson_sid)

	END

	SELECT @li_course_sid, @li_lesson_sid;

END
GO

