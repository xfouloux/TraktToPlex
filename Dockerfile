FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
# Copy csproj and restore as distinct layers
COPY . /app
WORKDIR /app
RUN dotnet restore
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build-env /app/out .
EXPOSE 5001
ENTRYPOINT ["dotnet", "TraktToPlex.dll"]
