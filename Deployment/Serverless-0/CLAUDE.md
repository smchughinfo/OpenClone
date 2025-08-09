# Claude Instructions for Serverless-0

## Overview

Serverless-0 is a static web application that serves as a fallback page for the OpenClone self-hosting setup. It's deployed to Cloudflare Pages and acts as the primary entry point when users visit the OpenClone domain.

## Core Functionality

### Server Status Detection
The page performs health checks against the self-hosted OpenClone instance:
- **Health Check Endpoint**: `https://app.clonezone.me/api/health`
- **Method**: HEAD request with 8-second timeout
- **CORS Mode**: Cross-origin requests enabled
- **Caching**: No-cache headers to ensure fresh status

### Behavioral Logic
1. **Server Online**: Shows "Server Online" status with green indicator and 5-second countdown, then redirects to `https://app.clonezone.me`
2. **Server Offline**: Shows "Server Offline" status with red indicator and displays fallback options

### Fallback Options (When Server Offline)
- **Tutorial Video Button**: Opens embedded YouTube tutorial (`https://www.youtube.com/embed/cZOO1pzmcWQ`)
- **Try Connecting Anyway Button**: Opens `https://app.clonezone.me` in new tab for users who want to attempt connection despite offline status

## Visual Effects

### Three.js Particle System
The page includes an animated particle background with two systems:
1. **Base Particles**: 1000 static particles with blue/teal color scheme
2. **Geometry Particles**: 2000 dynamic particles with orbital spawning effects

### Visual State Changes
- **Offline State**: Blue/teal particles with standard animation
- **Online State**: Particles gradually transition to green during 5-second countdown
- **Clone Effect**: Red spawning particles with green throbbing effect that orbit around parent particles

### Animation Features
- **Galaxy Rotation**: Configurable rotation speed (default: 0.003)
- **Orbital Spawning**: Dynamic radius and speed for particle clones
- **Spawn Frequency**: Adjustable frequency of particle spawning effects
- **Camera Movement**: Slow orbital camera movement for depth

## Implementation Details

### Status Checking
```javascript
async function checkServer() {
    try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 8000);
        
        const response = await fetch('https://app.clonezone.me/api/health', {
            method: 'HEAD',
            mode: 'cors',
            signal: controller.signal,
            cache: 'no-cache'
        });
        clearTimeout(timeoutId);
        return response.ok;
    } catch (error) {
        return false;
    }
}
```

### Redirect Logic
- **5-Second Countdown**: Visual countdown with green particle transition
- **Automatic Redirect**: `window.location.href = 'https://app.clonezone.me'` after countdown
- **Fallback Access**: Manual connection option bypasses health check

## File Structure
- `index.html`: Complete single-page application with embedded CSS/JS
- `favicon.ico`: OpenClone favicon for browser tab/bookmarks

## Deployment Context
- **Cloudflare Pages**: Static hosting platform
- **Domain**: Primary domain entry point (e.g., clonezone.me)
- **CDN**: Uses Cloudflare's global CDN for fast worldwide access
- **External Dependencies**: 
  - Google Fonts (Inter font family)
  - Three.js via CDN (`https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js`)

## Debug Controls
Hidden debug panel (display: none) includes:
- Galaxy rotation speed control
- Orbit radius adjustment  
- Orbit speed modification
- Spawn frequency tuning
- Values persist in localStorage

## Project Etymology
The "Serverless-0" name is a play on words referencing the earlier "Server-0" concept that was a more complex IAC deployment mechanism. This static page approach represents a simpler, more reliable fallback solution - hence "serverless" in contrast to the previous server-based approach.