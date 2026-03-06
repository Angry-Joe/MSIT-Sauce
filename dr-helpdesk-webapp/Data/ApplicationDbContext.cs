using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Azure.Identity;  // Add if missing (NuGet: Azure.Identity)

namespace dr_helpdesk_webapp.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Add your custom DbSets here (e.g., for support tickets)
        // Example: public DbSet<SupportTicket> SupportTickets { get; set; }  // We'll define SupportTicket model later

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);  // Calls Identity's model setup
            // Add any custom configurations here if needed (e.g., table mappings)
        }
    }
}
