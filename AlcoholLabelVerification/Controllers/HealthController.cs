using Microsoft.AspNetCore.Mvc;

namespace AlcoholLabelVerification.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get() => Ok(new { status = "healthy", timestamp = System.DateTime.UtcNow });
    }
}
