using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

//namespace DRHelpDeskFunctions
namespace DRHelpDeskFunctions.Functions
{
	public class GetSqlData
	{
		private readonly ILogger<GetSqlData> _logger;

		public GetSqlData(ILogger<GetSqlData> logger)
		{
			_logger = logger;
		}

		[Function("GetSqlData")]
		public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
		{
			_logger.LogInformation("C# HTTP trigger function processed a request.");

			var response = req.CreateResponse(HttpStatusCode.OK);
			response.Headers.Add("Content-Type", "text/plain");

			try
			{
				var connectionString = Environment.GetEnvironmentVariable("SqlConnection");
				if (string.IsNullOrEmpty(connectionString))
				{
					await response.WriteStringAsync("ERROR: SqlConnection app setting is missing!");
					return response;
				}

				await using var conn = new SqlConnection(connectionString);
				await conn.OpenAsync();

				await using var cmd = new SqlCommand("SELECT @@VERSION AS SqlVersion, GETDATE() AS ServerTime;", conn);
				await using var reader = await cmd.ExecuteReaderAsync();

				if (await reader.ReadAsync())
				{
					var version = reader["SqlVersion"].ToString();
					var time = reader["ServerTime"].ToString();
					await response.WriteStringAsync($"✅ Connected successfully to your PRIVATE Azure SQL!\n\nSQL Server Version:\n{version}\n\nServer Time: {time}");
				}
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "SQL connection failed");
				await response.WriteStringAsync($"❌ Error connecting to SQL: {ex.Message}");
			}

			return response;
		}
	}
}
