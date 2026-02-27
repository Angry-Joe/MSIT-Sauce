using System.ComponentModel.DataAnnotations;
using DR_HelpDesk.Api.Models;   // for the Customer navigation property

namespace DR_HelpDesk.Api.Models;

public class CustomerSite {
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid CustomerId { get; set; }

    [Required]
    [MaxLength(150)]
    public string SiteName { get; set; } = string.Empty;

    [MaxLength(200)]
    public string? Address1 { get; set; }

    [MaxLength(200)]
    public string? Address2 { get; set; }

    [MaxLength(100)]
    public string? City { get; set; }

    [MaxLength(50)]
    public string? State { get; set; }

    [MaxLength(20)]
    public string? Zip { get; set; }

    [MaxLength(100)]
    public string? Country { get; set; } = "USA";

    [MaxLength(30)]
    public string? SitePhone { get; set; }

    public bool IsPrimary { get; set; } = false;

    [MaxLength(2000)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation property (for EF Core relationships)
    public Customer? Customer { get; set; }
}