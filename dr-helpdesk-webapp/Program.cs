// Bring in the necessary namespaces
using dr_helpdesk_webapp.Data;
using dr_helpdesk_webapp.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);

// Get the connection string for the main ITSM database (DRHelpDeskDB)
var itsmConnectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

// Register the ITSM Database Context
builder.Services.AddDbContext<DrHelpDeskDbContext>(options =>
    options.UseSqlServer(itsmConnectionString));

// --- Step 3: Standard Service Registration ---
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

builder.Services.AddDefaultIdentity<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ApplicationDbContext>();

builder.Services.AddRazorPages();
builder.Services.AddApplicationInsightsTelemetry(new Microsoft.ApplicationInsights.AspNetCore.Extensions.ApplicationInsightsServiceOptions
{
    ConnectionString = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]
});

var app = builder.Build();

// --- Standard Pipeline Configuration (No changes needed here) ---
if (app.Environment.IsDevelopment()) { app.UseMigrationsEndPoint(); }
else { app.UseExceptionHandler("/Error");app.UseHsts(); }

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();
app.MapRazorPages();
app.Run();
