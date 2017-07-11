IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_delete_lesson_steps') 
	DROP PROCEDURE dbo.p_delete_lesson_steps;
GO

CREATE PROCEDURE dbo.p_delete_lesson_steps
(
	  @ai_debug_level INT = 0
	, @ai_course_sid  INT 
	, @ai_lesson_sid  INT
)
AS
/*******************************************************************************
Procedure
p_delete_lesson_steps

Description 
Delete all the steps from a lesson

--------------------------------Interface-----------------------------------------
Input Parameter(s)

--------------------------------History-----------------------------------------
Date : 2017-01-14 14:18:07
Comment : 
Initial submission
*******************************************************************************/
BEGIN
BEGIN TRY
	DECLARE @ls_error_message AS NVARCHAR(MAX);
	DECLARE @lb_course_exists AS BIT;
	DECLARE @lb_lesson_exists AS BIT; 

	SET @lb_course_exists = 
	(
		SELECT 
			CASE 
				WHEN EXISTS(SELECT * FROM dbo.course_hdr WHERE course_sid = @ai_course_sid)
					THEN 
						1
					ELSE 
						0
			END
	); 

	IF @lb_course_exists = 0
	BEGIN
		SET @ls_error_message = 
			CONCAT(N'A course with SID '
				  , @ai_course_sid
				  , ' does not exist.'
				  );
		RAISERROR(@ls_error_message, 16, 1);
	END; 

	SET @lb_lesson_exists = 
	(
		SELECT 
			CASE 
				WHEN EXISTS(SELECT * FROM dbo.lesson_hdr WHERE lesson_sid = @ai_lesson_sid)
					THEN 
						1
					ELSE 
						0
			END
	); 

	IF @lb_lesson_exists = 0
	BEGIN
		SET @ls_error_message = 
			CONCAT
			(
				N'A lesson with SID '
				, @ai_lesson_sid
				, ' and course SID '
				, @ai_course_sid 
				, ' does not exist.'
			);
		RAISERROR(@ls_error_message, 16, 1);
	END; 

	DELETE FROM dbo.lesson_dtl 
	WHERE course_sid = @ai_course_sid
		  AND 
		  lesson_sid = @ai_lesson_sid
	; 
END TRY
BEGIN CATCH
	SET @ls_error_message = ERROR_MESSAGE(); 
	RAISERROR(@ls_error_message, 16, 1); 
END CATCH
END
GO
