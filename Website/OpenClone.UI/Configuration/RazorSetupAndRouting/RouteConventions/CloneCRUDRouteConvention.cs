using Microsoft.AspNetCore.Mvc.ApplicationModels;

namespace OpenClone.UI.Configuration.RoutingSetupAndRouting.RouteConventions
{
    public class CloneCRUDRouteConvention : IPageRouteModelConvention
    {
        // what's going on here is for a programming perspective it makes more sense to call it clone CRUD
        // but from a user perspective it could be offensive if the url were called CloneCRUD. so here we tell asp.net to treat /CloneManager as if it were /CloneCRUD
        public void Apply(PageRouteModel model)
        {
            // Only apply this convention to the specific page
            if (model.RelativePath.Contains("/Pages/CloneCRUD", StringComparison.OrdinalIgnoreCase))
            {
                var selectorCount = model.Selectors.Count;
                for (var i = 0; i < selectorCount; i++)
                {
                    var selector = model.Selectors[i];
                    AddSelector(model, selector, "CloneCRUD");
                    AddSelector(model, selector, "CloneManager");
                }
            }
        }

        private void AddSelector(PageRouteModel model, SelectorModel? selector, string route)
        {
            model.Selectors.Add(new SelectorModel
            {
                AttributeRouteModel = new AttributeRouteModel
                {
                    Order = 2, // Ensure this has a lower priority than the original
                    Template = route,
                }
            });
        }
    }
}
