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
	   libtiff-dev \
	   libwebp-dev \
	   libopenjp2-7 \
	   libgif-dev \
	   zlib1g \
	   ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Create compatibility symlinks for native library filenames some NuGet packages expect
# (e.g. libleptonica-1.82.0.so). If the distro provides a differently-named .so, link it.
RUN set -eux; \
	ldconfig || true; \
	mkdir -p /usr/lib/x86_64-linux-gnu; \
	# Link libleptonica to expected name if a compatible file exists
	for f in /usr/lib/x86_64-linux-gnu/libleptonica*.so* /usr/lib/libleptonica*.so* /usr/local/lib/libleptonica*.so*; do \
	  if [ -e "$f" ]; then \
		ln -sf "$f" /usr/lib/x86_64-linux-gnu/libleptonica-1.82.0.so; \
		break; \
	  fi; \
	done; \
	# Link libtesseract to an expected name
	for f in /usr/lib/x86_64-linux-gnu/libtesseract*.so* /usr/lib/libtesseract*.so* /usr/local/lib/libtesseract*.so*; do \
	  if [ -e "$f" ]; then \
		ln -sf "$f" /usr/lib/x86_64-linux-gnu/libtesseract50.so; \
		break; \
	  fi; \
	done; \
	ldconfig || true

# Ensure Tesseract can find traineddata and native loader can find libraries
ENV TESSDATA_PREFIX=/app/tessdata
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu:/usr/local/lib

COPY --from=build /app/publish .

# Copy critical native .so files into the app folder so the managed loader can find them reliably
# (some native loaders prefer files next to the executable; copying avoids loader search issues)
RUN set -eux; \
	for f in /usr/lib/x86_64-linux-gnu/libleptonica-1.82.0.so* /lib/x86_64-linux-gnu/libleptonica-1.82.0.so*; do \
	  if [ -e "$f" ]; then cp -L "$f" /app/ || true; fi; \
	done; \
	for f in /usr/lib/x86_64-linux-gnu/libtesseract50.so* /lib/x86_64-linux-gnu/libtesseract50.so*; do \
	  if [ -e "$f" ]; then cp -L "$f" /app/ || true; fi; \
	done; \
	ls -l /app | sed -n '1,200p'
# Let the container bind to the PORT variable Railway provides at runtime
EXPOSE 80
# Use a shell entry so the runtime PORT value provided by Railway is expanded into ASPNETCORE_URLS
ENTRYPOINT ["sh","-c","export ASPNETCORE_URLS=http://*:${PORT:-80} && dotnet AlcoholLabelVerification.dll"]
