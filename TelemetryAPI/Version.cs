using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Reflection;

namespace BQSync
{
    public class Version
    {
        private readonly ILogger<Telemetry> _logger;

        public Version(ILogger<Telemetry> logger)
        {
            _logger = logger;
        }

        [Function("version")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest httpRequest)
        {
            // Get the version defined in TelemetryAPI.csproj and return it
            var informationalVersion = Assembly.GetExecutingAssembly()
                                               .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                                               ?.InformationalVersion
                                               .Split('+')[0];

            return new OkObjectResult(new { version = informationalVersion });
        }
    }
}
