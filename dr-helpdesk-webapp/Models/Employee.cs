using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class Employee
{
    public int EmployeeId { get; set; }

    public Guid? EntraObjectId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string DisplayName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? JobTitle { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<ServiceRequest> ServiceRequestAssignedToEmployees { get; set; } = new List<ServiceRequest>();

    public virtual ICollection<ServiceRequestNote> ServiceRequestNotes { get; set; } = new List<ServiceRequestNote>();

    public virtual ICollection<ServiceRequest> ServiceRequestResolvedByEmployees { get; set; } = new List<ServiceRequest>();

    public virtual ICollection<AssignmentGroup> AssignmentGroups { get; set; } = new List<AssignmentGroup>();
}
