using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class Impact
{
    public int ImpactId { get; set; }

    public string ImpactName { get; set; } = null!;

    public int ImpactLevel { get; set; }

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
