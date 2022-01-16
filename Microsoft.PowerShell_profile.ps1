# Profile
Clear-Host;
Write-Host "Welcome to" -NoNewLine;
Write-Host " Pish v1.4" -ForegroundColor Green;
$ConfigLoc = "C:\Users\$($env:username)\Documents\WindowsPowerShell\config.json";
$PkgLoc = "C:\Users\$($env:username)\Documents\WindowsPowerShell\packages";
$ConfigJson = Get-Content $ConfigLoc | ConvertFrom-Json;
`

function Get-PishPath {
    $arg = "";
    if ($null -ne $args[0]) {
        $arg = $args[0];
    }
    $loc = $(get-location).Path;
    $loc = $loc -replace "C:\\Users\\$($env:username)", "~";
    $loc = $loc -replace "\\", "/";
    $loc = $loc -replace "C:/", "/";
    $loc = $loc -replace "^([a-zA-Z]):/", "/`$1/";
    $locarr = $loc.Split("/");
    $newloc = @("");
    $index = 0;
    foreach ($item in $locarr) {
        if ($item -ne "") {
            if ($index -eq $locarr.length - 1) {
                $newloc += $item.ToLower();
            }
            else {
                if ($arg -ne "-Expand") {
                    $newloc += $item.Substring(0, 1).ToLower();
                }
                else {
                    $newloc += $item.ToLower();
                }
            }
        }
        # $newloc[$index] = $item.ToString().Substring(0, 1);
        # echo "Setting $$newloc[($index)] to `"$item`"";
        # # Write-Host "/$($item)." -ForegroundColor red -NoNewLine;
        # # Write-Host "$(locarr[2])"
        $index += 1;
    }
    $loc = $newloc -join "/";
    return $loc;
}

$chars = @{
    "check" = [regex]::Unescape("\u2713"); # ✔
    "cross" = [regex]::Unescape("\u2717"); # ✗
}

if ($null -ne $ConfigJson) {
    Write-Host "$($chars.check) Loaded configuration successfully." -ForegroundColor DarkGreen;
    if ($ConfigJson.startdir) {
        try {
            Set-Location $ConfigJson.startdir -ErrorAction SilentlyContinue;
        }
        catch {
            Write-Host "$($chars.cross) Could not change directory to $ConfigJson.startdir.`nPlease read more from the documentation.`n" -ForegroundColor DarkRed;
        }
    }
    else {
        Set-Location "C:\Users\$($env:username))";
    }
} 
else {
    Write-Host "$($chars.cross) Failed to load configuration.`n" -ForegroundColor DarkRed;
}

Write-Host "To access our new package manager, type 'pishpack' (without the quotes).";

function Prompt {
    $name = $env:username.ToLower();
    $name = $name -Replace " ", "";
    if ($ConfigJson.user) {
        $name = $ConfigJson.user;
    }
    Write-Host $name -ForegroundColor Green -NoNewLine;
    if ($ConfigJson.host) {
        Write-Host "@$($ConfigJson.host) " -NoNewLine;
    }
    else {
        Write-Host "@$($env:computername) " -NoNewLine;
    }
    
    $loc = Get-PishPath;

    Write-Host "$loc" -ForegroundColor Green -NoNewLine;

    $err = !$?;

    if ($err) {
        Write-Host " [" -ForegroundColor DarkRed;
        Write-Host "Error" -ForegroundColor Red;
        Write-Host "]" -ForegroundColor DarkRed;
    }

    Get-AliasList

    return "> ";
}

$PSReadLineOptions = @{
    Colors             = @{
        # "Command"    = "Blue";
        "Command"            = 'Blue'
        "Number"             = 'Green'
        "Member"             = 'Green'
        "Operator"           = 'Blue'
        "Type"               = 'Yellow'
        "Variable"           = 'White'
        "Parameter"          = 'Cyan'
        "ContinuationPrompt" = 'DarkCyan'
        "Default"            = 'Cyan'
    }
    ContinuationPrompt = "> ";
}
Set-PSReadLineOption @PSReadLineOptions;

function pishpack {
    $comamnd = $args[0];
    $pkg = $args[1];

    if ($comamnd -eq "install") {
        Write-Host "Going to install $pkg";
        $pkgurl = Invoke-WebRequest "https://raw.githubusercontent.com/zeondev/pishpackrepo/main/$($pkg).ps1";
        $pkgcontent = $pkgurl.content
        Set-Content $PkgLoc/$($pkg).ps1 $pkgcontent
        Write-Host "Wrote $($($pkgurl).rawcontentlength) bytes to '$PkgLoc/$($pkg).ps1'`nTry running '$($pkg)' now!";
    }
    elseif ($comamnd -eq "uninstall") {
        Write-Host "Attempting to uninstall $pkg...";
        if (Test-Path $PkgLoc/$($pkg).ps1) {
            Remove-Item $PkgLoc/$($pkg).ps1 -Force -Recurse -ErrorAction SilentlyContinue;
            Write-Host "Successfully uninstalled $pkg";
        }
        else {
            Write-Host "Could not find $pkg to uninstall";
        }
    }
    else {
        Write-Host "Invalid argument";
        return;
    }

    return;
}

$boxes = @{
    # box drawing characters
    "row" = [regex]::Unescape("\u2500"); # 
    "col" = [regex]::Unescape("\u2502"); # │
    "bl"  = [regex]::Unescape("\u2514"); # └
    "br"  = [regex]::Unescape("\u2518"); # ┘
    "tl"  = [regex]::Unescape("\u250C"); # ┌
    "tr"  = [regex]::Unescape("\u2510"); # ┐
    "h"   = [regex]::Unescape("\u2501"); # ━
    "v"   = [regex]::Unescape("\u2503"); # ┃
    "ul"  = [regex]::Unescape("\u2534"); # ┴
    "ur"  = [regex]::Unescape("\u252C"); # ┬
    "ll"  = [regex]::Unescape("\u251C"); # ├
    "lr"  = [regex]::Unescape("\u2524"); # ┤
    "t"   = [regex]::Unescape("\u250F"); # ┏
    "b"   = [regex]::Unescape("\u2513"); # ┓
    "l"   = [regex]::Unescape("\u2517"); # ┗
    "r"   = [regex]::Unescape("\u251B"); # ┛
    "u"   = [regex]::Unescape("\u2533"); # ┻
    "d"   = [regex]::Unescape("\u252B"); # ┫
}

function Get-SimpleFileName {
    try {
        Write-Host "  $($boxes.tl)$($boxes.row)$($boxes.row)$($boxes.row) $(Get-PishPath -Expand)" -ForegroundColor Green;
    }
    catch {
        Write-Host "  $($boxes.tl)$($boxes.row)$($boxes.row)$($boxes.row) Unknown directory" -ForegroundColor Green;
    }
    [array]$Files = @(Get-ChildItem);
    foreach ($file in $Files) {
        Write-Host "  $($boxes.col) " -ForegroundColor DarkGreen -NoNewLine;
        Write-Host "$($file.Name)" -ForegroundColor Green;
    }
    # Write-Host the file count
    Write-Host "  $($boxes.bl)$($boxes.row) $($Files.count) total" -ForegroundColor Green -NoNewLine;
}

Remove-Item 'Alias:\ls' -ErrorAction SilentlyContinue -Force;
Set-Alias -Name "ls" -Value "Get-SimpleFileName";
# New-Alias "hello world" $PkgLoc"\hello.ps1";
New-Alias "piwd" "Get-PishPath";

function Get-AliasList {
    try {
        if (!(Test-Path $PkgLoc)) {
            $err = $true;
        }
        $outputDebug = $args[0];
        $outputDebug2 = $args[1];
        [array]$Files = @(Get-ChildItem $PkgLoc -ErrorAction SilentlyContinue);
    }
    catch {
        $err = $true;
    }
    if ($err -eq $true -and $outputDebug -eq "-outputdebug" -and $outputDebug2 -eq "yes") {
        Write-Host "Something went wrong fetching packages to alias, check the directory $PkgLoc" -ForegroundColor Red;
        # attempt to create the directory
        if (!(Test-Path $PkgLoc)) {
            Write-Host "Attempting to create directory $PkgLoc" -ForegroundColor Green;
            New-Item -Path $PkgLoc -ItemType Directory -Force -ErrorAction SilentlyContinue;
        }
        else {
            Write-Host "Directory $PkgLoc already exists" -ForegroundColor Green;
        }
        return;
    }
    if ($outputDebug -eq "-outputdebug" -and $outputDebug2 -eq "yes") {
        Write-Host "Setting up aliases..." -ForegroundColor Green -NoNewLine;
    }
    foreach ($file in $Files) {
        if ($file.Extension -eq ".ps1") {
            try {
                $TheAlias = $file.Name;
                $TheAlias = $TheAlias -Replace ".ps1", "";
                $ThePath = "$PkgLoc\$($File.Name.ToString())";
                New-Alias $TheAlias.ToString() $ThePath -Force -Scope Global;
                if ($outputDebug -eq "-outputdebug" -and $outputDebug2 -eq "yes") {
                    Write-Host "$($TheAlias) " -ForegroundColor White -NoNewLine;
                }
            } 
            catch {
                if ($outputDebug -eq "-outputdebug" -and $outputDebug2 -eq "yes") {
                    Write-Host "Could not add alias for $file.Name";
                }
            }
        }
    }
    if ($outputDebug -eq "-outputdebug" -and $outputDebug2 -eq "yes") {
        if ($Files.Length -gt 0) {
            Write-Host "Done" -ForegroundColor Green -NoNewLine;
        }
        else {
            Write-Host "Couldn't find any.." -ForegroundColor Red -NoNewLine;
        }
        Write-Host "`nConsult the documentation to disable this alias message.`n" -ForegroundColor Blue;
        return;
    }
}
Get-AliasList -outputdebug yes;
