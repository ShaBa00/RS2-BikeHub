using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;
using MapsterMapper;
using BikeHub.Model.BicikliFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using BikeHub.Model;
using Microsoft.AspNetCore.Authorization;
using BikeHub.Services.Database;
using BikeHubBck.Ostalo;
using Azure.Core;
using System.Security.Claims;
namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BicikliController : BaseCRUDController<Bicikli,BicikliSearchObject,BicikliInsertR,BicikliUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;

        private readonly BicikliService _bicikliService;
        public BicikliController(IBicikliService service, BikeHubDbContext context, FunctionHelper functionHelper)
        : base(service, context) { _functionHelper = functionHelper;
            _context = context;
            _bicikliService = (BicikliService)service; }

        [AllowAnonymous]
        public override PagedResult<Bicikli> GetList([FromQuery] BicikliSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override Bicikli GetById(int id)
        {
            return base.GetById(id);
        }

        public override Bicikli Insert(BicikliInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }

        public override Bicikli Update(int id, BicikliUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername,request.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }

        public override IActionResult SoftDelete(int id)
        {
            var Bicikl = _context.Bicikls.Find(id);
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null && Bicikl!=null)
            {

                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.IsCurrentUser(currentUsername, Bicikl.KorisnikId.Value))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }

        [HttpGet("promoted-items")]
        [AllowAnonymous]
        public IActionResult GetPromotedItems()
        {
            var result = _bicikliService.GetPromotedItems();
            return Ok(result);
        }
    }
}
