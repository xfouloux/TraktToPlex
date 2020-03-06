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

docker tag whoami "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

if ($isWindows) {
	# Windows
	Write-Host "Rebasing image to produce 1909 variant"
	npm install -g rebase-docker-image
	rebase-docker-image `
	"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
	-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1909" `
	-b mcr.microsoft.com/dotnet/core/aspnet:2.2-nanoserver-1909
	
	Write-Host "Rebasing image to produce 1903 variant"
	npm install -g rebase-docker-image
	rebase-docker-image `
	"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
	-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1903" `
	-b mcr.microsoft.com/dotnet/core/aspnet:2.2-nanoserver-1903
	
	Write-Host "Rebasing image to produce 1809 variant"
	npm install -g rebase-docker-image
	rebase-docker-image `
	"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
	-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1809" `
	-b mcr.microsoft.com/dotnet/core/aspnet:2.2-nanoserver-1809
	
	Write-Host "Rebasing image to produce 1709 variant"
	npm install -g rebase-docker-image
	rebase-docker-image `
	"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
	-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1709" `
	-b mcr.microsoft.com/dotnet/core/aspnet:2.2-nanoserver-1709
	
		
}else{
  # Linux
  if ($env:ARCH -eq "amd64") {
	 Write-Host "Pushing manifest $($image):$env:APPVEYOR_REPO_TAG_NAME"
    # The last in the build matrix
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1909" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
    docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"
	#LATEST
    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1909" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809" `
	  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
    docker manifest annotate "$($image):latest" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
    docker manifest push "$($image):latest"
  }
}