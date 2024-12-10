// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sized_box_for_whitespace, empty_catches, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/prikaz_slika.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_sacuvani_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

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
  final BiciklSacuvaniServis _biciklSacuvaniServis = BiciklSacuvaniServis();

  bool loadingZapisi = true;
  Map<String, dynamic>? zapis;
  Map<String, dynamic>? kategorija;
  Map<String, dynamic>? adresa;

  bool sacuvanZapisi = false;
  Map<String, dynamic>? zapisSacuvanog;
  bool? isLoggedInCache;

  _getSpaseni() async {
    isLoggedInCache ??= await _korisnikServis.isLoggedIn();
    if (isLoggedInCache == true) {
      Map<String, String?> userInfo = await _korisnikServis.getUserInfo();
      int korisnikId = int.tryParse(userInfo['korisnikId'] ?? '0') ?? 0;
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

  _initialize() async {
    try {
      var result = await _biciklService.getBiciklById(widget.biciklId);
      setState(() {
        zapis = result;
        _getSpaseni();
        _getAdresa();
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

    // Ostali kod za funkciju naruci
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
      Map<String, String?> userInfo = await _korisnikServis.getUserInfo();
      int korisnikId = int.tryParse(userInfo['korisnikId'] ?? '0') ?? 0;
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
        child: PrikazSlike(slikeBiciklis: slikeBiciklis),
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
                child: GestureDetector(
                  onTap: () {
                    naruci();
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
}
