using System.ComponentModel.DataAnnotations;
using DR_HelpDesk.Api.Models;   // for navigation properties

namespace DR_HelpDesk.Api.Models;

public class Contact {
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid CustomerId { get; set; }

    public Guid? CustomerSiteId { get; set; }   // nullable — can be company-level or site-specific

    [Required]
    [MaxLength(100)]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string LastName { get; set; } = string.Empty;

    [EmailAddress]
    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(30)]
    public string? Phone { get; set; }

    [MaxLength(30)]
    public string? Mobile { get; set; }

    [MaxLength(150)]
    public string? Title { get; set; }   // e.g. "IT Manager", "Facilities Coordinator"

    public bool IsPrimary { get; set; } = false;

    [MaxLength(2000)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // Navigation properties (for EF Core)
    public Customer? Customer { get; set; }
    public CustomerSite? CustomerSite { get; set; }
}