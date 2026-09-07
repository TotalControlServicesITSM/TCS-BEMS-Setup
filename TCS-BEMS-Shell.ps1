# TCS - BEMS Machine Setup Tool - v26.09 - Copyright (c) 2025 Carl Hopkins

# Bypasses server certificate mismatch error
winget settings --enable BypassCertificatePinningForMicrosoftStore

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ErrorActionPreference = 'SilentlyContinue'
$wshell = New-Object -ComObject Wscript.Shell
$Button = [System.Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Error
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

# Init
Write-Host "+===================================================+"
Write-Host ".              TCS BEMS Shell - v26.09              ."
Write-Host "+===================================================+"
Write-Host ""
Write-Host "Loading, please wait..."
Write-Host ""

# Download required local resources
Import-Module BitsTransfer
Start-BitsTransfer -Source "https://raw.githubusercontent.com/TotalControlServicesITSM/TCS-BEMS-Setup/main/trekimage.jpg" -Destination trekimage.jpg
Start-BitsTransfer -Source "https://raw.githubusercontent.com/TotalControlServicesITSM/TCS-BEMS-Setup/main/tcsimage.jpg" -Destination tcsimage.jpg
Add-Type -Assembly System.Drawing
$bimage = [System.Drawing.Image]::FromFile("./trekimage.jpg")
Add-Type -Assembly System.Drawing
$himage = [System.Drawing.Image]::FromFile("./tcsimage.jpg")

# Check if Winget is installed
Write-Host "Checking for winget..."
if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe){
    Write-Host "Winget Already Installed"
    $ResultText.text = "Winget Already Installed"
}  
else{
	Write-Host "Winget not found, installing it now."
    $ResultText.text = "`r`n" +"`r`n" + "Installing Winget... Please Wait"
	Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
	$nid = (Get-Process AppInstaller).Id
	Wait-Process -Id $nid
	Write-Host "Winget Installed"
    $ResultText.text = "`r`n" +"`r`n" + "Winget Installed - Ready for Next Task"
}

# GUI Specs
$Form                         = New-Object system.Windows.Forms.Form
$Form.ClientSize              = New-Object System.Drawing.Point(780,780)
$Form.text                    = "TCS Machine Preparation Tool - v26.08"
$Form.StartPosition           = "CenterScreen"
$Form.TopMost                 = $false
$Form.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#e9e9e9")
$Form.AutoScaleDimensions     = '192, 192'
$Form.AutoScaleMode           = "Dpi"
$Form.AutoSize                = $True
$Form.AutoScroll              = $True
$Form.ClientSize              = '700, 700'
$Form.FormBorderStyle         = 'FixedSingle'

# GUI Icon
$iconBase64                   = '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAAgACADASIAAhEBAxEB/8QAGAABAAMBAAAAAAAAAAAAAAAACQcICgP/xAArEAABBAEDAwQCAQUAAAAAAAACAQMEBQYHERIICSEAExQxFSIKIzI0QVL/xAAXAQEBAQEAAAAAAAAAAAAAAAAFBgME/8QAJhEAAQMDBAEEAwAAAAAAAAAAAQIDEQQhQQASEzFhBTJxsVGBof/aAAwDAQACEQMRAD8AIftadvXIO5x1l43pfSPFX17/ACsshtNuX4eqZIPkSETZeTn7g22K+CddaFVEVUkVTux9nbpX0H6akwzSvHa2t1SeciN0NxOzRCsLQkIVkuvtvzEB9tW+QezDhk97ytcARHUQol/j9dLDOSdLma5NgGqcii1eyt5ytt6KqajfmnscZQnEi15STBlqVMmsttrIdVWmWxEk4ueUtHpv0hysBnu2GsF5f6d2V8qvHpTp3fK7k89l5OCOZNlH+ZIdfBFQ2mjBokIvabb5mCcrz6wdrSZ8/f7HkjwZtpajoWFNl2pc2xjJnrBgHBAWclITBI662doHXzQ7TyVl0zBrS2xeBDCxl2FfFfQosUt0SScZ9tqSkfx5f9r2U8fv59Vk9bDejzt36OaC48zm1XpPhMHLrxPl/k3o62Vg0BqLgmU6abzxOEoi6rnJPKjsA7KPo4v5MHVjozhXT9d6Y1lDp/I1SyWYw40DGP1cuVTRUdRx6X8mO2BxH3eKCPMjNwHDXYBLdd29+0ckT40fUcXIeCduJif592+B1o0+lnXO+046Za9msqcaF6vsfkVmRNocO/oZTjj5/wBF1kh+QyYRDEgeQxFVT73BBYPpszKlmTcbyLJnZF7Gmz0tLUn+KyrNFdVH+SGXEjFxDbJOXFCbUd+O3rPnpzrW/h9IVTKbORAVV9sgVOcfflvsi+C8kq/afa+fO3qwrXc8XHqMo8GDbyJDpe86rNg/AZfd4oPuOA25sp7IiKSJuqJ6mFvepUlYSGS42qfaUgi8gmSBkgyZ6idVCW/TayiSkvBtxEe4Eg2ggRJ7AIgRc6Y7uVdxHJcxr7FWbayxHCW1QINRWH7V5kbg+difaUkbHluqttucUHZTJf7EAfq+yocs1NSQTsU5StkUhuOSE3GJTXi2ip/yKCnnz9KvlV9dNYetHONYJskn7A61mVuLiRnCV94F+hdfJVdc2Tx+xfXj1EpEpLuvlV8qq/79L06at10PPgISOkgyZOVGw6wJ+ToV9ylaaUxTysqiVEQIF4SLmJyYn8DX/9k='
$iconBytes                    = [Convert]::FromBase64String($iconBase64)
$stream                       = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length)
$Form.Icon                    = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())

$Form.Width                   = $objImage.Width
$Form.Height                  = $objImage.Height

# Panel1 - L/H Spacer
$Panel1                          = New-Object system.Windows.Forms.Panel
$Panel1.height                   = 250
$Panel1.width                    = 250
$Panel1.location                 = New-Object System.Drawing.Point(5,75)

# Panel2 - Actions
$Panel2                          = New-Object system.Windows.Forms.Panel
$Panel2.height                   = 510
$Panel2.width                    = 250
$Panel2.location                 = New-Object System.Drawing.Point(265,75)

$warptweaks                      = New-Object system.Windows.Forms.Button
$warptweaks.Image                = $bimage
$warptweaks.width                = 205
$warptweaks.height               = 205
$warptweaks.location             = New-Object System.Drawing.Point(5,20)
$warptweaks.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$wingetapps                      = New-Object system.Windows.Forms.Button
$wingetapps.text                 = "Install Application Packages"
$wingetapps.width                = 205
$wingetapps.height               = 68
$wingetapps.location             = New-Object System.Drawing.Point(5,245)
$wingetapps.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$dismonline                      = New-Object system.Windows.Forms.Button
$dismonline.text                 = "Install Online DISM DotNet PKG"
$dismonline.width                = 205
$dismonline.height               = 68
$dismonline.location             = New-Object System.Drawing.Point(5,333)
$dismonline.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$dismoffline                      = New-Object system.Windows.Forms.Button
$dismoffline.text                 = "Install Offline DISM DotNet PKG"
$dismoffline.width                = 205
$dismoffline.height               = 68
$dismoffline.location             = New-Object System.Drawing.Point(5,421)
$dismoffline.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

# Panel3 - R/H Spacer
$Panel3                          = New-Object system.Windows.Forms.Panel
$Panel3.height                   = 250
$Panel3.width                    = 250
$Panel3.location                 = New-Object System.Drawing.Point(525,75)

# Status Panel
$Panel4                          = New-Object system.Windows.Forms.Panel
$Panel4.height                   = 65
$Panel4.width                    = 730
$Panel4.location                 = New-Object System.Drawing.Point(20,570)

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "Current Status:"
$Label10.AutoSize                = $true
$Label10.width                   = 205
$Label10.height                  = 20
$Label10.location                = New-Object System.Drawing.Point(5,5)
$Label10.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ResultText                      = New-Object system.Windows.Forms.TextBox
$ResultText.width                = 725
$ResultText.height               = 40
$ResultText.location             = New-Object System.Drawing.Point(5,25)
$ResultText.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

# Branding Panel
$Panel0                          = New-Object system.Windows.Forms.Panel
$Panel0.height                   = 70
$Panel0.width                    = 730
$Panel0.location                 = New-Object System.Drawing.Point(5,5)

$PictureBox1                     = New-Object system.Windows.Forms.PictureBox
$PictureBox1.width               = 600
$PictureBox1.height              = 60
$PictureBox1.location            = New-Object System.Drawing.Point(65,15)
$PictureBox1.image               = $himage
$PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom

$Form.controls.AddRange(@($Panel0,$Panel1,$Panel2,$Panel3,$Panel4))
$Panel0.controls.AddRange(@($PictureBox1))
$Panel2.controls.AddRange(@($warptweaks,$wingetapps,$dismonline,$dismoffline))
$Panel4.controls.AddRange(@($Label10,$ResultText))

# App loaded and waiting for user input
Write-Host "TCS BEMS Setup Tool Ready...Please select action!"
$ResultText.text = "TCS BEMS Setup Tool Ready...Please select action!"

# Apply BEMS Headend System Tweaks 
$warptweaks.Add_Click({
Write-Host "BEMS System Defaults and Tweaks in Progress..."
    $ResultText.text = "BEMS System Defaults and Tweaks in Progress..."

# Pause to init
Start-Sleep -Seconds 2

Write-Host "Enabling F8 boot menu options..."
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null

Write-Host "Disabling Hibernation..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0

Write-Host "Setting AC Timeout defaults"
    powercfg /change monitor-timeout-ac 0
    powercfg /change standby-timeout-ac 0
    #powercfg /change disk-timeout-ac 0 not sure this is worthwhile for flash since on pci bus etc...

Write-Host "Hiding People icon..."
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

Write-Host "Disable Meet Now button"
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 1

Write-Host "Enabling Remote Desktop Services"
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Remove default Windows Bloatware Pre-installed Apps 
Write-Host "Removing Bloatware..."
    $ResultText.text = "Removing Bloatware..."
$Bloatware = @(
# Add sponsored/featured apps to remove in the "*AppName*" format
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Duolingo-LearnLanguagesforFree*"
    "*PandoraMediaInc*"
    "*CandyCrush*"
    "*BubbleWitch3Saga*"
    "*BubbleWitchSaga*"
    "*Wunderlist*"
    "*Flipboard*"
    "*Twitter*"
    "*Facebook*"
    "*Royal Revolt*"
    "*Sway*"
    "*Speed Test*"
    "*SpeedTest*"
    "*Viber*"
    "*ACGMediaPlayer*"
    "*Netflix*"
    "*OneCalendar*"
    "*LinkedInforWindows*"
    "*HiddenCityMysteryofShadows*"
    "*Hulu*"
    "*HiddenCity*"
    "*AdobePhotoshopExpress*"
    "*HotspotShieldFreeVPN*"
    "*TikTok*"
    "*Whatsapp*"
    "*WhatsApp*"
    "*SpotifyAB*"
    "*Spotify*"
    "*Minecraft*"
    "*Disney*"
    "MirametrixInc.GlancebyMirametrix"
    "RealtimeboardInc.RealtimeBoard"
    "SpotifyAB.SpotifyMusic"
    "5A894077.McAfeeSecurity"
    "5A894077.McAfeeSecurity_2.1.27.0_x64__wafk5atnkzcwy"
    "Adobe Creative Cloud All Apps 2-month membership"
    "McAfeeWPSSparsePackage_0j6k21vdgrmfw"
    "Slack*"
)
    foreach ($Bloat in $Bloatware) {
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        Write-Host "Trying to remove $Bloat."
        $ResultText.text = "Trying to remove $Bloat..."
    }

Write-Host "Operations complete! Please wait..."
    $ResultText.text = "Operations complete! Please wait..."

# Pause to init
Start-Sleep -Seconds 2

# End subroutine
Write-Host "Please select another action or reboot your system NOW!"
    $ResultText.text = "Please select another action or reboot your system NOW!"

})

# Winget Utilities Install Routine
$wingetapps.Add_Click({
Write-Host "Installation in Progress..."
    $ResultText.text = "Installation in Progress..."

# Pause to init
Start-Sleep -Seconds 2

# 7-Zip Compression Tool
Write-Host "Installing 7-Zip Compression Tool"
    $ResultText.text = "`r`n" +"`r`n" + "Installing 7-Zip Compression Tool... Please Wait" 
    winget install -e --accept-source-agreements --accept-package-agreements --id 7zip.7zip | Out-Host
    if($?) { Write-Host "Installed 7-Zip Compression Tool" }
    $ResultText.text = "`r`n" + "Finished Installing 7-Zip Compression Tool" + "`r`n" + "`r`n" + "Ready for Next Task"

# Notepad++
Write-Host "Installing Notepad++"
    $ResultText.text = "`r`n" +"`r`n" + "Installing Notepad++... Please Wait" 
    winget install -e --accept-source-agreements --accept-package-agreements --id Notepad++.Notepad++ | Out-Host
    if($?) { Write-Host "Installed Notepad++" }
    $ResultText.text = "`r`n" + "Finished Installing Notepad++" + "`r`n" + "`r`n" + "Ready for Next Task"

# Advanced IP Scanner
Write-Host "Installing Advanced IP Scanner"
    $ResultText.text = "`r`n" +"`r`n" + "Installing Advanced IP Scanner... Please Wait" 
    winget install -e --accept-source-agreements --accept-package-agreements --id Famatech.AdvancedIPScanner | Out-Host
    if($?) { Write-Host "Installed Advanced IP Scanner" }
    $ResultText.text = "`r`n" + "Finished Installing Advanced IP Scanner" + "`r`n" + "`r`n" + "Ready for Next Task"

# WINGET MANIFEST TEMPLATE - COPY BELOW TO USE
# APP NAME
#Write-Host "Installing APPNAME"
#    $ResultText.text = "`r`n" +"`r`n" + "Installing APPNAME... Please Wait" 
#    winget install -e --accept-source-agreements --accept-package-agreements --id APP.LINK | Out-Host
#    if($?) { Write-Host "Installed APPNAME" }
#    $ResultText.text = "`r`n" + "Finished Installing APPNAME" + "`r`n" + "`r`n" + "Ready for Next Task"

Write-Host "Installation complete! Please wait..."
    $ResultText.text = "Installation complete! Please wait..."

# Pause to init
Start-Sleep -Seconds 2

# End subroutine
Write-Host "Please select another action or reboot your system NOW!"
    $ResultText.text = "Please select another action or reboot your system NOW!"

})

# DISM Install Routine (online version)
$dismonline.Add_Click({
Write-Host "Installation in Progress..."
    $ResultText.text = "Installation in Progress..."

# Pause to init
Start-Sleep -Seconds 2

Write-Host "Installing DotNetFx3. Please wait..."
    $ResultText.text = "Installing DotNetFx3. Please wait..."
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
    if($?) { Write-Host "The operation completed successfully." }
    $ResultText.text = "`r`n" + "Installation complete!" + "`r`n" + "`r`n" + "Please wait..."

# Pause to init
Start-Sleep -Seconds 2

# End subroutine
Write-Host "Please select another action or reboot your system NOW!"
    $ResultText.text = "Please select another action or reboot your system NOW!"

})

# DISM Install Routine (offline version)
$dismoffline.Add_Click({
Write-Host "Installation in Progress..."
    $ResultText.text = "Installation in Progress..."

# Pause to init
Start-Sleep -Seconds 2

Write-Host "Installing DotNetFx3. Please wait..."
    $ResultText.text = "Installing DotNetFx3. Please wait..."
    Start-BitsTransfer -Source "https://raw.githubusercontent.com/TotalControlServicesITSM/TCS-BEMS-Setup/main/Packages/Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~~.cab" -Destination Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~~.cab
    Start-Sleep -Seconds 2
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:./

# Pause to init
Start-Sleep -Seconds 2

# End subroutine
Write-Host "Please select another action or reboot your system NOW!"
    $ResultText.text = "Please select another action or reboot your system NOW!"

})

[void]$Form.ShowDialog()
