using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class RequestState
{
    public int RequestStateId { get; set; }

    public string StateName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
