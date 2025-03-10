// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, unused_element, empty_catches, sized_box_for_whitespace, use_build_context_synchronously, unused_local_variable, dead_code

import 'dart:convert';
import 'dart:io';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_slike_servis.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_slike_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';

class DodajNovi extends StatefulWidget {
  const DodajNovi({super.key});

  @override
  _DodajNoviState createState() => _DodajNoviState();
}

class _DodajNoviState extends State<DodajNovi> {
  final KorisnikServis _korisnikService = KorisnikServis();
  final KategorijaServis _kategorijaServis = KategorijaServis();
  final BiciklService _biciklService = BiciklService();
  final BiciklSlikeService _biciklSlikeService = BiciklSlikeService();
  final DijeloviService _dijeloviService = DijeloviService();
  final DijeloviSlikeService _dijeloviSlikeService = DijeloviSlikeService();

  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);
  int korisnikId = 0;
  String _selectedSection = 'Bicikl';

  bool isLogiran = false;
  String statusPrijavljenog = "kreiran";

  Future<void> _getKategorije() async {
    try {
      final kategorije = await _kategorijaServis.getKategorije(
        isBikeKategorija: true,
      );
      if (kategorije != null && kategorije.isNotEmpty) {
        setState(() {
          _kategorijeBicikl = kategorije;
          _odabranaKategorijaBicikli = null;
        });
      }
    } catch (e) {}
    try {
      final kategorije = await _kategorijaServis.getKategorije(
        isBikeKategorija: false,
      );
      if (kategorije != null && kategorije.isNotEmpty) {
        setState(() {
          _kategorijeDijelovi = kategorije;
          _odabranaKategorijaDijelovi = null;
        });
      }
    } catch (e) {}
  }

  getLogInStatus() async {
    futureKorisnik = _korisnikService.isLoggedIn().then((isLoggedIn) async {
      if (isLoggedIn) {
        Map<String, String?> userInfo = await _korisnikService.getUserInfo();
        korisnikId = int.parse(userInfo['korisnikId']!);
        statusPrijavljenog = userInfo['status'] ?? 'kreiran';
        setState(() {
          statusPrijavljenog;
          korisnikId;
          isLogiran = true;
        });
      }
      return null;
    });
  }

  @override
  initState() {
    super.initState();
    getLogInStatus();
    _getKategorije();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text(
          'Dodaj Novi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        toolbarHeight: MediaQuery.of(context).size.height * 0.06,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GlavniProzor()),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            widgetOdabir(context),
            _buildSelectedSection(context),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget widgetOdabir(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.07,
      color: Colors.blueAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          customButton(context, "Bicikl"),
          customButton(context, "Dijelovi"),
        ],
      ),
    );
  }

  Widget _buildSelectedSection(BuildContext context) {
    switch (_selectedSection) {
      case 'Bicikl':
        return widgetDodajBicikl(context);
      case 'Dijelovi':
        return widgetDodajDio(context);
      default:
        return widgetDodajBicikl(context);
    }
  }

  List<String> slike = [];
  String nazivBicikla = "";
  int cijenaBicikla = 0;
  int kolicinaBicikla = 0;
  String selectedRam = "";
  String selectedVelicina = "";
  int brojBrzina = 0;
  Map<String, dynamic>? _odabranaKategorijaBicikli;
  List<Map<String, dynamic>>? _kategorijeBicikl;

  String errorSlike = "";
  String errorNazivBicikla = "";
  String errorCijenaBicikla = "";
  String errorKolicinaBicikla = "";
  String errorSelectedRam = "";
  String errorSelectedVelicina = "";
  String errorBrojBrzina = "";
  String errorOdabranaKategorijaBicikli = "";

  Future<String> pretvoriSlikuUBase64(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  dodajBicikl() async {
    if (statusPrijavljenog != "aktivan") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Samo verifikovani korisnici mogu dodavati',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 219, 244, 31),
        ),
      );
      return;
    }
    bool greska = false;
    setState(() {
      if (slike.isEmpty) {
        errorSlike = 'Potrebno je dodati barem jednu sliku';
        greska = true;
      } else {
        errorSlike = '';
      }
      if (nazivBicikla.isEmpty) {
        errorNazivBicikla = 'Potrebno je dodati naziv';
        greska = true;
      } else {
        errorNazivBicikla = '';
      }
      if (cijenaBicikla <= 0) {
        errorCijenaBicikla = 'Potrebno je dodati cijenu u numerickom obliku';
        greska = true;
      } else {
        errorCijenaBicikla = '';
      }
      if (kolicinaBicikla <= 0) {
        errorKolicinaBicikla = 'Potrebno je dodati količinu u numerickom obliku';
        greska = true;
      } else {
        errorKolicinaBicikla = '';
      }
      if (selectedRam.isEmpty) {
        errorSelectedRam = 'Potrebno je odabrati veličinu rama';
        greska = true;
      } else {
        errorSelectedRam = '';
      }
      if (selectedVelicina.isEmpty) {
        errorSelectedVelicina = 'Potrebno je odabrati veličinu točka';
        greska = true;
      } else {
        errorSelectedVelicina = '';
      }
      if (brojBrzina <= 0) {
        errorBrojBrzina = 'Potrebno je odabrati broj brzina';
        greska = true;
      } else {
        errorBrojBrzina = '';
      }
      if (_odabranaKategorijaBicikli == null) {
        errorOdabranaKategorijaBicikli = 'Potrebno je odabrati kategoriju';
        greska = true;
      } else {
        errorOdabranaKategorijaBicikli = '';
      }
    });

    if (greska) {
      return;
    }
    Map<String, dynamic> rezultat = await _biciklService.postBicikl(
      naziv: nazivBicikla,
      cijena: cijenaBicikla,
      kolicina: kolicinaBicikla,
      velicinaRama: selectedRam,
      velicinaTocka: selectedVelicina,
      brojBrzina: brojBrzina,
      kategorijaId: _odabranaKategorijaBicikli!['kategorijaId'],
      korisnikId: korisnikId,
    );

    String poruka = rezultat['poruka'];
    int? biciklId = rezultat['biciklId'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          poruka,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (poruka.contains("Uspjesno")) {
      nazivBicikla = "";
      cijenaBicikla = 0;
      kolicinaBicikla = 0;
      selectedRam = "";
      selectedVelicina = "";
      brojBrzina = 0;

      List<String> base64Slike = [];
      for (String slika in slike) {
        String base64Slika = await pretvoriSlikuUBase64(slika);
        base64Slike.add(base64Slika);
      }

      // Slanje slika API-ju
      String rezultatSlika = await _biciklSlikeService.postSlikeBicikl(
        slike: base64Slike,
        biciklId: biciklId.toString(),
      );

      if (rezultatSlika.contains("Uspjesno")) {
        slike = [];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rezultatSlika,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 220, 39, 39),
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GlavniProzor()),
      );
    }
  }

  Widget widgetDodajBicikl(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.689,
      color: const Color.fromARGB(0, 105, 240, 175),
      child: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.689,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 205, 238, 239),
                Color.fromARGB(255, 165, 196, 210),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: isLogiran
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        widgetDodajSlikuBicikl(context),
                        widgetBicikl2Red(context),
                        widgetBicikl3Red(context),
                        widgetBicikl4Red(context),
                        widgetBicikl5Red(context),
                      ],
                    ),
                  )
                : Text(
                    'Samo logirani korisnici mogu dodavati',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget widgetDodajSlikuBicikl(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      height: MediaQuery.of(context).size.height * 0.32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
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
        child: slike.isEmpty
            ? ElevatedButton(
                onPressed: () async {
                  String odabranaSlika = await odaberiSlikuIzGalerije();
                  if (odabranaSlika.isNotEmpty) {
                    setState(() {
                      slike.add(odabranaSlika);
                      errorSlike = '';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Boja pozadine
                ),
                child: Text(
                  'Dodaj sliku',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    itemCount: slike.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: DecorationImage(
                            image: FileImage(File(slike[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: const Color.fromARGB(255, 255, 0, 0)),
                                onPressed: () {
                                  setState(() {
                                    slike.removeAt(index); // Izbriši trenutno prikazanu sliku
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget widgetBicikl2Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      color: const Color.fromARGB(0, 255, 82, 82),
      child: Center(
        child: Column(
          children: [
            slike.isNotEmpty
                ? ElevatedButton(
                    onPressed: () async {
                      String odabranaSlika = await odaberiSlikuIzGalerije();
                      if (odabranaSlika.isNotEmpty) {
                        setState(() {
                          slike.insert(0, odabranaSlika); // Dodaj novu sliku na prvo mjesto
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Boja pozadine
                    ),
                    child: Text(
                      'Dodaj sljedeću',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: MediaQuery.of(context).size.width * 0.04, // Rensponsivni tekst
                      ),
                    ),
                  )
                : Container(),
            if (errorSlike.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorSlike,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget widgetBicikl3Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.36,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Naziv",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            nazivBicikla = text;
                          },
                        ),
                      ),
                      if (errorNazivBicikla.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorNazivBicikla,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Cijena",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            cijenaBicikla = int.tryParse(text) ?? 0;
                          },
                        ),
                      ),
                      if (errorCijenaBicikla.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorCijenaBicikla,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Količina",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            kolicinaBicikla = int.tryParse(text) ?? 0;
                          },
                        ),
                      ),
                      if (errorKolicinaBicikla.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorKolicinaBicikla,
                            style: TextStyle(color: Colors.red),
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
    );
  }

  Widget widgetBicikl4Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Veličina rama",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            selectedRam = text;
                          },
                        ),
                      ),
                      if (errorSelectedRam.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorSelectedRam,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Veličina točka",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            selectedVelicina = text;
                          },
                        ),
                      ),
                      if (errorSelectedVelicina.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorSelectedVelicina,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Broj brzina",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (text) {
                            brojBrzina = int.tryParse(text) ?? 0;
                          },
                        ),
                      ),
                      if (errorBrojBrzina.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorBrojBrzina,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                          value: _odabranaKategorijaBicikli != null ? _odabranaKategorijaBicikli!['naziv'] ?? 'N/A' : null,
                          hint: Text(
                            'Kategorija',
                            style: TextStyle(color: Colors.white),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _odabranaKategorijaBicikli =
                                  _kategorijeBicikl?.firstWhere((kategorija) => kategorija['naziv'] == newValue, orElse: () => {'naziv': 'N/A'});
                            });
                          },
                          items: _kategorijeBicikl?.map<DropdownMenuItem<String>>((kategorija) {
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
                      if (errorOdabranaKategorijaBicikli.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorOdabranaKategorijaBicikli,
                            style: TextStyle(color: Colors.red),
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
    );
  }

  Widget widgetBicikl5Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.1,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            child: ElevatedButton(
              onPressed: () {
                dodajBicikl();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white, // Boja teksta
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  'Dodaj proizvod',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> odaberiSlikuIzGalerije() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return '';
    }
  }

  List<String> slikeDijelovi = [];
  String nazivDijelovi = "";
  int cijenaDijelovi = 0;
  int kolicinaDijelovi = 0;
  String opis = "";
  List<Map<String, dynamic>>? _kategorijeDijelovi;
  Map<String, dynamic>? _odabranaKategorijaDijelovi;

  String errorSlikeD = "";
  String errorNazivDijela = "";
  String errorCijenaDijela = "";
  String errorKolicinaDijela = "";
  String errorOpis = "";
  String errorOdabranaKategorijaDijela = "";

  dodajDijelovi() async {
    bool greska = false;
    setState(() {
      if (slikeDijelovi.isEmpty) {
        errorSlikeD = 'Potrebno je dodati barem jednu sliku';
        greska = true;
      } else {
        errorSlikeD = '';
      }
      if (nazivDijelovi.isEmpty) {
        errorNazivDijela = 'Potrebno je dodati naziv';
        greska = true;
      } else {
        errorNazivDijela = '';
      }
      if (cijenaDijelovi <= 0) {
        errorCijenaDijela = 'Potrebno je dodati cijenu u numerickom obliku';
        greska = true;
      } else {
        errorCijenaDijela = '';
      }
      if (kolicinaDijelovi <= 0) {
        errorKolicinaDijela = 'Potrebno je dodati količinu u numerickom obliku';
        greska = true;
      } else {
        errorKolicinaDijela = '';
      }
      if (opis.isEmpty) {
        errorOpis = 'Potrebno je dodati opis';
        greska = true;
      } else {
        errorOpis = '';
      }
      if (_odabranaKategorijaDijelovi == null) {
        errorOdabranaKategorijaDijela = 'Potrebno je odabrati kategoriju';
        greska = true;
      } else {
        errorOdabranaKategorijaDijela = '';
      }
    });

    if (greska) {
      return;
    }
    Map<String, dynamic> rezultat = await _dijeloviService.postDijelovi(
      naziv: nazivDijelovi,
      cijena: cijenaDijelovi,
      kolicina: kolicinaDijelovi,
      opis: opis,
      kategorijaId: _odabranaKategorijaDijelovi!['kategorijaId'],
      korisnikId: korisnikId,
    );

    String poruka = rezultat['poruka'];
    int? dijeloviId = rezultat['dijeloviId'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          poruka,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (poruka.contains("Uspjesno")) {
      nazivDijelovi = "";
      cijenaDijelovi = 0;
      kolicinaDijelovi = 0;
      opis = "";

      List<String> base64Slike = [];
      for (String slika in slikeDijelovi) {
        String base64Slika = await pretvoriSlikuUBase64(slika);
        base64Slike.add(base64Slika);
      }

      // Slanje slika API-ju
      String rezultatSlika = await _dijeloviSlikeService.postSlikeDijelovi(
        slike: base64Slike,
        biciklId: dijeloviId.toString(),
      );

      if (rezultatSlika.contains("Uspjesno")) {
        slike = [];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rezultatSlika,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 220, 39, 39),
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GlavniProzor()),
      );
    }
  }

  Widget widgetDodajDio(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.689,
      color: const Color.fromARGB(0, 105, 240, 175),
      child: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.689,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 205, 238, 239),
                Color.fromARGB(255, 165, 196, 210),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: isLogiran
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        widgetDodajSlikuDijelovi(context),
                        widgetDijelovi2Red(context),
                        widgetDijelovi3Red(context),
                        widgetDijelovi4Red(context),
                        widgetDijelovi5Red(context),
                      ],
                    ),
                  )
                : Text(
                    'Samo logirani korisnici mogu dodavati',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget widgetDodajSlikuDijelovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      height: MediaQuery.of(context).size.height * 0.32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
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
        child: slikeDijelovi.isEmpty
            ? ElevatedButton(
                onPressed: () async {
                  String odabranaSlika = await odaberiSlikuIzGalerije();
                  if (odabranaSlika.isNotEmpty) {
                    setState(() {
                      slikeDijelovi.add(odabranaSlika);
                      errorSlikeD = '';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Boja pozadine
                ),
                child: Text(
                  'Dodaj sliku',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    itemCount: slikeDijelovi.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: DecorationImage(
                            image: FileImage(File(slikeDijelovi[index])),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: const Color.fromARGB(255, 255, 0, 0)),
                                onPressed: () {
                                  setState(() {
                                    slikeDijelovi.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget widgetDijelovi2Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      color: const Color.fromARGB(0, 255, 82, 82),
      child: Center(
        child: Column(
          children: [
            slikeDijelovi.isNotEmpty
                ? ElevatedButton(
                    onPressed: () async {
                      String odabranaSlika = await odaberiSlikuIzGalerije();
                      if (odabranaSlika.isNotEmpty) {
                        setState(() {
                          slikeDijelovi.insert(0, odabranaSlika);
                          errorSlikeD = '';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Boja pozadine
                    ),
                    child: Text(
                      'Dodaj sljedeću',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: MediaQuery.of(context).size.width * 0.04, // Rensponsivni tekst
                      ),
                    ),
                  )
                : Container(),
            if (errorSlikeD.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorSlikeD,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget widgetDijelovi3Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.38,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Naziv",
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
                      if (errorNazivDijela.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorNazivDijela,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Cijena",
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
                      if (errorCijenaDijela.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorCijenaDijela,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                            hintText: "Količina",
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
                      if (errorKolicinaDijela.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorKolicinaDijela,
                            style: TextStyle(color: Colors.red),
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
    );
  }

  Widget widgetDijelovi4Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Opis",
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
                      if (errorOpis.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorOpis,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border(
                    bottom: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    left: BorderSide(color: Colors.white),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
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
                              _odabranaKategorijaDijelovi =
                                  _kategorijeDijelovi?.firstWhere((kategorija) => kategorija['naziv'] == newValue, orElse: () => {'naziv': 'N/A'});
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
                      if (errorOdabranaKategorijaDijela.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorOdabranaKategorijaDijela,
                            style: TextStyle(color: Colors.red),
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
    );
  }

  Widget widgetDijelovi5Red(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.1,
      color: Color.fromARGB(0, 166, 255, 82),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
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
            child: ElevatedButton(
              onPressed: () {
                dodajDijelovi();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white, // Boja teksta
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  'Dodaj proizvod',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customButton(BuildContext context, String title) {
    bool isSelected = title == _selectedSection;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSection = title;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 87, 202, 255) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.lightBlueAccent),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.lightBlueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
