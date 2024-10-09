using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class RecommendedKategorija
{
    public int RecommendedKategorijaId { get; set; }

    public int DijeloviId { get; set; }

    public int BicikliId { get; set; }

    public int? BrojPreporuka { get; set; }

    public DateTime? DatumKreiranja { get; set; }

    public string? Status { get; set; }

    public virtual Bicikl Bicikli { get; set; } = null!;

    public virtual Dijelovi Dijelovi { get; set; } = null!;
}
