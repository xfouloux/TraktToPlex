FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY /TraktToPlex/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY /TraktToPlex/* ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine
WORKDIR /app
COPY --from=build-env /app/out .
#create trakt api app at https://trakt.tv/oauth/applications/new
#Only important field is Redirect uri, which should be 
# http://IP:5001/Home/TraktReturn (modify hostname and port for your own needs. Localhost works perfectly fine for development)
ENV TRAKT_CLIENTID changeme
ENV TRAKT_CLIENT_SECRET changeme
# just put a random hash there
ENV PLEX_CLIENT_SECRET changeme

EXPOSE 80

ENTRYPOINT ["dotnet", "TraktToPlex.dll"]
