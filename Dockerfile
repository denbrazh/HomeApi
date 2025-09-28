# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Копируем только .csproj для оптимизации кэширования
COPY ["HomeApi/HomeApi.csproj", "HomeApi/"]
RUN dotnet restore "HomeApi/HomeApi.csproj"

# Копируем всё остальное
COPY . .

# Переходим в папку проекта
WORKDIR /src/HomeApi

# Собираем
RUN dotnet build "HomeApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Публикуем
RUN dotnet publish "HomeApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false


# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
ARG APP_UID=1000
ENV ASPNETCORE_URLS=http://+:8080
WORKDIR /app

# Создаём непривилегированного пользователя (опционально, но безопаснее)
RUN adduser --disabled-password --gecos '' --uid $APP_UID appuser
USER $APP_UID

# Копируем опубликованные артефакты
COPY --from=build /app/publish .

# Запуск
ENTRYPOINT ["dotnet", "HomeApi.dll"]