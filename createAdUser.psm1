function Import-NamCsv {
  param (
    [Parameter(Mandatory = $true)][string]$Path    
  )
  
}

function Create-NamBulkAdUser {
  <#
  
  #>
  [CmdletBinding()]
  param (
    # Basic account information #
    [string]$FirstName,
    [string]$LastName,
    [Parameter(Mandatory = $true)][string]$FullName,
    [Parameter(Mandatory = $true)][string]$UPN,
    [Parameter(Mandatory = $true)][string]$SamAccountName,
    # OU path and security group will get from another script
    [Parameter(Mandatory = $true)][string]$OU,
    [string]$SecurityGroup,
    
    # Account's option
    #[string]$EmploymentType,
    #[string]$EndOfContract,
    # Need more information on this one

    # Organization information #
    [string]$DisplayName,
    [string]$JobTitle,
    [string]$Department,
    [string]$Company,
    [string]$Manager,

    # Office's location information #
    [string]$Address,
    [string]$Location,
    [string]$Region,
    [string]$PostalCode,
    [string]$Country
  )

  # Check if ad user is exist yet using user principal name
  $Password = "Welcome10"
  $chkUsrExist = Get-ADUser -Identity $SamAccountName
  if ($chkUsrExist -eq $null) {
    # Create AD user with basic account information
    $scrptBlkCreateAdUsr = { New-ADUser `
        -Name "$LastName, $FirstName" `
        -DisplayName $DisplayName `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UPN `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -Path $OU `
        -AccountPassword (convertto-securestring $Password -AsPlainText -Force) }
    # Start job and wait for it to finish
    $jobCreateUsr = Start-Job -ScriptBlock $scrptBlkCreateAdUsr
    $jobCreateUsr | Wait-Job | Out-Null
    # Re-check if user creation suceed or not
    $reCheck = 0
    do {
      $chkUsrExist = Get-ADUser -Identity $SamAccountName
      if ($chkUsrExist -eq $null) {
        Write-Information "User is not exist - retry checking after 2 seconds"
        Start-Sleep -Seconds 2
      }
      else {
        Write-Information "User $SamAccountName creation succeed"
      }
      $reCheck += 1
    } until ($chkUsrExist -ne $null -and $reCheck -eq 5)
    
  }
  else {
    Write-Information "User $SamAccountName is already exist"
    Continue
  }


  # Create user
  # Output to log file
  # Check if user creation is success or not
  # Update user information - maybe it will be non mandatory information
  # Check if update is success or not
  # Output result to CSV file

  # Maybe just get rid of the log and csv file
  # Instead using the verbose and then allow all that information to pipe into variable with multiple properties?
}

function Out-NamCsv {
  param (
    [Parameter(Mandatory = $true)][string]$Path
  )
  
}