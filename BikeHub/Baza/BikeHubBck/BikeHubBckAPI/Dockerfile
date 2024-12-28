#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 7077

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["BikeHubBckAPI/BikeHubBckAPI.csproj", "BikeHubBckAPI/"]
RUN dotnet restore "BikeHubBckAPI/BikeHubBckAPI.csproj"
COPY . .
WORKDIR "/src/BikeHubBckAPI"
RUN dotnet build "BikeHubBckAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BikeHubBckAPI.csproj" -c Release -o /app/publish /p:UseAppMost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BikeHubBckAPI.dll"]