using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class ResolutionCode
{
    public int ResolutionCodeId { get; set; }

    public string CodeName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
