﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.SlikeFM;

namespace BikeHub.Services
{
    public interface ISlikeBicikliService : ICRUDService<SlikeBicikli, SlikeBicikliSearchObject, SlikeBicikliInsertR, SlikeBicikliUpdateR>
    {
    }
}