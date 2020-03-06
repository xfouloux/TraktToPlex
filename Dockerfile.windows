FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /src
# Copy csproj and restore as distinct layers
COPY /TraktToPlex/*.csproj ./
RUN dotnet restore
# Copy everything else and build
COPY /TraktToPlex/* ./
RUN dotnet build -c Release -o /app
RUN ls /app

FROM build AS publish
RUN dotnet publish -c Release -o /app
RUN ls /app

# Build runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app .
COPY /TraktToPlex/ ./
RUN ls /app
ENTRYPOINT ["dotnet", "TraktToPlex.dll"]