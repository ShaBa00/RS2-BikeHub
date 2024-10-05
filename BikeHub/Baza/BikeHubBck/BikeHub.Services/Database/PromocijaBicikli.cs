using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class PromocijaBicikli
{
    public int PromocijaBicikliId { get; set; }

    public int BiciklId { get; set; }

    public DateTime DatumPocetka { get; set; }

    public DateTime DatumZavrsetka { get; set; }

    public decimal CijenaPromocije { get; set; }

    public string? Status { get; set; }

    public virtual Bicikl Bicikl { get; set; } = null!;
}
