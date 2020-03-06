$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
  docker build --pull -t whoami -f Dockerfile.windows .
} else {
  if($env:ARCH == "arm"){
	docker build -t whoami -f Dockerfile.arm --build-arg "arch=$env:ARCH" .
  }else{
	docker build -t whoami --build-arg "arch=$env:ARCH" .
  }
}

docker images