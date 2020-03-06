$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
	#build other windows versions
	if ($env:VERSION) {
		Write-Host "Build windows version ${env:VERSION}"
		docker build --pull -t whoami --build-arg "version=${env:VERSION}" -f Dockerfile.windows.versions . 
	}else{
		docker build --pull -t whoami -f Dockerfile.windows .
	}
} else {
	docker build -t whoami --build-arg "arch=$env:ARCH" .
}

docker images