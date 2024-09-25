using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class Serviser
{
    public int ServiserId { get; set; }

    public int KorisnikId { get; set; }

    public decimal? Cijena { get; set; }

    public int? BrojServisa { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual ICollection<RezervacijaServisa> RezervacijaServisas { get; set; } = new List<RezervacijaServisa>();
}
