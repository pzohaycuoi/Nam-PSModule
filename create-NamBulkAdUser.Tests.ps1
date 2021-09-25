BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "create-NamBulkAdUser" {
    It "Returns expected output" {
        create-NamBulkAdUser | Should -Be "YOUR_EXPECTED_VALUE"
    }
}
