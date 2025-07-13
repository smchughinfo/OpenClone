# Session Memory - July 13, 2025

## Session Overview
Working on server-0 (CloneZone) debugging and OAuth integration setup. Fixed major infrastructure issues and established debugging capabilities.

## Key Accomplishments

### 1. Fixed StartStopScripts run-all.bat
**Problem**: Batch script had incorrect paths (`../BatchScripts/` instead of current directory structure)
**Solution**: Updated all paths to use current directory structure (e.g., `Database\start.bat`, `SadTalker\start.bat`)
**Added**: Website startup and Claude Code integration to the run-all sequence
**Result**: Complete development environment now starts with single command

### 2. Resolved Google OAuth Callback Mismatch
**Problem**: Server-0 OAuth callback URL didn't match Google OAuth configuration
- Server sent: `/auth/google/callback` 
- Google expected: `/signin-google`
**Solution**: Updated server-0 code to use `/signin-google` in both:
- `/Server-0/config/auth.js` - callback URL configuration
- `/Server-0/routes/auth.js` - route handler
**Result**: OAuth flow now works end-to-end

### 3. Created OAuth Success Page
**Implementation**: Added `/auth/user-info` endpoint that displays comprehensive user information after successful Google authentication
**Features**: Beautiful HTML page showing user profile data, with raw JSON view option
**Purpose**: Debugging OAuth flow and verifying user data retrieval

### 4. Built Server-0 Debug Endpoint System
**Endpoint**: `https://clonezone.me/server-0-logs?password=debug123`
**Features**:
- PM2 logs (last 100 lines)
- PM2 process status
- Server information (Node version, uptime, memory)
- System process information
- Both HTML (browser) and JSON (API) formats
**Authentication**: Password-protected using `SERVER_0_LOGS_PASSWORD` environment variable

### 5. Discovered Server-0 Environment Variable Management System
**Location**: `/etc/profile.d/openclone.sh` (53KB file with all OpenClone environment variables)
**Management**: All server-0 secrets and configuration managed in this single file
**Process**: 
```bash
echo 'export SERVER_0_LOGS_PASSWORD="debug123"' >> /etc/profile.d/openclone.sh
pm2 restart clonezone
```
**Benefit**: Consistent with existing infrastructure, automatic PM2 loading

### 6. Established Claude Debug Access
**Discovery**: Claude can directly access server-0 logs using curl
**Command**: `curl -s "https://clonezone.me/server-0-logs?password=debug123"`
**Capability**: Real-time debugging of OAuth issues, environment problems, and server errors
**Documentation**: Updated CLAUDE.md with complete debugging procedures

## Technical Context

### Server-0 Architecture
- **Always-on Node.js application** (CloneZone landing page)
- **Cost optimization strategy**: Cheap always-on front door, expensive GPU resources only on-demand
- **Two-tier system**: Server-0 (always running) + Server-0-Delta (created after payment)
- **IAC container reuse**: Same infrastructure logic across development, Server-0, and Server-0-Delta

### Key Files Modified
- `/StartStopScripts/run-all.bat` - Fixed path references
- `/Server-0/config/auth.js` - OAuth callback URL
- `/Server-0/routes/auth.js` - Route definitions and user info page
- `/Server-0/routes/debug.js` - Debug endpoint (new file)
- `/Server-0/routes/index.js` - Added debug routes
- `/Server-0/.env` - Local development environment variables
- `/Server-0/CLAUDE.md` - Comprehensive documentation updates

### Environment Variables
- **Local**: Uses `.env` file with `SERVER_0_LOGS_PASSWORD=debug123`
- **Production**: Managed in `/etc/profile.d/openclone.sh` with all other OpenClone secrets
- **Consistency**: Same management approach as existing infrastructure

## Current Status
- ✅ OAuth flow works end-to-end (Google → Server-0 → User info display)
- ✅ Debug endpoint accessible and functional
- ✅ Environment variable management established
- ✅ Claude can independently debug server-0 issues
- ✅ Complete development environment startup restored

## Next Steps
- Continue working on Google OAuth integration features
- Test payment processing integration
- Validate cluster provisioning workflow

## Development Workflow Improvements
- **Unified startup**: Single `run-all.bat` command starts entire development environment
- **Real-time debugging**: Claude can fetch live logs during issue reproduction
- **Consistent secrets management**: All environment variables follow same pattern
- **Documentation**: Comprehensive debugging procedures for future sessions

## Important URLs
- **Server-0 Debug Logs**: `https://clonezone.me/server-0-logs?password=debug123`
- **OAuth Test Flow**: `https://clonezone.me/auth/google` → `https://clonezone.me/auth/user-info`
- **Health Check**: `https://clonezone.me/health`

This session established robust debugging infrastructure and resolved critical OAuth integration issues, setting up server-0 for reliable operation and future development work.