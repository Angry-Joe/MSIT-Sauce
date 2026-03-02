using System;
using System.Collections.Generic;

namespace dr_helpdesk_webapp.Models;

public partial class ServiceCategory
{
    public int ServiceCategoryId { get; set; }

    public int BusinessServiceId { get; set; }

    public string CategoryName { get; set; } = null!;

    public virtual BusinessService BusinessService { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();

    public virtual ICollection<ServiceSubcategory> ServiceSubcategories { get; set; } = new List<ServiceSubcategory>();
}
