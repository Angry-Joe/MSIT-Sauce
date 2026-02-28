using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class ServiceRequest
{
    public int ServiceRequestId { get; set; }

    public string Title { get; set; } = null!;

    public string Description { get; set; } = null!;

    public int RequestorContactId { get; set; }

    public int CustomerId { get; set; }

    public int? SiteId { get; set; }

    public int BusinessServiceId { get; set; }

    public int ServiceCategoryId { get; set; }

    public int ServiceSubcategoryId { get; set; }

    public int ChannelId { get; set; }

    public int ImpactId { get; set; }

    public int UrgencyId { get; set; }

    public int PriorityId { get; set; }

    public int RequestStateId { get; set; }

    public int? OnHoldReasonId { get; set; }

    public bool RequiresTouchLabor { get; set; }

    public int? AssignmentGroupId { get; set; }

    public int? AssignedToEmployeeId { get; set; }

    public string? ResolutionNotes { get; set; }

    public int? ResolutionCodeId { get; set; }

    public int? ResolvedByEmployeeId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime LastModifiedDate { get; set; }

    public DateTime? ResolvedDate { get; set; }

    public DateTime? FirstResponseDate { get; set; }

    public DateTime? SlaDueDate { get; set; }

    public int ReassignmentCount { get; set; }

    public int CommunicationCount { get; set; }

    public virtual Employee? AssignedToEmployee { get; set; }

    public virtual AssignmentGroup? AssignmentGroup { get; set; }

    public virtual BusinessService BusinessService { get; set; } = null!;

    public virtual Channel Channel { get; set; } = null!;

    public virtual Customer Customer { get; set; } = null!;

    public virtual Impact Impact { get; set; } = null!;

    public virtual OnHoldReason? OnHoldReason { get; set; }

    public virtual Priority Priority { get; set; } = null!;

    public virtual RequestState RequestState { get; set; } = null!;

    public virtual Contact RequestorContact { get; set; } = null!;

    public virtual ResolutionCode? ResolutionCode { get; set; }

    public virtual Employee? ResolvedByEmployee { get; set; }

    public virtual ServiceCategory ServiceCategory { get; set; } = null!;

    public virtual ICollection<ServiceRequestNote> ServiceRequestNotes { get; set; } = new List<ServiceRequestNote>();

    public virtual ServiceSubcategory ServiceSubcategory { get; set; } = null!;

    public virtual Site? Site { get; set; }

    public virtual Urgency Urgency { get; set; } = null!;
}
