FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
COPY PocRandD/PocRandD.csproj ./app/PocRandD/

WORKDIR /app/PocRandD
RUN dotnet restore

COPY PocRandD/. ./
RUN dotnet publish -o out /p:PublishWithAspNetCoreTargetManifest="false"

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
ENV ASPNETCORE_URLS http://+:80
WORKDIR /app
COPY --from=build /app/PocRandD/out ./
ENTRYPOINT ["dotnet", "PocRandD.dll"]