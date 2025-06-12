// add qa -> chatgpt sum this personality -> system prompt
// switch to openvoice and grok

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using Microsoft.Extensions.Options;
using OpenClone.UI.Configuration;
using OpenCloneUI.Configuration;
using Microsoft.AspNetCore.Routing;
using OpenClone.UI;
using Microsoft.Extensions.FileProviders;
using OpenClone.Core;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Hosting.Internal;
using OpenClone.UI.Configuration.RequestMiddleware;
using OpenClone.Core.Services.Logging;
using Microsoft.Extensions.Logging;
using OpenClone.UI.Configuration.Services;
using OpenClone.UI.Configuration.RoutingSetupAndRouting;

// ######################################################################################
// ###### STEP 1: SITE CONFIGURATION AND SERVICE SETUP  #################################
// ######################################################################################

var builder = WebApplication.CreateBuilder(args);

DbContextConfigurator.Configure(builder);
IdentityConfigurator.Configure(builder);
OpenCloneServicesConfigurator.Configure(builder);
RazorPageAndControllerConfigurator.Configure(builder);
JSONConfigurator.Configure(builder);
PolicyConfigurator.Configure(builder);
SignalRConfigurator.ConfigureErrorHandling(builder);

// ######################################################################################
// ###### STEP 2: BUILD THE APP #########################################################
// ######################################################################################

var app = builder.Build();
StaticServiceProvider.ServiceProvider = app.Services; // this allows dependency injection (DI) to be accessed from non-DI-managed classes or static contexts.

// ######################################################################################
// ###### STEP 3: MIDDLEWARE CONFIGURATION AND APPLICATION PIPELINE SETUP ###############
// ######################################################################################

// DEVELOPMENT DATA
DevDataConfigurator.Configure(app).Wait();

// SETUP SERVING FILES FROM FILE SYSTEM
app.UseStaticFiles(); // server from wwwroot
OpenCloneFSMiddleware.SetupURL(app); // server from /OpenCloneFS

// REDIRECT HTTP TO HTTPS
app.UseHttpsRedirection(); // TODO: IMPORTANT - THIS DOESNT SEEM TO WORK (can goto http://127.0.0.1 in container. ...is it a problem though? will be 80 in prod so who cares.

// REDIRECT 404'S TO 404 PAGE
_404Configurator.Configure404(app);

// SIGNALR ROUTES
SignalRConfigurator.ConfigureRoutes(app);

// ###############################
// ##### BEGIN ORDER MATTERS #####
// ###############################

// CONFIGURE CUSTOM MIDDLEWARE
app.UseMiddleware<ExceptionHandlingMiddleware>(); // handle global exceptions, except for SignalR, which uses a custom filter.
app.UseMiddleware<OpenCloneFSMiddleware>(); // allow files to be served from /OpenCloneFS directory

// CONFIGURE ASP.NET MIDDLEWARE
app.UseRouting(); // Configures routing for the application, allowing it to match incoming requests to appropriate endpoints.
app.UseAuthorization(); // Adds the middleware required for authentication and authorization, enabling the application to authenticate and authorize requests.
app.MapRazorPages(); // Configures the routing system to handle Razor Pages, which are used for building UI views and handling user interactions in MVC-based applications.
app.MapControllers(); // Configures the routing system to handle Web API controllers, allowing the application to process API requests and generate JSON responses.
app.MapFallbackToPage("/NotFound"); // app.MapFallbackToPage("/Error"): Ensures any unmatched routes also fall back to the /Error page.

// ###############################
// ###### END ORDER MATTERS ######
// ###############################

#if NET8_0_WINDOWS
ConsoleWindow.Minimize();
#endif
app.Run();