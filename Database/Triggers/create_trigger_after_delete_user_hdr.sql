IF OBJECT_ID(N'tD_user_hdr', N'TR') IS NOT NULL
	DROP TRIGGER tD_user_hdr;
GO

CREATE TRIGGER dbo.tD_user_hdr 
ON dbo.user_hdr
AFTER
DELETE
AS
BEGIN
	DELETE uc 
	FROM dbo.user_course AS uc
		INNER JOIN DELETED AS d
			ON uc.user_sid = d.user_sid
END
GO
