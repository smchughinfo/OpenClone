# Use the official .NET 8 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Install Node.js for npm/webpack build
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Copy the solution file and restore dependencies
COPY ["OpenClone.sln", "./"]

# Copy all projects into the Docker image
COPY ["OpenClone.Core/OpenClone.Core.csproj", "OpenClone.Core/"]
COPY ["OpenClone.Services/OpenClone.Services.csproj", "OpenClone.Services/"]
COPY ["OpenClone.UI/OpenClone.UI.csproj", "OpenClone.UI/"]

# Restore dependencies for the solution
RUN dotnet restore

# Copy all the source code into the Docker image
COPY . .

# Build frontend assets BEFORE building .NET
WORKDIR /src/OpenClone.UI
RUN npm install
RUN npm run build

# Build the solution
WORKDIR /src
RUN dotnet build "OpenClone.sln" -c Release -o /app/build

# Publish the main project (the entry point of your app)
RUN dotnet publish "OpenClone.UI/OpenClone.UI.csproj" -c Release -o /app/publish

# Use the official ASP.NET 8 runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Install FFmpeg, Certbot for Let's Encrypt, and cron for certificate renewal
RUN apt-get update && \
    apt-get install -y ffmpeg certbot cron && \
    rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /app/ssl

# Copy the app files from the build stage
COPY --from=build /app/publish .

# Copy SSL setup script
COPY setup-ssl.sh /app/setup-ssl.sh
RUN chmod +x /app/setup-ssl.sh

# Expose both HTTP and HTTPS ports
EXPOSE 80 443

# Create startup script that handles SSL certificate generation
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Set the entry point to our custom script
ENTRYPOINT ["/app/docker-entrypoint.sh"]
