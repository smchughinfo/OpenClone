# Serverless-0 - OpenClone Fallback Page

![OpenClone Serverless-0](/Documentation/serverless-0.png)

## What is this?

This is a static web application that serves as the primary entry point and fallback page for OpenClone self-hosting setups. When deployed to Cloudflare Pages, it performs health checks against the self-hosted OpenClone instance and either redirects users to the live application or provides fallback options including a tutorial video.

The page includes an animated Three.js particle system that visualizes the "clone" concept with orbital spawning effects and dynamic color transitions based on server status. It handles offline scenarios gracefully by offering users alternative ways to access content.

## How to run it

Deploy the static files to Cloudflare Pages or any static hosting platform. The page requires no server-side processing and works entirely in the browser. Point your domain's DNS to the hosting platform and configure it as the primary entry point for your OpenClone domain.

For technical implementation details, see [CLAUDE.md](CLAUDE.md).