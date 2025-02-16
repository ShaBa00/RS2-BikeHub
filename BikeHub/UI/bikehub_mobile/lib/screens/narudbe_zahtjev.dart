// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, unused_element, avoid_print, use_build_context_synchronously, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'dart:convert';

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/screens/prikaz/bicikli_prikaz.dart';
import 'package:bikehub_mobile/screens/prikaz/dijelovi_prikaz.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_bicikl_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/narudba/narudba_service.dart';
import 'package:flutter/material.dart';

class NarudbeZahtjev extends StatefulWidget {
  @override
  _NarudbeZahtjevaState createState() => _NarudbeZahtjevaState();
}

class _NarudbeZahtjevaState extends State<NarudbeZahtjev> {
  //servisi
  final KorisnikServis _korisnikService = KorisnikServis();
  final NarudbaService _narudbaService = NarudbaService();
  final NarudbaBiciklService _narudbaBiciklService = NarudbaBiciklService();
  final NarudbaDijeloviService _narudbaDijeloviService = NarudbaDijeloviService();
  final BiciklService _biciklService = BiciklService();
  final DijeloviService _dijeloviService = DijeloviService();

  //bicikl

  // rezervacije
  late Map<String, dynamic> rezervacija;
  String? odabranaOcjena;

  // zajednicko
  int _odabraniId = 0;
  bool zapisUcitan = false;
  String _selectedSection = 'bicikl';
  bool isLoading = true;

  // korisnik
  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);
  int korisnikId = 0;
  bool isLogged = false;

  // liste
  List<Map<String, dynamic>> listaNarudbaBicikli = [];
  List<Map<String, dynamic>> listaNarudbaDijelovi = [];
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _getNarudbe() async {
    await _narudbaService.getNarudbe(prodavaocId: korisnikId);
    listaNarudbaBicikli = _narudbaService.listaNarudbaBicikli;
    listaNarudbaDijelovi = _narudbaService.listaNarudbaDijelovi;
  }

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _korisnikService.getUserInfo();
      korisnikId = int.parse(userInfo['korisnikId']!);
      await _getNarudbe();
      isLogged = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _updateSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Column(
          children: <Widget>[
            //glavniDio
            dioPretrage(context),
            // Prikaz odabranog dijela
            _buildSelectedSection(context),
            //navBar
            const NavBar(),
          ],
        ),
      ),
    );
  }

  Widget dioPretrage(BuildContext context) {
    return Column(
      children: [
        // Drugi dio
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.10, // 10% visine ekrana
          color: Color.fromARGB(0, 255, 235, 59), // Zamijenite s bojom po želji
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
              height: MediaQuery.of(context).size.height * 0.05, // 5% visine ekrana
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  // dD
                  Container(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.09,
                    color: const Color.fromARGB(0, 244, 67, 54), // Zamijenite s bojom po želji
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ikone crne boje
                          iconSize: 24.0, // Veličina ikone
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const GlavniProzor()),
                            );
                          },
                        ),
                        const Text(
                          'Zahtjev za narudžbu',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  // lD
                  Container(
                    width: MediaQuery.of(context).size.width * 0.10, // 55% širine ekrana
                    height: MediaQuery.of(context).size.height * 0.09, // 9% visine ekrana
                    color: const Color.fromARGB(0, 33, 149, 243), // Zamijenite s bojom po želji
                  ),
                ],
              ),
            ),
          ),
        ),

        //dP
        Container(
          width: MediaQuery.of(context).size.width, // 100% širine ekrana
          height: MediaQuery.of(context).size.height * 0.12, // 15% visine ekrana
          color: const Color.fromARGB(0, 255, 153, 0), // Zamijenite s bojom po želji
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customButton(context, 'bicikl', Icons.directions_bike, _selectedSection, _updateSection),
              customButton(context, 'dijelovi', Icons.handyman, _selectedSection, _updateSection),
            ],
          ),
        ),
      ],
    );
  }

  //bicikl
  Widget dioHistorijaBicikla(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.66,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 238, 228),
            Color.fromARGB(255, 6, 93, 73),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : isLogged
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.6,
                        color: const Color.fromARGB(0, 68, 137, 255),
                        child: listaNarudbaBicikli.isEmpty
                            ? Center(
                                child: Text(
                                  'Nema odradenih narudbi',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: listaNarudbaBicikli.map((narudzba) {
                                    return GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          zapisUcitan = false;
                                          _selectedSection = "biciklPrikaz";
                                          _odabraniId = narudzba['narudzbaBicikliId'];
                                        });
                                        await getBicikl();
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.85,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
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
                                          child: Text(
                                            'Cijena: ${narudzba['cijena']}KM, Kolicina: ${narudzba['kolicina']}',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Potrebno je prijaviti se',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 87, 202, 255),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LogIn()),
                                );
                              },
                              child: Text(
                                "Prijava",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget buildNarudbaBicikl(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.66,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 238, 228),
            Color.fromARGB(255, 6, 93, 73),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: !zapisUcitan
              ? Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.065,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSection = "bicikl";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.4,
                                MediaQuery.of(context).size.height * 0.055,
                              ),
                            ),
                            child: Text(
                              'Nazad',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.33,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.77,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Center(
                                  child: Container(
                                width: MediaQuery.of(context).size.width * 0.37,
                                height: MediaQuery.of(context).size.height * 0.19,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BicikliPrikaz(biciklId: bicikl['biciklId']),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: bicikl['slikeBiciklis'] != null &&
                                            bicikl['slikeBiciklis'].isNotEmpty &&
                                            bicikl['slikeBiciklis'][0]['slika'] != null
                                        ? Image.memory(
                                            base64Decode(bicikl['slikeBiciklis'][0]['slika']),
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                  ),
                                ),
                              )),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.77,
                              height: MediaQuery.of(context).size.height * 0.13,
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.77,
                                    height: MediaQuery.of(context).size.height * 0.065,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Kolicina: ${biciklNarudba['kolicina'] ?? 'N/A'}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Cijena: ${biciklNarudba['cijena'] ?? 'N/A'}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.77,
                                    height: MediaQuery.of(context).size.height * 0.065,
                                    child: Row(
                                      children: [
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.45,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Status: ${biciklNarudba['status'] == 'vracen' ? 'Otkazana' : biciklNarudba['status'] == 'kreiran' ? 'Obrada' : biciklNarudba['status'] == 'zavrseno' || biciklNarudba['status'] == 'obrisan' ? 'Isporucena' : biciklNarudba['status'] != null ? 'U isporuci' : 'N/A'}',
                                                style: TextStyle(color: Colors.white),
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
                          ],
                        ),
                      ),
                      if (biciklNarudba['status'] == 'kreiran')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    posaljiNarudbom(biciklNarudba['narudzbaId'], true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      MediaQuery.of(context).size.height * 0.055,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Posalji artikal',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    posaljiNarudbom(biciklNarudba['narudzbaId'], false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 244, 3, 99),
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      MediaQuery.of(context).size.height * 0.055,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Otkaži ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  late Map<String, dynamic> bicikl;
  late Map<String, dynamic> biciklNarudba;

  Future<void> getBicikl() async {
    try {
      biciklNarudba = await _narudbaBiciklService.getNarudbaBiciklById(_odabraniId);

      bicikl = await _biciklService.getBiciklById(biciklNarudba['biciklId']);
      setState(() {
        zapisUcitan = true;
      });
    } catch (e) {
      setState(() {
        zapisUcitan = false;
      });
    }
  }

  //Dijelovi
  Widget dioHistorijDijelova(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.66, // 53% visine ekrana
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 235, 238),
            Color.fromARGB(255, 6, 99, 107),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ), // Zamijenite s bojom po želji
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : isLogged
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.6,
                        color: const Color.fromARGB(0, 68, 137, 255),
                        child: listaNarudbaDijelovi.isEmpty
                            ? Center(
                                child: Text(
                                  'Nema odradenih narudbi',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: listaNarudbaDijelovi.map((narudzba) {
                                    return GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          zapisUcitan = false;
                                          _selectedSection = "dijeloviPrikaz";
                                          _odabraniId = narudzba['narudzbaDijeloviId'];
                                        });
                                        await getDijelovi();
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.85,
                                        height: MediaQuery.of(context).size.height * 0.06,
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
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
                                          child: Text(
                                            'Cijena: ${narudzba['cijena']}KM, Kolicina: ${narudzba['kolicina']}',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Potrebno je prijaviti se',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 87, 202, 255),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LogIn()),
                                );
                              },
                              child: Text(
                                "Prijava",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  late Map<String, dynamic> dijelovi;
  late Map<String, dynamic> dijeloviNarudba;

  Widget buildNarudbaDijelovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.66,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 235, 238),
            Color.fromARGB(255, 6, 99, 107),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: !zapisUcitan
              ? Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.065,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSection = "dijelovi";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.4,
                                MediaQuery.of(context).size.height * 0.055,
                              ),
                            ),
                            child: Text(
                              'Nazad',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.33,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.77,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.37,
                                  height: MediaQuery.of(context).size.height * 0.19,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 82, 205, 210),
                                        Color.fromARGB(255, 7, 161, 235),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DijeloviPrikaz(dijeloviId: dijelovi['dijeloviId']),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: dijelovi['slikeDijelovis'] != null &&
                                              dijelovi['slikeDijelovis'].isNotEmpty &&
                                              dijelovi['slikeDijelovis'][0]['slika'] != null
                                          ? Image.memory(
                                              base64Decode(dijelovi['slikeDijelovis'][0]['slika']),
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.77,
                              height: MediaQuery.of(context).size.height * 0.13,
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.77,
                                    height: MediaQuery.of(context).size.height * 0.065,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Kolicina: ${dijeloviNarudba['kolicina'] ?? 'N/A'}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Cijena: ${dijeloviNarudba['cijena'] ?? 'N/A'}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.77,
                                    height: MediaQuery.of(context).size.height * 0.065,
                                    child: Row(
                                      children: [
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.45,
                                          height: MediaQuery.of(context).size.height * 0.055,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border(
                                              bottom: BorderSide(color: Colors.white),
                                              right: BorderSide(color: Colors.white),
                                              left: BorderSide(color: Colors.white),
                                            ),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Status: ${dijeloviNarudba['status'] == 'vracen' ? 'Otkazana' : dijeloviNarudba['status'] == 'kreiran' ? 'Obrada' : dijeloviNarudba['status'] == 'zavrseno' || dijeloviNarudba['status'] == 'obrisan' ? 'Isporucena' : dijeloviNarudba['status'] != null ? 'U isporuci' : 'N/A'}',
                                                style: TextStyle(color: Colors.white),
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
                          ],
                        ),
                      ),
                      if (dijeloviNarudba['status'] == 'kreiran')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    posaljiNarudbom(dijeloviNarudba['narudzbaId'], true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      MediaQuery.of(context).size.height * 0.055,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Posalji artikal',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(0, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    posaljiNarudbom(dijeloviNarudba['narudzbaId'], false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 244, 3, 99),
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.3,
                                      MediaQuery.of(context).size.height * 0.055,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Otkaži ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> getDijelovi() async {
    try {
      dijeloviNarudba = await _narudbaDijeloviService.getNarudbaDijeloviById(_odabraniId);

      dijelovi = await _dijeloviService.getDijeloviById(dijeloviNarudba['dijeloviId']);
      setState(() {
        zapisUcitan = true;
      });
    } catch (e) {
      setState(() {
        zapisUcitan = false;
      });
    }
  }
  //zajednicke funkcije

  Future<void> posaljiNarudbom(int odabranaNarudbaId, bool aktivacija) async {
    bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, "Da li ste sigurni da želite vratiti narudbu?");
    if (confirmed != true) {
      return;
    }
    String poruka = await _narudbaService.aktivacijaNarudbe(odabranaNarudbaId, aktivacija);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          poruka,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: poruka == "Uspjesno izvrsena radnja" ? Colors.green : Colors.red,
      ),
    );
    setState(() {
      _selectedSection = "bicikl";
    });
  }

  Widget _buildSelectedSection(BuildContext context) {
    switch (_selectedSection) {
      case 'bicikl':
        return dioHistorijaBicikla(context);
      case 'dijelovi':
        return dioHistorijDijelova(context);
      case 'biciklPrikaz':
        return buildNarudbaBicikl(context);
      case 'dijeloviPrikaz':
        return buildNarudbaDijelovi(context);
      default:
        return dioHistorijaBicikla(context);
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  //dugmici
  Widget customButton(BuildContext context, String title, IconData icon, String currentSection, Function onPressed) {
    bool isSelected = currentSection == title;
    return Container(
      width: 70.0, // Povećanje veličine dugmića
      height: 70.0, // Povećanje veličine dugmića
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isSelected
              ? [Colors.blue, Colors.lightBlueAccent] // Boje za odabrani dugmić
              : [Color.fromARGB(255, 82, 205, 210), Color.fromARGB(255, 7, 161, 235)], // Boje za neodabrane dugmiće
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white), // Ikone bijele boje
        iconSize: 30.0, // Povećanje veličine ikone
        onPressed: () => onPressed(title),
      ),
    );
  }
}
