using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface INarudzbaBicikliService : ICRUDService<Model.NarudzbaFM.NarudzbaBicikli, Model.NarudzbaFM.NarudzbaBicikliSearchObject,
                                                            Model.NarudzbaFM.NarudzbaBicikliInsertR, Model.NarudzbaFM.NarudzbaBicikliUpdateR>
    {
    }
}
