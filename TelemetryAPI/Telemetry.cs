using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace BQSync
{
    public class Telemetry
    {
        private readonly ILogger<Telemetry> _logger;

        public Telemetry(ILogger<Telemetry> logger)
        {
            _logger = logger;
        }

        public readonly string EventHubName = Environment.GetEnvironmentVariable("EventHubName") ?? "";

        [Function("telemetry")]
        public async Task<Output> Run([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest httpRequest)
        {
            try
            {
                using var streamReader = new StreamReader(httpRequest.Body);
                var requestBody = await streamReader.ReadToEndAsync();

                if (string.IsNullOrEmpty(requestBody))
                {
                    return new Output
                    {
                        HttpResponse = new BadRequestObjectResult(new { error = "invalid_format" })
                    };
                }

                var requestBodyObject = JsonObject.Parse(requestBody)!;

                // Add the timestamp as an example of adding to the event payload
                requestBodyObject["timestamp"] = DateTime.UtcNow;

                // Output an HTTP Ok 200 and to Event Hubs/Fabric Real Time Analytics
                return new Output
                {
                    HttpResponse = new OkResult(),
                    TelemetryEvent = JsonSerializer.Serialize(requestBodyObject)
                };
            } 
            catch(Exception e)
            {
                _logger.LogError("{e}", e);
                return new Output
                {
                    HttpResponse = new BadRequestObjectResult(new { error = "unknown_error" })
                };
            }
        }

        public class Output
        {
            [HttpResult]
            public required IActionResult HttpResponse { get; set; }

            [EventHubOutput("", Connection = "EventHubConnectionString")]
            public string? TelemetryEvent { get; set; }
        }
    }
}
