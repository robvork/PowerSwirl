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