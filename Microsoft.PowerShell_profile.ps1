# General variables
$homePath = (Join-Path $Env:HomeDrive $Env:HomePath)
$pathToPortableGit = (Join-Path $homePath "\AppData\Local\GitHub\PortableGit_c2ba306e536fdf878271f7fe636a147ff37326ad")

# Add Git executables to the mix.
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $pathToPortableGit "\bin") + ";", "Process")

# Setup Home so that Git doesn't freak out.
[System.Environment]::SetEnvironmentVariable("HOME", $homePath, "Process")

# Output verbose git status?
$git_status_verbose = $true

# Setup command aliases
set-alias s (Join-Path $Env:HomeDrive "\Program Files\Sublime Text 3\sublime_text.exe")
set-alias ws (Join-Path $Env:HomeDrive "\Program Files (x86)\JetBrains\WebStorm 10.0.4\bin\WebStorm.exe")

$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$UserType = "User"
$CurrentUser.Groups | foreach { 
    if ($_.value -eq "S-1-5-32-544") {
        $UserType = "Admin"
    } 
}

function prompt {
    $cwd = $(get-location)
    if($UserType -eq "Admin") {
         $host.UI.RawUI.WindowTitle = "" + $cwd + " : *Administrator*"
         $host.UI.RawUI.ForegroundColor = "white"
     }
     else {
         $host.ui.rawui.WindowTitle = $cwd
     }

    Write-Host("")

    $symbolicref = git symbolic-ref HEAD
    $has_changes = $false
    $git_branch = $NULL
    if($symbolicref -ne $NULL) {
        $git_branch = $symbolicref.substring($symbolicref.LastIndexOf("/") +1 )
        $differences = (git diff-index --name-status HEAD)
        if($differences -ne $NULL) {
            $git_update_count = [regex]::matches($differences, "M`t").count
            $git_create_count = [regex]::matches($differences, "A`t").count
            $git_delete_count = [regex]::matches($differences, "D`t").count
            $has_changes = ($git_create_count -gt 0) -or ($git_update_count -gt 0) -or ($git_delete_count -gt 0)
        }
    }

    Write-Host ($env:UserName) -nonewline -foregroundcolor DarkGreen
    Write-Host (" at ") -nonewline -foregroundcolor Gray
    Write-Host ($env:COMPUTERNAME) -nonewline -foregroundcolor DarkCyan
    Write-Host (" in ") -nonewline -foregroundcolor Gray
    Write-Host ($cwd) -nonewline -foregroundcolor DarkGreen

    if ($git_branch -ne $NULL) {
        Write-Host (" on ") -nonewline -foregroundcolor Gray
        Write-Host ($git_branch) -nonewline -foregroundcolor  Cyan
        Write-Host(" [") -nonewline -foregroundcolor Gray
        if ($has_changes -eq $true) {
            Write-Host("!") -nonewline -foregroundcolor Yellow
        }
        Write-Host("$") -nonewline -foregroundcolor Yellow
        Write-Host($has_changes +" "+ $git_status_verbose)
        if (($has_changes -eq $true) -and ($git_status_verbose -eq $true)) {
            Write-Host(" - a:" + $git_create_count + ", m:" + $git_update_count + ", r:" + $git_remove_count) -nonewline -foregroundcolor White
        }
        Write-Host("]") -nonewline -foregroundcolor Gray
    }

    Write-Host("")

    $prompt = "PS>"
    if ($git_branch -ne $NULL) {
        $prompt = "$"
    }
    Write-Host($prompt) -nonewline -foregroundcolor DarkGray

    return " "
 }