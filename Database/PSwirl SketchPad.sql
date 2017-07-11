USE PowerSwirl;

SELECT * FROM sys.all_columns;

SELECT * FROM sys.tables; 

WITH user_tables AS
(
	SELECT object_id
	FROM sys.tables 
	WHERE name LIKE '%course%'
		  OR name LIKE '%lesson%'
)
SELECT OBJECT_NAME(UT.object_id), name, *
FROM sys.all_columns AS C
	INNER JOIN user_tables AS UT
		ON C.object_id = UT.object_id
ORDER BY OBJECT_NAME(UT.object_id)

SELECT * FROM sys.all_columns; 

SELECT * FROM lesson_hdr; 



   SELECT ISNULL(
                            (
                                SELECT course_sid
                                FROM course_hdr
                                WHERE course_id = 'Csdkfjlsk'
                            ), 
                            (
                                SELECT MAX(course_sid) + 1
                                FROM course_hdr
                            )
                            )



DELETE FROM dbo.course_hdr 
WHERE course_sid = 5;

DELETE FROM dbo.course_dtl 
WHERE course_sid = 5;

DELETE FROM dbo.lesson_hdr 
WHERE course_sid = 5;

DELETE FROM dbo.lesson_dtl 
WHERE course_sid = 5;


UPDATE dbo.lesson_dtl
SET variable = NULL
WHERE variable 

SELECT * FROM course_hdr;
SELECT * FROM lesson_hdr; 
SELECT * FROM course_dtl;
SELECT * FROM lesson_dtl; 

DECLARE @ls_current_table SYSNAME;
DECLARE @ls_sql NVARCHAR(MAX);

DECLARE table_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT name FROM sys.tables; 

OPEN table_cursor;

WHILE 0 = 0
BEGIN
	FETCH NEXT FROM table_cursor
	INTO @ls_current_table;

	IF @@FETCH_STATUS <> 0
		BREAK;

	SET @ls_sql = 
	CONCAT
	(
		N'SELECT ''', @ls_current_table, N''';
		SELECT * FROM ', @ls_current_table, N';'
	);

	EXEC(@ls_sql);
END;

CLOSE table_cursor; 
DEALLOCATE table_cursor; 

SELECT C_hdr.course_id, L_hdr.lesson_id, SC.step_count AS num_steps
FROM dbo.course_hdr AS C_hdr
	INNER JOIN dbo.lesson_hdr AS l_hdr
		ON C_hdr.course_sid = l_hdr.course_sid
	CROSS APPLY 
	(
		SELECT COUNT(*) AS step_count
		FROM dbo.lesson_dtl AS l_dtl
		WHERE 
			l_dtl.course_sid = l_hdr.course_sid 
			AND 
			l_dtl.lesson_sid = l_hdr.lesson_sid 
	) AS SC
WHERE L_hdr.course_sid IN (1, 3, 5) 
ORDER BY L_hdr.course_sid, L_hdr.lesson_sid

SELECT * 
FROM dbo.course_hdr
WHERE course_sid IN (1, 3, 5) 

SELECT *
FROM dbo.lesson_hdr 
WHERE course_sid IN (1, 3, 5) 

SELECT * 
FROM dbo.lesson_dtl 

TRUNCATE TABLE dbo.user_pause_state

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

