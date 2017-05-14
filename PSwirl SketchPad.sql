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
