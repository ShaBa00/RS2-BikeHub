using BikeHub.Model;
using BikeHub.Model.ServisFM;
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
    public class ServiserController : BaseCRUDController<BikeHub.Model.ServisFM.Serviser, ServiserSearchObject, ServiserInsertR, ServiserUpdateR>
    {
        private BikeHubDbContext _context;
        private readonly FunctionHelper _functionHelper;
        private readonly ServiserService _serviserService;
        public ServiserController(IServiserService service, BikeHubDbContext context, FunctionHelper functionHelper) 
        : base(service, context) 
        {
            _functionHelper = functionHelper;
            _context = context;
            _serviserService =  (ServiserService) service;
        }

        [AllowAnonymous]
        public override PagedResult<BikeHub.Model.ServisFM.Serviser> GetList([FromQuery] ServiserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }
        [AllowAnonymous]
        public override BikeHub.Model.ServisFM.Serviser GetById(int id)
        {
            return base.GetById(id); 
        }

        public override BikeHub.Model.ServisFM.Serviser Insert(ServiserInsertR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.IsCurrentUser(currentUsername, request.KorisnikId))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Insert(request);
        }

        public override BikeHub.Model.ServisFM.Serviser Update(int id, ServiserUpdateR request)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (!_functionHelper.CurrentUserServiser(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.Update(id, request);
        }

        public override IActionResult SoftDelete(int id)
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername != null)
            {
                if (_functionHelper.IsUserAdmin(currentUsername))
                {
                    return base.SoftDelete(id);
                }
                if (!_functionHelper.CurrentUserServiser(currentUsername, id))
                {
                    throw new UserException("Ne možete unositi podatke za drugog korisnika.");
                }
            }
            return base.SoftDelete(id);
        }

        [AllowAnonymous]
        [HttpGet("GetServiserDTOList")]
        public ActionResult<PagedResult<BikeHub.Model.Ostalo.ServiserDto>> GetServiserDTOList([FromQuery] ServiserSearchObjectDTO searchObject)
        {
            var result = _serviserService.GetServiserDTOList(searchObject);
            return Ok(result);
        }
    }
}
