// Bring in the necessary namespaces
using dr_helpdesk_webapp.Data;
using dr_helpdesk_webapp.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Azure.Identity;

var builder = WebApplication.CreateBuilder(args);

// Get the connection string for the main ITSM database (DRHelpDeskDB)
var itsmConnectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

// Get the connection string for the separate Identity database
var identityConnectionString = builder.Configuration.GetConnectionString("IdentityConnection") ?? throw new InvalidOperationException("Connection string 'IdentityConnection' not found.");

// Register the ITSM Database Context
builder.Services.AddDbContext<DrHelpDeskDbContext>(options =>
    options.UseSqlServer(itsmConnectionString));

// Register the Identity Database Context (for users, logins, etc.)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(identityConnectionString));


// --- Step 3: Standard Service Registration ---
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

builder.Services.AddDefaultIdentity<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ApplicationDbContext>(); // <-- This now correctly points to the Identity DB

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
