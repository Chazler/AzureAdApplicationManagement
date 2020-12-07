#Invoke-Pester -Output Detailed .\Remove-AadApplication.Tests.ps1

BeforeAll { 
    Remove-Module ManageAadApplications
    Import-Module .\ManageAadApplications.psm1
}

Describe 'Remove-AadApplication' {
    Context "Remove-AadApplication" {
        BeforeEach { 
            $app1 = New-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" -IdentifierUris "https://AzureAdApplicationManagementTestApp1"
            $sp1 = Get-AzADApplication -ObjectId $app1.ObjectId | New-AzADServicePrincipal
            Start-Sleep 15
        }
        
        It "Given empty objectid should throw error" {
            { Remove-AadApplication "" -InformationAction Continue } | Should -Throw "Cannot validate argument on parameter 'ObjectId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        It "Given invalid objectid should show information message" {
            Remove-AadApplication -ObjectId "foo" -InformationAction Continue
        }

        It "Given non existing objectid with fail switch should throw error" {
            { Remove-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec -FailIfNotFound -InformationAction Continue } | Should -Throw "The application with ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec cannot be found. Check if the application exists and if you search with the right values."
        }

        It "Given non existing objectid without fail switch should continue without error" {
            $result = Remove-AadApplication -ObjectId 88a82126-c223-4f2e-b997-2fe44d9131ec -InformationAction Continue
            
            $result | Should -BeNullOrEmpty
        }

        It "Given only existing objectid should remove the application" {
            $result = Remove-AadApplication -ObjectId $app1.ObjectId -InformationAction Continue

            $result | Should -BeNullOrEmpty
        }
        
        AfterEach { 
            Get-AzADApplication -DisplayName "AzureAdApplicationManagementTestApp1" | Remove-AzADApplication -Force
        }
    }
}
