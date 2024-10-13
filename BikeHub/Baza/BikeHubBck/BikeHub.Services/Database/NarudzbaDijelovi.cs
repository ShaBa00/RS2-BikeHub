using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class NarudzbaDijelovi
{
    public int NarudzbaDijeloviId { get; set; }

    public int NarudzbaId { get; set; }

    public int DijeloviId { get; set; }

    public int Kolicina { get; set; }

    public decimal Cijena { get; set; }

    public string? Status { get; set; }

    public virtual Dijelovi Dijelovi { get; set; } = null!;

    public virtual Narudzba Narudzba { get; set; } = null!;
}
