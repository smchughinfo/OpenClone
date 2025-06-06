using Microsoft.IdentityModel.Tokens;
using OpenClone.Services.Services;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace OpenClone.UI
{
    public class JWTokenGenerator
    {
        ConfigurationService _configurationService;

        public JWTokenGenerator(ConfigurationService configurationService)
        {
            _configurationService = configurationService;
        }

        public string GenerateJwtToken()
        {
            var secretKey = _configurationService.GetJWTokenKey();
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configurationService.GetJWTokenIssuer(),
                audience: _configurationService.GetJWTokenAudience(),
                expires: DateTime.Now.AddHours(3), // TODO: expire when? ...how to renew?
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
