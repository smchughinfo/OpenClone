# Session Memory - June 19, 2025

## Major Issues Resolved

### 1. **413 "Content Too Large" Upload Error - SOLVED ✅**

**Problem**: Users getting 413 errors when uploading images to clone creation page
**Root Cause**: Two-layer issue - both ASP.NET Core and nginx ingress controller had upload limits

**Solutions Applied**:
- **Server-side**: Added FormOptions configuration in `Program.cs:48-52` setting 50MB limits
- **nginx-side**: Added `"nginx.ingress.kubernetes.io/proxy-body-size" = "50m"` annotation to ingress in `IAC/terraform/ssl.tf:201`

**Key Insight**: The error was coming from nginx ingress controller (evidenced by `<center>nginx</center>` in HTML response), not the ASP.NET Core app. Windows development worked because it bypassed nginx entirely.

### 2. **Container CrashLoopBackOff - inotify Limits - SOLVED ✅**

**Problem**: Website container crashing with exit code 139 and inotify limit errors
**Root Cause**: .NET Core file watchers hitting Linux container inotify instance limit (128)

**Comprehensive Solution Applied** in `Program.cs`:
- **Environment variables**: Set `DOTNET_USE_POLLING_FILE_WATCHER=1` and disabled hosting startup assemblies
- **Configuration watching**: Disabled `reloadOnChange` for all JSON config files
- **Static files**: Configured PhysicalFileProvider with `UsePollingFileWatcher=false`

**Critical Learning**: Container environments need file watching disabled entirely for production stability.

### 3. **GPU Memory Issues Identified**

**Problem**: SadTalker deepfake generation failing with CUDA out of memory
**Analysis**: 4GB GPU with 3+ GiB already allocated to multiple processes, trying to allocate additional 488MB
**Status**: Identified need for either larger GPU (8GB+) or request queuing to prevent concurrent deepfake generation

## Technical Architecture Insights

### nginx Ingress Controller Setup
- **Location**: `IAC/terraform/ssl.tf` contains complete nginx ingress configuration
- **SSL**: Automated Let's Encrypt certificate management via cert-manager
- **Key Learning**: Upload limits must be configured at nginx level for Kubernetes deployments

### Container File Watching Strategy
- **Production Philosophy**: Disable all file watchers in containerized environments
- **Development vs Production**: File watching useful for development hot-reload, problematic in containers
- **Implementation**: Multi-layer approach targeting configuration, static files, and Razor views

### OpenClone Project Structure Understanding
- **Hybrid Frontend**: ASP.NET Razor Pages + React components bundled per-page via Webpack
- **Three-layer Architecture**: OpenClone.Core (shared), OpenClone.Services (business logic), OpenClone.UI (web interface)
- **File Upload Flow**: Client → nginx ingress → ASP.NET Core → multipart processing → U-2-Net background removal

## Environment Configurations

### Upload Limit Settings
- **ASP.NET Core**: 50MB FormOptions (MultipartBodyLengthLimit, ValueLengthLimit)
- **nginx Ingress**: 50MB proxy-body-size annotation
- **Rationale**: Conservative 50MB limit balances functionality with resource usage

### Container Deployment Process
1. Webpack build required: `npm run build` in OpenClone.UI directory
2. Docker image build and push to registry
3. Terraform apply to update Kubernetes deployment
4. Rolling update of pods with new configuration

## Key Files Modified

### Core Application Files
- `Website/OpenClone.UI/Program.cs`: File watching disabled, upload limits configured
- `Website/OpenClone.UI/Configuration/RazorSetupAndRouting/RazorPageAndControllerConfigurator.cs`: Static file provider configuration

### Infrastructure Files
- `IAC/terraform/ssl.tf`: nginx ingress upload limit annotation added

### Client-side Files
- `Website/OpenClone.UI/ClientApp/Pages/CloneCRUD/CloneCRUD.jsx`: Image compression implementation (backed out per user request)

## Development Workflow Insights

### Debugging Container Issues
- **Error Patterns**: Exit code 139 = segmentation fault, often inotify limits in .NET containers
- **Log Analysis**: `kubectl logs` and `kubectl describe pod` essential for container troubleshooting
- **Environment Differences**: Local Windows vs Kubernetes Linux containers behave differently

### Upload Error Diagnosis
- **HTTP Response Analysis**: HTML error pages reveal which layer (nginx vs application) is rejecting requests
- **Network Tools**: Browser dev tools network tab shows exact error responses and headers
- **Multi-layer Architecture**: Must check both application and infrastructure layers for upload limits

## Future Considerations

### Performance Optimizations
- **GPU Scaling**: Consider 8GB+ GPU or request queuing for SadTalker
- **Image Compression**: Client-side compression can be re-enabled if needed to reduce upload sizes
- **Caching Strategy**: Static file caching could improve performance

### Production Readiness
- **Monitoring**: File watcher limits should be monitored in production
- **Resource Limits**: Container resource limits may need adjustment based on usage patterns
- **Error Handling**: Upload error user experience could be improved with better feedback

## Claude Code Integration Success

### Effective Collaboration Patterns
- **Systematic Debugging**: Used todo lists to track multi-step problem resolution
- **Architecture Discovery**: Successfully navigated complex codebase structure through exploration tools
- **Infrastructure Understanding**: Identified nginx ingress controller role through terraform analysis

### Tool Usage Highlights
- **Task tool**: Excellent for comprehensive codebase exploration and finding related files
- **Concurrent tool usage**: Parallel file reading for efficient investigation
- **Grep/Glob patterns**: Effective for locating configuration and error patterns

## Status Summary
- ✅ **Upload errors resolved**: Both nginx and ASP.NET Core limits addressed
- ✅ **Container stability**: inotify file watching issues eliminated  
- ⚠️ **GPU capacity**: Identified as bottleneck for deepfake generation
- ✅ **Development workflow**: Established reliable build and deploy process

**Next Session Priorities**: GPU capacity optimization, potential client-side image compression re-implementation, production monitoring setup.