using Microsoft.AspNetCore.Mvc.ApplicationModels;
using OpenClone;
using OpenClone.UI;
using OpenClone.UI.Configuration;

namespace OpenClone.UI.Configuration.RoutingSetupAndRouting.RouteConventions
{
    /// <summary>
    /// This class is what allows the /QA/Answer/category-name urls to all use the same answer.cshtml
    /// </summary>
    public class AnswerPageRouteConvention : IPageRouteModelConvention
    {
        List<string> _questionCategories;
        public AnswerPageRouteConvention(List<string> questionCategories)
        {
            _questionCategories = questionCategories;
        }

        public void Apply(PageRouteModel model)
        {
            // Only apply this convention to the specific page
            if (model.RelativePath.Contains("/QA/Answer", StringComparison.OrdinalIgnoreCase))
            {
                var selectorCount = model.Selectors.Count;
                for (var i = 0; i < selectorCount; i++)
                {
                    var selector = model.Selectors[i];
                    _questionCategories.ForEach(c => AddSelector(model, selector, c));
                    AddSelector(model, selector, "round-robin");
                }
            }
        }

        private void AddSelector(PageRouteModel model, SelectorModel? selector, string category)
        {
            model.Selectors.Add(new SelectorModel
            {
                AttributeRouteModel = new AttributeRouteModel
                {
                    Order = 2, // Ensure this has a lower priority than the original
                    Template = AttributeRouteModel.CombineTemplates(
                                    selector.AttributeRouteModel!.Template,
                                    category),
                }
            });
        }
    }
}
