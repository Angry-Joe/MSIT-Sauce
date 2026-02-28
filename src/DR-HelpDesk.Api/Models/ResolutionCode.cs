using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class ResolutionCode
{
    public int ResolutionCodeId { get; set; }

    public string CodeName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
