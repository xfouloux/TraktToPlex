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
	docker tag whoami "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-$env:VERSION"
	docker push "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-$env:VERSION"
	}else{
		Write-Host "$os image"
		docker tag whoami "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME"
		docker push "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME"
	}
}else{
  # Linux
  Write-Host "$os image $env:ARCH $env:ARCHVERSION"
  docker tag whoami "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME"
  docker push "$($image):$os-$env:ARCH-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME"
  
  if ($env:ARCH -eq "amd64") {
	Write-Host "Pushing manifest $($image):$env:APPVEYOR_REPO_TAG_NAME"
    # The last in the build matrix
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-arm-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-1803" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-1809"
    docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v7
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"
	#LATEST
    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
	"$($image):linux-arm-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):linux-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-1803" `
	"$($image):windows-amd64-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME-1809"
    docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-dotnet-$env:dotnet_version-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v7
    docker manifest push "$($image):latest"
  }
}