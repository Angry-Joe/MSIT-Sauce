using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class AssignmentGroup
{
    public int AssignmentGroupId { get; set; }

    public Guid? EntraGroupId { get; set; }

    public string GroupName { get; set; } = null!;

    public string? GroupEmail { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<BusinessService> BusinessServices { get; set; } = new List<BusinessService>();

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
