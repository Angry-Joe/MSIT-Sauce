using DR_HelpDesk.Api.Data;
using DR_HelpDesk.Api.Models;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions =>
        {
            sqlOptions.CommandTimeout(300);     // 5 minutes — plenty for cold start
            sqlOptions.EnableRetryOnFailure();   // Auto-retry transient Azure hiccups
        }));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseDeveloperExceptionPage();
}

// Endpoints
app.MapGet("/tickets", async (AppDbContext db) =>
    await db.Tickets.ToListAsync())
    .WithName("GetAllTickets")
    .WithOpenApi();

app.MapPost("/tickets", async (Ticket ticket, AppDbContext db) =>
{
    db.Tickets.Add(ticket);
    await db.SaveChangesAsync();
    return Results.Created($"/tickets/{ticket.Id}", ticket);
})
.WithName("CreateTicket")
.WithOpenApi();

app.Run();