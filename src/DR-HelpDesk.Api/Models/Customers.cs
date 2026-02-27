using System.ComponentModel.DataAnnotations;

namespace DR_HelpDesk.Api.Models;

public class Customer {
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string CompanyName { get; set; } = string.Empty;

    [MaxLength(50)]
    public string? AccountNumber { get; set; }

    [MaxLength(30)]
    public string? MainPhone { get; set; }

    [EmailAddress]
    [MaxLength(150)]
    public string? MainEmail { get; set; }

    [MaxLength(200)]
    public string? BillingAddress1 { get; set; }

    [MaxLength(200)]
    public string? BillingAddress2 { get; set; }

    [MaxLength(100)]
    public string? City { get; set; }

    [MaxLength(50)]
    public string? State { get; set; }

    [MaxLength(20)]
    public string? Zip { get; set; }

    [MaxLength(100)]
    public string? Country { get; set; } = "USA";

    [MaxLength(150)]
    public string? Website { get; set; }

    public DateTime? ContractStartDate { get; set; }
    public DateTime? ContractEndDate { get; set; }

    [MaxLength(50)]
    public string? SLATier { get; set; } = "Standard";

    public bool IsActive { get; set; } = true;

    [MaxLength(4000)]
    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}