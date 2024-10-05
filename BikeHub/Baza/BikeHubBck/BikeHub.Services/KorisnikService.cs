using BikeHub.Model;
using BikeHub.Model.BicikliFM;
using BikeHub.Model.KorisnikFM;
using BikeHub.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BikeHub.Services
{
    public class KorisnikService : BaseService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Database.Korisnik>, IKorisnikService
    {
        public KorisnikService(BikeHubDbContext context, IMapper mapper)
        : base(context,mapper){        }

        //public virtual PagedResult<Model.KorisnikFM.Korisnik> GetList( Model.KorisnikFM.KorisniciSearchObject searchObject)
        //{
        //    List<Model.KorisnikFM.Korisnik> result = new List<Model.KorisnikFM.Korisnik>();
        //    var query = Context.Korisniks.AsQueryable();
        //    if (!string.IsNullOrWhiteSpace(searchObject?.Username))
        //    {
        //        query = query.Where(x=>x.Username.StartsWith(searchObject.Username));
        //    }
        //    if (!string.IsNullOrWhiteSpace(searchObject?.Email))
        //    {
        //        query = query.Where(x => x.Email.StartsWith(searchObject.Email));
        //    }
        //    if (searchObject?.IsAdmin != null)
        //    {
        //        query = query.Where(x => x.IsAdmin == searchObject.IsAdmin);
        //    }
        //    if (searchObject?.IsInfoIncluded != null)
        //    {
        //        query = query.Include(x=>x.KorisnikInfos);
        //    }
        //    int count = query.Count();
        //    if(searchObject?.Page.HasValue==true && searchObject?.PageSize.HasValue == true)
        //    {
        //        query = query.Skip(searchObject.Page.Value * searchObject.PageSize.Value).Take(searchObject.PageSize.Value);
        //    }

        //    var list = query.ToList();
        //    result = Mapper.Map(list, result);
        //    PagedResult<Model.KorisnikFM.Korisnik> response = new PagedResult<Model.KorisnikFM.Korisnik>();
        //    response.ResultsList = result;
        //    response.Count = count;
        //    return response;
        //}

        public virtual Model.KorisnikFM.Korisnik Insert(KorisniciInsertR request)
        {
            if (request.Lozinka != request.LozinkaPotvrda)
            {
                return null;
            }
            Database.Korisnik entity = new Database.Korisnik();
            Mapper.Map(request, entity);

            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.KorisnikFM.Korisnik>(entity);
        }
        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);

            return Convert.ToBase64String(byteArray);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);

            return Convert.ToBase64String(inArray);
        }

        public Model.KorisnikFM.Korisnik Promjeni(int id, KorisnikPromjeniR request)
        {
            var entity = Context.Korisniks.Find(id);
            Mapper.Map(request, entity);
            if (request.Lozinka != null)
            {
                entity.LozinkaSalt = GenerateSalt();
                entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            }
            Context.SaveChanges();
            return Mapper.Map<Model.KorisnikFM.Korisnik>(entity);
            throw new NotImplementedException();
        }
    }
}
