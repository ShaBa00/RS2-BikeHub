using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Adresa
{
    public int AdresaId { get; set; }

    public int KorisnikId { get; set; }

    public string Grad { get; set; } = null!;

    public string PostanskiBroj { get; set; } = null!;

    public string Ulica { get; set; } = null!;

    public virtual Korisnik Korisnik { get; set; } = null!;
}
