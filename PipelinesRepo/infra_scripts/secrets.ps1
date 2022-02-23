$ErrorActionPreference = "Stop"

$vault_name = $args[0]
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Output "`nRunning secrets script ....."
function GetExpectedListOfSecrets {
    $expected_secrets_response = Get-Content "$scriptPath/secrets.json" | out-string | ConvertFrom-Json
    return $expected_secrets_response
}

function GetListOfCurrentSecrets {
    param($vaultName)
    $current_secrets_response = az keyvault secret list --vault-name "$vaultName"
    $current_secrets_object = ConvertFrom-Json -InputObject "$current_secrets_response"
    return $current_secrets_object
}

function UpdateAndDeleteCurrentSecrets {
    $current_secrets | ForEach-Object {
        $secret_name = $_.name
        $secret_id = $_.id
        $expected_secret = $expected_secrets | Where-Object name -EQ $secret_name
        if ( $null -eq $expected_secret ) {
            Write-Output "`nDeleting following secret from keyvault: " $secret_name
            az keyvault secret delete --id $secret_id
        }
        else {
            Write-Output "`nUpdating value of secret: " $secret_name
            $secret_new_value = GetSecretValue $expected_secret
            az keyvault secret set --name $secret_name --vault-name $vault_name --value $secret_new_value
            Write-Host "##vso[task.setvariable variable=$secret_name; isOutput=true]$secret_new_value"
        }
    }
}

function CreateNewSecrets {
    $expected_secrets | ForEach-Object {
        $secret_name = $_.name
        $secret_value = GetSecretValue $_
        $current_secret = $current_secrets | Where-Object name -EQ $secret_name
        if ( $null -eq $current_secret ) {
            Write-Output "`nCreating secret in keyvault: " $secret_name
            Try {
                Invoke-Command -ScriptBlock "az keyvault secret set --name $secret_name --vault-name $vault_name --value $secret_value" -ErrorAction Stop 
            }
            Catch {
                Write-Output "`nRecovering secret in keyvault:" $secret_name
                az keyvault secret recover --name $secret_name --vault-name $vault_name
                Start-Sleep -Seconds 15
                az keyvault secret set --name $secret_name --vault-name $vault_name --value $secret_value
            }
            Write-Host "##vso[task.setvariable variable=$secret_name; isOutput=true]$secret_value"
        }
    }
}

function GetSecretValue {
    param($expected_secret)
    if ( "password" -eq $expected_secret.type ) { 
        $minLength = 12 ## characters
        $maxLength = 15 ## characters
        $length = Get-Random -Minimum $minLength -Maximum $maxLength
        $nonAlphaChars = 3
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
        return $password
    } else {
        return $expected_secret.value
    }
    
}

function Main () {
    $expected_secrets = GetExpectedListOfSecrets
    Write-Output "`nExpected Secrets file read:" $expected_secrets
    Write-Output "`n___________________________"
    $current_secrets = GetListOfCurrentSecrets $vault_name
    Write-Output "`nCurrent Secrets in vault:" $current_secrets
    Write-Output "`n___________________________"

    UpdateAndDeleteCurrentSecrets
    CreateNewSecrets
}

Main
