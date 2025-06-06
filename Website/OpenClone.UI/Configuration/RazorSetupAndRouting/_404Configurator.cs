namespace OpenClone.UI.Configuration.RoutingSetupAndRouting
{
    public static class _404Configurator
    {
        public static void Configure404(WebApplication app)
        {
            app.UseStatusCodePages(context =>
            {
                /*
                 *  so all usestatuscodepages does in this case it redirect things that have already been flagged as 404 to /Error?
                    ChatGPT
                    Yes, that's correct. In your case, app.UseStatusCodePages is specifically handling requests that have already been flagged with a 404 status code and redirecting them to /Error.
                 */
                if (context.HttpContext.Response.StatusCode == 404)
                {
                    context.HttpContext.Response.Redirect("/NotFound");
                }
                return Task.CompletedTask;
            });
        }
    }
}
