using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class Urgency
{
    public int UrgencyId { get; set; }

    public string UrgencyName { get; set; } = null!;

    public int UrgencyLevel { get; set; }

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
