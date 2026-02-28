using System;
using System.Collections.Generic;

namespace DR_HelpDesk.Api.Models;

public partial class Channel
{
    public int ChannelId { get; set; }

    public string ChannelName { get; set; } = null!;

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
