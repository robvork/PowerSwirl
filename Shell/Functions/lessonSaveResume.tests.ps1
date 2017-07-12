Get-Module -Name "PowerSwirl" -All | Remove-Module -Force 
Import-Module "PowerSwirl" -Force -ErrorAction Stop 

InModuleScope PowerSwirl {
    Describe "Save-Lesson" {
        BeforeEach {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            # Clear any existing user_course entries
            $Query = "TRUNCATE TABLE dbo.user_course;" 
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
                    Query=$Query; 
                }
                $rc = Invoke-Sqlcmd2 @Params -As PSObject | Select-Object -ExpandProperty rc
                $rc | Should be 1
            }

            It "should maintain at most one row in user_pause_state, even if the user already has pause state and saves again" {
                $Params = @{} 
                $Params["UserSid"] = 1
                $Params["StepNum"] = 10
                $Params["CourseSid"] = 2
                $Params["LessonSid"] = 1
                Save-Lesson @Params 
                $Query = "SELECT COUNT(*) AS rc FROM dbo.user_pause_state WHERE user_sid = $UserSid;"
                $Params = @{
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
                    Query=$Query; 
                }

                Invoke-Sqlcmd2 @Params | 
                Select-Object -ExpandProperty $columnName | 
                Should be $expectedValue
            }
        }
        
    }

    Describe "Resume-Lesson" {
        $UserSid1 = 1
        $CourseSid1 = 2
        $LessonSid1 = 1
        $StepNum1 = 19

        $UserSid2 = 2
        $CourseSid2 = 1
        $LessonSid2 = 3
        $StepNum2 = 6
            
        $UserSid3 = 3
        $CourseSid3 = 5
        $LessonSid3 = 6
        $StepNum3 = 24

        BeforeEach {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            $Query = "TRUNCATE TABLE dbo.user_pause_state;"
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
                Query=$Query; 
            }

            Invoke-Sqlcmd2 @Params

            $Query = "INSERT INTO dbo.user_pause_state
            (
                user_sid
            ,   course_sid
            ,   lesson_sid
            ,   step_num
            )
            VALUES 
              ($UserSid1, $CourseSid1, $LessonSid1, $StepNum1)
            , ($UserSid2, $CourseSid2, $LessonSid2, $StepNum2)
            , ($UserSid3, $CourseSid3, $LessonSid3, $StepNum3)
            "

            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params
        }
        Mock Start-PowerSwirlLesson {"$userSid,$courseSid,$lessonSid,$stepNum"} -Verifiable -ModuleName PowerSwirl

        $tc = @(
               @{userSidExpected=$UserSid1; courseSidExpected=$CourseSid1; lessonSidExpected=$lessonSid1; stepNumExpected=$stepNum1}
               @{userSidExpected=$UserSid2; courseSidExpected=$CourseSid2; lessonSidExpected=$lessonSid2; stepNumExpected=$stepNum2}
               @{userSidExpected=$UserSid3; courseSidExpected=$CourseSid3; lessonSidExpected=$lessonSid3; stepNumExpected=$stepNum3}
        )
	    It "should call Start-PowerSwirl with courseSid=<courseSidExpected>, lessonSid=<lessonSidExpected>, stepNum=<stepNumExpected> for user <userSidExpected>" -TestCases $tc {
            param
            (
                [Int] $userSidExpected 
            ,
                [Int] $courseSidExpected
            ,
                [Int] $lessonSidExpected
            ,
                [Int] $stepNumExpected
            )
            Resume-Lesson -UserSid $userSidExpected 
            Assert-MockCalled Start-PowerSwirlLesson -Scope It -ExclusiveFilter  {
                $UserSid -eq $UserSidExpected -and 
                $CourseSid -eq $CourseSidExpected -and 
                $LessonSid -eq $LessonSidExpected -and
                $StepNumStart -eq $StepNumExpected
            }
	    }
    }
}