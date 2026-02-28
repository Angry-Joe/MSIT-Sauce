using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class OnHoldReason
{
    public int OnHoldReasonId { get; set; }

    public string ReasonName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
