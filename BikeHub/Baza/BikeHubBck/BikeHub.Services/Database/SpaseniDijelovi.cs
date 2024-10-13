using System;
using System.Collections.Generic;

namespace BikeHub.Services.Database;

public partial class SpaseniDijelovi
{
    public int SpaseniDijeloviId { get; set; }

    public int DijeloviId { get; set; }

    public DateTime DatumSpasavanja { get; set; }

    public string? Status { get; set; }

    public virtual Dijelovi Dijelovi { get; set; } = null!;
}
