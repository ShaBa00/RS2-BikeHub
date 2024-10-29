using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.SlikeFM;

namespace BikeHub.Services
{
    public interface ISlikeDijeloviService : ICRUDService<Model.SlikeFM.SlikeDijelovi, Model.SlikeFM.SlikeDijeloviSearchObject,
                                                            Model.SlikeFM.SlikeDijeloviInsertR, Model.SlikeFM.SlikeDijeloviUpdateR>
    {
    }
}
