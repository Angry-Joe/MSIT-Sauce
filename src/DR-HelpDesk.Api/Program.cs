using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Connect to your real Azure SQL database
builder.Services.AddDbContext<DR_HelpDesk.Api.Data.AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

// Basic test
app.MapGet("/", () => "DR-HelpDesk API is running! Middle-earth edition 🧝‍♂️");

// Your real data endpoint - shows all ServiceRequests
app.MapGet("/servicerequests", async (DR_HelpDesk.Api.Data.AppDbContext db) =>
    await db.ServiceRequests.ToListAsync());

app.Run();