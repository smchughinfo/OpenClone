using System.Text;
using System.Text.RegularExpressions;

namespace OpenClone.Core.Extensions
{
    public static class StringExtensions
    {
        public static string ConvertToSnakeCase(this string input)
        {
            if (string.IsNullOrEmpty(input)) return input;

            var builder = new StringBuilder();
            builder.Append(char.ToLower(input[0]));

            for (int i = 1; i < input.Length; i++)
            {
                if (char.IsUpper(input[i]))
                {
                    builder.Append('_');
                    builder.Append(char.ToLower(input[i]));
                }
                else
                {
                    builder.Append(input[i]);
                }
            }

            return builder.ToString();
        }

        public static string ConvertCamelCaseToSpaces(this string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return input;

            // Use a regular expression to find positions where a lowercase letter is followed by an uppercase letter.
            var result = Regex.Replace(input, "(?<=.)([A-Z])", " $1");

            return result;
        }
    }
}
