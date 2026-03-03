using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using dr_helpdesk_webapp.Models;

namespace dr_helpdesk_webapp.Models;

public partial class DrHelpDeskDbContext : DbContext
{
    public DrHelpDeskDbContext()
    {
    }

    public DrHelpDeskDbContext(DbContextOptions<DrHelpDeskDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AssignmentGroup> AssignmentGroups { get; set; }

    public virtual DbSet<BusinessService> BusinessServices { get; set; }

    public virtual DbSet<Channel> Channels { get; set; }

    public virtual DbSet<Contact> Contacts { get; set; }

    public virtual DbSet<Customer> Customers { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<Impact> Impacts { get; set; }

    public virtual DbSet<OnHoldReason> OnHoldReasons { get; set; }

    public virtual DbSet<Priority> Priorities { get; set; }

    public virtual DbSet<RequestState> RequestStates { get; set; }

    public virtual DbSet<ResolutionCode> ResolutionCodes { get; set; }

    public virtual DbSet<ServiceCategory> ServiceCategories { get; set; }

    public virtual DbSet<ServiceRequest> ServiceRequests { get; set; }

    public virtual DbSet<ServiceRequestNote> ServiceRequestNotes { get; set; }

    public virtual DbSet<ServiceSubcategory> ServiceSubcategories { get; set; }

    public virtual DbSet<Site> Sites { get; set; }

    public virtual DbSet<Urgency> Urgencies { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=tcp:dr-helpdesk-sql-2026.database.windows.net,1433;Initial Catalog=DR-HelpDeskDB;User ID=sqladmin;Password=8uhepumu#uT?a;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AssignmentGroup>(entity =>
        {
            entity.HasIndex(e => e.EntraGroupId, "UQ_AssignmentGroups_EntraGroupID")
                .IsUnique()
                .HasFilter("([EntraGroupID] IS NOT NULL)");

            entity.HasIndex(e => e.GroupName, "UQ_AssignmentGroups_GroupName").IsUnique();

            entity.Property(e => e.AssignmentGroupId).HasColumnName("AssignmentGroupID");
            entity.Property(e => e.EntraGroupId).HasColumnName("EntraGroupID");
            entity.Property(e => e.GroupEmail).HasMaxLength(255);
            entity.Property(e => e.GroupName).HasMaxLength(255);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<BusinessService>(entity =>
        {
            entity.HasIndex(e => e.ServiceName, "UQ_BusinessServices_ServiceName").IsUnique();

            entity.Property(e => e.BusinessServiceId).HasColumnName("BusinessServiceID");
            entity.Property(e => e.DefaultAssignmentGroupId).HasColumnName("DefaultAssignmentGroupID");
            entity.Property(e => e.ServiceName).HasMaxLength(100);

            entity.HasOne(d => d.DefaultAssignmentGroup).WithMany(p => p.BusinessServices)
                .HasForeignKey(d => d.DefaultAssignmentGroupId)
                .HasConstraintName("FK_BusinessServices_DefaultAssignmentGroup");
        });

        modelBuilder.Entity<Channel>(entity =>
        {
            entity.HasKey(e => e.ChannelId).HasName("PK__Channels__38C3E8F42DF208BB");

            entity.HasIndex(e => e.ChannelName, "UQ__Channels__3DC071E92900A74D").IsUnique();

            entity.Property(e => e.ChannelId).HasColumnName("ChannelID");
            entity.Property(e => e.ChannelName).HasMaxLength(50);
        });

        modelBuilder.Entity<Contact>(entity =>
        {
            entity.HasIndex(e => e.CustomerId, "IX_Contacts_CustomerID");

            entity.HasIndex(e => e.SiteId, "IX_Contacts_SiteID");

            entity.HasIndex(e => e.EmailAddress, "UQ_Contacts_EmailAddress").IsUnique();

            entity.Property(e => e.ContactId).HasColumnName("ContactID");
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.CustomerId).HasColumnName("CustomerID");
            entity.Property(e => e.EmailAddress).HasMaxLength(255);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.JobTitle).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.PhoneNumber).HasMaxLength(50);
            entity.Property(e => e.SiteId).HasColumnName("SiteID");

            entity.HasOne(d => d.Customer).WithMany(p => p.Contacts)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Contacts_Customers");

            entity.HasOne(d => d.Site).WithMany(p => p.Contacts)
                .HasForeignKey(d => d.SiteId)
                .HasConstraintName("FK_Contacts_Sites");
        });

        modelBuilder.Entity<Customer>(entity =>
        {
            entity.HasIndex(e => e.CompanyName, "IX_Customers_CompanyName");

            entity.Property(e => e.CustomerId).HasColumnName("CustomerID");
            entity.Property(e => e.Address1).HasMaxLength(255);
            entity.Property(e => e.Address2).HasMaxLength(255);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.CompanyName).HasMaxLength(255);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PhoneNumber).HasMaxLength(50);
            entity.Property(e => e.PostalCode).HasMaxLength(20);
            entity.Property(e => e.StateOrProvince).HasMaxLength(100);
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasIndex(e => e.DisplayName, "IX_Employees_DisplayName");

            entity.HasIndex(e => e.Email, "UQ_Employees_Email").IsUnique();

            entity.HasIndex(e => e.EntraObjectId, "UQ_Employees_EntraObjectID")
                .IsUnique()
                .HasFilter("([EntraObjectID] IS NOT NULL)");

            entity.Property(e => e.EmployeeId).HasColumnName("EmployeeID");
            entity.Property(e => e.DisplayName).HasMaxLength(255);
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.EntraObjectId).HasColumnName("EntraObjectID");
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.JobTitle).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);

            entity.HasMany(d => d.AssignmentGroups).WithMany(p => p.Employees)
                .UsingEntity<Dictionary<string, object>>(
                    "EmployeeGroupMembership",
                    r => r.HasOne<AssignmentGroup>().WithMany()
                        .HasForeignKey("AssignmentGroupId")
                        .HasConstraintName("FK_EmployeeGroupMemberships_AssignmentGroups"),
                    l => l.HasOne<Employee>().WithMany()
                        .HasForeignKey("EmployeeId")
                        .HasConstraintName("FK_EmployeeGroupMemberships_Employees"),
                    j =>
                    {
                        j.HasKey("EmployeeId", "AssignmentGroupId");
                        j.ToTable("EmployeeGroupMemberships");
                        j.IndexerProperty<int>("EmployeeId").HasColumnName("EmployeeID");
                        j.IndexerProperty<int>("AssignmentGroupId").HasColumnName("AssignmentGroupID");
                    });
        });

        modelBuilder.Entity<Impact>(entity =>
        {
            entity.HasKey(e => e.ImpactId).HasName("PK__Impacts__2297C5DD9897179F");

            entity.HasIndex(e => e.ImpactLevel, "UQ__Impacts__5253D8971665694A").IsUnique();

            entity.Property(e => e.ImpactId).HasColumnName("ImpactID");
            entity.Property(e => e.ImpactName).HasMaxLength(50);
        });

        modelBuilder.Entity<OnHoldReason>(entity =>
        {
            entity.HasKey(e => e.OnHoldReasonId).HasName("PK__OnHoldRe__FB9526B563E776BB");

            entity.HasIndex(e => e.ReasonName, "UQ__OnHoldRe__9D4D92B5CD66621C").IsUnique();

            entity.Property(e => e.OnHoldReasonId).HasColumnName("OnHoldReasonID");
            entity.Property(e => e.ReasonName).HasMaxLength(100);
        });

        modelBuilder.Entity<Priority>(entity =>
        {
            entity.HasKey(e => e.PriorityId).HasName("PK__Prioriti__D0A3D0DE7CFDDE70");

            entity.HasIndex(e => e.PriorityName, "UQ__Prioriti__346EBED65DD7A554").IsUnique();

            entity.HasIndex(e => e.PriorityLevel, "UQ__Prioriti__522F1310C6BB2C80").IsUnique();

            entity.Property(e => e.PriorityId).HasColumnName("PriorityID");
            entity.Property(e => e.PriorityName).HasMaxLength(50);
        });

        modelBuilder.Entity<RequestState>(entity =>
        {
            entity.HasKey(e => e.RequestStateId).HasName("PK__RequestS__382E9CC9C5E85D62");

            entity.HasIndex(e => e.StateName, "UQ__RequestS__554763151D794F0B").IsUnique();

            entity.Property(e => e.RequestStateId).HasColumnName("RequestStateID");
            entity.Property(e => e.StateName).HasMaxLength(50);
        });

        modelBuilder.Entity<ResolutionCode>(entity =>
        {
            entity.HasKey(e => e.ResolutionCodeId).HasName("PK__Resoluti__95AE6B593DEC742B");

            entity.HasIndex(e => e.CodeName, "UQ__Resoluti__404488D513C04953").IsUnique();

            entity.Property(e => e.ResolutionCodeId).HasColumnName("ResolutionCodeID");
            entity.Property(e => e.CodeName).HasMaxLength(100);
        });

        modelBuilder.Entity<ServiceCategory>(entity =>
        {
            entity.Property(e => e.ServiceCategoryId).HasColumnName("ServiceCategoryID");
            entity.Property(e => e.BusinessServiceId).HasColumnName("BusinessServiceID");
            entity.Property(e => e.CategoryName).HasMaxLength(100);

            entity.HasOne(d => d.BusinessService).WithMany(p => p.ServiceCategories)
                .HasForeignKey(d => d.BusinessServiceId)
                .HasConstraintName("FK_ServiceCategories_BusinessServices");
        });

        modelBuilder.Entity<ServiceRequest>(entity =>
        {
            entity.HasKey(e => e.ServiceRequestId).HasName("PK__ServiceR__790F6CABA6E36396");

            entity.Property(e => e.ServiceRequestId).HasColumnName("ServiceRequestID");
            entity.Property(e => e.AssignedToEmployeeId).HasColumnName("AssignedToEmployeeID");
            entity.Property(e => e.AssignmentGroupId).HasColumnName("AssignmentGroupID");
            entity.Property(e => e.BusinessServiceId).HasColumnName("BusinessServiceID");
            entity.Property(e => e.ChannelId).HasColumnName("ChannelID");
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.CustomerId).HasColumnName("CustomerID");
            entity.Property(e => e.ImpactId).HasColumnName("ImpactID");
            entity.Property(e => e.LastModifiedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.OnHoldReasonId).HasColumnName("OnHoldReasonID");
            entity.Property(e => e.PriorityId).HasColumnName("PriorityID");
            entity.Property(e => e.RequestStateId).HasColumnName("RequestStateID");
            entity.Property(e => e.RequestorContactId).HasColumnName("RequestorContactID");
            entity.Property(e => e.ResolutionCodeId).HasColumnName("ResolutionCodeID");
            entity.Property(e => e.ResolvedByEmployeeId).HasColumnName("ResolvedByEmployeeID");
            entity.Property(e => e.ServiceCategoryId).HasColumnName("ServiceCategoryID");
            entity.Property(e => e.ServiceSubcategoryId).HasColumnName("ServiceSubcategoryID");
            entity.Property(e => e.SiteId).HasColumnName("SiteID");
            entity.Property(e => e.Title).HasMaxLength(255);
            entity.Property(e => e.UrgencyId).HasColumnName("UrgencyID");

            entity.HasOne(d => d.AssignedToEmployee).WithMany(p => p.ServiceRequestAssignedToEmployees)
                .HasForeignKey(d => d.AssignedToEmployeeId)
                .HasConstraintName("FK__ServiceRe__Assig__395884C4");

            entity.HasOne(d => d.AssignmentGroup).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.AssignmentGroupId)
                .HasConstraintName("FK__ServiceRe__Assig__3864608B");

            entity.HasOne(d => d.BusinessService).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.BusinessServiceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Busin__2EDAF651");

            entity.HasOne(d => d.Channel).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ChannelId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Chann__31B762FC");

            entity.HasOne(d => d.Customer).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Custo__2CF2ADDF");

            entity.HasOne(d => d.Impact).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ImpactId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Impac__32AB8735");

            entity.HasOne(d => d.OnHoldReason).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.OnHoldReasonId)
                .HasConstraintName("FK__ServiceRe__OnHol__367C1819");

            entity.HasOne(d => d.Priority).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.PriorityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Prior__3493CFA7");

            entity.HasOne(d => d.RequestState).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.RequestStateId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Reque__3587F3E0");

            entity.HasOne(d => d.RequestorContact).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.RequestorContactId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Reque__2BFE89A6");

            entity.HasOne(d => d.ResolutionCode).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ResolutionCodeId)
                .HasConstraintName("FK__ServiceRe__Resol__3A4CA8FD");

            entity.HasOne(d => d.ResolvedByEmployee).WithMany(p => p.ServiceRequestResolvedByEmployees)
                .HasForeignKey(d => d.ResolvedByEmployeeId)
                .HasConstraintName("FK__ServiceRe__Resol__3B40CD36");

            entity.HasOne(d => d.ServiceCategory).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ServiceCategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Servi__2FCF1A8A");

            entity.HasOne(d => d.ServiceSubcategory).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.ServiceSubcategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Servi__30C33EC3");

            entity.HasOne(d => d.Site).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.SiteId)
                .HasConstraintName("FK__ServiceRe__SiteI__2DE6D218");

            entity.HasOne(d => d.Urgency).WithMany(p => p.ServiceRequests)
                .HasForeignKey(d => d.UrgencyId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Urgen__339FAB6E");
        });

        modelBuilder.Entity<ServiceRequestNote>(entity =>
        {
            entity.HasKey(e => e.NoteId).HasName("PK__ServiceR__EACE357FC4B88D34");

            entity.Property(e => e.NoteId).HasColumnName("NoteID");
            entity.Property(e => e.CreatedByEmployeeId).HasColumnName("CreatedByEmployeeID");
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.ServiceRequestId).HasColumnName("ServiceRequestID");

            entity.HasOne(d => d.CreatedByEmployee).WithMany(p => p.ServiceRequestNotes)
                .HasForeignKey(d => d.CreatedByEmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ServiceRe__Creat__42E1EEFE");

            entity.HasOne(d => d.ServiceRequest).WithMany(p => p.ServiceRequestNotes)
                .HasForeignKey(d => d.ServiceRequestId)
                .HasConstraintName("FK__ServiceRe__Servi__41EDCAC5");
        });

        modelBuilder.Entity<ServiceSubcategory>(entity =>
        {
            entity.Property(e => e.ServiceSubcategoryId).HasColumnName("ServiceSubcategoryID");
            entity.Property(e => e.ServiceCategoryId).HasColumnName("ServiceCategoryID");
            entity.Property(e => e.SubcategoryName).HasMaxLength(100);

            entity.HasOne(d => d.ServiceCategory).WithMany(p => p.ServiceSubcategories)
                .HasForeignKey(d => d.ServiceCategoryId)
                .HasConstraintName("FK_ServiceSubcategories_ServiceCategories");
        });

        modelBuilder.Entity<Site>(entity =>
        {
            entity.HasIndex(e => e.CustomerId, "IX_Sites_CustomerID");

            entity.Property(e => e.SiteId).HasColumnName("SiteID");
            entity.Property(e => e.Address1).HasMaxLength(255);
            entity.Property(e => e.Address2).HasMaxLength(255);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getutcdate())");
            entity.Property(e => e.CustomerId).HasColumnName("CustomerID");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PostalCode).HasMaxLength(20);
            entity.Property(e => e.SiteName).HasMaxLength(255);
            entity.Property(e => e.SitePhoneNumber).HasMaxLength(50);
            entity.Property(e => e.StateOrProvince).HasMaxLength(100);

            entity.HasOne(d => d.Customer).WithMany(p => p.Sites)
                .HasForeignKey(d => d.CustomerId)
                .HasConstraintName("FK_Sites_Customers");
        });

        modelBuilder.Entity<Urgency>(entity =>
        {
            entity.HasKey(e => e.UrgencyId).HasName("PK__Urgencie__7A92287A9B2FD848");

            entity.HasIndex(e => e.UrgencyLevel, "UQ__Urgencie__053C032113883B68").IsUnique();

            entity.Property(e => e.UrgencyId).HasColumnName("UrgencyID");
            entity.Property(e => e.UrgencyName).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
