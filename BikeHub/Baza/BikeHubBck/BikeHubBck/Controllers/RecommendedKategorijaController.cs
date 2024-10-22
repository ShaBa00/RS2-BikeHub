using BikeHub.Model;
using BikeHub.Model.RecommendedKategorijaFM;
using BikeHub.Services;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RecommendedKategorijaController : BaseCRUDController<BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija, RecommendedKategorijaSearchObject, RecommendedKategorijaInsertR, RecommendedKategorijaUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        public RecommendedKategorijaController(IRecommendedKategorijaService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) { _functionHelper = functionHelper; _context = context; }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija> GetList([FromQuery] RecommendedKategorijaSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija GetById(int id)
        {
            return base.GetById(id);
        }

        public override BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija Insert(RecommendedKategorijaInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsUserAdmin(currentUsername))
                {
                    throw new UserException("Samo administrator moze izvrsiti ovu funkciju");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.RecommendedKategorijaFM.RecommendedKategorija Update(int id, RecommendedKategorijaUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsUserAdmin(currentUsername))
                {
                    throw new UserException("Samo administrator moze izvrsiti ovu funkciju");
                }
            }
            return base.Update(id, request); 
        }

        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsUserAdmin(currentUsername))
                {
                    throw new UserException("Samo administrator moze izvrsiti ovu funkciju");
                }
            }
            return base.SoftDelete(id);
        }
    }
}
