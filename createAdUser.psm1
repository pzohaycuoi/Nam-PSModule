function Create-NamBulkAdUser {
  <#
  
  #>
  [CmdletBinding()]
  param (

    # Account information
    [string]$FirstName,
    [string]$LastName,
    [Parameter(Mandatory=$true)][string]$FullName,
    [Parameter(Mandatory=$true)][string]$UPN,
    [Parameter(Mandatory=$true)][string]$SamAccountName,
    
    # Account's option
    #[string]$EmploymentType,
    #[string]$EndOfContract,
    # Need more information on this one

    # Organization information
    [string]$DisplayName,
    [string]$JobTitle,
    [string]$Department,
    [string]$Company,
    [string]$Manager,

    # Office's location information
    [string]$Address,
    [string]$Location,
    [string]$Region,
    [string]$PostalCode,
    [string]$Country

  )

  # Create log file
  # Create csv file
  # Check if ad user is exist yet using user principal name
  # Create user
  # Output to log file
  # Check if user creation is success or not
  # Update user information - maybe it will be non mandatory information
  # Check if update is success or not
  # Output result to CSV file

  # Maybe just get rid of the log and csv file
  # Instead using the verbose and then allow all that information to pipe into variable with multiple properties?
}