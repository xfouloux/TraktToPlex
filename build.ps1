$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
	#build other windows versions
	if ($env:VERSION) {
		Write-Host "Build windows version $env:VERSION"
		docker build -t whoami --build-arg "VERSION=$env:VERSION" --isolation=hyperv -f Dockerfile.windows.versions . 
	}else{
		docker build --pull -t whoami --isolation=hyperv -f Dockerfile.windows .
	}
} else {
	if ($env:ARCHVERSION) {
		docker build -t whoami -f "Dockerfile.$env:ARCH" --build-arg "archversion=$env:ARCHVERSION" .
	}else{
		docker build -t whoami --build-arg "arch=$env:ARCH" .
	}
}

docker images