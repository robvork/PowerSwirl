
Get-Module -Name "PowerSwirl" -All | Remove-Module -Force 
Import-Module "PowerSwirl" -Force -ErrorAction Stop 

InModuleScope "PowerSwirl" {
    Describe "Write-RetryPrompt" {
        Context "Non-empty message" {
            BeforeAll {
                $message = "The course you selected is not valid"
                $postMessage = "Please try again."
                Write-RetryPrompt -Message $message -InformationVariable iv

                $messageWritten = $iv | 
                                  Where-Object {$_.Tags -eq "message"} | 
                                  Select-Object -ExpandProperty MessageData
                $postMessageWritten = $iv | 
                                  Where-Object {$_.Tags -eq "postmessage"} | 
                                  Select-Object -ExpandProperty MessageData    
            }

            It "should not throw" {
                {Write-RetryPrompt $message} | should not throw
            }

            It "should put a message m1 into the information stream with tag 'message'" {
                 $messageWritten | should not be nulllorempty   
	        }

            It "should put a string into m1 (defined above)" {
                 $messageWritten | should beoftype [string]  
	        }

            It "should put the string specified into m1 (defined above)" {
                 $messageWritten | should be $message
	        }
            
            It "should put a message m2 into the information stream with tag 'postmessage'" {
                 $postMessageWritten | should not be nulllorempty     
	        }

            It "should put a string into m2 (defined above)" {
                 $postMessageWritten | should beoftype [string]  
	        }

            It "should put the string specified into m2 (defined above)" {
                 $postMessageWritten | should be $postMessage 
	        }

            
        }
        Context "Empty or null message" {
            BeforeAll {
                $ErrorMessage = "Message must be not null and not empty"
            }
            
            It "should throw when message is empty" { 
                {Write-RetryPrompt -Message ""} | should throw $ErrorMessage 
            }

            It "should throw when message is null" { 
                {Write-RetryPrompt -Message $null} | should throw $ErrorMessage 
            }
        }
    }

    Describe "Write-CourseSelections" {
	    Context "One course" {
            BeforeAll {
                $CourseSelections = [CourseSelection[]] @()
                $CourseSelections += [CourseSelection]::new(1, "The First Course", 45)

                Write-CourseSelections -CourseSelections $CourseSelections -InformationVariable iv
                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreSelection = $iv | 
                             Where-Object {$_.Tags -eq "PreSelection"}
                $CourseSelectionStrings = $iv | 
                                        Where-Object {$_.Tags -eq "CourseSelectionString"} |
                                        Sort-Object

                $PreSelectionMessage = "Choose a course from the following"                
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'CourseCount'" {
                $CourseCount.Length | Should be 1
            }

            It "should write an int for Coursecount" {
                $CourseCount.MessageData | Should beoftype [int]
            }

            It "should write a course count equal to the number of course selections" {
                $CourseCount.MessageData | Should be $CourseSelectionStrings.Length
            }

            It "should write a message m2 into the information stream with tag 'PreSelection'" {
                $PreSelection | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'PreSelection'" {
                $PreSelection.Length | Should be 1
            }
            
            It "should write a string for the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should beoftype [String]
            }

            It "should write a predetermined message to the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should be $PreSelectionMessage
            }

            It "should write at least one message into the information stream with tag 'CourseSelectionString'" {
                $CourseSelectionStrings | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'CourseSelection'" {
                $CourseSelectionStrings.Length | Should be 1
            }

            It "should write the ToString version of the FirstCourse to the information stream" {
                $CourseSelections[0].ToString() | Should bein $CourseSelectionStrings.MessageData
            }

            
        }

        Context "Two courses" {
            BeforeAll {
                $CourseSelections = [CourseSelection[]] @()
                $CourseSelections += [CourseSelection]::new(1, "The First Course", 45)
                $CourseSelections += [CourseSelection]::new(2, "The Second Course", 29)

                Write-CourseSelections -CourseSelections $CourseSelections -InformationVariable iv
                
                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreSelection = $iv | 
                               Where-Object {$_.Tags -eq "PreSelection"}
                $CourseSelectionStrings = $iv | 
                               Where-Object {$_.Tags -eq "CourseSelectionString"} |
                               Sort-Object 
                 
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'CourseCount'" {
                $CourseCount.Length | Should be 1
            }

            It "should write an int for Coursecount" {
                $CourseCount.MessageData | Should beoftype [int]
            }

            It "should write a course count equal to the number of course selections" {
                $CourseCount.MessageData | Should be $CourseSelectionStrings.Length
            }

            It "should write a message m2 into the information stream with tag 'PreSelection'" {
                $PreSelection | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'PreSelection'" {
                $PreSelection.Length | Should be 1
            }
            
            It "should write a string for the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should beoftype [String]
            }

            It "should write a predetermined message to the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should be $PreSelectionMessage
            }

            It "should write at least one message into the information stream with tag 'CourseSelectionString'" {
                $CourseSelectionStrings | Should not beNullOrEmpty
            }

            It "should write exactly two messages with tag 'CourseSelection'" {
                $CourseSelectionStrings.Length | Should be 2
            }

            It "should write the ToString version of The First Course to the information stream" {
                $CourseSelections[0].ToString() | Should bein $CourseSelectionStrings.MessageData
            }

            It "should write the ToString version of The Second Course to the information stream" {
                $CourseSelections[1].ToString() | Should bein $CourseSelectionStrings.MessageData
            }
        }

        Context "Three courses" { 
            BeforeAll {
                $CourseSelections = [CourseSelection[]] @()
                $CourseSelections += [CourseSelection]::new(1, "The First Course", 45)
                $CourseSelections += [CourseSelection]::new(2, "The Second Course", 29)
                $CourseSelections += [CourseSelection]::new(3, "The Third Course", 188)

                Write-CourseSelections -CourseSelections $CourseSelections -InformationVariable iv

                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreSelection = $iv | 
                               Where-Object {$_.Tags -eq "PreSelection"}
                $CourseSelectionStrings = $iv | 
                               Where-Object {$_.Tags -eq "CourseSelectionString"} |
                               Sort-Object 
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'CourseCount'" {
                $CourseCount.Length | Should be 1
            }

            It "should write an int for Coursecount" {
                $CourseCount.MessageData | Should beoftype [int]
            }

            It "should write a course count equal to the number of course selections" {
                $CourseCount.MessageData | Should be $CourseSelectionStrings.Length
            }

            It "should write a message m2 into the information stream with tag 'PreSelection'" {
                $PreSelection | Should not beNullOrEmpty
            }

            It "should write exactly one message with tag 'PreSelection'" {
                $PreSelection.Length | Should be 1
            }
            
            It "should write a string for the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should beoftype [String]
            }

            It "should write a predetermined message to the message with tag 'PreSelection'" {
                $PreSelection.MessageData | Should be $PreSelectionMessage
            }

            It "should write at least one message into the information stream with tag 'CourseSelectionString'" {
                $CourseSelectionStrings | Should not beNullOrEmpty
            }

            It "should write exactly three messages with tag 'CourseSelection'" {
                $CourseSelectionStrings.Length | Should be 3
            }

            It "should write the ToString version of The First Course to the information stream" {
                $CourseSelections[0].ToString() | Should bein $CourseSelectionStrings.MessageData
            }

            It "should write the ToString version of The Second Course to the information stream" {
                $CourseSelections[1].ToString() | Should bein $CourseSelectionStrings.MessageData
            }

            It "should write the ToString version of The Third Course to the information stream" {
                $CourseSelections[2].ToString() | Should bein $CourseSelectionStrings.MessageData
            }
        }

        Context "0 courses" {
            BeforeAll {
                $ErrorMessage = "Courses must be non-null"
            }
        }

        It "should throw when CourseSelections -eq `$null" {
            {Write-CourseSelections -CourseSelections $null} | Should throw $ErrorMessage    
	    }
    }


    Describe "Get-Course" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 

            $Query = "TRUNCATE TABLE dbo.course_hdr;"
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
                Query=$Query;
            }

            Invoke-Sqlcmd2 @Params 

            $Query = "INSERT INTO dbo.course_hdr(course_sid, course_id) 
                      VALUES
                        (1, 'Course A')
                      , (2, 'Course B')
                      , (3, 'Course C')
                      ; 
                     "

            $Params["Query"] = $Query 

            Invoke-Sqlcmd2 @Params 
        }

        Context 'Valid course selections' {
            BeforeAll {
                $CourseResultA = Get-Course  -CourseID "Course A"
                $CourseResultB = Get-Course  -CourseID "Course B"
                $CourseResultC = Get-Course  -CourseID "Course C"
            }
            It "should not throw" { 
                {Get-Course  -CourseID "Course A"} | 
                    Should not throw
            }

            It "should return an object with property CourseSID" { 
                "CourseSID" | Should Bein ($CourseResultA | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return CourseSID as an int" { 
                $CourseResultA | Select-Object -ExpandProperty CourseSID | Should beoftype [int]
            }

            It "should return an object with property CourseExists" { 
                "CourseExists" | Should Bein ($CourseResultA | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return CourseExists as a bool" { 
                $CourseResultA | Select-Object -ExpandProperty CourseExists | Should beoftype [bool]
            }

            It "should return CourseExists = true for CourseID = 'Course A' when the courses available are 'Course A', 'Course B', and 'Course C'" {
                $CourseResultA | Select-Object -ExpandProperty CourseExists | Should be $true 
            }

            It "should return CourseSID = 1 for CourseID = 'Course A', when the SID correspondence is A -> 1, B -> 2, C -> 3" {
                $CourseResultA | Select-Object -ExpandProperty CourseSID | Should be 1 
            }

            It "should return CourseExists = true for CourseID = 'Course B' when the courses available are 'Course A', 'Course B', and 'Course C'" {
                $CourseResultB | Select-Object -ExpandProperty CourseExists | Should be $true 
            }

            It "should return CourseSID = 2 for CourseID = 'Course A', when the SID correspondence is A -> 1, B -> 2, C -> 3" {
                $CourseResultB | Select-Object -ExpandProperty CourseSID | Should be 2
            }

            It "should return CourseExists = true for CourseID = 'Course C' when the courses available are 'Course A', 'Course B', and 'Course C'" {
                $CourseResultC | Select-Object -ExpandProperty CourseExists | Should be $true 
            }

            It "should return CourseSID = 3 for CourseID = 'Course A', when the SID correspondence is A -> 1, B -> 2, C -> 3" {
                $CourseResultC | Select-Object -ExpandProperty CourseSID | Should be 3 
            }

            
        }

        Context 'Invalid course selections' {
            BeforeAll {
                $CourseResultD = Get-Course  -CourseID "Course D"
            }
            
            It "should not throw" { 
                {Get-Course  -CourseID "Course D"} | 
                    Should not throw
            }

            It "should return an object with property CourseSID" { 
                "CourseSID" | Should Bein ($CourseResultD | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return a [System.DBNull] for CourseSID" {
                $CourseResultD | Select-Object -ExpandProperty CourseSID | Should beoftype [System.DBNull]
            }

            It "should return an object with property CourseExists" { 
                "CourseExists" | Should Bein ($CourseResultD | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return CourseExists as a bool" { 
                $CourseResultD | Select-Object -ExpandProperty CourseExists | Should beoftype [bool]
            }

            It "should return CourseExists = false" { 
                $CourseResultD | Select-Object -ExpandProperty CourseExists | Should be $false 
            }
        }
    }

    Describe "Test-PSwirlCourse" {
        BeforeAll {
                $ErrorMessage = "Course does not exist"
        }

        Context 'Course exists' {

            Mock Get-Course {
                Write-Output (New-Object -TypeName PSObject -Property @{courseExists=$true; courseSID=1})
            }
            
            It "should not throw" {
                {Test-PSwirlCourse  -CourseID "Course A"} |
                Should not throw
	        }

            It "should write an int to the pipeline" { 
                Test-PSwirlCourse  -CourseID "Course A" | 
                Should beoftype [int]
            }

            It "should write the int 1 to the pipeline" { 
                Test-PSwirlCourse  -CourseID "Course A" | 
                Should be 1
            }
        }

        Context 'Course does not exist' {
            
            Mock Get-Course {
                Write-Output (New-Object -TypeName PSObject -Property @{courseExists=$false; courseSID=[System.DBNull]})
            }

            It "should throw" {
                {Test-PSwirlCourse  -CourseID "Course A"} |
                Should throw "Course does not exist"
	        }
        }
	    
    }

    Describe "Get-Lesson" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 

            $Query = "TRUNCATE TABLE dbo.lesson_hdr;"
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
                Query=$Query;
            }

            Invoke-Sqlcmd2 @Params 

            $Query = "INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id) 
                      VALUES
                        (1, 1, 'C1 Lesson 1')
                      , (2, 1, 'C2 Lesson 1')
                      , (2, 2, 'C2 Lesson 2')
                      , (3, 1, 'C3 Lesson 1')
                      , (3, 2, 'C3 Lesson 2')
                      , (3, 3, 'C3 Lesson 3')
                      ; 
                     "

            $Params["Query"] = $Query 

            Invoke-Sqlcmd2 @Params 
        }

        Context 'Valid lesson selections' {
            BeforeAll {
                $C1L1Result = Get-Lesson  -CourseSID 1 -LessonID "C1 Lesson 1"
                $C2L1Result = Get-Lesson  -CourseSID 2 -LessonID "C2 Lesson 1"
                $C2L2Result = Get-Lesson  -CourseSID 2 -LessonID "C2 Lesson 2"
                $C3L1Result = Get-Lesson  -CourseSID 3 -LessonID "C3 Lesson 1"
                $C3L2Result = Get-Lesson  -CourseSID 3 -LessonID "C3 Lesson 2"
                $C3L3Result = Get-Lesson  -CourseSID 3 -LessonID "C3 Lesson 3"
            }

            It "should not throw" { 
                {Get-Lesson  -CourseSID 1 -LessonID "C1 Lesson 1"} | 
                    Should not throw
            }

            It "should return an object with property LessonSID" { 
                "LessonSID" | Should Bein ($c1L1Result | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return LessonSID as an int" { 
                $C1L1Result | Select-Object -ExpandProperty LessonSID | Should beoftype [int]
            }

            It "should return an object with property LessonExists" { 
                "LessonExists" | Should Bein ($C1L1Result | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return LessonExists as a bool" { 
                $C1L1Result | Select-Object -ExpandProperty LessonExists | Should beoftype [bool]
            }


            # Course 1
            #  Lesson 1

            It "should return LessonExists = true for CourseSid = 1 and LessonID = 'C1 Lesson 1'" {
                $C1L1Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 1 and LessonID = 'C1 Lesson 1'" {
                $C1L1Result | Select-Object -ExpandProperty LessonSID | Should be 1 
            }
            
            # Course 2
            #  Lesson 1

            It "should return LessonExists = true for CourseSid = 2 and LessonID = 'C2 Lesson 1'" {
                $C2L1Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 2 and LessonID = 'C2 Lesson 1'" {
                $C2L1Result | Select-Object -ExpandProperty LessonSID | Should be 1 
            }


            #  Lesson 2
            It "should return LessonExists = true for CourseSid = 2 and LessonID = 'C2 Lesson 2'" {
                $C2L2Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 2 and LessonID = 'C2 Lesson 2'" {
                $C2L2Result | Select-Object -ExpandProperty LessonSID | Should be 2 
            }

            # Course 3
            #  Lesson 1

            It "should return LessonExists = true for CourseSid = 3 and LessonID = 'C3 Lesson 1'" {
                $C3L1Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 3 and LessonID = 'C3 Lesson 1'" {
                $C3L1Result | Select-Object -ExpandProperty LessonSID | Should be 1 
            }

            #  Lesson 2
            It "should return LessonExists = true for CourseSid = 3 and LessonID = 'C3 Lesson 2" {
                $C3L2Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 3 and LessonID = 'C3 Lesson 2'" {
                $C3L2Result | Select-Object -ExpandProperty LessonSID | Should be 2 
            }

            #  Lesson 3
            It "should return LessonExists = true for CourseSid = 3 and LessonID = 'C3 Lesson 3'" {
                $C3L3Result | Select-Object -ExpandProperty LessonExists | Should be $true 
            }

            It "should return LessonSid = 1 for CourseSID = 3 and LessonID = 'C3 Lesson 3'" {
                $C3L3Result | Select-Object -ExpandProperty LessonSID | Should be 3
            }
        }

        Context 'Invalid lesson selections' {
            BeforeAll {
                $LessonNotFoundAnywhere = Get-Lesson  -CourseSID 1 -LessonID "Complete bogus"
                $LessonNotFoundInCourse = Get-Lesson  -CourseSID 1 -LessonID "C2 Lesson 1" 
            }
            
            It "should not throw" {
                {Get-Lesson  -CourseSID 1 -LessonID "C1 Lesson 100"} | 
                    Should not throw
            }

            It "should return an object with property LessonSID" { 
                "LessonSID" | Should Bein ($LessonNotFoundAnywhere | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return LessonSID as a [System.DBNull]" { 
                $LessonNotFoundAnywhere | Select-Object -ExpandProperty LessonSID | Should beoftype [System.DBNull]
            }

            It "should return an object with property LessonExists" { 
                "LessonExists" | Should Bein ($LessonNotFoundAnywhere | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should return LessonExists as a bool" { 
                $LessonNotFoundAnywhere | Select-Object -ExpandProperty LessonExists | Should beoftype [bool]
            }

            It "should write LessonExists = false when the lesson does not exist in any course" {
                $LessonNotFoundAnywhere | Select-Object -ExpandProperty LessonExists | Should be $false 
            }

            It "should write LessonExists = false when the lesson does not exist for the chosen course, but does for some other course" {
                $LessonNotFoundInCourse | Select-Object -ExpandProperty LessonExists | Should be $false 
            }
        }
    }

    Describe "Test-MenuSelection" {
        BeforeAll {
            $menuSelections = @((New-MenuSelection 1), (New-MenuSelection 2), (New-MenuSelection 3))
            $menuSelection1 = New-MenuSelection 1
            $menuSelection2 = New-MenuSelection 2
            $menuSelection3 = New-MenuSelection 3
            $menuSelection0 = New-MenuSelection 0
            $menuSelectionNeg4 = New-MenuSelection -4 
            $menuSelection8 = New-MenuSelection 8

            $CourseSelections = @((New-CourseSelection 1), (New-CourseSelection 2), (New-CourseSelection 3))
            $CourseSelection1 = New-CourseSelection 1
            $CourseSelection2 = New-CourseSelection 2
            $CourseSelection3 = New-CourseSelection 3
            $CourseSelection0 = New-CourseSelection 0
            $CourseSelectionNeg4 = New-CourseSelection -4 
            $CourseSelection8 = New-CourseSelection 8

            $LessonSelections = @((New-LessonSelection 1), (New-LessonSelection 2), (New-LessonSelection 3))
            $LessonSelection1 = New-LessonSelection 1
            $LessonSelection2 = New-LessonSelection 2
            $LessonSelection3 = New-LessonSelection 3
            $LessonSelection0 = New-LessonSelection 0
            $LessonSelectionNeg4 = New-LessonSelection -4 
            $LessonSelection8 = New-LessonSelection 8
        }

        Context "Valid MenuSelections" {
            It "should not throw when the MenuSelection is 1 and the possible MenuSelections are (1, 2, 3)" {
            {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelection1} |
            Should not throw
	        }

            It "should not throw when the MenuSelection is 2 and the possible MenuSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelection2} |
                Should not throw
	        }

            It "should not throw when the MenuSelection is 3 and the possible MenuSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelection3} |
                Should not throw
	        }
        }

        Context "Valid CourseSelections" {
            It "should not throw when the CourseSelection is 1 and the possible CourseSelections are (1, 2, 3)" {
            {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $courseSelection1} |
            Should not throw
	        }

            It "should not throw when the CourseSelection is 2 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $courseSelection2} |
                Should not throw
	        }

            It "should not throw when the CourseSelection is 3 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $courseSelection3} |
                Should not throw
	        }
        }

        Context "Valid LessonSelections" {
            It "should not throw when the LessonSelection is 1 and the possible LessonSelections are (1, 2, 3)" {
            {Test-MenuSelection -MenuSelections $lessonSelections -MenuSelection $lessonSelection1} |
            Should not throw
	        }

            It "should not throw when the LessonSelection is 2 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $lessonSelections -MenuSelection $lessonSelection2} |
                Should not throw
	        }

            It "should not throw when the LessonSelection is 3 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $lessonSelections -MenuSelection $lessonSelection3} |
                Should not throw
	        }
        }

        Context "Valid MenuSelection from CourseSelections" {
            It "should not throw when the MenuSelection is 1 and the possible CourseSelections are (1, 2, 3)" {
            {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $menuSelection1} |
            Should not throw
	        }

            It "should not throw when the MenuSelection is 2 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $menuSelection2} |
                Should not throw
	        }

            It "should not throw when the MenuSelection is 3 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $courseSelections -MenuSelection $menuSelection3} |
                Should not throw
	        }
        }

        Context "Valid MenuSelection from LessonSelections" {
            It "should not throw when the MenuSelection is 1 and the possible LessonSelections are (1, 2, 3)" {
            {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $menuSelection1} |
            Should not throw
	        }

            It "should not throw when the MenuSelection is 2 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $menuSelection2} |
                Should not throw
	        }

            It "should not throw when the MenuSelection is 3 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $menuSelection3} |
                Should not throw
	        }
        }

        Context "Invalid MenuSelections" {
            BeforeAll {
                $ErrorMessage = "Invalid menu selection"
            }

            It "should throw when the MenuSelection is 0 and the possible MenuSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelection0} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the MenuSelection is -4 and the possible MenuSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelectionneg4} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the MenuSelection is 8 and the possible MenuSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $menuSelections -MenuSelection $menuSelection8} | 
                Should throw $ErrorMessage 
            }
        }

        Context "Invalid CourseSelections" {
            BeforeAll {
                $ErrorMessage = "Invalid menu selection"
            }

            It "should throw when the CourseSelection is 0 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $CourseSelections -MenuSelection $CourseSelection0} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the CourseSelection is -4 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $CourseSelections -MenuSelection $CourseSelectionneg4} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the CourseSelection is 8 and the possible CourseSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $CourseSelections -MenuSelection $CourseSelection8} | 
                Should throw $ErrorMessage 
            }
        }

        Context "Invalid LessonSelections" {
            BeforeAll {
                $ErrorMessage = "Invalid menu selection"
            }

            It "should throw when the LessonSelection is 0 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $LessonSelection0} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the LessonSelection is -4 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $LessonSelectionneg4} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the LessonSelection is 8 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $LessonSelection8} | 
                Should throw $ErrorMessage 
            }
        }

        Context "Invalid MenuSelection from LessonSelections" {
            BeforeAll {
                $ErrorMessage = "Invalid menu selection"
            }

            It "should throw when the MenuSelection is 0 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $MenuSelection0} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the MenuSelection is -4 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $MenuSelectionneg4} | 
                Should throw $ErrorMessage 
            }

            It "should throw when the MenuSelection is 8 and the possible LessonSelections are (1, 2, 3)" {
                {Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $MenuSelection8} | 
                Should throw $ErrorMessage 
            }
        }
	    
        



    }

    Describe "Get-CourseSelections" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            $Query = "TRUNCATE TABLE dbo.course_hdr" 
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
                Query=$Query;
            }
            Invoke-Sqlcmd2 @Params

            $Query = "INSERT INTO dbo.course_hdr(course_sid, course_id) 
                      VALUES
                        (4, 'Course A')
                      , (91, 'Course B')
                      , (55, 'Course C')
                      ; 
                     "

            $Params["Query"] = $Query 

            Invoke-Sqlcmd2 @Params 

            $courseSelections = Get-CourseSelections 
            $courseA = $courseSelections | Where-Object {$_.course.courseID -eq 'Course A'}
            $courseB = $courseSelections | Where-Object {$_.course.courseID -eq 'Course B'}
            $courseC = $courseSelections | Where-Object {$_.course.courseID -eq 'Course C'}
        }

	    It "should write 3 course selections to the pipeline" {
            $courseSelections.count | should be 3
	    }

        It "should write objects with property 'Selection'" { 
            "Selection" | Should bein ($courseSelections | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
        }

        It "should write ints as the Selection property" {
            $courseSelections | Select-Object -ExpandProperty Selection | Should beoftype [int]
        }

        It "should write objects with property 'Course'" { 
            "Course" | Should bein ($courseSelections | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
        }

        It "should have courses with a courseID property" { 
            "CourseID" | Should bein ($courseSelections | Select-Object -ExpandProperty Course | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
        }

        It "should have courseIDs with type string" { 
            $courseSelections | Select-Object -ExpandProperty Course | Select-Object -ExpandProperty CourseID | Should beoftype [String]
        }

        It "should have courses with a courseSID property" { 
            "CourseSID" | Should bein ($courseSelections | Select-Object -ExpandProperty Course | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
        }

        It "should have courseIDs with type int" { 
            $courseSelections | Select-Object -ExpandProperty Course | Select-Object -ExpandProperty CourseSID | Should beoftype [int]
        }

        It "should return course A" {
            $courseA | should not be nullorempty
        }

        It "should have course A with CourseSid = 4" {
            $courseA | Select-Object -ExpandProperty Course | Select-Object -ExpandProperty courseSid | Should be 4
        }

        It "should return course B" {
            $courseB | should not be nullorempty
        }

        It "should have course B with CourseSid = 91" {
            $courseB | Select-Object -ExpandProperty Course | Select-Object -ExpandProperty courseSid | Should be 91
        }

        It "should return course C" {
            $courseC | should not be nullorempty
        }

        It "should have course C with CourseSid = 55" {
            $courseC | Select-Object -ExpandProperty Course | Select-Object -ExpandProperty courseSid | Should be 55
        }

        It "should have a selection of 1" {
            1 | Should bein $courseSelections.selection
        }

        It "should have a selection of 2" {
            2 | Should bein $courseSelections.selection
        }

        It "should have a selection of 3" {
            3 | Should bein $courseSelections.selection
        }

        
    }

    Describe "Get-LessonSelections" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            $Query = "TRUNCATE TABLE dbo.lesson_hdr" 
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
                Query=$Query;
            }
            Invoke-Sqlcmd2 @Params

            $Query = "INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id) 
                      VALUES
                        (1, 4, 'C1 Lesson 1')
                      , (2, 17 , 'C2 Lesson 1')
                      , (2, 52 , 'C2 Lesson 2')
                      , (3, 41 , 'C3 Lesson 1')
                      , (3, 29 , 'C3 Lesson 2')
                      , (3, 195 , 'C3 Lesson 3')
                      ; 
                     "

            $Params["Query"] = $Query 

            Invoke-Sqlcmd2 @Params 
        }

        Context "selecting from a course with 1 lesson" {
            BeforeAll {
                $C1Lessons = Get-LessonSelections  -CourseSID 1
            }
         
            It "should write 1 lesson selection to the pipeline" {
                $C1Lessons.Count | Should be 1
            }

            It "should write objects with property 'Selection' to the pipeline" {
                "Selection" | Should bein ($C1Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should write Selection as an int" {
                $C1Lessons | Select-Object -ExpandProperty Selection | Should beoftype [int]
            }

            It "should write objects with property 'Lesson' to the pipeline" {
                "Lesson" | Should bein ($C1Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessons with property lessonID" {
                "LessonID" | Should bein ($C1Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonIDs of type String" {
                $C1Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonID | Should beoftype [String]
            }

            It "should have lessons with property lessonSID" {
                "LessonSID" | Should bein ($C1Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonSIDs of type int" {
                $C1Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonSID | Should beoftype [int]
            }

            It "should have a lesson with the given lesson ID for lesson 1" {
                $C1Lessons | Where-Object {$_.Lesson.LessonID -eq "C1 Lesson 1"} | Should not be $null 
            }

            It "should have a lesson with the given lesson SID for lesson 1" {
                $C1Lessons | Where-Object {$_.Lesson.LessonSID -eq 4} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 1" {
                $C1Lessons | Where-Object {$_.Lesson.LessonID -eq "C1 Lesson 1" -and $_.Lesson.LessonSID -eq 4} | Should not be $null
            }

            It "should have a lesson with a selection of 1" {
                $C1Lessons | Where-Object {$_.Selection -eq 1} | Should not be $null
            }

            It "should not have a lesson with a selection of <1" {
                $C1Lessons | Where-Object {$_.Selection -lt 1} | Should be $null
            }

            It "should not have a lesson with a selection of >1" {
                $C1Lessons | Where-Object {$_.Selection -gt 1} | Should be $null
            }
        }
	    
        Context "selecting from a course with 2 lessons" {
            BeforeAll {
                $C2Lessons = Get-LessonSelections  -CourseSID 2
            }

            It "should write 2 lesson selections to the pipeline" {
                $C2Lessons.Count | Should be 2
            }

            It "should write objects with property 'Selection' to the pipeline" {
                "Selection" | Should bein ($C2Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should write Selection as an int" {
                $C2Lessons | Select-Object -ExpandProperty Selection | Should beoftype [int]
            }

            It "should write objects with property 'Lesson' to the pipeline" {
                "Lesson" | Should bein ($C2Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessons with property lessonID" {
                "LessonID" | Should bein ($C2Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonIDs of type String" {
                $C2Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonID | Should beoftype [String]
            }

            It "should have lessons with property lessonSID" {
                "LessonSID" | Should bein ($C2Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonSIDs of type int" {
                $C2Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonSID | Should beoftype [int]
            }

            It "should have a lesson with the given lesson ID for lesson 1" {
                $C2Lessons | Where-Object {$_.Lesson.LessonID -eq "C2 Lesson 1"} | Should not be $null
            }

            It "should have a lesson with the given lesson SID for lesson 1" {
                $C2Lessons | Where-Object {$_.Lesson.LessonSID -eq 17} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 1" {
                $C2Lessons | Where-Object {$_.Lesson.LessonID -eq "C2 Lesson 1" -and $_.Lesson.LessonSID -eq 17} | Should not be $null
            }

            It "should have a lesson with the given lesson ID for lesson 2" {
                $C2Lessons | Where-Object {$_.Lesson.LessonID -eq "C2 Lesson 2"} | Should not be $null
            }

            It "should have a lesson with the given lesson SID for lesson 2" {
                $C2Lessons | Where-Object {$_.Lesson.LessonSID -eq 52} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 2" {
                $C2Lessons | Where-Object {$_.Lesson.LessonID -eq "C2 Lesson 2" -and $_.Lesson.LessonSID -eq 52} | Should not be $null
            }

            It "should have a lesson with a selection of 1" {
                $C2Lessons | Where-Object {$_.Selection -eq 1} | Should not be $null 
            }

            It "should have a lesson with a selection of 2" {
                $C2Lessons | Where-Object {$_.Selection -eq 2} | Should not be $null 
            }

            It "should not have a lesson with a selection of < 1" {
                $C2Lessons | Where-Object {$_.Selection -lt 1} | Should be $null
            }

            It "should not have a lesson with a selection of > 2" {
                $C2Lessons | Where-Object {$_.Selection -gt 2} | Should be $null
            }
        }
        
        Context "selecting from a course with 3 lessons" {
            BeforeAll {
                $C3Lessons = Get-LessonSelections  -CourseSID 3
                $C3Lesson1 = $C3Lessons | Where-Object {$_.lesson.lessonID -eq 'C3 Lesson 1'}
                $C3Lesson2 = $C3Lessons | Where-Object {$_.lesson.lessonID -eq 'C3 Lesson 2'}
                $C3Lesson3 = $C3Lessons | Where-Object {$_.lesson.lessonID -eq 'C3 Lesson 3'}
            }

            It "should write 3 lesson selection to the pipeline" {
                $C3Lessons.Count | Should be 3
            }

            It "should write objects with property 'Selection' to the pipeline" {
                "Selection" | Should bein ($C3Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should write Selection as an int" {
                $C3Lessons | Select-Object -ExpandProperty Selection | Should beoftype [int]
            }

            It "should write objects with property 'Lesson' to the pipeline" {
                "Lesson" | Should bein ($C3Lessons | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessons with property lessonID" {
                "LessonID" | Should bein ($C3Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonIDs of type String" {
                $C3Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonID | Should beoftype [String]
            }

            It "should have lessons with property lessonSID" {
                "LessonSID" | Should bein ($C3Lessons | Select-Object -ExpandProperty Lesson | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name)
            }

            It "should have lessonSIDs of type int" {
                $C3Lessons | Select-Object -ExpandProperty Lesson | Select-Object -ExpandProperty LessonSID | Should beoftype [int]
            }

            It "should have a lesson with the given lesson ID for lesson 1" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 1"} | Should not be $null
            }

            It "should have a lesson with the given lesson SID for lesson 1" {
                $C3Lessons | Where-Object {$_.Lesson.LessonSID -eq 41} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 1" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 1" -and $_.Lesson.LessonSID -eq 41} | Should not be $null
            }

            It "should have a lesson with the given lesson ID for lesson 2" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 2"} | Should not be $null
            }

            It "should have a lesson with the given lesson SID for lesson 2" {
                $C3Lessons | Where-Object {$_.Lesson.LessonSID -eq 29} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 2" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 2" -and $_.Lesson.LessonSID -eq 29} | Should not be $null
            }

            It "should have a lesson with the given lesson ID for lesson 3" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 3"} | Should not be $null
            }

            It "should have a lesson with the given lesson SID for lesson 3" {
                $C3Lessons | Where-Object {$_.Lesson.LessonSID -eq 195} | Should not be $null 
            }

            It "should have a lesson with the given lesson ID and lesson SID for lesson 3" {
                $C3Lessons | Where-Object {$_.Lesson.LessonID -eq "C3 Lesson 3" -and $_.Lesson.LessonSID -eq 195} | Should not be $null
            }

            It "should have a lesson with a selection of 1" {
                $C3Lessons | Where-Object {$_.Selection -eq 1} | Should not be $null 
            }

            It "should have a lesson with a selection of 2" {
                $C3Lessons | Where-Object {$_.Selection -eq 2} | Should not be $null 
            }

            It "should have a lesson with a selection of 3" {
                $C3Lessons | Where-Object {$_.Selection -eq 3} | Should not be $null 
            }

            It "should not have a lesson with a selection of < 1" {
                $C3Lessons | Where-Object {$_.Selection -lt 1} | Should be $null
            }

            It "should not have a lesson with a selection of > 3" {
                $C3Lessons | Where-Object {$_.Selection -gt 3} | Should be $null
            }
        }
    }


}
