[![Build status](https://ci.appveyor.com/api/projects/status/ft1s37y2dfqs435g?svg=true)](https://ci.appveyor.com/project/xfouloux/trakttoplex) 
[![Docker Pulls](https://img.shields.io/docker/pulls/sclemenceau/trakttoplex?style=flat-square)](https://hub.docker.com/repository/docker/sclemenceau/trakttoplex/)

# TraktToPlex
Sync watched status from Trakt to Plex Media Server
From https://github.com/Inrego/TraktToPlex
My Fork https://github.com/xfouloux/TraktToPlex

## Usage

### TRAKT
You need to create an API App on trakt website first at https://trakt.tv/oauth/applications/new
Only important field is Redirect uri, which should be http://localhost:80/Home/TraktReturn 
(modify hostname and port for your own needs. Localhost works perfectly fine for development)

### DOCKER
Here are some example snippets to help you get started creating a container.

```
docker create \
  --name=trakttoplex \
  -v <HOSTDIR>/appsettings.json:/app/appsettings.json
  -p 80:80 \
  --restart unless-stopped \
  sclemenceau/trakttoplex
```

### appsettings.json content
```
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  },
  "AllowedHosts": "*",
  "TraktConfig": { // create trakt api app at https://trakt.tv/oauth/applications/new
    // Only important field is Redirect uri, which should be http://localhost:80/Home/TraktReturn (modify hostname and port for your own needs. Localhost works perfectly fine for development)
    "ClientId": "",
    "ClientSecret": ""
  },
  "PlexConfig": {
    "ClientSecret": "" // Just make your own, for example generate a random guid with : date +%s | sha256sum | base64 | head -c 32 ; echo
  }
}
```