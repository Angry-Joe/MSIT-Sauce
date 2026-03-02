using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Authorization;

namespace dr_helpdesk_webapp.Pages
{
    [Authorize]
    public class HelpDeskModel : PageModel {
        public void OnGet() {

        }//public void OnGet()
    }//public class HelpDeskModel : PageModel
}
