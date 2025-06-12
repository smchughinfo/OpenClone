# Website - Core OpenClone Web Application

[![Website Overview](https://img.youtube.com/vi/SMhwddNQSWQ/0.jpg)](https://www.youtube.com/watch?v=SMhwddNQSWQ)

## What is this?

This is the main OpenClone web application built with .NET 8 ASP.NET Core. It provides the user interface and orchestrates all backend services including authentication, clone management, Q&A training, chat interfaces, and deepfake video generation. The application uses a hybrid architecture combining Razor Pages for server-side rendering with React components for interactive features.

The website coordinates all OpenClone services (Database, SadTalker, U-2-Net, ElevenLabs, OpenAI) and provides role-based access control, Google OAuth authentication, and real-time chat via SignalR.

## Container

Build container: `docker build --no-cache -t openclone-website:1.0 .`

Set all required environment variables (see complete list below). The application requires database connections, API keys for external services, JWT configuration, and service host addresses.

## Setup Requirements

**IMPORTANT**: Before running the website, install npm dependencies and build webpack bundles:

```bash
cd OpenClone.UI
npm install
npm run build
```

If you see 404 errors for JavaScript bundles or React components don't work, run the commands above.

## How to run it

Set required environment variables (see root README.md for complete list). Run the container using `/StartStopScripts/OpenClone/start.bat` or start manually with the docker command. The application runs on port 8080 and requires SadTalker and U-2-Net services to be running for full functionality.

For more technical details and architecture information, see [CLAUDE.md](CLAUDE.md).