# Serverless-0 - OpenClone Splash Page

![OpenClone Serverless-0](/Documentation/serverless-0.png)

## What is this?

This is a static web application that serves as the primary splash page for OpenClone. Deployed to Cloudflare Pages, it acts as the main entry point that users see when visiting your OpenClone domain. The page performs real-time health checks against your self-hosted OpenClone instance and either automatically redirects users to the live application after a 5-second countdown, or provides fallback options including a tutorial video when the server is offline.

*Serverless-0 is a play on words. An old version of OpenClone used a rube goldberg deployment strategy called "Server 0". That strategy/approach was subsequently removed. Since this page can be thought of as a "serverless site" the play on words becomes Serverless-0. Get it? ha ha.*

## CloneZone Flow:
- **Server Online** → `https://clonezone.me` redirects to `https://app.clonezone.me`
- **Server Offline** → `https://clonezone.me` shows OpenClone tutorial video as fallback

## How to run it

You'll need to modify the `index.html` file to point to your own domain. Deploy the Serverless-0 files to Cloudflare Pages and use Cloudflare as your name servers. Add `*` and `www` A records pointing to the Cloudflare Page you just setup. Add an `app` A record pointing to the computer you will be hosting on. Configure port forwarding and firewalls as needed.

For technical implementation details, see [CLAUDE.md](CLAUDE.md).