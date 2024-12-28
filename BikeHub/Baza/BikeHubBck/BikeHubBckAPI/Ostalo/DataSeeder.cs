using BikeHub.Services.Database;
using System.Security.Cryptography;
using System.Text;

namespace BikeHubBck.Ostalo
{
    public  class DataSeeder
    {
        public static void Seed(BikeHubDbContext context)
        {
            if (!context.Korisniks.Any())
            {
                string salt = GenerateSalt();
                context.Korisniks.AddRange(new List<Korisnik>
            {
                new Korisnik
                {
                    Username = "Admin",
                    Email = "nekiAdmin@edu.fit.ba",
                    LozinkaSalt = salt,
                    LozinkaHash = GenerateHash(salt, "admin"),
                    Status = "aktivan",
                    IsAdmin = true
                },
                new Korisnik
                {
                    Username = "Korisnik",
                    Email = "nekiKorisnik@edu.fit.ba",
                    LozinkaSalt = salt,
                    LozinkaHash = GenerateHash(salt, "korisnik"),
                    Status = "kreiran",
                    IsAdmin = false
                },
                new Korisnik
                {
                    Username = "KorisnikD2",
                    Email = "nekiKorisnikD2@edu.fit.ba",
                    LozinkaSalt = salt,
                    LozinkaHash = GenerateHash(salt, "korisnikd2"),
                    Status = "vracen",
                    IsAdmin = false
                }
            });
                context.SaveChanges();
            }

            if (!context.Adresas.Any())
            {
                context.Adresas.AddRange(new List<Adresa>
            {
                new Adresa { KorisnikId = 1, Grad = "Mostar", PostanskiBroj = "88000", Ulica = "Ulica 1" , Status="aktivan"},
                new Adresa { KorisnikId = 2, Grad = "Sarajevo", PostanskiBroj = "71000", Ulica = "Ulica 2" , Status="kreiran"},
                new Adresa { KorisnikId = 3, Grad = "Tuzla", PostanskiBroj = "75000", Ulica = "Ulica 3", Status="vracen" }
            });
            }
            context.SaveChanges();
            if (!context.KorisnikInfos.Any())
            {
                context.KorisnikInfos.AddRange(new List<KorisnikInfo>
            {
                new KorisnikInfo { KorisnikId = 1, ImePrezime = "Admin Adminović", Telefon = "123456789", BrojNarudbi = 0, BrojServisa = 0 , Status="aktivan"},
                new KorisnikInfo { KorisnikId = 2, ImePrezime = "Korisnik Korisniković", Telefon = "987654321", BrojNarudbi = 2, BrojServisa = 1 , Status="kreiran"},
                new KorisnikInfo { KorisnikId = 3, ImePrezime = "KorisnikD2 Korisniković", Telefon = "112233445", BrojNarudbi = 1, BrojServisa = 0 , Status="vracen"}
            });
            }
            context.SaveChanges();
            if (!context.Kategorijas.Any())
            {
                context.Kategorijas.AddRange(new List<Kategorija>
            {
                new Kategorija { Naziv = "Cestovni bicikli", Status = "aktivan", IsBikeKategorija=true },
                new Kategorija { Naziv = "Planinski bicikli", Status = "aktivan", IsBikeKategorija=true },
                new Kategorija { Naziv = "Gume", Status = "kreiran", IsBikeKategorija=false }
            });
            }

            context.SaveChanges();
        }

        private static string GenerateSalt()
        {
            byte[] byteArray = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(byteArray);
            }
            return Convert.ToBase64String(byteArray);
        }

        private static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            using (HashAlgorithm algorithm = HashAlgorithm.Create("SHA1"))
            {
                return Convert.ToBase64String(algorithm.ComputeHash(dst));
            }
        }
    }
}
