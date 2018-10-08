Set-PSReadLineOption -HistoryNoDuplicates -ShowToolTips

function Get-ParentProcName {
    $parentProcessId = (Get-WmiObject Win32_Process -Filter "ProcessId=$PID").ParentProcessId
    # avoid second WMI query
    (Get-Process -Id $parentProcessId).Name
}

# Workaround for certain domain policies of certain company
if (($ExecutionContext.SessionState.LanguageMode -eq
        [System.Management.Automation.PSLanguageMode]::ConstrainedLanguage) -and
        -not ((Get-ParentProcName) -eq 'powershell')
     ) {
    Write-Host "Running in ConstrainedLanguage mode. Trying to drop __PSLockdownPolicy and spawn child shell in FullLanguage mode"
    if (setx /M __PSLockdownPolicy 0) {
        $Env:__PSLockdownPolicy = 0
        powershell
    } else {
        Write-Host "Didn't work... Sorry."
    }
}

function New-SymbolicLink {
    param(
        [string]$Path,
        [string]$Value
    )
    New-Item -Type SymbolicLink -Path $Path -Value $Value
}
New-Alias mklink New-SymbolicLink | Out-Null

function Enter-RemoteShell {
    param(
        $ComputerName,
        $Credential = 'Administrator'
    )
    $sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
    Enter-PSSession -ComputerName $ComputerName -UseSSL `
        -SessionOption $sessionOption -Credential $Credential
}

# http://serverfault.com/questions/95431
function Test-ElevatedSession {
    try {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole(
                [Security.Principal.WindowsBuiltinRole]::Administrator)
    } catch {
        $false
    }
}

$PSElevatedSession = (Test-ElevatedSession)

function prompt {

    function Get-FormattedPath {
        $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
        switch -wildcard ($curPath.ToLower()) {
            { $_.StartsWith($Home.ToLower()) } {
                "~" + $curPath.SubString($Home.Length)
                break
            }
#            { $_.StartsWith($Env:SystemDrive.ToLower()) } {
#                $curPath.SubString($Env:SystemDrive.Length)
#                break
#            }
            default { $curPath; break }
        }
    }

    $origLastExitCode = $LastExitCode
    if ($PSElevatedSession) {
        $pchar  = '#'
        $color = 'Red'
    } else {
        $pchar  = '%'
        $color = 'Yellow'
    }

    Write-Host "<" -NoNewline -ForegroundColor $color
    Write-Host "$env:USERNAME@$env:COMPUTERNAME" -NoNewline -ForegroundColor Green
    Write-Host ":" -NoNewline
    Write-Host (Get-FormattedPath) -NoNewline -ForegroundColor Yellow
    Write-Host ">" -NoNewline -ForegroundColor $color

    $LastExitCode = $origLastExitCode
    "`nPS $pchar "
}
