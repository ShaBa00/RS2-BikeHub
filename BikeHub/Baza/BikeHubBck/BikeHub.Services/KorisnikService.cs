﻿using BikeHub.Model.KorisnikFM;
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
    public class KorisnikService : BaseCRUDService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Database.Korisnik, KorisniciInsertR, KorisniciUpdateR>, IKorisnikService
    {
        //public class KorisnikService : BaseService<Model.KorisnikFM.Korisnik, KorisniciSearchObject, Database.Korisnik>, IKorisnikService
        //{
        public KorisnikService(BikeHubDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Korisnik> AddFilter(KorisniciSearchObject search, IQueryable<Database.Korisnik> query)
        {
            var NoviQuery = base.AddFilter(search, query);
            if (!string.IsNullOrWhiteSpace(search?.Username))
            {
                NoviQuery = NoviQuery.Where(x => x.Username.StartsWith(search.Username));
            }
            if (!string.IsNullOrWhiteSpace(search?.Email))
            {
                NoviQuery = NoviQuery.Where(x => x.Email.StartsWith(search.Email));
            }
            if (search?.IsAdmin != null)
            {
                NoviQuery = NoviQuery.Where(x => x.IsAdmin == search.IsAdmin);
            }
            if (search?.IsInfoIncluded == true)
            {
                NoviQuery = NoviQuery.Include(x => x.KorisnikInfos);
            }

            return NoviQuery;
        }

        public override void BeforeInsert(KorisniciInsertR request, Database.Korisnik entity)
        {
            if (request.Lozinka != request.LozinkaPotvrda)
            {
                throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste");
            }
            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            base.BeforeInsert(request, entity);
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

        public override void BeforeUpdate(KorisniciUpdateR request, Database.Korisnik entity)
        {
            base.BeforeUpdate(request, entity);
            if (request.Lozinka != null)
            {
                if (request.Lozinka != request.LozinkaPotvrda)
                {
                    throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste");
                }

                entity.LozinkaSalt = GenerateSalt();
                entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, request.Lozinka);
            }
        }

        public Model.KorisnikFM.Korisnik Promjeni(int id, KorisniciUpdateR request)
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
