Write-Output "Remove unnecessary packages"

$unnecessaryPackages = @(
  "7EE7776C.LinkedInforWindows",
  "Clipchamp.Clipchamp",
  "Disney.37853FC22B2CE",
  "MSTeams",
  "Microsoft.549981C3F5F10",
  "Microsoft.BingNews",
  "Microsoft.BingSearch",
  "Microsoft.BingWeather",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.Microsoft3DViewer",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.MixedReality.Portal",
  "Microsoft.OutlookForWindows",
  "Microsoft.Paint",
  "Microsoft.People",
  "Microsoft.Print3D",
  "Microsoft.ScreenSketch",
  "Microsoft.SkypeApp",
  "Microsoft.Todos",
  "Microsoft.Windows.DevHome",
  "Microsoft.Windows.Photos",
  "Microsoft.WindowsAlarms",
  "Microsoft.WindowsCalculator",
  "Microsoft.WindowsCamera",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.WindowsMaps",
  "Microsoft.WindowsSoundRecorder",
  "Microsoft.YourPhone",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo",
  "MicrosoftCorporationII.MicrosoftFamily",
  "MicrosoftCorporationII.QuickAssist",
  "MicrosoftTeams",
  "MicrosoftWindows.Client.WebExperience",
  "MicrosoftWindows.CrossDevice",
  "SpotifyAB.SpotifyMusic",
  "microsoft.windowscommunicationsapps"
)

foreach ($unnecessaryPackage in $unnecessaryPackages) {
  Write-Output "Remove: $unnecessaryPackage"
  Get-AppxPackage $unnecessaryPackage | Remove-AppxPackage
}

Write-Output "Install necessary packages"

$wingetPackagesArray = @(
  "AgileBits.1Password",
  "Discord.Discord",
  "ElectronicArts.EADesktop",
  "Mozilla.Firefox.DeveloperEdition",
  "RiotGames.Valorant.AP",
  "Valve.Steam"
)
$wingetPackages = [System.Collections.Generic.HashSet[string]]::new()
$wingetPackagesArray | ForEach-Object { $wingetPackages.Add($_) | Out-Null }

$usbDevices = Get-PnpDevice -Class USB
foreach ($device in $usbDevices) {
  if ($device.DeviceId -match "VID_046D") {
    $wingetPackages.Add("Logitech.GHUB") | Out-Null
  }
}

if (Get-Command -Name winget -ErrorAction SilentlyContinue) {
  Set-Variable -Name WINDOWS11_24H2_BUILD_NUMBER -Value 26100 -Option Constant
  $buildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
  if ($buildNumber -ge $WINDOWS11_24H2_BUILD_NUMBER -and (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
    sudo winget install $wingetPackages
  }
  else
  {
    winget install $wingetPackages
  }
}