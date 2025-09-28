FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
ARG APP_UID=1000
RUN adduser --disabled-password --gecos '' --uid $APP_UID appuser
USER appuser
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["HomeApi/HomeApi.csproj", "HomeApi/"]
RUN dotnet restore "HomeApi/HomeApi.csproj"
COPY . .
WORKDIR "/src/HomeApi"  # ← ИСПРАВЛЕНО: только один уровень HomeApi
RUN dotnet build "HomeApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "HomeApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HomeApi.dll"]