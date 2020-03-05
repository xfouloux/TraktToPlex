# TraktToPlex
Sync watched status from Trakt to Plex Media Server

## Usage

### TRAKT
You need to create an API App on trakt website first at https://trakt.tv/oauth/applications/new
Only important field is Redirect uri, which should be http://localhost:80/Home/TraktReturn 
(modify hostname and port for your own needs. Localhost works perfectly fine for development)

### docker
Here are some example snippets to help you get started creating a container.


```
docker create \
  --name=trakttoplex \
  -e TRAKT_CLIENTID=<YOUR_TRAKT_CLIENT_ID> # create trakt api app at https://trakt.tv/oauth/applications/new \
  -e TRAKT_CLIENT_SECRET=<YOUR_TRAKT_CLIENT_SECRET> #create trakt api app at https://trakt.tv/oauth/applications/new \
  -e PLEX_CLIENT_SECRET=<YOUR_PLEX_CLIENT_SECRET> #RANDOM NUMBER+LETTER \
  -p 80:80 \
  --restart unless-stopped \
  sclemenceau/trakttoplex
```
