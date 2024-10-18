using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class SpaseniBicikli
{
    public int SpaseniBicikliId { get; set; }

    public int BiciklId { get; set; }

    public DateTime DatumSpasavanja { get; set; }

    public string? Status { get; set; }

    public int? KorisnikId { get; set; }

    public virtual Bicikl Bicikl { get; set; } = null!;

    public virtual Korisnik? Korisnik { get; set; }
}
