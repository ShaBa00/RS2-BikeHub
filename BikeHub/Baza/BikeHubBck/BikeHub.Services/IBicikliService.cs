using BikeHub.Model.BicikliFM;
using BikeHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IBicikliService : IService<Bicikli,BicikliSearchObject>
    {
    }
}
