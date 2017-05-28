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
WHERE course_sid IN (1, 3, 5) AND lesson_sid = (course_sid + 1)/ 2 
ORDER BY L_hdr.course_sid, L_hdr.lesson_sid

SELECT * 
FROM dbo.course_hdr
WHERE course_sid IN (1, 3, 5) 

SELECT *
FROM dbo.lesson_hdr 
WHERE course_sid IN (1, 3, 5) AND lesson_sid = (course_sid + 1)/ 2 

SELECT * 
FROM dbo.lesson_dtl 
