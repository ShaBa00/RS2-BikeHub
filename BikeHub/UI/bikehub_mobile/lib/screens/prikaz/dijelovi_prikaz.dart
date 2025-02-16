// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sized_box_for_whitespace, empty_catches, use_build_context_synchronously, prefer_const_literals_to_create_immutables, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:bikehub_mobile/screens/dodavanje/promocija_zapisa.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikovi_proizvodi.dart';
import 'package:bikehub_mobile/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/screens/ostalo/prikaz_slika.dart';
import 'package:bikehub_mobile/screens/prikaz/bicikli_prikaz.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_promocija_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_sacuvani_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_slike_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_recomended_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DijeloviPrikaz extends StatefulWidget {
  final int dijeloviId;

  DijeloviPrikaz({super.key, required this.dijeloviId});

  @override
  _DijeloviPrikazState createState() => _DijeloviPrikazState();
}

class _DijeloviPrikazState extends State<DijeloviPrikaz> {
  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  final DijeloviService _dijeloviService = DijeloviService();
  final KategorijaServis _kategorijaServis = KategorijaServis();
  final KategorijaRecommendedService _kategorijaRecommendedService = KategorijaRecommendedService();
  final NarudbaDijeloviService _narudbaDijeloviService = NarudbaDijeloviService();
  final NarudbaService _narudbaService = NarudbaService();
  final AdresaServis _adresaServis = AdresaServis();
  final KorisnikServis _korisnikServis = KorisnikServis();
  final DijeloviSlikeService _dijeloviSlikeService = DijeloviSlikeService();
  final DijeloviPromocijaService _dijeloviPromocijaService = DijeloviPromocijaService();
  final DijeloviSacuvaniServis _dijeloviSacuvaniServis = DijeloviSacuvaniServis();

  bool loadingZapisi = true;
  Map<String, dynamic>? zapis;
  Map<String, dynamic>? kategorija;
  Map<String, dynamic>? adresa;
  bool isPromovisan = false;

  bool sacuvanZapisi = false;
  Map<String, dynamic>? zapisSacuvanog;
  bool? isLoggedInCache;
  String statusPrijavljenog = "kreiran";

  _getKategorija() async {
    try {
      var result = await _kategorijaServis.getKategorijaById(zapis?['kategorijaId']);
      setState(() {
        kategorija = result;
        loadingZapisi = false;
      });
    } catch (e) {}
    try {
      final kategorije = await _kategorijaServis.getKategorije(
        isBikeKategorija: false,
      );
      if (kategorije != null && kategorije.isNotEmpty) {
        setState(() {
          _kategorijeDijelovi = kategorije;
          _odabranaKategorijaDijelovi =
              _kategorijeDijelovi?.firstWhere((kategorija) => kategorija['kategorijaId'] == kategorijaP, orElse: () => {'naziv': 'N/A'});
        });
      }
    } catch (e) {}
  }

  _getAdresa() async {
    try {
      var result = await _adresaServis.getAdresa(korisnikId: zapis?['korisnikId']);
      setState(() {
        adresa = result;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  _getSpaseni() async {
    isLoggedInCache ??= await _korisnikServis.isLoggedIn();
    if (isLoggedInCache == true) {
      zapisSacuvanog = await _dijeloviSacuvaniServis.isDioSacuvan(korisnikId: korisnikId, dijeloviId: widget.dijeloviId);
      if (zapisSacuvanog != null && zapisSacuvanog?['status'] != "obrisan") {
        sacuvanZapisi = true;
      }
    }

    setState(() {
      sacuvanZapisi;
    });
  }

  List<dynamic> listaRecomendedBicikala = [];
  _getRecomended() async {
    try {
      await _kategorijaRecommendedService.getRecommendedBiciklis(dijeloviId: widget.dijeloviId);
      setState(() {
        listaRecomendedBicikala = _kategorijaRecommendedService.listaRecomendedBicikala;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  List<String> listaSlik = [];
  List<String> listaIdova = [];

  var kategorijaP = 0;
  _initialize() async {
    try {
      var userInfo = await _korisnikServis.getUserInfo();
      setState(() {
        korisnikId = int.tryParse(userInfo['korisnikId'] ?? '0') ?? 0;
        statusPrijavljenog = userInfo['status'] ?? 'kreiran';
      });

      var result = await _dijeloviService.getDijeloviById(widget.dijeloviId);
      isPromovisan = await _dijeloviPromocijaService.isPromovisan(dijeloviId: widget.dijeloviId);
      setState(() {
        kategorijaP =
            result['kategorijaId'] != null && result['kategorijaId'].toString().isNotEmpty ? int.tryParse(result['kategorijaId'].toString()) ?? 0 : 0;

        nazivDijelovi = result['naziv'] != null && result['naziv'].toString().isNotEmpty ? result['naziv'].toString() : "N/A";

        cijenaDijelovi = result['cijena'] != null && result['cijena'].toString().isNotEmpty
            ? (result['cijena'] is double ? result['cijena'].toInt() : int.tryParse(result['cijena'].toString()) ?? 0)
            : 0;

        kolicinaDijelovi =
            result['kolicina'] != null && result['kolicina'].toString().isNotEmpty ? int.tryParse(result['kolicina'].toString()) ?? 0 : 0;

        opis = result['opis'] != null && result['opis'].toString().isNotEmpty ? result['opis'].toString() : "N/A";

        isPromovisan;
        zapis = result;
        listaSlik = (result['slikeDijelovis'] as List<dynamic>?)
                ?.where((item) => item['slika'] != null && item['slika'].isNotEmpty)
                .map<String>((item) => item['slika'] as String)
                .toList() ??
            [];
        listaIdova = (result['slikeDijelovis'] as List<dynamic>?)
                ?.where((item) => item['slikeDijeloviId'] != null)
                .map<String>((item) => item['slikeDijeloviId'].toString())
                .toList() ??
            [];

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
            'Samo prijavljeni korisnici mogu naruciti',
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
        poruka = await _dijeloviSacuvaniServis.promjeniSacuvani(
            zapisSacuvanog?['spaseniDijeloviId'], zapisSacuvanog?['korisnikId'], zapisSacuvanog?['dijeloviId'], true);
      } else {
        poruka = await _dijeloviSacuvaniServis.promjeniSacuvani(
            zapisSacuvanog?['spaseniDijeloviId'], zapisSacuvanog?['korisnikId'], zapisSacuvanog?['dijeloviId'], false);
      }
    } else {
      poruka = await _dijeloviSacuvaniServis.dodajNoviSacuvani(
        widget.dijeloviId,
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.06),
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
                          'Dijelovi Prikaz',
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
                          sacuvanZapisi ? Icons.bookmark : Icons.bookmark_border,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: const NavBar(),
            ),
          ],
        ),
      ),
    );
  }

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
    } else if (zapis!['slikeDijelovis'] != null) {
      List<Map<String, dynamic>> slikeBiciklis = (zapis!['slikeDijelovis'] as List).map((item) => item as Map<String, dynamic>).toList();
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
                height: MediaQuery.of(context).size.height * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.height * 0.04,
                      color: Color.fromARGB(0, 54, 238, 244),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Opis",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.height * 0.135,
                      color: Color.fromARGB(0, 244, 67, 54),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            zapis?['opis']?.toString() ?? 'N/A',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
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
                                            zapisId: widget.dijeloviId,
                                            isBicikl: false,
                                          )),
                                );
                              },
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
              height: MediaQuery.of(context).size.height * 0.05,
              color: const Color.fromARGB(0, 244, 67, 54),
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
                        for (int i = 0; i < (listaRecomendedBicikala.length > 5 ? 5 : listaRecomendedBicikala.length); i++)
                          GestureDetector(
                            onTap: () {
                              int biciklId = listaRecomendedBicikala[i]['biciklId'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BicikliPrikaz(biciklId: biciklId),
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
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height * 0.19,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child:
                                        listaRecomendedBicikala[i]['slikeBiciklis'] != null && listaRecomendedBicikala[i]['slikeBiciklis'].isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30.0),
                                                  topRight: Radius.circular(30.0),
                                                ),
                                                child: Image.memory(
                                                  base64Decode(listaRecomendedBicikala[i]['slikeBiciklis'][0]['slika']),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(
                                                Icons.image_not_supported,
                                                size: MediaQuery.of(context).size.height * 0.1,
                                              ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            height: MediaQuery.of(context).size.height * 0.05,
                                            alignment: Alignment.center,
                                            child: Text(
                                              listaRecomendedBicikala[i]?['naziv'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                            height: MediaQuery.of(context).size.height * 0.05,
                                            alignment: Alignment.center,
                                            child: Text(
                                              (listaRecomendedBicikala[i]?['cijena']?.toString() ?? 'N/A'),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.1,
                                  ),
                                  // Container za prikaz slika
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height * 0.32,
                                    child: listaSlik.isNotEmpty
                                        ? GestureDetector(
                                            onHorizontalDragEnd: (details) {
                                              if (details.primaryVelocity != null) {
                                                if (details.primaryVelocity! > 0) {
                                                  // Swiped Right
                                                  setState(() {
                                                    currentIndexSlike = (currentIndexSlike - 1 + listaSlik.length) % listaSlik.length;
                                                  });
                                                } else if (details.primaryVelocity! < 0) {
                                                  // Swiped Left
                                                  setState(() {
                                                    currentIndexSlike = (currentIndexSlike + 1) % listaSlik.length;
                                                  });
                                                }
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.memory(
                                                base64Decode(listaSlik[currentIndexSlike]),
                                                fit: BoxFit.cover,
                                                width: MediaQuery.of(context).size.width * 0.8,
                                                height: MediaQuery.of(context).size.height * 0.32,
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
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height * 0.1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        if (listaSlik.isNotEmpty)
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.lightBlue,
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                listaSlik.removeAt(currentIndexSlike);
                                                if (listaSlik.isEmpty) {
                                                  currentIndexSlike = 0;
                                                } else {
                                                  currentIndexSlike = currentIndexSlike % listaSlik.length;
                                                }
                                              });
                                            },
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "Obriši",
                                                style: TextStyle(color: const Color.fromARGB(255, 244, 3, 3)),
                                              ),
                                            ),
                                          ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.lightBlue,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () async {
                                            String novaSlika = await odaberiSlikuIzGalerije();
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
                                              style: TextStyle(color: Colors.lightBlue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Container za dugmić dodavanja u bazu
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.lightBlue,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () async {
                                            sacuvajSlike();
                                          },
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Sacuvaj slike",
                                              style: TextStyle(color: Colors.lightBlue),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16), // Razmak između dva dugmeta
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            obrisiBicikl();
                                          },
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Obriši bicikl",
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.height * 0.66,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              bottom: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.65,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue, Colors.purple],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: nazivDijelovi.isEmpty ? "Naziv" : nazivDijelovi,
                                                  hintStyle: TextStyle(color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                                onChanged: (text) {
                                                  nazivDijelovi = text;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              bottom: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.65,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue, Colors.purple],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: cijenaDijelovi == 0 ? "Cijena" : cijenaDijelovi.toString(),
                                                  hintStyle: TextStyle(color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                                onChanged: (text) {
                                                  cijenaDijelovi = int.tryParse(text) ?? 0;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              bottom: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.65,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue, Colors.purple],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: kolicinaDijelovi == 0 ? "Kolicina" : kolicinaDijelovi.toString(),
                                                  hintStyle: TextStyle(color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                                onChanged: (text) {
                                                  kolicinaDijelovi = int.tryParse(text) ?? 0;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              bottom: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.65,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue, Colors.purple],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: opis.isEmpty ? "Opis" : opis,
                                                  hintStyle: TextStyle(color: Colors.white),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                                onChanged: (text) {
                                                  opis = text;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border(
                                              left: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              bottom: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.65,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue, Colors.purple],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: _odabranaKategorijaDijelovi != null ? _odabranaKategorijaDijelovi!['naziv'] ?? 'N/A' : null,
                                                hint: Text(
                                                  'Kategorija',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _odabranaKategorijaDijelovi = _kategorijeDijelovi
                                                        ?.firstWhere((kategorija) => kategorija['naziv'] == newValue, orElse: () => {'naziv': 'N/A'});
                                                  });
                                                },
                                                items: _kategorijeDijelovi?.map<DropdownMenuItem<String>>((kategorija) {
                                                      return DropdownMenuItem<String>(
                                                        value: kategorija['naziv'] ?? 'N/A',
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width * 0.3,
                                                          height: MediaQuery.of(context).size.height * 0.04,
                                                          child: Center(
                                                            child: Text(
                                                              kategorija['naziv'] ?? 'N/A',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList() ??
                                                    [],
                                                dropdownColor: Colors.blue[700],
                                                iconEnabledColor: Colors.white,
                                                style: TextStyle(color: Colors.white),
                                                underline: Container(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.85,
                                    height: MediaQuery.of(context).size.height * 0.06,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.lightBlue,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: () async {
                                          sacuvajPodatke();
                                        },
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Sacuvaj podatke",
                                            style: TextStyle(color: Colors.lightBlue),
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
                                width: currentIndexPopUp == 0 ? MediaQuery.of(context).size.width * 0.1 : MediaQuery.of(context).size.width * 0.04,
                                height:
                                    currentIndexPopUp == 0 ? MediaQuery.of(context).size.height * 0.012 : MediaQuery.of(context).size.height * 0.01,
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
                                width: currentIndexPopUp == 1 ? MediaQuery.of(context).size.width * 0.1 : MediaQuery.of(context).size.width * 0.04,
                                height:
                                    currentIndexPopUp == 1 ? MediaQuery.of(context).size.height * 0.012 : MediaQuery.of(context).size.height * 0.01,
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

  int korisnikId = 0;
  String nazivDijelovi = "";
  int cijenaDijelovi = 0;
  int kolicinaDijelovi = 0;
  String opis = "";
  List<Map<String, dynamic>>? _kategorijeDijelovi;
  Map<String, dynamic>? _odabranaKategorijaDijelovi;

  int odabranaKolicina = 0;

  obrisiBicikl() async {
    bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, "Da li ste sigurni da želite obrisati zapis?");
    if (confirmed != true) {
      return;
    }
    try {
      await _dijeloviService.upravljanjeDijelom("obrisan", widget.dijeloviId);
      PorukaHelper.prikaziPorukuUspjeha(context, "Zapis uspješno obrisan");
    } catch (e) {
      PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom brisanja zapisa");
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GlavniProzor()),
    );
  }

  narudbaDijelovi() async {
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
    final narudbaOdgovor = await _narudbaService.postNarudba(korisnikId: korisnikId, prodavaocId: zapis?['korisnikId']);

    if (narudbaOdgovor['narudzbaId'] != null) {
      final int narudzbaId = narudbaOdgovor['narudzbaId'];
      final narudbaDijeloviOdgovor = await _narudbaDijeloviService.postNarudbaDijelovi(
        narudzbaId: narudzbaId,
        dijeloviId: widget.dijeloviId,
        kolicina: odabranaKolicina,
      );
      if (narudbaDijeloviOdgovor['poruka'] == "Uspjesno dodata narudba") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              narudbaDijeloviOdgovor['poruka'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GlavniProzor()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              narudbaDijeloviOdgovor['poruka'],
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
                                height: MediaQuery.of(context).size.height * 0.05,
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
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  color: const Color.fromARGB(0, 33, 149, 243),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.35,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.white, width: 2.0),
                                            left: BorderSide(color: Colors.white, width: 2.0),
                                            right: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Upiši količinu",
                                              hintStyle: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            textAlign: TextAlign.center,
                                            onChanged: (value) {
                                              setState(() {
                                                odabranaKolicina = int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.35,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.white, width: 2.0),
                                            left: BorderSide(color: Colors.white, width: 2.0),
                                            right: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          borderRadius: BorderRadius.circular(10.0),
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
                                  width: MediaQuery.of(context).size.width * 0.35,
                                  height: MediaQuery.of(context).size.height * 0.06,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white, width: 2.0),
                                      left: BorderSide(color: Colors.white, width: 2.0),
                                      right: BorderSide(color: Colors.white, width: 2.0),
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
                            narudbaDijelovi();
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
    if ((nazivDijelovi.isEmpty) && cijenaDijelovi == 0 && (opis.isEmpty) && _odabranaKategorijaDijelovi == null && kolicinaDijelovi == 0) {
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
      String? response = await _dijeloviService.putDijelovi(
        widget.dijeloviId,
        nazivDijelovi.isNotEmpty == true ? nazivDijelovi : "",
        cijenaDijelovi,
        opis.isNotEmpty == true ? opis : "",
        _odabranaKategorijaDijelovi?['kategorijaId'] ?? zapis?['kategorijaId'],
        kolicinaDijelovi,
        korisnikId,
      );

      if (response == "Dijelovi uspješno izmijenjeni") {
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
              response ?? 'Došlo je do greške pri izmjeni dijelova.',
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
            'Došlo je do greške pri izmjeni dijelova.',
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
      // Ako listaIdova nije prazna
      if (listaIdova.isNotEmpty) {
        for (int i = 0; i < listaSlik.length; i++) {
          if (i < listaIdova.length) {
            // Poziv funkcije putSlike za svaku sliku dok ima id-ova
            await _dijeloviSlikeService.putSlike(listaSlik[i], widget.dijeloviId, int.parse(listaIdova[i]));
          } else {
            // Ako listaIdova ima manje elemenata od listaSlik, preostale slike se dodaju putem postSlike
            break;
          }
        }

        // Ako listaSlik ima više elemenata od listaIdova, preostale slike dodaj putem postSlike
        if (listaSlik.length > listaIdova.length) {
          await _dijeloviSlikeService.postSlike(listaSlik.sublist(listaIdova.length), widget.dijeloviId);
        } else if (listaIdova.length > listaSlik.length) {
          // Ako listaIdova ima više elemenata od listaSlik, preostale id-ove obriši
          for (int i = listaSlik.length; i < listaIdova.length; i++) {
            await _dijeloviSlikeService.obrisiSliku(int.parse(listaIdova[i]));
          }
        }
      } else {
        // Ako je listaIdova prazna, dodaj sve slike putem postSlike
        await _dijeloviSlikeService.postSlike(listaSlik, widget.dijeloviId);
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
