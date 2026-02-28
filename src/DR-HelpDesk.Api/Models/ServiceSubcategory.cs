using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class ServiceSubcategory
{
    public int ServiceSubcategoryId { get; set; }

    public int ServiceCategoryId { get; set; }

    public string SubcategoryName { get; set; } = null!;

    public virtual ServiceCategory ServiceCategory { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
