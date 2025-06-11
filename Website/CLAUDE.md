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

## Build & Development

**NPM Scripts**:
- `npm run build`: Production webpack build
- `npm run dev`: Development build with watch mode

**Key Dependencies**: React, Babel, Webpack, SignalR client, AutoMapper

**Notes**:
- No TypeScript (kept JavaScript for simplicity)
- Source maps enabled for development (`eval-source-map`)
- CSS injection via style-loader for component-scoped styling