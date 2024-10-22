using BikeHub.Model.Ostalo;
using BikeHub.Services;
using BikeHub.Services.Database;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BikeHubBck.Controllers
{
    public class BaseCRUDController<TModel, TSearch,TInsert, TUpdate> : BaseController<TModel, TSearch>
        where TSearch : BaseSearchObject where TModel : class
    {
        private BikeHubDbContext _context;
        protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;
        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service, BikeHubDbContext context) : base(service)
        {
            _service = service;
            _context = context;
        }
        [HttpPost]
        public virtual TModel Insert(TInsert request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        public virtual TModel Update(int id, TUpdate request)
        {
            return _service.Update(id, request);
        }
        [HttpDelete("{id}")]
        public virtual IActionResult SoftDelete(int id)
        {
            _service.SoftDelete(id);
            return Ok(); 
        }
        [HttpPut("aktivacija/{id}")]
        public virtual IActionResult Aktivacija(int id, [FromQuery] bool aktivacija)
        {
            if (!IsUserAdmin())
            {
                return Unauthorized("Samo administratori mogu izvršiti aktivaciju.");
            }
            _service.Aktivacija(id, aktivacija);
            return Ok();
        }
        [HttpPut("zavrsi/{id}")]
        public  IActionResult Zavrsavanje(int id)
        {
            if (!IsUserAdmin())
            {
                return Unauthorized("Samo administratori mogu izvršiti aktivaciju.");
            }
            _service.Zavrsavanje(id);
            return Ok();
        }

        protected bool IsUserAdmin()
        {
            var currentUsername = HttpContext.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (currentUsername == null)
            {
                return false;
            }

            var currentUser = _context.Korisniks.FirstOrDefault(x=>x.Username== currentUsername);
            return currentUser?.IsAdmin ?? false;
        }
    }
}
