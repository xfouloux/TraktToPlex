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

$os = If ($isWindows) {"windows"} Else {"linux"}
docker tag whoami "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

# The last in the build matrix
docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"

Write-Host "Pushing manifest $($image):latest"
docker -D manifest create "$($image):latest" `
  "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
docker manifest annotate "$($image):latest" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
docker manifest annotate "$($image):latest" "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
docker manifest push "$($image):latest"