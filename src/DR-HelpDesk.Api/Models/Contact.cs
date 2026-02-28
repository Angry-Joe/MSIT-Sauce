using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class Contact
{
    public int ContactId { get; set; }

    public int CustomerId { get; set; }

    public int? SiteId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string EmailAddress { get; set; } = null!;

    public string? JobTitle { get; set; }

    public string? PhoneNumber { get; set; }

    public bool IsPrimaryContactForCustomer { get; set; }

    public bool IsPrimaryContactForSite { get; set; }

    public DateTime CreatedDate { get; set; }

    public bool IsActive { get; set; }

    public virtual Customer Customer { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();

    public virtual Site? Site { get; set; }
}
