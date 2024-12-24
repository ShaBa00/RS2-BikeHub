// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sized_box_for_whitespace, empty_catches, use_build_context_synchronously, prefer_const_literals_to_create_immutables, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:bikehub_mobile/screens/dodavanje/promocija_zapisa.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikovi_proizvodi.dart';
import 'package:bikehub_mobile/screens/ostalo/prikaz_slika.dart';
import 'package:bikehub_mobile/screens/prikaz/dijelovi_prikaz.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_promocija_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_sacuvani_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_slike_servis.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_recomended_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_bicikl_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BicikliPrikaz extends StatefulWidget {
  final int biciklId;

  BicikliPrikaz({super.key, required this.biciklId});

  @override
  _BicikliPrikazState createState() => _BicikliPrikazState();
}

class _BicikliPrikazState extends State<BicikliPrikaz> {
  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  final BiciklService _biciklService = BiciklService();
  final KategorijaServis _kategorijaServis = KategorijaServis();
  final AdresaServis _adresaServis = AdresaServis();
  final KorisnikServis _korisnikServis = KorisnikServis();
  final KategorijaRecommendedService _kategorijaRecommendedService =
      KategorijaRecommendedService();
  final BiciklSlikeService _biciklSlikeService = BiciklSlikeService();
  final BiciklSacuvaniServis _biciklSacuvaniServis = BiciklSacuvaniServis();
  final BiciklPromocijaService _biciklPromocijaService =
      BiciklPromocijaService();
  final NarudbaBiciklService _narudbaBiciklService = NarudbaBiciklService();
  final NarudbaService _narudbaService = NarudbaService();

  bool loadingZapisi = true;
  Map<String, dynamic>? zapis;
  Map<String, dynamic>? kategorija;
  Map<String, dynamic>? adresa;
  bool isPromovisan = false;

  bool sacuvanZapisi = false;
  Map<String, dynamic>? zapisSacuvanog;
  bool? isLoggedInCache;

  _getSpaseni() async {
    isLoggedInCache ??= await _korisnikServis.isLoggedIn();
    if (isLoggedInCache == true) {
      zapisSacuvanog = await _biciklSacuvaniServis.isBiciklSacuvan(
          korisnikId: korisnikId, biciklId: widget.biciklId);
      if (zapisSacuvanog != null && zapisSacuvanog?['status'] != "obrisan") {
        sacuvanZapisi = true;
      }
      setState(() {
        sacuvanZapisi;
      });
    }
  }

  _getKategorija() async {
    try {
      var result =
          await _kategorijaServis.getKategorijaById(zapis?['kategorijaId']);
      setState(() {
        kategorija = result;
        loadingZapisi = false;
      });
    } catch (e) {}
    try {
      final kategorije = await _kategorijaServis.getKategorije(
        isBikeKategorija: true,
      );
      if (kategorije != null && kategorije.isNotEmpty) {
        setState(() {
          _kategorijeBicikl = kategorije;
          _odabranaKategorijaBicikl = null;
        });
      }
    } catch (e) {}
  }

  _getAdresa() async {
    try {
      var result =
          await _adresaServis.getAdresa(korisnikId: zapis?['korisnikId']);
      setState(() {
        adresa = result;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  List<dynamic> listaRecomendedDijelova = [];
  _getRecomended() async {
    try {
      await _kategorijaRecommendedService.getRecommendedDijelovis(
          biciklID: widget.biciklId);
      setState(() {
        listaRecomendedDijelova =
            _kategorijaRecommendedService.listaRecomendedDijelova;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  List<String> listaSlik = [];
  List<String> listaIdova = [];
  String statusPrijavljenog = "kreiran";

  _initialize() async {
    try {
      var userInfo = await _korisnikServis.getUserInfo();
      setState(() {
        korisnikId = int.tryParse(userInfo['korisnikId'] ?? '0') ?? 0;
        statusPrijavljenog = userInfo['status'] ?? 'kreiran';
      });
      var result = await _biciklService.getBiciklById(widget.biciklId);
      isPromovisan =
          await _biciklPromocijaService.isPromovisan(biciklId: widget.biciklId);
      setState(() {
        isPromovisan;
        zapis = result;
        listaSlik = (result['slikeBiciklis'] as List<dynamic>?)
                ?.where(
                    (item) => item['slika'] != null && item['slika'].isNotEmpty)
                .map<String>((item) => item['slika'] as String)
                .toList() ??
            [];
        listaIdova = (result['slikeBiciklis'] as List<dynamic>?)
                ?.where((item) => item['slikeBicikliId'] != null)
                .map<String>((item) => item['slikeBicikliId'].toString())
                .toList() ??
            [];

        zapis = result;
        _getSpaseni();
        _getAdresa();
        _getRecomended();
        _getKategorija();
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  naruci() async {
    isLoggedInCache ??= await _korisnikServis.isLoggedIn();

    if (!isLoggedInCache!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Samo prijavljeni korisnici mogu naručiti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.yellow,
        ),
      );
      return;
    }

    showCustomPopup(context);
  }

  Future<void> spaseniUpravljanje() async {
    isLoggedInCache ??= await _korisnikServis.isLoggedIn();

    if (!isLoggedInCache!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Samo prijavljeni korisnici mogu spasiti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.yellow,
        ),
      );
      return;
    }

    String? poruka;
    if (zapisSacuvanog != null) {
      if (zapisSacuvanog?['status'] != "obrisan") {
        poruka = await _biciklSacuvaniServis.promjeniSacuvani(
            zapisSacuvanog?['spaseniBicikliId'],
            zapisSacuvanog?['korisnikId'],
            zapisSacuvanog?['biciklId'],
            true);
      } else {
        poruka = await _biciklSacuvaniServis.promjeniSacuvani(
            zapisSacuvanog?['spaseniBicikliId'],
            zapisSacuvanog?['korisnikId'],
            zapisSacuvanog?['biciklId'],
            false);
      }
    } else {
      poruka = await _biciklSacuvaniServis.dodajNoviSacuvani(
        widget.biciklId,
        korisnikId,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          poruka!,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true); // Vrati rezultat
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.06),
          child: AppBar(
            backgroundColor: Colors.blueAccent,
            iconTheme: IconThemeData(color: Colors.white),
            title: Row(
              children: [
                Expanded(
                  flex: 75,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Bicikli Prikaz',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 82, 205, 210),
                          Color.fromARGB(255, 7, 161, 235),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: MediaQuery.of(context).size.height * 0.055,
                    child: Visibility(
                      visible: !loadingZapisi,
                      child: ElevatedButton(
                        onPressed: () {
                          spaseniUpravljanje();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(0, 255, 82, 82),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Icon(
                          sacuvanZapisi
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            centralniDio(context),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const NavBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

//
  Widget centralniDio(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 205, 238, 239),
                  Color.fromARGB(255, 165, 196, 210),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: loadingZapisi
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        slikaDio(context),
                        pDio(context),
                        dDio(context),
                        tDio(context),
                        cDio(context),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget slikaDio(BuildContext context) {
    if (loadingZapisi) {
      return Center(child: CircularProgressIndicator());
    } else if (zapis == null) {
      return Center(child: Text('Greška pri učitavanju podataka.'));
    } else if (zapis!['slikeBiciklis'] != null) {
      // Pretipkavanje liste
      List<Map<String, dynamic>> slikeBiciklis =
          (zapis!['slikeBiciklis'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();

      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.35,
        color: const Color.fromARGB(255, 255, 2, 2),
        child: PrikazSlike(
          slikeBiciklis: slikeBiciklis,
          isPromovisan: isPromovisan,
        ),
      );
    } else {
      return Center(child: Text('Nema slika za prikaz.'));
    }
  }

  Widget pDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      color: Color.fromARGB(0, 2, 175, 255),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.08,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 82, 205, 210),
                Color.fromARGB(255, 7, 161, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.475,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        zapis?['naziv'] ?? 'N/A',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.475,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border(
                        bottom: BorderSide(color: Colors.white),
                        left: BorderSide(color: Colors.white),
                        right: BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${zapis?['cijena']?.toString() ?? 'N/A'} KM',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.48,
      color: Color.fromARGB(0, 82, 255, 2),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 82, 205, 210),
                Color.fromARGB(255, 7, 161, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Velicina rama",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            zapis?['velicinaRama']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Velicina tocka",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            zapis?['velicinaTocka']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Broj brzina",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            zapis?['brojBrzina']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Kolicina",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            zapis?['kolicina']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Kategorija",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.37,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            kategorija?['naziv']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.74,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 5),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${adresa?['grad']?.toString() ?? 'N/A'}, ${adresa?['ulica']?.toString() ?? 'N/A'}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      color: Color.fromARGB(0, 247, 255, 2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: korisnikId != zapis?['korisnikId']
                    ? GestureDetector(
                        onTap: () => naruci(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.05,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border(
                                bottom: BorderSide(color: Colors.white),
                                right: BorderSide(color: Colors.white),
                                left: BorderSide(color: Colors.white),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Naruci",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => prikaziPopup(context),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white),
                                    right: BorderSide(color: Colors.white),
                                    left: BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Edituj",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PromocijaZapisa(
                                            zapisId: widget.biciklId,
                                            isBicikl: true,
                                          )),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border(
                                    bottom: BorderSide(color: Colors.white),
                                    right: BorderSide(color: Colors.white),
                                    left: BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Promovisi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.01,
              color: Color.fromARGB(0, 244, 67, 54),
            ),
          ],
        ),
      ),
    );
  }

  Widget cDio(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      color: Color.fromARGB(0, 2, 175, 255),
      child: Center(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.33,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 205, 238, 239),
                        Color.fromARGB(255, 165, 196, 210),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0;
                            i <
                                (listaRecomendedDijelova.length > 5
                                    ? 5
                                    : listaRecomendedDijelova.length);
                            i++)
                          GestureDetector(
                            onTap: () {
                              int dijeloviId =
                                  listaRecomendedDijelova[i]['dijeloviId'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DijeloviPrikaz(dijeloviId: dijeloviId),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: MediaQuery.of(context).size.height * 0.24,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 82, 205, 210),
                                    Color.fromARGB(255, 7, 161, 235),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.19,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child: listaRecomendedDijelova[i]
                                                    ['slikeDijelovis'] !=
                                                null &&
                                            listaRecomendedDijelova[i]
                                                    ['slikeDijelovis']
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30.0),
                                              topRight: Radius.circular(30.0),
                                            ),
                                            child: Image.memory(
                                              base64Decode(
                                                  listaRecomendedDijelova[i]
                                                          ['slikeDijelovis'][0]
                                                      ['slika']),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.image_not_supported,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                          ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            alignment: Alignment.center,
                                            child: Text(
                                              listaRecomendedDijelova[i]
                                                      ?['naziv'] ??
                                                  'N/A',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            alignment: Alignment.center,
                                            child: Text(
                                              (listaRecomendedDijelova[i]
                                                          ?['cijena']
                                                      ?.toString() ??
                                                  'N/A'),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.01,
              color: Color.fromARGB(0, 244, 67, 54),
            ),
          ],
        ),
      ),
    );
  }

  int currentIndexPopUp = 0;
  int currentIndexSlike = 0;

  void prikaziPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 0) {
                      setState(() {
                        currentIndexPopUp = 0;
                      });
                    } else if (details.primaryVelocity! < 0) {
                      setState(() {
                        currentIndexPopUp = 1;
                      });
                    }
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 82, 205, 210),
                        Color.fromARGB(255, 7, 161, 235),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.03,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Moguce je promjenuti jednu, ili sve vrijednosti",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.03,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      currentIndexPopUp == 0
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.72,
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  // Container za prikaz slika
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.32,
                                    child: listaSlik.isNotEmpty
                                        ? GestureDetector(
                                            onHorizontalDragEnd: (details) {
                                              if (details.primaryVelocity !=
                                                  null) {
                                                if (details.primaryVelocity! >
                                                    0) {
                                                  setState(() {
                                                    currentIndexSlike =
                                                        (currentIndexSlike -
                                                                1 +
                                                                listaSlik
                                                                    .length) %
                                                            listaSlik.length;
                                                  });
                                                } else if (details
                                                        .primaryVelocity! <
                                                    0) {
                                                  setState(() {
                                                    currentIndexSlike =
                                                        (currentIndexSlike +
                                                                1) %
                                                            listaSlik.length;
                                                  });
                                                }
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.memory(
                                                base64Decode(listaSlik[
                                                    currentIndexSlike]),
                                                fit: BoxFit.cover,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.32,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                          ),
                                  ),
                                  // Container za dugmiće
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        if (listaSlik.isNotEmpty)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.lightBlue,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                listaSlik.removeAt(
                                                    currentIndexSlike);
                                                if (listaSlik.isEmpty) {
                                                  currentIndexSlike = 0;
                                                } else {
                                                  currentIndexSlike =
                                                      currentIndexSlike %
                                                          listaSlik.length;
                                                }
                                              });
                                            },
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "Obriši",
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 244, 3, 3)),
                                              ),
                                            ),
                                          ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.lightBlue,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () async {
                                            String novaSlika =
                                                await odaberiSlikuIzGalerije();
                                            if (novaSlika.isNotEmpty) {
                                              setState(() {
                                                listaSlik.insert(0, novaSlika);
                                              });
                                            }
                                          },
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Dodaj novu",
                                              style: TextStyle(
                                                  color: Colors.lightBlue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Container za dugmić dodavanja u bazu
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.lightBlue,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: () async {
                                          sacuvajSlike();
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Sacuvaj slike",
                                            style: TextStyle(
                                                color: Colors.lightBlue),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.72,
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.height *
                                        0.66,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: "Naziv",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                onChanged: (text) {
                                                  nazivBicikl = text;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: "Cijena",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                onChanged: (text) {
                                                  cijenaBicikl =
                                                      int.tryParse(text) ?? 0;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                              child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.purple
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: velicinaRama.isNotEmpty
                                                    ? velicinaRama
                                                    : null,
                                                hint: Text(
                                                  "Velicina rama",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                icon: Icon(Icons.arrow_downward,
                                                    color: Colors.white),
                                                iconSize: 24,
                                                elevation: 16,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                dropdownColor: Colors.purple,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    velicinaRama = newValue!;
                                                  });
                                                },
                                                items: <String>[
                                                  "",
                                                  "S",
                                                  "M",
                                                  "L",
                                                  "XL",
                                                  "XXL"
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.04,
                                                      child: Center(
                                                        child: Text(
                                                          value.isEmpty
                                                              ? "Velicina rama"
                                                              : value,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value:
                                                      velicinaTocka.isNotEmpty
                                                          ? velicinaTocka
                                                          : null,
                                                  hint: Text(
                                                    "Velicina tocka",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: Icon(
                                                      Icons.arrow_downward,
                                                      color: Colors.white),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  dropdownColor: Colors.purple,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      velicinaTocka = newValue!;
                                                    });
                                                  },
                                                  items: <String>[
                                                    "",
                                                    "21",
                                                    "26",
                                                    "27.5",
                                                    "29",
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                        child: Center(
                                                          child: Text(
                                                            value.isEmpty
                                                                ? "Velicina tocka"
                                                                : value,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: brojBrzina != 0
                                                      ? brojBrzina.toString()
                                                      : null,
                                                  hint: Text(
                                                    "Broj brzina",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: Icon(
                                                      Icons.arrow_downward,
                                                      color: Colors.white),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  dropdownColor: Colors.purple,
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      brojBrzina =
                                                          int.parse(newValue!);
                                                    });
                                                  },
                                                  items: <String>[
                                                    "0",
                                                    "16",
                                                    "18",
                                                    "21",
                                                    "24",
                                                    "27",
                                                    "31"
                                                  ].map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                        child: Center(
                                                          child: Text(
                                                            value.isEmpty
                                                                ? "Broj brzina"
                                                                : value,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: "Kolicina",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                onChanged: (text) {
                                                  kolicinaBicikla =
                                                      int.tryParse(text) ?? 0;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(
                                                  color: Colors.white),
                                              right: BorderSide(
                                                  color: Colors.white),
                                              bottom: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.65,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.purple
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _odabranaKategorijaBicikl !=
                                                        null
                                                    ? _odabranaKategorijaBicikl![
                                                            'naziv'] ??
                                                        'N/A'
                                                    : null,
                                                hint: Text(
                                                  'Kategorija',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _odabranaKategorijaBicikl =
                                                        _kategorijeBicikl
                                                            ?.firstWhere(
                                                                (kategorija) =>
                                                                    kategorija[
                                                                        'naziv'] ==
                                                                    newValue,
                                                                orElse: () => {
                                                                      'naziv':
                                                                          'N/A'
                                                                    });
                                                  });
                                                },
                                                items: _kategorijeBicikl?.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (kategorija) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: kategorija[
                                                                'naziv'] ??
                                                            'N/A',
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.04,
                                                          child: Center(
                                                            child: Text(
                                                              kategorija[
                                                                      'naziv'] ??
                                                                  'N/A',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList() ??
                                                    [],
                                                dropdownColor: Colors.blue[700],
                                                iconEnabledColor: Colors.white,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                underline: Container(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.lightBlue,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: () async {
                                          sacuvajPodatke();
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Sacuvaj podatke",
                                            style: TextStyle(
                                                color: Colors.lightBlue),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentIndexPopUp = 0;
                                });
                              },
                              child: Container(
                                width: currentIndexPopUp == 0
                                    ? MediaQuery.of(context).size.width * 0.1
                                    : MediaQuery.of(context).size.width * 0.04,
                                height: currentIndexPopUp == 0
                                    ? MediaQuery.of(context).size.height * 0.012
                                    : MediaQuery.of(context).size.height * 0.01,
                                margin: EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentIndexPopUp = 1;
                                });
                              },
                              child: Container(
                                width: currentIndexPopUp == 1
                                    ? MediaQuery.of(context).size.width * 0.1
                                    : MediaQuery.of(context).size.width * 0.04,
                                height: currentIndexPopUp == 1
                                    ? MediaQuery.of(context).size.height * 0.012
                                    : MediaQuery.of(context).size.height * 0.01,
                                margin: EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String nazivBicikl = "";
  int cijenaBicikl = 0;
  String velicinaRama = "";
  String velicinaTocka = "";
  int brojBrzina = 0;
  int kolicinaBicikla = 0;
  int korisnikId = 0;
  List<Map<String, dynamic>>? _kategorijeBicikl;
  Map<String, dynamic>? _odabranaKategorijaBicikl;

  int odabranaKolicina = 0;

  narudbaBicikla() async {
    if (statusPrijavljenog != "aktivan") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Samo verifikovani korisnici mogu naruciti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 219, 244, 31),
        ),
      );
      return;
    }

    if (odabranaKolicina == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Potrebno je unjeti kolicinu',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 59, 59),
        ),
      );
      return;
    }

    // Prvo pozovi postNarudba
    final narudbaOdgovor = await _narudbaService.postNarudba(
        korisnikId: korisnikId, prodavaocId: zapis?['korisnikId']);

    if (narudbaOdgovor['narudzbaId'] != null) {
      // Uzmi narudzbaId iz odgovora
      final int narudzbaId = narudbaOdgovor['narudzbaId'];

      // Zatim pozovi postNarudbaBicikl s potrebnim podacima
      final narudbaBiciklOdgovor =
          await _narudbaBiciklService.postNarudbaBicikl(
        narudzbaId: narudzbaId,
        biciklId: widget.biciklId,
        kolicina: odabranaKolicina,
      );
      if (narudbaBiciklOdgovor['poruka'] == "Uspjesno dodata narudba") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              narudbaBiciklOdgovor['poruka'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Preusmjeravanje na GlavniProzor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GlavniProzor()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              narudbaBiciklOdgovor['poruka'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 59, 59),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            narudbaOdgovor['poruka'],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 59, 59),
        ),
      );
    }
  }

  void showCustomPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 238, 239),
                      Color.fromARGB(255, 165, 196, 210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.24,
                      color: Color.fromARGB(0, 255, 0, 0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                color: Color.fromARGB(0, 13, 255, 0),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.19,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  color: const Color.fromARGB(0, 33, 149, 243),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            left: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            right: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              // Centriranje teksta u okviru TextStyle-a
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Upiši količinu",
                                              hintStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                  vertical:
                                                      10), // Postavljanje paddinga
                                            ),
                                            textAlign: TextAlign
                                                .center, // Centriranje unosa korisnika
                                            onChanged: (value) {
                                              setState(() {
                                                odabranaKolicina =
                                                    int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            left: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            right: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${(zapis?['cijena'] ?? 0)} KM',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: 2.0),
                                      left: BorderSide(
                                          color: Colors.white, width: 2.0),
                                      right: BorderSide(
                                          color: Colors.white, width: 2.0),
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${((zapis?['cijena'] ?? 0) * odabranaKolicina).toString()} KM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.06,
                      color: Color.fromARGB(0, 255, 0, 242),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            narudbaBicikla();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.55,
                              MediaQuery.of(context).size.height * 0.05,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Potvrdi narudžbu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  sacuvajPodatke() async {
    if ((nazivBicikl.isEmpty) &&
        cijenaBicikl == 0 &&
        (velicinaRama.isEmpty) &&
        (velicinaTocka.isEmpty) &&
        brojBrzina == 0 &&
        _odabranaKategorijaBicikl == null &&
        kolicinaBicikla == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Potrebno je izmijeniti barem jedan zapis.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String? response = await _biciklService.putBicikl(
        widget.biciklId,
        nazivBicikl.isNotEmpty == true ? nazivBicikl : "",
        cijenaBicikl,
        velicinaRama.isNotEmpty == true ? velicinaRama : "",
        velicinaTocka.isNotEmpty == true ? velicinaTocka : "",
        brojBrzina,
        _odabranaKategorijaBicikl?['kategorijaId'] ?? zapis?['kategorijaId'],
        kolicinaBicikla,
        korisnikId,
      );

      if (response == "Bicikli uspješno izmijenjeni") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response!,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KorisnikoviProizvodi()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response ?? 'Došlo je do greške pri izmjeni bicikla.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Došlo je do greške pri izmjeni bicikla.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sacuvajSlike() async {
    if (listaSlik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lista slika je prazna.'),
        ),
      );
      return;
    }

    try {
      if (listaIdova.isNotEmpty) {
        for (int i = 0; i < listaSlik.length; i++) {
          if (i < listaIdova.length) {
            await _biciklSlikeService.putSlikeBicikl(
                listaSlik[i], widget.biciklId, int.parse(listaIdova[i]));
          } else {
            break;
          }
        }
        if (listaSlik.length > listaIdova.length) {
          await _biciklSlikeService.postSlikeBicikli(
              listaSlik.sublist(listaIdova.length), widget.biciklId);
        } else if (listaIdova.length > listaSlik.length) {
          for (int i = listaSlik.length; i < listaIdova.length; i++) {
            await _biciklSlikeService
                .obrisiSlikuBicikl(int.parse(listaIdova[i]));
          }
        }
      } else {
        await _biciklSlikeService.postSlikeBicikli(listaSlik, widget.biciklId);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => KorisnikoviProizvodi()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Slike su uspješno sačuvane.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Došlo je do greške pri čuvanju slika.'),
        ),
      );
    }
  }

  Future<String> odaberiSlikuIzGalerije() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      return base64Encode(bytes);
    } else {
      return '';
    }
  }
}
