param
(
[String] $TestServerInstance = "ASPIRING\SQL16"
,
[String] $TestDatabase = "PowerSwirl_test"
)

Import-Module "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl" -Force 

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

    Describe "Read-MenuSelection" {
	    It "should..." -Pending {

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
                $CourseCount | Should not benullorempty
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
                $PreSelection | Should not benullorempty
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
                $CourseSelectionStrings | Should not benullorempty
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
                $CourseCount | Should not benullorempty
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
                $PreSelection | Should not benullorempty
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
                $CourseSelectionStrings | Should not benullorempty
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
                $CourseCount | Should not benullorempty
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
                $PreSelection | Should not benullorempty
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
                $CourseSelectionStrings | Should not benullorempty
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

    Describe "Write-LessonSelections" {
	    It "should..." {

	    }
    }

    Describe "Test-PSwirlCourse" {
	    It "should..." {

	    }
    }

    Describe "Test-PSwirlLesson" {
	    It "should..." {

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
	    
        



    }

    Describe "Get-CourseSelections" {
	    It "should..." {

	    }
    }

    Describe "Get-LessonSelections" {
	    It "should..." {

	    }
    }


}
