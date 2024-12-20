﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BikeHub.Model.ServisFM;

namespace BikeHub.Services
{
    public interface IRezervacijaServisaService : ICRUDService<RezervacijaServisa, RezervacijaServisaSearchObject,
                                                                RezervacijaServisaInsertR, RezervacijaServisaUpdateR>
    {
    }
}
