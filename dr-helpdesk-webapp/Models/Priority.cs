using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class Priority
{
    public int PriorityId { get; set; }

    public string PriorityName { get; set; } = null!;

    public int PriorityLevel { get; set; }

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
