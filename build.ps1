$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
	#build other windows versions
	if ($env:VERSION) {
		Write-Host "Build windows version $env:VERSION"
		docker build -t whoami --build-arg "VERSION=$env:VERSION" --build-arg "platform=$env:platform" --build-arg "dotnet_version=$env:dotnet_version" --isolation=hyperv -f Dockerfile.windows.versions . 
	}else{
		docker build --pull -t whoami --build-arg "dotnet_version=$env:dotnet_version" --isolation=hyperv -f Dockerfile.windows .
	}
} else {
	if ($env:ARCHVERSION) {
		sudo apt-get -y install qemu binfmt-support qemu-user-static
		# This step will execute the registering scripts
		docker run --rm --privileged multiarch/qemu-user-static --reset -p yes	
		docker build -t whoami -f "Dockerfile.$env:ARCH" --build-arg "archversion=$env:ARCHVERSION" --build-arg "platform=$env:platform" --build-arg "dotnet_version=$env:dotnet_version" .
	}else{
		docker build -t whoami --build-arg "platform=$env:platform" --build-arg "dotnet_version=$env:dotnet_version" .
	}
}

docker images