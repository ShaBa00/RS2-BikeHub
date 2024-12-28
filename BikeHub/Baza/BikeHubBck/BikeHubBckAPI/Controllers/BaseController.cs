using BikeHub.Model;
using BikeHub.Model.Ostalo;
using BikeHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace BikeHubBck.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<TModel,TSearch> : ControllerBase where TSearch : BaseSearchObject
    {
        protected IService<TModel, TSearch> _service;
        
        public BaseController(IService<TModel, TSearch> service)
        {
            _service = service;
        }
        [HttpGet]
        public virtual PagedResult<TModel> GetList([FromQuery] TSearch searchObject)
        {
            return _service.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public virtual TModel GetById(int id)
        {
            return _service.GetById(id);
        }
    }
    
}
