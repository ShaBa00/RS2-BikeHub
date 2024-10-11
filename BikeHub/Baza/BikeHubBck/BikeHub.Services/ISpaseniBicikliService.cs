using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface ISpaseniBicikliService : ICRUDService<Model.SpaseniFM.SpaseniBicikli, Model.SpaseniFM.SpaseniBicikliSearchObject,
                                                            Model.SpaseniFM.SpaseniBicikliInsertR, Model.SpaseniFM.SpaseniBicikliUpdateR>
    {
    }
}
