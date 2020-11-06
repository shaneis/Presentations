<#  Save yourself from yourself... #>
throw "Don't run the entire thing!"





































<#
    Feel Validated with dbachecks
#>























<#
    How to you describe dbachecks?
#>

<#
    Splatting, it helps
#>

Get-Help -Name Invoke-DbcCheck -Parameter Value | Select-Object -ExpandProperty Description



$helpParams = @{
    Name = 'Invoke-DbcCheck'
    Parameter = 'Value'
}

(Get-Help @helpParams).Description










































<#
    Where do we start?
#>


    <#  PowerShell #>

    <#  Pester #>





















<#
    PowerShell
#>


    $PSVersionTable






















<#
    Pester
#>


    <#  PowerShell Module ported to PowerShell #>

    <#  Actual Results vs. Expected Results #>

    <#  Green is good, Red is bad #>

    <#  Continuously getting worked on #>






















<#
    Making a Pester test
#>


    <#  We need a 'Describe' block... #>
    Describe 'Pestering' {

        <# ... and an 'It' block (note the bracket) #>
        It 'should fail when appropriate' {
            1 + 1 | Should -Be 'Peanuts'
        }

        It 'should pass correctly' {
            1 + 1 | Should -Be 2
        }

    }














    <#  Pester, through PowerShell, can test more than just values #>

    <#  Say we want to check if our demo instance is running. #>
    Get-DbaService -InstanceName SQLDEV2K14 -Type Engine

    Describe 'SQL Server Service' {
        It 'should be running' {
            $DemoInstance = Get-DbaService -InstanceName SQLDEV2K14 -Type Engine

            $DemoInstance.State | Should -Be 'Running'
        }
    }

    Describe 'dbachecks Module Installed' {
        It 'should be installed so we can import it' {
            $InstalledModule = Get-Module -ListAvailable -Name dbachecks

            $InstalledModule | Should -Not -BeNullOrEmpty
        }
    }

    Describe 'dbachecks Module Imported' {
        It 'should be imported cause we need it!' {
            $ImportedModule = Get-Module -Name dbachecks

            $ImportedModule | Should -Not -BeNullOrEmpty
        }
    }


















<#
    dbachecks
#>


    <#  What is dbachecks? #>
    
    <#  Why you should be using it? #>


        <# 
            Made up of 3 modules (and itself)
                #  dbatools
                #  Pester
                #  PSFramework
        #>


        <#  How do you know? #>

        <#  How can you prove it? #>
















<#
    3 Actions to aid Adopters
#>


    <#  Collaboration #>

    <#  Discovery #>

    <#  Configuration #>






















<#
    Collaboration
#>


    <#  Combining all the checks at their disposal #>


    <#  How many checks does it have? #>
    $stringParams = @(
        (Get-DbcCheck).Count,
        (Get-Module -Name dbachecks).Version
    )
    'dbachecks has {0} different checks as of version {1}' -f $stringParams


    <#  I do not want to run > 100 checks at this time, thank you very much...  ~ 10 minutes on my machine #>
    Invoke-DbcCheck -SqlInstance localhost\SQLDEV2K14 -AllChecks


    <#  Why not? (also don't do this!) #>
    Get-DbcCheck -Pattern TestLast |
        Format-Table UniqueTag, Description -AutoSize -Wrap















<#
    Discovery
#>


    <#  What about a subset of tests? #>

    <#  What about only 1? #>


    Get-DbcCheck |
        Format-Table -Property Group, Type, UniqueTag, AllTags


    Get-DbcCheck |
        Group-Object -Property Group -NoElement |
        Sort-Object -Property Count -Descending


    Get-DbcCheck |
        Group-Object -Property UniqueTag -NoElement |
        Sort-Object -Property Count


    Get-DbcCheck -Pattern Service

    $serviceAccountParams = @{
        SqlInstance = 'localhost\SQLDEV2K14'
        Check = 'SqlEngineServiceAccount'
    }
    Invoke-DbcCheck @serviceAccountParams













<#
    Configuration
#>


    <#  Do we hard-code values in Stored Procedures? #>

    <#  Main difference when combining checks were name. #>

    <#  Can we specify these at runtime? #>

    <#  Do we have to specify these all the time? #>



    Get-DbcConfig |
        Format-Table -Property Name, Description -Wrap

    Get-DbcConfig -Name policy.pageverify |
        Format-Table -Property Name, Value, Description -Wrap


    <#  Specified at runtime #>
    $pageVerifyParams = @{
        SqlInstance = 'localhost\SQLDEV2K14'
        Check = 'PageVerify'
    }
    Invoke-DbcCheck @pageVerifyParams


    <#  Save off the config #>
    Export-DbcConfig -Path C:\Users\Shane\Downloads\PreCustomisedConfig.json


    <#  Do we need to specify these? #>
    Get-DbcConfig -Name app.sqlinstance

    Set-DbcConfig -Name app.sqlinstance -Value 'localhost\SQLDEV2K14'


    <#  Do we need to specify it at runtime now? #>
    Invoke-DbcCheck -Check PageVerify


    <#  Reset #>
    Import-DbcConfig -Path C:\Users\Shane\Downloads\PreCustomisedConfig.json


    <#  Temporary settings #>

    Set-DbcConfig -Name app.sqlinstance -Value DoesNotExist -Temporary













<#
    Sharing Results
#>


    <#  Automate it. #>

    <#  Email. #>

    <#  PowerBI #>

    <#  A.N.Other #>




        <#  Automate it #>

            <#  SQL Agent Job #>
            
                <#  https://dbatools.io/agent/ #>

                    <#  Create a SqlCredential #>

                    <#  Create a Proxy #>

                    <#  Use CmdExec #>

                    <#  Have the code in a file. #>


        <#  Email it #>

            <#  Send-MailMessage (depreciated but still used and in PowerShell 7) #>


        <#  Power BI #>



            <#  How do we create the json file? #>
            $pageVerifyParams = @{
                SqlInstance = 'localhost\SQLDEV2K14'
                Check = 'PageVerify'
            }
            Invoke-DbcCheck @pageVerifyParams -outvariable Test

            <#  Our results... #>
            $Test

            Invoke-DbcCheck @pageVerifyParams -PassThru -outvariable Test2

            <#  Our results??? #>
            $Test2

            <#  Tip - Create a file per check (Claudio Silva) #>

                <#  https://claudioessilva.eu/2018/02/22/dbachecks-a-different-approach-for-an-in-progress-and-incremental-validation/ #>

                foreach ($check in 'AutoClose', 'AutoShrink', 'PageVerify') {
                    Invoke-DbcCheck -Check $Check -SqlInstance localhost\SQLDEV2K14 -Passthru -Show Summary |
                        Update-DbcPowerBiDataSource -Path C:\Users\Shane\Desktop\In_Progress\Presentations\FeelValidatedWithdbachecks
                }

                Start-DbcPowerBi

        <#  A.N.Other #>

                <#  Rob Sewell has a post about this & we have a new command! #>

                    <#  https://sqldbawithabeard.com/2018/05/23/dbachecks-save-the-results-to-a-database-for-historical-reporting/ #>


<#
    Make it Personal
#>


    <#  Know what you're testing. #>

    <#  Write the Pester test #>

    <#  Add it to the config. #>

    <#  Profit. #>

    <# Let's check out our SQL Agent Jobs #>
    Get-DbaAgentJob -SqlInstance localhost\SQLDEV2K14 |
        Format-Table -Wrap

    <# Now what properties do we have? #>
    Get-DbaAgentJob -SqlInstance localhost\SQLDEV2K14 |
        Get-Member -MemberType *Property

    <# So we can grab the name of the job and if we have an operator set up to email #>
    Get-DbaAgentJob -SqlInstance localhost\SQLDEV2K14 |
        Select-Object -Property Name, OperatorToEmail


    <#
        We need
            # Tags
            # Unique "singular" (doesn't end in s) 
            # Context ends in $PSItem
            # Use values, not true/false
            # Save this off to a separate file e.g. "JobEmailOperator.Tests.ps1" 
    #>
    Describe 'Job Email Operators' -Tags "JobEmailOperator" {
        (Get-DbaAgentJob -SqlInstance localhost\SQLDEV2K14).ForEach{
            Context "Checking email operator on $psitem" {
                $expectedOperator = 'test_operator'

                It "should match the expected operator" {
                    $psitem.OperatorToEmail | Should -Be $expectedOperator
                }
            }
        }
    }



    Get-DbcConfigValue -Name app.checkrepos

    $setConfigCheckRepos = @{
        Name = 'app.checkrepos'
        Value = 'C:\Users\Shane\Desktop\In_Progress\Presentations\FeelValidatedWithdbachecks'
        Append = $true
        Temporary = $true
    }
    Set-DbcConfig @setConfigCheckRepos

    $jobOperatorCheck = @{
        SqlInstance = 'localhost\SQLDEV2K14'
        Check = 'JobEmailOperator'
    }
    Invoke-DbcCheck @jobOperatorCheck -Show Summary

    Invoke-DbcCheck @jobOperatorCheck -Passthru -Show Summary |
        Update-DbcPowerBiDataSource -Path C:\Users\Shane\Desktop\In_Progress\Presentations\FeelValidatedWithdbachecks
    

    Reset-DbcConfig | Out-Null
    



    <#  Add your own #>

        <#  https://github.com/sqlcollaborative/dbachecks #>


<#
    Writing to a database
#>

    <# Let's capture some results #>
    $autoCloseParams = @{
        SqlInstance = 'localhost\SQLDEV2K14'
        Check = 'AutoClose'
        Passthru = $true
        Show = 'None'
    }
    $AutoCloseResults = Invoke-DbcCheck @autoCloseParams

    <# dbachecks has a command where we convert it into a datatable format #>
    $autoCloseConvertParams = @{
        TestResults = $AutoCloseResults
        Label = (Get-Date -Format FileDateTime)
    }
    Convert-DbcResult @autoCloseConvertParams -OutVariable ConvertedAutoCloseResults

    <# Now we can write this to a table in our database #>
    $autoCloseDBParams = @{
        SqlInstance = 'localhost\SQLDEV2K14'
        Database = 'LocalTesting'
        InputObject = $ConvertedAutoCloseResults
        Truncate = $true
    }
    Write-DbcTable @autoCloseDBParams

    <# And, lets show our results from the database #>
    Start-DbcPowerBi -FromDatabase



    Invoke-DbcCheck -Check 'PageVerify', 'AutoClose' -SqlInstance localhost\SQLDEV2K14 -Show None|
        Convert-DbcResult -Label TestTwoChecks |
        Write-DbcTable -SqlInstance localhost\SQLDEV2K14 -Database LocalTesting -Truncate


















<#
    Questions?
#>
