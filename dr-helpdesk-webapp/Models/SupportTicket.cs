// Models/SupportTicket.cs
using System.ComponentModel.DataAnnotations;

namespace dr_helpdesk_webapp.Models
{
    public class SupportTicket
    {
        public int Id { get; set; }

        [Required]
        public string Title { get; set; }

        [Required]
        public string Description { get; set; }

        public string Priority { get; set; }  // e.g., "Critical", "High", "Medium", "Low" – per RFP

        public string Status { get; set; } = "Open";

        public string SubmittedByUserId { get; set; }  // Links to AspNetUsers

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Later: public string AssignedTo { get; set; } etc.
    }
}