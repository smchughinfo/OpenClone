using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using static System.Formats.Asn1.AsnWriter;
using OpenClone.Services.Services;
using OpenCloneUI;
using OpenCloneUI.Configuration;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.UI.Configuration.RoutingSetupAndRouting.RouteConventions;

namespace OpenClone.UI.Configuration.RoutingSetupAndRouting
{
    public static class RazorPageAndControllerConfigurator
    {
        // #####################################################################################
        // ##### GENERAL #######################################################################
        // #####################################################################################
        public static void Configure(WebApplicationBuilder builder)
        {
            var doingDBRestore = !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("OpenClone_EF_MIGRATION"));
            if (doingDBRestore) {
                return;
            }

            builder.Services.AddRazorPages(options => AddRoutes(builder, options));
            builder.Services.AddControllers();
        }

        private static void AddRoutes(WebApplicationBuilder builder, RazorPagesOptions options)
        {
            ConfigureCloneCrudRoutes(builder, options);
            ConfigureQuestionCategoryRoutes(builder, options);
        }

        // #####################################################################################
        // ##### CLONE CRUD/MANAGER ROUTES #####################################################
        // #####################################################################################

        private static void ConfigureCloneCrudRoutes(WebApplicationBuilder builder, RazorPagesOptions options)
        {
            // this shit doesn't work
            //options.Conventions.AddPageRoute("/Pages/CloneCRUD", "/CloneCRUD");
            //options.Conventions.AddPageRoute("/Pages/CloneCRUD", "/CloneManager");

            // but conventions do...
            options.Conventions.Add(new CloneCRUDRouteConvention());
        }

        // #####################################################################################
        // ##### QUESTION CATEGORY ROUTES ######################################################
        // #####################################################################################

        private static void ConfigureQuestionCategoryRoutes(WebApplicationBuilder builder, RazorPagesOptions options)
        {
            var questionCategories = GetQuestionCategoryUrls(builder);
            options.Conventions.Add(new AnswerPageRouteConvention(questionCategories));
        }

        private static List<string> GetQuestionCategoryUrls(WebApplicationBuilder builder)
        {
            List<string> questionCategories = null;
            using (var serviceProvider = builder.Services.BuildServiceProvider())
            {
                questionCategories = serviceProvider.GetRequiredService<QAService>().GetQuestionCategories().Select(q => q.NameToUrlFriendly()).ToList();
            }
            return questionCategories;
        }
    }
}