using Microsoft.AspNetCore.Mvc;
using BikeHub.Services;
using BikeHub.Model.KorisnikFM;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using BikeHub.Model;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KorisnikController : BaseController<Korisnik, KorisniciSearchObject>
    {
        private readonly IKorisnikService _service;

        public KorisnikController(IKorisnikService service)
            : base(service)
        {
            _service = service;
        }
        //[HttpGet]
        //public virtual PagedResult<Korisnik> GetList([FromQuery]KorisniciSearchObject searchObject)
        //{
        //    return _service.GetList(searchObject);
        //}
        [HttpPost]
        public virtual Korisnik Insert(KorisniciInsertR request)
        {
            return _service.Insert(request);
        }
        [HttpPut("{id}")]
        public virtual Korisnik Promjeni(int id, KorisnikPromjeniR request)
        {
            return _service.Promjeni(id, request);
        }
    }
}
