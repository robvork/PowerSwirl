IF OBJECT_ID('dbo.lesson_dtl', 'U') IS NOT NULL
	DROP TABLE dbo.lesson_dtl;
GO

CREATE TABLE dbo.lesson_dtl
(
	course_sid SID NOT NULL,
	lesson_sid SID NOT NULL,
	step_num STEP NOT NULL,
	step_prompt PROMPT NOT NULL,
	requires_pause FLAG NOT NULL,
	requires_solution FLAG NOT NULL,
	requires_code_execution FLAG NOT NULL,
	requires_set_variable FLAG NOT NULL,
	requires_solution_execution FLAG NOT NULL,
	code_to_execute NVARCHAR(1000) NULL, 
	variable_to_set VARIABLE NULL,
	solution_expression NVARCHAR(500) NULL,
	PRIMARY KEY(course_sid, lesson_sid, step_num)
);
GO