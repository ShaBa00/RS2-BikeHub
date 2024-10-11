using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface ISpaseniDijeloviService : ICRUDService<Model.SpaseniFM.SpaseniDijelovi, Model.SpaseniFM.SpaseniDijeloviSearchObject,
                                                            Model.SpaseniFM.SpaseniDijeloviInsertR, Model.SpaseniFM.SpaseniDijeloviUpdateR>
    {
    }
}
