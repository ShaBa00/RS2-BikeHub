using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class RezervacijaServisa
{
    public int RezervacijaId { get; set; }

    public int KorisnikId { get; set; }

    public int ServiserId { get; set; }

    public DateTime DatumKreiranja { get; set; }

    public DateTime DatumRezervacije { get; set; }

    public decimal? Ocjena { get; set; }

    public string? Status { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;

    public virtual Serviser Serviser { get; set; } = null!;
}
