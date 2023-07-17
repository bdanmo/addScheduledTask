# Remediation Code
$User = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$UserName = $User.Split('\')[1]

$TaskName = "CopyFilesTask"
$ScriptPath = "C:\Temp\CopyFiles.ps1"

$ScriptContent = @"
`$MyDocumentsPath = '\\hmfsvr.hmfexpress.local\home\$UserName\My Documents'
`$DocumentsPath = '\\hmfsvr.hmfexpress.local\home\$UserName\Documents'
`$Destination = 'C:\Users\$UserName\Documents'

if (Test-Path -Path `$MyDocumentsPath) {
    `$Source = `$MyDocumentsPath
} else {
    `$Source = `$DocumentsPath
}

`$SourceFiles = Get-ChildItem -Path `$Source -File -Recurse
`$DestinationFiles = Get-ChildItem -Path `$Destination -File -Recurse

foreach (`$File in `$SourceFiles) {
    `$RelativePath = `$File.FullName.Substring(`$Source.length)
    `$TargetPath = Join-Path -Path `$Destination -ChildPath `$RelativePath

    if (-not (Test-Path -Path `$TargetPath)) {
        `$TargetDir = Split-Path -Path `$TargetPath -Parent
        if (-not (Test-Path -Path `$TargetDir)) {
            New-Item -ItemType Directory -Path `$TargetDir | Out-Null
        }
        Copy-Item -Path `$File.FullName -Destination `$TargetPath
    }
}
"@

# Write the script content to a file
Set-Content -Path $ScriptPath -Value $ScriptContent

# Delete task if it already exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create new scheduled task
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-WindowStyle Hidden -File `"$ScriptPath`""
$Principal = New-ScheduledTaskPrincipal -UserID "$UserName" -LogonType Interactive
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)

# Set an expiration date for the task
$Trigger.EndBoundary = (Get-Date).AddDays(30).ToString('s')

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal