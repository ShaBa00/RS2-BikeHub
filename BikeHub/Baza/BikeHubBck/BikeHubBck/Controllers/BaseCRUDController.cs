using BikeHub.Model.Ostalo;
using BikeHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace BikeHubBck.Controllers
{
    public class BaseCRUDController<TModel, TSearch,TInsert, TUpdate> : BaseController<TModel, TSearch>
        where TSearch : BaseSearchObject where TModel : class
    {
        protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;
        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
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
            _service.Aktivacija(id, aktivacija);
            return Ok();
        }
        [HttpPut("zavrsi/{id}")]
        public  IActionResult Zavrsavanje(int id)
        {
            _service.Zavrsavanje(id);
            return Ok();
        }
    }
}
