# Use the official .NET 8 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

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

# Build the solution
RUN dotnet build "OpenClone.sln" -c Release -o /app/build

# Publish the main project (the entry point of your app)
RUN dotnet publish "OpenClone.UI/OpenClone.UI.csproj" -c Release -o /app/publish

# Use the official ASP.NET 8 runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Install FFmpeg
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Copy the app files from the build stage
COPY --from=build /app/publish .

# Set the entry point to your main project DLL
ENTRYPOINT ["dotnet", "OpenClone.UI.dll"]
