using Microsoft.EntityFrameworkCore;
using DR_HelpDesk.Api.Models;

namespace DR_HelpDesk.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    // All tables
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<CustomerSite> CustomerSites => Set<CustomerSite>();
    public DbSet<Contact> Contacts => Set<Contact>();
    public DbSet<Ticket> Tickets => Set<Ticket>();
    public DbSet<Employee> Employees => Set<Employee>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Customer → CustomerSite (one-to-many)
        modelBuilder.Entity<CustomerSite>()
            .HasOne(cs => cs.Customer)
            .WithMany()
            .HasForeignKey(cs => cs.CustomerId)
            .OnDelete(DeleteBehavior.Cascade);

        // Customer → Contact (one-to-many)
        modelBuilder.Entity<Contact>()
            .HasOne(c => c.Customer)
            .WithMany()
            .HasForeignKey(c => c.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        // CustomerSite → Contact (optional)
        modelBuilder.Entity<Contact>()
            .HasOne(c => c.CustomerSite)
            .WithMany()
            .HasForeignKey(c => c.CustomerSiteId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);

        // Customer → Ticket (one-to-many)
        modelBuilder.Entity<Ticket>()
            .HasOne(t => t.Customer)
            .WithMany()
            .HasForeignKey(t => t.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        // Contact → Ticket (one-to-many)
        modelBuilder.Entity<Ticket>()
            .HasOne(t => t.Contact)
            .WithMany()
            .HasForeignKey(t => t.ContactId)
            .OnDelete(DeleteBehavior.SetNull);

        // Employee → Ticket (one-to-many, no cascade)
        modelBuilder.Entity<Ticket>()
            .HasOne(t => t.AssignedTo)
            .WithMany()
            .HasForeignKey(t => t.AssignedToEmployeeId)
            .OnDelete(DeleteBehavior.SetNull);

        // Ticket defaults
        modelBuilder.Entity<Ticket>()
            .Property(t => t.Status)
            .HasDefaultValue("Open");

        modelBuilder.Entity<Ticket>()
            .HasIndex(t => t.CustomerEmail);
    }
}