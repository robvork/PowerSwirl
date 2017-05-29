Import-Module PowerSwirl -Force

InModuleScope PowerSwirl {
    $TestServerInstance = "ASPIRING\SQL16"
    $TestDatabase = "PowerSwirl_test"

    Describe "Save-Lesson" {
        BeforeEach {
            # Clear any existing user_course entries
            $Query = "TRUNCATE TABLE dbo.user_course;" 
            $Params = @{
                ServerInstance=$TestServerInstance;
                Database=$TestDatabase;
                Query=$Query; 
            }
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params 

            # 2 users, 2 courses, with 2 lessons per course
            # Note that each combination of user, course, and lesson must appear in this table
            $Query = "INSERT INTO dbo.user_course 
                      ( 
                        user_sid
                      , course_sid
                      , lesson_sid
                      , step_num
                      , lesson_in_progress_flag
                      , lesson_completed_flag
                      )
                      VALUES
                       (1, 1, 1, 1, 0, 0)
                      ,(1, 1, 2, 1, 0, 0)
                      ,(1, 2, 1, 1, 0, 0)
                      ,(1, 2, 2, 1, 0, 0)
                      ,(2, 1, 1, 1, 0, 0)
                      ,(2, 1, 2, 1, 0, 0)
                      ,(2, 2, 1, 1, 0, 0)
                      ,(2, 2, 2, 1, 0, 0)
                      ;
            "
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params

             # Clear any existing user_pause_state entries
            $Query = "TRUNCATE TABLE dbo.user_pause_state;" 
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params 

            # Deliberately omit adding anything to the user_pause_state table. 
            # There is an entry for a user/course/lesson combination only when a lesson is paused.
            # When there are no paused lessons, the table may be completely empty
            }

        Context "Saving one user" {
            BeforeEach {
                $CourseSid = 1
                $LessonSid = 2
                $UserSid = 1
                $StepNum = 4
                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    CourseSid=$CourseSid;
                    LessonSid=$LessonSid;
                    UserSid=$UserSid;
                    StepNum=$StepNum;
                }
                Save-Lesson @Params
            }

            It "should insert exactly one row into user_pause_state for the specified user" {
                $Query = "SELECT COUNT(*) AS rc FROM dbo.user_pause_state WHERE user_sid = $UserSid;"
                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }
                $rc = Invoke-Sqlcmd2 @Params -As PSObject | Select-Object -ExpandProperty rc
                $rc | Should be 1
            }

            It "should maintain at most one row in user_pause_state, even if the user already has pause state and saves again" {
                $Params["StepNum"] = 10
                $Params["CourseSid"] = 2
                $Params["LessonSid"] = 1
                Save-Lesson @Params 
                $Query = "SELECT COUNT(*) AS rc FROM dbo.user_pause_state WHERE user_sid = $UserSid;"
                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }
                $rc = Invoke-Sqlcmd2 @Params -As PSObject | Select-Object -ExpandProperty rc
                $rc | Should be 1
            } 

            $tc = @(
                @{columnName="user_sid"; expectedValue=1}
                @{columnName="course_sid"; expectedValue=1}
                @{columnName="lesson_sid"; expectedValue=2}
                @{columnName="step_num"; expectedValue=4}
            )
            It "should set in user_pause_state: <columnName> = <expectedValue>" -TestCases $tc {
                param
                (
                    [String] $columnName
                ,
                    [Int] $expectedValue
                )

                $Query = "SELECT user_sid
                        ,        course_sid
                        ,        lesson_sid
                        ,        step_num 
                          FROM 
                                 dbo.user_pause_state 
                          WHERE  
                                 user_sid = $UserSid
                        ;"

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }

                Invoke-Sqlcmd2 @Params | 
                Select-Object -ExpandProperty $columnName | 
                Should be $expectedValue
            }

            $tc = @(
                @{columnName="step_num"; expectedValue=4}
                @{columnName="lesson_in_progress_flag"; expectedValue=$true}
            )
            It "should set in user_course: <columnName> = <expectedValue>" -TestCases $tc  {
                param
                (
                    [String] $columnName
                ,
                    [Int] $expectedValue
                )

                $Query = "SELECT user_sid
                        ,        course_sid
                        ,        lesson_sid
                        ,        step_num 
                        ,        lesson_in_progress_flag
                          FROM 
                                 dbo.user_course
                          WHERE  
                                 user_sid = $UserSid
                            AND
                                 course_sid = $CourseSid
                            AND 
                                 lesson_sid = $LessonSid
                        ;"

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }

                Invoke-Sqlcmd2 @Params | 
                Select-Object -ExpandProperty $columnName | 
                Should be $expectedValue
            }
        }
        
        Context "Saving two users concurrently" {
            BeforeEach {
                $UserSid1 = 1
                $CourseSid1 = 1
                $LessonSid1 = 2
                $StepNum1 = 4

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    CourseSid=$CourseSid1;
                    LessonSid=$LessonSid1;
                    UserSid=$UserSid1;
                    StepNum=$StepNum1;
                }
                Save-Lesson @Params

                $UserSid2 = 2
                $CourseSid2 = 2
                $LessonSid2 = 1
                $StepNum2 = 8

                $Params["CourseSid"] = $CourseSid2
                $Params["LessonSid"] = $LessonSid2
                $Params["UserSid"] = $UserSid2 
                $Params["StepNum"] = $StepNum2

                Save-Lesson @Params
            }

            It "should insert exactly two rows into user_pause_state" {
                $Query = "SELECT COUNT(*) AS rc FROM dbo.user_pause_state;"
                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }
                $rc = Invoke-Sqlcmd2 @Params -As PSObject | Select-Object -ExpandProperty rc
                $rc | Should be 2
            }

            $tc = @(
                @{userSid=1}
                @{userSid=2}
            )

            It "should insert exactly one row into user_pause_state for user sid <userSid>" -TestCases $tc {
                param
                (
                    [Int] $userSid
                )
                $Query = "SELECT COUNT(*) AS rc FROM dbo.user_pause_state WHERE user_sid = $UserSid;"
                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }
                $rc = Invoke-Sqlcmd2 @Params -As PSObject | Select-Object -ExpandProperty rc
                $rc | Should be 1
            }

            $tc = @(
                @{userSid=1; columnName="user_sid"; expectedValue=$UserSid1}
                @{userSid=1; columnName="course_sid"; expectedValue=$CourseSid1}
                @{userSid=1; columnName="lesson_sid"; expectedValue=$LessonSid1}
                @{userSid=1; columnName="step_num"; expectedValue=$StepNum1}
                @{userSid=2; columnName="user_sid"; expectedValue=$UserSid2}
                @{userSid=2; columnName="course_sid"; expectedValue=$CourseSid2}
                @{userSid=2; columnName="lesson_sid"; expectedValue=$LessonSid2}
                @{userSid=2; columnName="step_num"; expectedValue=$StepNum2}
            )
            It "should set in user_pause_state: <columnName> = <expectedValue> for user <userSid>" -TestCases $tc {
                param
                (
                    [Int] $userSid
                ,
                    [String] $columnName
                ,
                    [Int] $expectedValue
                )

                $Query = "SELECT user_sid
                        ,        course_sid
                        ,        lesson_sid
                        ,        step_num 
                          FROM 
                                 dbo.user_pause_state 
                          WHERE  
                                 user_sid = $UserSid
                        ;"

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }

                Invoke-Sqlcmd2 @Params | 
                Select-Object -ExpandProperty $columnName | 
                Should be $expectedValue
            }

            $tc = @(
                @{
                     courseSid=$courseSid1; 
                     lessonSid=$lessonSid1;
                     userSid=$userSid1; 
                     columnName="step_num"; 
                     expectedValue=$StepNum1;
                 }

                @{
                     courseSid=$courseSid1;
                     lessonSid=$lessonSid1; 
                     userSid=$userSid1; 
                     columnName="lesson_in_progress_flag"; 
                     expectedValue=$true;
                 }

                @{
                     courseSid=$courseSid2;
                     lessonSid=$lessonSid2; 
                     userSid=$userSid2; 
                     columnName="step_num"; 
                     expectedValue=$StepNum2
                 }

                @{
                     courseSid=$courseSid2;
                     lessonSid=$lessonSid2; 
                     userSid=$userSid2; 
                     columnName="lesson_in_progress_flag"; 
                     expectedValue=$true
                 }
            )
            It "should set in user_course: <columnName> = <expectedValue> for user <userSid>" -TestCases $tc  {
                param
                (
                    [Int] $courseSid
                ,
                    [Int] $lessonSid
                ,
                    [Int] $userSid
                ,
                    [String] $columnName
                ,
                    [Int] $expectedValue
                )

                $Query = "SELECT user_sid
                        ,        course_sid
                        ,        lesson_sid
                        ,        step_num 
                        ,        lesson_in_progress_flag
                          FROM 
                                 dbo.user_course
                          WHERE  
                                 user_sid = $UserSid
                            AND
                                 course_sid = $CourseSid
                            AND 
                                 lesson_sid = $LessonSid
                        ;"

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    Query=$Query; 
                }

                Invoke-Sqlcmd2 @Params | 
                Select-Object -ExpandProperty $columnName | 
                Should be $expectedValue
            }
        }
        
    }

    Describe "Resume-Lesson" {
	    It "should..." {

	    }
    }
}