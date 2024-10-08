﻿using BikeHub.Model.DijeloviFM;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public interface IDijeloviService : ICRUDService<Model.DijeloviFM.Dijelovi,Model.DijeloviFM.DijeloviSearchObject,Model.DijeloviFM.DijeloviInsertR,Model.DijeloviFM.DijeloviUpdateR>
    {
    }
}
