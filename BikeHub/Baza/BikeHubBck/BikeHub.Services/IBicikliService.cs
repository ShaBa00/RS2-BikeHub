using BikeHub.Model.BicikliFM;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IBicikliService : ICRUDService<Bicikli, BicikliSearchObject, BicikliInsertR, BicikliUpdateR>
    {
    }
}
