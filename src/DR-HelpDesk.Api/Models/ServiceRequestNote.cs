using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class ServiceRequestNote
{
    public int NoteId { get; set; }

    public int ServiceRequestId { get; set; }

    public string NoteText { get; set; } = null!;

    public int CreatedByEmployeeId { get; set; }

    public DateTime CreatedDate { get; set; }

    public bool IsVisibleToCustomer { get; set; }

    public virtual Employee CreatedByEmployee { get; set; } = null!;

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;
}
