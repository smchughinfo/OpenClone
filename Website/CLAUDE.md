# Website - Core OpenClone Web Application

## Overview
The Website is the central orchestration layer and user interface for the entire OpenClone system. Built as a .NET 8 ASP.NET application, it manages user authentication, clone creation/management, Q&A training, chat interfaces, and coordinates all backend and third party services (SadTalker, U-2-Net, Database, ElevenLabs, OpenAI).

## Architecture

### **Three-Layer Project Structure**
- **OpenClone.Core**: Shared models, data contexts, DTOs used across multiple projects
- **OpenClone.Services**: Business logic and service layer
- **OpenClone.UI**: Web interface, controllers, Razor pages, React components

**Shared Code Pattern**: Code used by multiple projects moves to Core project (e.g., LogDbContext in Core because both UI and Services need it).

### **Hybrid Frontend Strategy**
**Server-Side**: ASP.NET Razor Pages for page structure, routing, initial data loading
**Client-Side**: React components for everything else, bundled per-page via Webpack

**Benefits**:
- "Access to the metal" - direct HTML/CSS control without SPA framework overhead
- Page-specific JavaScript bundles instead of monolithic SPA bundle
- Server-side rendering for performance and SEO
- React only where rich interaction is needed

### **Webpack Build Pipeline**
```javascript
// this is in /OpenClone.UI/webpack.config.js
entry: {
    answer: './ClientApp/Pages/QA/Answer/Answer.jsx',
    chatbot: './ClientApp/Pages/ChatBot/ChatBot.jsx',
    clonecrud: './ClientApp/Pages/CloneCRUD/CloneCRUD.jsx',
    // ...
}
```
**Flow**: `ClientApp/Pages/` → Webpack → `wwwroot/dist/[name].bundle.js` → Razor pages reference via script tags

**JavaScript Structure**:
- **ClientApp/Pages/**: Entry points referenced by Razor pages
- **ClientApp/Components/**: Reusable components (ConfirmDialog, DeepFakePlayers, etc.)
- **wwwroot/js/**: Traditional JavaScript files outside React bundling
- Co-located CSS files with each component

### **Traditional JavaScript Layer (wwwroot/js/)**
**Service Modules**:
- **audio.js**: Audio file download, duration calculation, blob management
- **camera.js**: WebRTC camera access, photo capture, device enumeration
- **openclone-fs.js**: File path utilities for OpenCloneFS (clone images, audio, videos)
- **network.js**: HTTP utilities and API communication
- **error.js**, **tooltip.js**, **cursor.js**: UI utility functions
- **form-utilities.js**, **cookie.js**: Browser API wrappers

**SignalR Integration**:
- **_openclone-signalr.js**: SignalR connection management with JWT authentication
- **chat-hub.js**: Chat-specific SignalR event handling

**Static Assets**:
- **images/qa-icons/**: Question category icons (personality-traits, interests-hobbies, etc.)
- **images/404s/**: Random cute 404 error page images (serves random image on 404)
- **css/site.css**: Global styles outside component CSS

## Configuration Architecture

### **Modular Configuration Pattern**
Each configurator handles one specific concern, called sequentially from `Program.cs`:

**DbContextConfigurator**:
- Dual connection strings (regular vs super for EF migrations)
- Pgvector extension for vector similarity matching
- Migration-aware connection string selection

**IdentityConfigurator**:
- Google OAuth + JWT Bearer token authentication
- ASP.NET Identity with relaxed password requirements
- HttpContextAccessor DI for service layer user access

**PolicyConfigurator** (Custom Authorization Innovation):
```csharp
AddComputedPolicy(builder, "HasActiveClone", (serviceScope, user) =>
{
    var applicationUserService = serviceScope.ServiceProvider.GetService<ApplicationUserService>();
    var applicationUser = applicationUserService.GetApplicationUser(user.Identity.Name);
    return applicationUser.ActiveCloneId != null;
});
```
- **Database-driven authorization** - policies evaluate against current user state
- **Service layer integration** - full business logic access during authorization
- **StaticServiceProvider pattern** - DI access from non-DI contexts

**Usage Examples**:
```csharp
// Page-level authorization
[Authorize]
[Authorize(Policy="HasActiveClone")]
public class QAModel : PageModel

// Conditional UI elements
var hasClone = (await AuthorizationService.AuthorizeAsync(User, "HasActiveClone")).Succeeded;
<li class="nav-item">
    <a class="nav-link @(hasClone ? "text-dark" : "disabled pointer-events-none")" 
       asp-area="" asp-page="@(hasClone ? "/ChatBot" : "#")">ChatBot</a>
</li>
```

**DevDataConfigurator**:
- Development role/claim setup: "Overlord" (god mode), "SuperUser" (staff), "User" (standard)
- Overloard is cringy. Replace with something better later - UltraSysGod
- ElevenLabs voice creation for hardcoded development clones (IDs 1, 2, 4)
- User-specific permissions (seanmchugh513@gmail.com → Overlord role)

**OpenCloneFSMiddleware**:
- Static file serving from environment-specified OpenCloneFS path
- Access control for clone-specific files
- M3U8 MIME type mapping for HLS video streaming

### **Custom Route Conventions**
**AnswerPageRouteConvention**:
- Single `Answer.cshtml` page handles all question categories
- Dynamic routes generated from database question categories at startup
- URLs like `/QA/Answer/personality-traits-and-characteristics`

**CloneCRUDRouteConvention**:
- URL aliases: `/CloneCRUD` (developer-friendly) and `/CloneManager` (user-friendly)
- Same page, multiple URL patterns

## Technology Stack

**Backend**: .NET 8 (upgraded from .NET 7, some references still need updating)
**Database**: PostgreSQL with Entity Framework Core, pgvector for similarity matching
**Frontend**: ASP.NET Razor Pages + React (no TypeScript - kept JavaScript for simplicity)
**Build**: Webpack with Babel, CSS bundling
**Authentication**: ASP.NET Identity + Google OAuth + JWT
**Real-time**: SignalR for chat functionality (likely overkill for current requirements)

## Core Functionality

### **Clone Management (CloneCRUD)**
- Clone creation, editing, deletion
- Avatar/image management integrated with U-2-Net background removal
- Voice sample management with ElevenLabs integration
- Active clone selection for user sessions

### **Q&A Training System**
- Question categories with custom icons
- Answer management and editing interfaces
- System message builder for AI personality construction
- User-defined questions and round-robin question assignment

### **Chat Interface (ChatBot)**
- Real-time chat with clones via SignalR
- Integration with OpenAI for conversation logic
- Deepfake video generation via SadTalker integration
- Multiple deepfake modes (QuickFake vs full DeepFake)

### **User Management**
- Google OAuth authentication
- Role-based access control (Overlord/SuperUser/User)
- Claims-based fine-grained permissions
- Email confirmation and password reset flows

## Service Integration

### **External Service Coordination**
**SadTalker**: Deepfake video generation
**U-2-Net**: Background removal for clone images
**Database**: PostgreSQL with dual contexts (Application + Logging)
**ElevenLabs**: Text To Speech
**OpenAI**: Clone speech and generative image generator

### **Environment Variables**
**Authentication**:
- `OpenClone_GoogleClientId`, `OpenClone_GoogleClientSecret`
- `OpenClone_JWT_Issuer`, `OpenClone_JWT_Audience`, `OpenClone_JWT_SecretKey`

**Database**:
- `OpenClone_DefaultConnection`, `OpenClone_DefaultConnection_Super`
- `OpenClone_LogDbConnection`, `OpenClone_LogDbConnection_Super`

**Services**:
- `OpenClone_OPENAI_API_KEY`, `OpenClone_ElevenLabsAPIKey`
- `OpenClone_SadTalker_HostAddress`, `OpenClone_U2Net_HostAddress`

**File System**:
- `OpenClone_OpenCloneFS`

**Logging**:
- `OpenClone_OpenCloneLogLevel`, `OpenClone_SystemLogLevel`

## Development Configuration

### **Development vs Production**
- Hard-coded development setup in `Program.cs` (ready to be commented out for production)
- `DevDataConfigurator` creates development users and clones
- ElevenLabs voice cleanup to prevent duplicate name conflicts

### **Migration Handling**
- `OpenClone_EF_MIGRATION=True` triggers super user connection strings
- Some configurators skip during migrations to prevent dependency issues
- Dual database context support (Application + Logging)

## Development Status & Technical Debt

### **CSS/Styling**
**IMPORTANT**: Minimal CSS effort - only functional prototype styling. Do not judge application appearance - UI/UX design work has not been undertaken, only the framework for it.

### **ASP.NET Boilerplate**
- **Areas/Identity/**: Contains unmodified ASP.NET Identity scaffolded pages - needs pruning
- **Boilerplate cleanup**: Not yet removed - time constraints during development

### **SignalR Over-Engineering**
- **Current usage**: Chat functionality
- **Original usage**: Chat functionality with many more features
- **Assessment**: Likely overkill for current requirements
- **Alternative**: Could be simplified to standard AJAX

### **404 Handling**
- Serves random cute error images from `images/404s/` directory

## File Structure
```
Website/
├── OpenClone.sln
├── OpenClone.Core/              # Shared models, data contexts
├── OpenClone.Services/          # Business logic services  
└── OpenClone.UI/               # Web application
    ├── Areas/Identity/         # ASP.NET Identity scaffolded pages (needs cleanup)
    ├── ClientApp/             # React components and pages
    ├── Configuration/         # Modular configuration setup
    ├── Controllers/           # API controllers
    ├── Hubs/                 # SignalR hubs
    ├── Pages/                # Razor pages
    ├── wwwroot/              # Static files and dist bundles
    ├── Program.cs            # Application startup
    ├── webpack.config.js     # Build configuration
    └── package.json          # NPM dependencies
```

## OpenClone.Services Layer

### **Service Architecture Overview**
Standard ASP.NET DI pattern: `Program.cs` → `OpenCloneServicesConfigurator.cs` → `ServicesSetup.cs`
AJAX arrives in controller → Controller injects service → Service executes business logic

**Service Registration Pattern**:
```csharp
// SCOPED (per-request lifetime)
services.AddScoped<QAService, QAService>();
services.AddScoped<EmbeddingService<Question>, EmbeddingService<Question>>();
services.AddScoped<EmbeddingService<Answer>, EmbeddingService<Answer>>();
services.AddScoped<EmbeddingService<GenerativeImage>, EmbeddingService<GenerativeImage>>();

// TRANSIENT (new instance per injection)
services.AddTransient<IEmailSender, EmailSenderService>();
services.AddTransient<AudioService, AudioService>();
```

### **Generics Implementation Quality: Excellent**

**EmbeddingService<T> - Model Generic Implementation**:
```csharp
public class EmbeddingService<T> where T : Embedding, new()
{
    public async Task<List<T>> GetClosest(string text, int limit = 5, 
        Func<DbSet<T>, IQueryable<T>> whereConcreteFilter = null, 
        Func<IOrderedQueryable<T>, IQueryable<T>> orderedConcreteFilter = null, 
        bool saveIfNew = false)
    {
        // Vector similarity search using pgvector
        var whereQueryable = whereConcreteFiltered
            .Where(e => e.Vector != null && e.Text != text)
            .OrderBy(e => e.Vector.CosineDistance(embedding.Vector));
    }
}
```

**Strengths**:
- **Proper type constraints**: `where T : Embedding, new()` ensures type safety
- **Flexible filtering**: Delegate parameters allow concrete type-specific queries
- **Type-safe Entity Framework**: Uses `_applicationDbContext.Set<T>()` correctly
- **Multiple implementations**: Question, Answer, and GenerativeImage embeddings
- **Vector operations**: pgvector integration for cosine distance similarity

### **Service Design Patterns**

**Well-Designed Services**:

**ConfigurationService**: Clean environment variable access
```csharp
public string GetOpenAIKey() => _configuration["OpenClone_OPENAI_API_KEY"];
public string GetSadTalkerHostAddress() => _configuration["OpenClone_SadTalker_HostAddress"];
```

**NetworkService**: Makes network calls simple by expecting and baking in only common use cases
```csharp
[Flags]
public enum CustomHeaders { 
    APIKeyOpenAI=1, APIKeyElevenLabs=2, ExpectMP3=3, ExpectJson=4 
}

// Usage example from EmbeddingService:
var data = new {
    input = text,
    model = "text-embedding-3-small"
};
var embeddingDto = await _networkService.Post<EmbeddingDTO>(_endpointUrl, data, 
    CustomHeaders.APIKeyOpenAI | CustomHeaders.ExpectJson);
```

**Features**:
- **Automatic FormData vs JSON detection** based on FileStream presence
- **Type-safe response casting** (byte[], string, JSON deserialization)
- **Flag-based header management** for common API patterns
- **Built-in error handling** with detailed exception messages

**DeepFakeOrchestrationService**: Coordinates multi-service workflows
- Chat completion → ElevenLabs TTS → SadTalker deepfake → M3U8 streaming
- Proper async/await patterns with file polling

### **Service Architecture Issues & Technical Debt**

**Major Issue - QAService**: 
```csharp
// Line 26 comment in QAService.cs:
// "THIS PLUS THE ANSWER SERVICE NEEDS A REFACTOR OF EPIC PROPORTIONS"
```
- **428 lines** - violates single responsibility principle
- **9 constructor dependencies** - indicates over-coupling
- **Multiple concerns**: Question CRUD, Answer CRUD, embeddings, moderation, user isolation
- **Security noted**: Comments about potential user data leakage between users
- **Transaction management**: Mixed with business logic

**Recommended Refactor**:
- `QuestionService` - Question CRUD operations
- `AnswerService` - Answer CRUD operations  
- `QAModerationService` - Content moderation workflows
- `QAEmbeddingService` - Embedding generation and similarity
- `QASecurityService` - User data isolation enforcement

**Medium Issues**:
- **Service size imbalance**: QAService 428 lines vs AudioService 45 lines
- **Missing interfaces**: Concrete classes limit testability and IoC flexibility
- **Async inconsistency**: Mix of sync and async patterns
- **Error handling variance**: Different exception patterns across services

### **Service Responsibilities**

**Core Business Logic**:
- **QAService**: Question/Answer management, embeddings, moderation (needs refactor)
- **CloneCRUDService**: Clone lifecycle management with transactions
- **CloneMetadataService**: File path resolution and clone configuration
- **ApplicationUserService**: User data access and active clone management

**External Integration**:
- **ElevenLabsService**: TTS generation with voice cloning
- **RenderingService**: SadTalker deepfake coordination
- **CompletionService**: OpenAI chat completions
- **ModerationsService**: OpenAI content moderation

**Infrastructure**:
- **NetworkService**: HTTP client abstraction with API key management
- **ConfigurationService**: Environment variable access
- **AudioService**: File duration calculation and format handling
- **EmailSenderService**: SMTP integration (has a hard coded value that needs replaced with an environment variable)

**AI/ML Services**:
- **EmbeddingService<T>**: Vector embedding generation and similarity search
- **GenerativeImageService**: DALL-E integration for vision boards (images associated with a particular question, all of the images in /OpenCloneFS/GenerativeImages were generated with this service)
- **ChatService**: Conversation management with context building

### **Integration Patterns**

**Service Composition**: Services depend on other services for functionality
```csharp
public DeepFakeOrchestrationService(
    CloneMetadataService cloneMetadataService,
    ChatService chatService, 
    RenderingService renderingService,
    ElevenLabsService elevenLabsService)
```

**Database Access**: All data services use ApplicationDbContext injection
**Configuration Access**: All services use ConfigurationService for environment variables
**HTTP Operations**: External API services use NetworkService for HTTP calls
**Logging**: ILogger injection with category-based logging

### **Database Transaction Patterns**

**CloneCRUDService Transaction Example**:
```csharp
using var transaction = await _applicationDbContext.Database.BeginTransactionAsync();
try 
{
    // Multiple database operations
    await _applicationDbContext.SaveChangesAsync();
    await transaction.CommitAsync();
}
catch 
{
    await transaction.RollbackAsync();
    // Cleanup operations
    throw;
}
```

## OpenClone.Core Layer

### **Shared Foundation**
Contains models, data contexts, DTOs, and extensions used across multiple projects (UI and Services).

**Key Components**:
- **Models**: Entity classes (ApplicationUser, Clone, Question, Answer, ChatMessage, etc.)
- **Data Contexts**: LogDbContext for logging database operations
- **DTOs**: Data transfer objects for cross-layer communication
- **Extensions**: Utility methods (StringExtensions, VectorExtensions, etc.)
- **Interfaces**: Service contracts and abstractions

**AutoMapper Integration**: 
- Configured in ServicesSetup.cs with `services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies())`
- Used for entity-to-DTO mappings throughout the application

### **Migration Management**
**Important**: All EF migrations are managed by the `/Database` project, not the Website project
- Database project deletes and recreates migrations as needed
- Migration files are computer-generated and treated as disposable artifacts  
- OpenClone does not track migration history independently of entity definitions

## HTTPS Self-Hosting Feature

### **Overview**
OpenClone includes built-in HTTPS support with automatic Let's Encrypt SSL certificate management for self-hosting scenarios. This is an **optional feature** for users who want to host OpenClone on their own infrastructure with production-ready SSL certificates.

### **Features**
- **Automatic Let's Encrypt SSL certificates** - production-ready trusted certificates
- **Certificate renewal** with automated cron jobs inside Docker container
- **Smart certificate validation** and regeneration when needed (>30 days remaining check)
- **Force renewal option** for certificate troubleshooting via environment variable
- **Persistent certificate storage** via Docker volume mounts
- **Docker-integrated** - all SSL management happens inside the container

### **Configuration**

**Required Environment Variables**:
```bash
OpenClone_Self_Hosting_Domain=your-domain.com    # Your domain name
OpenClone_Admin_Email=admin@your-domain.com      # Email for Let's Encrypt registration
```

**Optional Environment Variables**:
```bash
FORCE_SSL_RENEWAL=true    # Forces certificate regeneration (use sparingly due to rate limits)
```

### **Network Setup**

**Router Port Forwarding:**
- External port 80 → Internal port 8080 (HTTP redirect to HTTPS)
- External port 443 → Internal port 8443 (HTTPS)

**Windows Firewall Rules** (run as Administrator):
```cmd
netsh advfirewall firewall add rule name="OpenClone HTTP (8080)" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="OpenClone HTTPS (8443)" dir=in action=allow protocol=TCP localport=8443
```

### **How It Works**

1. **Container starts** → SSL setup runs BEFORE web application starts via `docker-entrypoint.sh`
2. **Certificate validation** → Checks for existing valid certificates (>30 days remaining)
3. **Let's Encrypt generation** → Uses HTTP challenge on port 80 for domain validation
4. **Certificate storage** → Copies certificates to `/app/ssl/` for ASP.NET usage
5. **Certificate renewal** → Sets up automatic renewal cron jobs inside container
6. **Application startup** → Launches ASP.NET with HTTPS on ports 8080/8443

### **Certificate Management**

**Automatic Renewal:**
- Cron jobs run twice daily inside container
- Certificates auto-renew when <30 days remaining
- Renewal uses `certbot renew --quiet --deploy-hook "/app/setup-ssl.sh"`

**Force Renewal:**
- Set `FORCE_SSL_RENEWAL=true` environment variable
- Bypasses existing certificate checks
- Use sparingly due to Let's Encrypt rate limits (20 certs/week/domain)

**Certificate Storage:**
- **Host path**: `/Website/SelfHosting/ssl/` (persistent across container recreations)
- **Container path**: `/app/ssl/` (where ASP.NET reads certificates)
- **Files**: `fullchain.pem`, `privkey.pem`

### **SSL File Structure**
```
Website/SelfHosting/
├── docker-entrypoint.sh     # Container startup script with SSL setup
├── setup-ssl.sh            # SSL certificate generation and management
└── ssl/                     # Certificate storage (gitignored)
    ├── fullchain.pem        # Let's Encrypt certificate chain
    └── privkey.pem          # Private key
```

### **Technical Implementation**
- **Let's Encrypt HTTP Challenge**: Uses port 80 for domain validation before web app starts
- **Certificate Storage**: Persistent Docker volume mount preserves certificates across container recreations
- **ASP.NET Integration**: Kestrel configured to load certificates from PEM files at startup
- **Automatic Renewal**: Cron jobs inside container handle certificate renewal without manual intervention
- **Error Handling**: Clear error messages with troubleshooting steps if certificate generation fails

### **Prerequisites**
- Domain must resolve to your server's public IP address
- Port 80 must be accessible from internet for Let's Encrypt validation
- No other services using port 80 during certificate generation
- Container needs internet connectivity to reach Let's Encrypt servers

### **Important Notes**
- This is an **optional feature** - not required for cloud deployments
- Only use this for self-hosting scenarios where you control the infrastructure
- Cloud providers (AWS, Azure, GCP) typically provide their own SSL/TLS solutions
- Let's Encrypt has rate limits: respect them by using certificate reuse and force renewal sparingly

## Build & Development

### **Setup Requirements**
**IMPORTANT**: Before running the website, you must install npm dependencies and build the webpack bundles:

```bash
# Install dependencies
cd /mnt/c/Users/seanm/Desktop/OpenClone/Website/OpenClone.UI
npm install

# Build production bundles (required for website to work)
npm run build

# OR for development with auto-rebuild
npm run dev
```

**Common Issue**: If the website loads but React components don't work and you see 404 errors in browser dev tools for `.bundle.js` files, the webpack bundles haven't been built. Run `npm install` then `npm run build`.

**Environment Note**: If using Windows batch scripts from `/StartStopScripts/WebPack/`, the npm dependencies must be installed in the Windows environment. For WSL development, install and run from WSL.

### **NPM Scripts**
- `npm run build`: Production webpack build (creates `wwwroot/dist/` bundles)
- `npm run dev`: Development build with watch mode (auto-rebuilds on changes)

**Key Dependencies**: React, Babel, Webpack, SignalR client, AutoMapper

**Notes**:
- No TypeScript (kept JavaScript for simplicity)
- Source maps enabled for development (`eval-source-map`)
- CSS injection via style-loader for component-scoped styling

### **Client-Side Library Management**
**IMPORTANT**: The website uses LibMan (Library Manager) to manage client-side libraries like Bootstrap, jQuery, React, etc.

**Current Setup Issue**: The `libman.json` configuration exists but libraries are not automatically restored. This causes 404 errors for missing JavaScript/CSS files referenced in `_Layout.cshtml`.

**Manual Setup Required**: 
```bash
# If LibMan CLI is available:
libman restore

# If LibMan CLI is not available, manually download libraries to wwwroot/lib/:
# - bootstrap@5.3.0 → lib/bootstrap/dist/
# - jquery@3.7.1 → lib/jquery/dist/
# - react@18.2.0 → lib/react/
# - bootstrap-icons@1.11.3 → lib/bootstrap-icons/font/
# - popper.js@2.11.8 → lib/popper.js/umd/
```

**Libraries Referenced in Layout**:
- `~/lib/bootstrap/dist/css/bootstrap.min.css`
- `~/lib/bootstrap-icons/font/bootstrap-icons.min.css`
- `~/lib/jquery/dist/jquery.min.js`
- `~/lib/popper.js/umd/popper.min.js`
- `~/lib/bootstrap/dist/js/bootstrap.bundle.min.js`
- `~/lib/react/react.production.min.js`
- `~/lib/react/react-dom.production.min.js`
- `~/lib/react/babel.min.js`

**Symptoms of Missing Libraries**: 404 errors in browser dev tools, unstyled pages (no Bootstrap), React components not working.

**Proper Solution**: Install LibMan CLI (`dotnet tool install -g Microsoft.Web.LibraryManager.Cli`) and run `libman restore` in OpenClone.UI directory. This should be automated in the Docker build process.