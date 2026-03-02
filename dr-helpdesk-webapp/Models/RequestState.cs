using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class RequestState
{
    public int RequestStateId { get; set; }

    public string StateName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
