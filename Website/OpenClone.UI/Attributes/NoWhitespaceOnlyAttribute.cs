using System.ComponentModel.DataAnnotations;

namespace OpenClone.UI.Attributes
{
    public class NoWhitespaceOnlyAttribute : ValidationAttribute 
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var stringValue = value as string;

            if (string.IsNullOrWhiteSpace(stringValue))
            {
                return new ValidationResult("The field cannot be empty or contain only whitespace.");
            }

            return ValidationResult.Success;
        }
    }
}
