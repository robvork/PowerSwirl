Get-Module -Name "PowerSwirl" -All | Remove-Module -Force 
Import-Module "PowerSwirl" -Force -ErrorAction Stop 

InModuleScope PowerSwirl {

    Describe Get-XMLElement {
        BeforeAll {
                $xmlObject = [xml] "<outer><inner>data</inner></outer>"
        }

        Context 'Top-level object' {
            BeforeAll {
                $validElement = "outer"
                $invalidElement = "outerSpace"
            }

            It 'should not throw when the top level object has the specified name' {
                {Get-XMLElement -xml $xmlObject -element $validElement} | should not throw
            }

            It 'should return something when the top level object has the specified name' {
                $res = Get-XMLElement -xml $xmlObject -element $validElement 
                if(-not $res)
                {
                    throw 
                }
            }

            It 'should return the specified contents when the top level object has the specified name ' {
                $res = Get-XMLElement -xml $xmlObject -element $validElement 
                if(($res | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name) -notcontains "inner")
                {
                    throw
                }
            }

            It 'throws an error when the top level object does not have the specified name' {
                {Get-XMLElement -xml $xmlObject -element $invalidElement} | should throw
            }
        }

        Context 'Child of top-level object' {
            BeforeAll {
                $xmlTopObject = $xmlObject.outer 
                $validChild = "inner"
                $invalidChild = "innerSpace"
            }

            It "should not throw when a valid child of the top-level object is used" {
                {Get-XMLElement -xml $xmlTopObject -element $validChild} | should not throw
            }

            It 'should return something when a valid child of the top-level object is used' {
                $res = Get-XMLElement -xml $xmlTopObject -element $validChild 
                if(-not $res)
                {
                    throw 
                }
            }

            It 'should return the right value when a valid child of the top-level object is use' {
                Get-XMLElement -xml $xmlTopObject -element $validChild |
                    Should be "data"
            }

            It 'should throw when an invalid child is specified' {
                {Get-XMLElement -xml $xmlTopObject -element $invalidChild} | 
                    should throw 
            }

        }
    }

    Describe Test-HasExactlyOneElement {
        BeforeAll {
            $XMLObject = [xml] "<outer>
                                    <inner0>
                                    </inner0>

                                    <inner1>
                                        <a>1</a>
                                    </inner1>
                                    
                                    <inner2>
                                        <a>1</a>
                                        <a>2</a>
                                    </inner2>
                                    
                                    <inner3>
                                        <a>1</a>
                                        <a>2</a>
                                        <a>3</a>
                                    </inner3>
                                </outer>
                               "
         }

         It "should throw when an attribute with 0 elements is selected" {
                {Test-HasExactlyOneElement -xml $xmlObject.outer.inner0 -element "a"} | should throw
         }

         It "should not throw when an attribute with 1 elements is selected" {
                {Test-HasExactlyOneElement -xml $xmlObject.outer.inner1 -element "a"} | should not throw
         }

         It "should throw when an attribute with 2 elements is selected" {
                {Test-HasExactlyOneElement -xml $xmlObject.outer.inner2 -element "a"} | should throw
         }

         It "should throw when an attribute with 3 elements is selected" {
                {Test-HasExactlyOneElement -xml $xmlObject.outer.inner3 -element "a"} | should throw
         }
    }

    Describe Test-HasOneOrMoreElement {
        BeforeAll {
            $XMLObject = [xml] "<outer>
                                    <inner0>
                                    </inner0>

                                    <inner1>
                                        <a>1</a>
                                    </inner1>
                                    
                                    <inner2>
                                        <a>1</a>
                                        <a>2</a>
                                    </inner2>
                                    
                                    <inner3>
                                        <a>1</a>
                                        <a>2</a>
                                        <a>3</a>
                                    </inner3>
                                </outer>
                               "
         }

         It "should throw when an attribute with 0 elements is selected" {
                {Test-HasOneOrMoreElement -xml $xmlObject.outer.inner0 -element "a"} | should throw
         }

         It "should not throw when an attribute with 1 elements is selected" {
                {Test-HasOneOrMoreElement -xml $xmlObject.outer.inner1 -element "a"} | should not throw
         }

         It "should not throw when an attribute with 2 elements is selected" {
                {Test-HasOneOrMoreElement -xml $xmlObject.outer.inner2 -element "a"} | should not throw
         }

         It "should not throw when an attribute with 3 elements is selected" {
                {Test-HasOneOrMoreElement -xml $xmlObject.outer.inner3 -element "a"} | should not throw
         }
    }

    Describe Test-HasOnlyElementsInList {
        BeforeAll {
            $XMLObject = [xml] "<outer>
                                    <inner1>
                                        <a>1</a>
                                    </inner1>
                                    
                                    <inner2>
                                        <x>1</x>
                                        <y>2</y>
                                    </inner2>
                                    
                                    <inner3>
                                        <x>1</x>
                                        <y>2</y>
                                        <z>3</z>
                                    </inner3>
                                </outer>
                               "
         }

         It "should not throw on an element with attribute 'a' when list = ('a')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner1 -elementList "a"} |
                should not throw
         }

         It "should not throw on an element with attribute 'a' when list = ('a', 'b')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner1 -elementList "a","b"} |
                should not throw
         }

         It "should throw on an element with attribute 'a' when list = ('b')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner1 -elementList "b"} |
                should throw
         }

         It "should not throw on an element with attributes 'x' and 'y' when list = ('x', 'y')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner2 -elementList "x","y"} |
                should not throw
         }

         It "should not throw on an element with attributes 'x' and 'y' when list = ('x', 'y', 'z')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner2 -elementList "x","y","z"} |
                should not throw
         }

         It "should throw on an element with attributes 'x' and 'y' when list = ('x')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner2 -elementList "x"} |
                should throw
         }

         It "should throw on an element with attributes 'x' and 'y' when list = ('a', 'b')" {
            {Test-HasOnlyElementsInList -xml $XMLObject.outer.inner2 -elementList "a","b"} |
                should throw
         }
    }

    Describe ConvertFrom-LessonMarkup  {
        It "step through" -Skip {
            $lessonPath = "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Database\Data\Lessons\intro_powerswirl_test_lesson.xml"
            $lessonString = Get-Content $lessonPath -raw
            ConvertFrom-LessonMarkup -LessonString $lessonString 
        }
    }

}