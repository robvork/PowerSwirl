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