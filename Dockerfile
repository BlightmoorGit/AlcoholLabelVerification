# Dockerfile for AlcoholLabelVerification (.NET 8)
# Builds the app and publishes a self-contained image that binds to the PORT env Railway provides

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy everything and restore/publish the project
COPY . .
RUN dotnet restore "AlcoholLabelVerification/AlcoholLabelVerification.csproj"
RUN dotnet publish "AlcoholLabelVerification/AlcoholLabelVerification.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install native dependencies required by Tesseract on Linux (Railway uses Linux containers)
# Keep the image lean and remove apt lists after install
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   tesseract-ocr \
	   libtesseract-dev \
	   libleptonica-dev \
	   libpng-dev \
	   libjpeg-dev \
	   ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# Let the container bind to the PORT variable Railway provides at runtime
EXPOSE 80
# Use a shell entry so the runtime PORT value provided by Railway is expanded into ASPNETCORE_URLS
ENTRYPOINT ["sh","-c","export ASPNETCORE_URLS=http://*:${PORT:-80} && dotnet AlcoholLabelVerification.dll"]
