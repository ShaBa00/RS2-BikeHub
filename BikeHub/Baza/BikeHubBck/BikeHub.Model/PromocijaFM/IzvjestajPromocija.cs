using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.PromocijaFM
{
    public class IzvjestajPromocija
    {
        public decimal UkupnaZarada { get; set; }
        public int BrojPromocija { get; set; }
        public int BrojAktivnihPromocija { get; set; }
        public decimal ZbirCijenePromocijaTrenutniMjesec { get; set; }
        public int BrojPromocijaTrenutniMjesec { get; set; }
        public decimal ZbirCijenePromocijaProsliMjesec { get; set; }
        public int BrojPromocijaProsliMjesec { get; set; }
        public string MjesecSaNajvisePromocija { get; set; }
        public decimal NajvecaZaradaMjeseca { get; set; }
    }
}
