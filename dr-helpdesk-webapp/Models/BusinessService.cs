using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class BusinessService
{
    public int BusinessServiceId { get; set; }

    public string ServiceName { get; set; } = null!;

    public int? DefaultAssignmentGroupId { get; set; }

    public virtual AssignmentGroup? DefaultAssignmentGroup { get; set; }

    public virtual ICollection<ServiceCategory> ServiceCategories { get; set; } = new List<ServiceCategory>();

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
