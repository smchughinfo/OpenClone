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
- Co-located CSS files with each component

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
**Real-time**: SignalR for chat functionality

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

## File Structure
```
Website/
├── OpenClone.sln
├── OpenClone.Core/              # Shared models, data contexts
├── OpenClone.Services/          # Business logic services  
└── OpenClone.UI/               # Web application
    ├── Areas/Identity/         # ASP.NET Identity scaffolded pages
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

## Build & Development

**NPM Scripts**:
- `npm run build`: Production webpack build
- `npm run dev`: Development build with watch mode

**Key Dependencies**: React, Babel, Webpack, SignalR client, AutoMapper

**Notes**:
- No TypeScript (kept JavaScript for simplicity)
- Source maps enabled for development (`eval-source-map`)
- CSS injection via style-loader for component-scoped styling