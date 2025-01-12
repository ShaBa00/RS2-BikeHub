using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model.ServisFM
{
    public class ServiserIzvjestaj
    {
        public string NajaktivnijiServiser { get; set; }
        public int BrojZavrsenihServisa { get; set; }
        public decimal ZbirCijenaZavrsenihServisa { get; set; }
        public string NajboljiServiserTrenutniMjesec { get; set; }
        public decimal ZbirCijenaTrenutniMjesec { get; set; }
        public decimal ProsjecnaOcjenaTrenutniMjesec { get; set; }
        public string NajboljiServiserProsliMjesec { get; set; }
        public decimal ZbirCijenaProsliMjesec { get; set; }
        public decimal ProsjecnaOcjenaProsliMjesec { get; set; }
        public int UkupanBrojServisera { get; set; }
        public int UkupanBrojRezervacija { get; set; }
    }
}
