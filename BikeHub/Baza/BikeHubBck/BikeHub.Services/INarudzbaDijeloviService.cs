using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface INarudzbaDijeloviService : ICRUDService<Model.NarudzbaFM.NarudzbaDijelovi, Model.NarudzbaFM.NarudzbaDijeloviSearchObject
                                                                , Model.NarudzbaFM.NarudzbaDijeloviInsertR, Model.NarudzbaFM.NarudzbaDijeloviUpdateR>
    {
    }
}
