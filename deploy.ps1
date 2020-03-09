#$ErrorActionPreference = 'Stop';

if (! (Test-Path Env:\APPVEYOR_REPO_TAG_NAME)) {
  Write-Host "No version tag detected. Skip publishing."
  exit 0
}

$image = "sclemenceau/trakttoplex"

Write-Host Starting deploy

if (!(Test-Path ~/.docker)) { mkdir ~/.docker }

'{ "experimental": "enabled" }' | Out-File ~/.docker/config.json -Encoding Ascii
docker login -u="$env:DOCKER_USER" -p="$env:DOCKER_PASS"

$os = if ($isWindows) {"windows"} else {"linux"}

Write-Host "I AM ON $os PLATFORM !"

if ($isWindows) {
	# Windows
	if ($env:VERSION) {
		Write-Host "Windows image to produce $env:VERSION variant"
		docker tag whoami "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-$env:VERSION"
		docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-$env:VERSION"
	}
	if ($env:VERSION == 1909) { #LATEST VERSION
		Write-Host "Windows image"
		docker tag whoami "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
		docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
	}
}else{
  # Linux
  
  docker tag whoami "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
  docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
  
  if ($env:ARCH -eq "amd64") {
	Write-Host "Pushing manifest $($image):$env:APPVEYOR_REPO_TAG_NAME"
    # The last in the build matrix
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-arm32v7-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1909"
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"
	#LATEST
    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
	"$($image):linux-arm32v7-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
	"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1909"
    docker manifest push "$($image):latest"
  }
}