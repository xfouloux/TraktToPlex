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

if ($isWindows) {
	# Windows
	if ($env:VERSION) {
	Write-Host "$os image to produce $env:VERSION variant"
	docker tag whoami "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version-$env:VERSION"
	docker push "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version-$env:VERSION"
	}else{
		Write-Host "$os image"
		docker tag whoami "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version"
		docker push "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version"
	}
}else{
  # Linux
  if($env:ARCHVERSION) {
	  Write-Host "$os image $env:ARCH $env:ARCHVERSION"
	  docker tag whoami "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCHVERSION-dotnet-$env:dotnet_version"
	  docker push "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCHVERSION-dotnet-$env:dotnet_version"
  }else{
	Write-Host "$os image $env:ARCH"
	docker tag whoami "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version"
	docker push "$($image):$env:APPVEYOR_REPO_TAG_NAME-$os-$env:ARCH-dotnet-$env:dotnet_version"
  }
  if ($env:ARCH -eq "amd64") {
	#TAG
	Write-Host "Pushing manifest $($image):$env:APPVEYOR_REPO_TAG_NAME"
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-linux-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1803" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1809"
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"
	
	#DOTNET VERSION
	Write-Host "Pushing manifest $($image):dotnet-$env:dotnet_version-latest"
    docker -D manifest create "$($image):dotnet-$env:dotnet_version-latest" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-linux-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1803" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1809"
    docker manifest push "$($image):dotnet-$env:dotnet_version-latest"
	
	#LATEST
    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-linux-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1803" `
	"$($image):$env:APPVEYOR_REPO_TAG_NAME-windows-amd64-dotnet-$env:dotnet_version-1809"
    docker manifest push "$($image):latest"
  }
}