using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class NarudzbaBicikli
{
    public int NarudzbaBicikliId { get; set; }

    public int NarudzbaId { get; set; }

    public int BiciklId { get; set; }

    public int Kolicina { get; set; }

    public decimal Cijena { get; set; }

    public virtual Bicikl Bicikl { get; set; } = null!;

    public virtual Narudzba Narudzba { get; set; } = null!;
}
