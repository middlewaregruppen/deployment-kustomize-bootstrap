$location = Get-Location

Write-Host "+------------------------------------------+"
Write-Host "+ OpenShift Kustomize deployment bootstrap +"
Write-Host "+------------------------------------------+"
Write-Host " "
$ProjectName = Read-Host -Prompt 'Project name'
$NumEnvs = Read-Host -Prompt 'Number of environments needed (max 5)'

Write-Host "You have chosen $NumEnvs environments:"

$ShortEnvNames = @()
$OpenShiftEnvNames = @()

For ($i=1; $i -le $NumEnvs; $i++) {
  $ShortName = Read-Host -Prompt "  - Name of environment $i (eg: dev, test, prod)"
  $OpenShiftName = Read-Host -Prompt "  - Name of $ShortName environment in OpenShift (eg: online-dev, online-test, online-prod)"
  $ShortEnvNames += $ShortName
  $OpenShiftEnvNames += $OpenShiftName
}

Write-Host ""
Write-Host "The following files will be generated:"
Write-Host " + build"
Write-Host "   + Deployments"
Write-Host "     + $ProjectName"
Write-Host "       + base"
$Files = Get-ChildItem -Path ".\Deployments\Project\base" -Name -Attributes !Directory
foreach ($File in $Files) {
  Write-Host "         - $File"
}
Write-Host "       + overlays"
$OverlayFiles = Get-ChildItem -Path ".\Deployments\Project\overlays\dev" -Name -Attributes !Directory
foreach ($EnvName in $ShortEnvNames) {
  Write-Host "         + $EnvName"
  foreach ($File in $OverlayFiles) {
    Write-Host "           - $File"
  }
}


$OkToContinue = Read-Host -Prompt 'Continue and create files (y/n)'
if ($OkToContinue.ToLower() -eq "y") {
  if (Test-Path ./build) {
    Write-Host "Deleting build folder..."
    Remove-Item -Recurse -Force ".\build"
  }
  
  Write-Host "Creating build folder..."
  $DestBase = "build\Deployments\$ProjectName" 
  New-Item -Path . -Name "build" -ItemType "directory" | Out-Null
  New-Item -Path . -Name "$DestBase" -ItemType "directory" | Out-Null
  New-Item -Path . -Name "$DestBase\base" -ItemType "directory" | Out-Null
  Copy-Item -Path ".\Deployments\Project\base\*.yaml" -Destination "$DestBase\base\"
  New-Item -Path . -Name "$DestBase\overlays" -ItemType "directory" | Out-Null
  For ($i=0; $i -lt $NumEnvs; $i++) {
    New-Item -Path . -Name "$DestBase\overlays\$($ShortEnvNames[$i])" -ItemType "directory" | Out-Null
    Copy-Item -Path ".\Deployments\Project\overlays\dev\*.yaml" -Destination "$DestBase\overlays\$($ShortEnvNames[$i])\"
  }

  $Files = Get-ChildItem -Path "$DestBase\base\" -Attributes !Directory
  foreach ($File in $Files) {
    (Get-Content $File).replace('projectname', $ProjectName) | Set-Content $File
  }
  For ($i=0; $i -lt $NumEnvs; $i++) {
    $OverlayFiles = Get-ChildItem -Path "$DestBase\overlays\$($ShortEnvNames[$i])" -Attributes !Directory
    foreach ($File in $OverlayFiles) {
      (Get-Content $File).replace('projectname', $ProjectName) | Set-Content $File
      (Get-Content $File).replace('openshift-namespace', $($OpenShiftEnvNames[$i])) | Set-Content $File
    }
  }
    
}
else {
  Write-Host "Exiting without creating any files."
}
