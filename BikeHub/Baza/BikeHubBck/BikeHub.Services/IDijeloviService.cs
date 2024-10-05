using BikeHub.Model.DijeloviFM;
using BikeHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IDijeloviService : IService<Model.DijeloviFM.Dijelovi,Model.DijeloviFM.DijeloviSearchObject>
    {
    }
}
