using System.ComponentModel.DataAnnotations;
using DR_HelpDesk.Api.Models;   // for navigation properties

namespace DR_HelpDesk.Api.Models;

public class Ticket
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(4000)]
    public string? Description { get; set; }

    public string Status { get; set; } = "Open";   // Open, InProgress, Resolved, Closed

    // Legacy field (we'll migrate away from this later)
    [EmailAddress]
    [MaxLength(150)]
    public string? CustomerEmail { get; set; }

    // === New professional relationships ===
    public Guid? CustomerId { get; set; }
    public Customer? Customer { get; set; }

    public Guid? ContactId { get; set; }
    public Contact? Contact { get; set; }

    // === Employee Assignment (Entra ID ready) ===
    public string? AssignedToEmployeeId { get; set; }   // This will be the Entra ObjectId (GUID string)
    public Employee? AssignedTo { get; set; }

    public DateTime? AssignedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
}