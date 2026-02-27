using System.ComponentModel.DataAnnotations;

namespace DR_HelpDesk.Api.Models;

public class Employee
{
    [Key]  // This will be the Entra ObjectId (GUID as string)
    [Required]
    [MaxLength(50)]
    public string Id { get; set; } = string.Empty;   // e.g. "a1b2c3d4-..." from Entra

    [Required]
    [MaxLength(200)]
    public string DisplayName { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(150)]
    public string? JobTitle { get; set; }

    [MaxLength(100)]
    public string? Department { get; set; }

    [MaxLength(30)]
    public string? Phone { get; set; }

    public bool IsActive { get; set; } = true;

    public bool IsOnCall { get; set; } = false;

    [MaxLength(50)]
    public string? SLATier { get; set; } = "Standard";  // for future reporting

    public DateTime LastSyncedFromEntra { get; set; } = DateTime.UtcNow;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}