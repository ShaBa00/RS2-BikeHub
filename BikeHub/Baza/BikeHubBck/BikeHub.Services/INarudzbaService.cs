using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface INarudzbaService : ICRUDService<Model.NarudzbaFM.Narudzba, Model.NarudzbaFM.NarudzbaSearchObject,
                                                    Model.NarudzbaFM.NarudzbaInsertR, Model.NarudzbaFM.NarudzbaUpdateR>
    {
    }
}
