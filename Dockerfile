FROM mcr.microsoft.com/dotnet/core/sdk-alpine:2.2 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY /TraktToPlex/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY /TraktToPlex/* ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet-alpine:2.2
WORKDIR /app
COPY --from=build-env /app/out .
VOLUME /app/Properties
EXPOSE 80
ENTRYPOINT ["dotnet", "trakttoplex.dll"]
