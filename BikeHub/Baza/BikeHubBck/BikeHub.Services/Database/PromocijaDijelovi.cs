using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class PromocijaDijelovi
{
    public int PromocijaDijeloviId { get; set; }

    public int DijeloviId { get; set; }

    public DateTime DatumPocetka { get; set; }

    public DateTime DatumZavrsetka { get; set; }

    public decimal CijenaPromocije { get; set; }

    public string? Status { get; set; }

    public virtual Dijelovi Dijelovi { get; set; } = null!;
}
