﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.PromocijaFM;

namespace BikeHub.Services
{
    public interface IPromocijaDijeloviService : ICRUDService<PromocijaDijelovi, PromocijaDijeloviSearchObject
                                                            , PromocijaDijeloviInsertR, PromocijaDijeloviUpdateR>
    {
    }
}
