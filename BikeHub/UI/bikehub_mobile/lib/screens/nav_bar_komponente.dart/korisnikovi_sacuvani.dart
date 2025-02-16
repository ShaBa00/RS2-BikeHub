// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, unused_element, sized_box_for_whitespace

import 'dart:convert';

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/screens/prikaz/bicikli_prikaz.dart';
import 'package:bikehub_mobile/screens/prikaz/dijelovi_prikaz.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_sacuvani_service.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_sacuvani_service.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class KoriskinoviSacuvai extends StatefulWidget {
  @override
  _KoriskinoviSacuvaiState createState() => _KoriskinoviSacuvaiState();
}

class _KoriskinoviSacuvaiState extends State<KoriskinoviSacuvai> {
  final KorisnikServis _korisnikService = KorisnikServis();
  final BiciklService _biciklService = BiciklService();
  final BiciklSacuvaniServis _biciklSacuvaniServis = BiciklSacuvaniServis();

  final DijeloviSacuvaniServis _dijeloviSacuvaniServis =
      DijeloviSacuvaniServis();
  final DijeloviService _dijeloviService = DijeloviService();

  String _selectedSection = 'bicikl';
  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant KoriskinoviSacuvai oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isLogged) {
      getSacuvaniBicikli();
    }
  }

//
  int korisnikId = 0;
  bool isLogged = false;
  bool isLoading = true;

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _korisnikService.getUserInfo();
      korisnikId = int.parse(userInfo['korisnikId']!);
      getSacuvaniBicikli();
      getSacuvaniDijelovi();
      isLogged = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> bicikliPodaci = [];
  bool isListaBiciklUcitana = false;
  int currentPage = 0;
  int itemsPerPage = 10;

  Future<void> getSacuvaniBicikli() async {
    List<int>? biciklIDovi = [];
    bicikliPodaci = [];
    final sacuvaniPodaci =
        await _biciklSacuvaniServis.getSacuvani(korisnikId: korisnikId);

    if (sacuvaniPodaci != null) {
      for (var zapis in sacuvaniPodaci) {
        if (zapis['status'] != 'obrisan') {
          biciklIDovi.add(zapis['biciklId']);
        }
      }
    } else {
      biciklIDovi = null;
    }

    if (biciklIDovi != null) {
      for (int biciklId in biciklIDovi) {
        final biciklPodaci = await _biciklService.getBiciklById(biciklId);
        bicikliPodaci.add(biciklPodaci);
      }
      if (bicikliPodaci.isNotEmpty) {
        setState(() {
          bicikliPodaci;
          currentPage = 0;
          isListaBiciklUcitana = true;
        });
      }
    }
  }

  List<Map<String, dynamic>> dijeloviPodaci = [];
  bool isListaDijeloviUcitana = false;
  int currentPageDijelovi = 0;
  int itemsPerPageDijelovi = 10;

  Future<void> getSacuvaniDijelovi() async {
    List<int>? dijeloviIDovi = [];
    dijeloviPodaci = [];

    final sacuvaniPodaci =
        await _dijeloviSacuvaniServis.getSacuvani(korisnikId: korisnikId);

    if (sacuvaniPodaci != null) {
      for (var zapis in sacuvaniPodaci) {
        if (zapis['status'] != 'obrisan') {
          dijeloviIDovi.add(zapis['dijeloviId']);
        }
      }
    } else {
      dijeloviIDovi = null;
    }

    if (dijeloviIDovi != null) {
      for (int dijeloviId in dijeloviIDovi) {
        final dioPodaci = await _dijeloviService.getDijeloviById(dijeloviId);
        dijeloviPodaci.add(dioPodaci);
      }
      if (dijeloviPodaci.isNotEmpty) {
        setState(() {
          dijeloviPodaci;
          currentPageDijelovi = 0;
          isListaDijeloviUcitana = true;
        });
      }
    }
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
          height: MediaQuery.of(context).size.height * 0.10,
          color: Color.fromARGB(0, 255, 235, 59), // Zamijenite s bojom po želji
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
              height:
                  MediaQuery.of(context).size.height * 0.05, // 5% visine ekrana
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  // dD
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.55, // 40% širine ekrana
                    height: MediaQuery.of(context).size.height *
                        0.09, // 9% visine ekrana
                    color: const Color.fromARGB(
                        0, 244, 67, 54), // Zamijenite s bojom po želji
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black), // Ikone crne boje
                          iconSize: 24.0, // Veličina ikone
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GlavniProzor()),
                            );
                          },
                        ),
                        const Text(
                          'Sacuvani proizvodi',
                          style: TextStyle(fontSize: 20), // Povećan font
                        ),
                      ],
                    ),
                  ),
                  // lD
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.40, // 55% širine ekrana
                    height: MediaQuery.of(context).size.height *
                        0.09, // 9% visine ekrana
                    color: const Color.fromARGB(
                        0, 33, 149, 243), // Zamijenite s bojom po želji
                  ),
                ],
              ),
            ),
          ),
        ),

        //dP
        Container(
          width: MediaQuery.of(context).size.width, // 100% širine ekrana
          height:
              MediaQuery.of(context).size.height * 0.12, // 15% visine ekrana
          color: const Color.fromARGB(
              0, 255, 153, 0), // Zamijenite s bojom po želji
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customButton(context, 'bicikl', Icons.directions_bike,
                  _selectedSection, _updateSection),
              customButton(context, 'dijelovi', Icons.handyman,
                  _selectedSection, _updateSection),
            ],
          ),
        ),
      ],
    );
  }

  //dugmici za pretraku Bicikla, dijela i servisera
  Widget customButton(BuildContext context, String title, IconData icon,
      String currentSection, Function onPressed) {
    bool isSelected = currentSection == title;
    return Container(
      width: 70.0, // Povećanje veličine dugmića
      height: 70.0, // Povećanje veličine dugmića
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isSelected
              ? [Colors.blue, Colors.lightBlueAccent] // Boje za odabrani dugmić
              : [
                  Color.fromARGB(255, 82, 205, 210),
                  Color.fromARGB(255, 7, 161, 235)
                ], // Boje za neodabrane dugmiće
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

  Widget _buildSelectedSection(BuildContext context) {
    switch (_selectedSection) {
      case 'bicikl':
        return dioSacuvaniBicikla(context);
      case 'dijelovi':
        return dioSacuvaniDijelova(context);
      default:
        return dioSacuvaniBicikla(context);
    }
  }

  Widget dioSacuvaniBicikla(BuildContext context) {
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
                        child: _buildlistaZapisa(context),
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
                                backgroundColor:
                                    Color.fromARGB(255, 87, 202, 255),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LogIn()),
                                );
                              },
                              child: Text(
                                "Prijava",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
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

  Widget _buildlistaZapisa(BuildContext context) {
    if (!isListaBiciklUcitana) {
      return Center(
        child: Text("Podatci se ucitavaju, ili nemate sacuvanih podataka"),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      color: Color.fromARGB(0, 244, 67, 54),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.54,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  (bicikliPodaci.length / 2).ceil().clamp(0, 5),
                  (index) {
                    int firstIndex = index * 2 + currentPage * itemsPerPage;
                    int secondIndex = firstIndex + 1;
                    if (firstIndex >= bicikliPodaci.length) return Container();

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.22,
                      color: Color.fromARGB(0, 255, 255, 255),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (firstIndex < bicikliPodaci.length)
                            GestureDetector(
                              onTap: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BicikliPrikaz(
                                        biciklId: bicikliPodaci[firstIndex]
                                            ['biciklId']),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isListaBiciklUcitana = false;
                                  });
                                  getSacuvaniBicikli();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(244, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Dodano zaobljenje ivica
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.16,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            0, 244, 67, 54),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ), // Zaobljene gornje ivice
                                      ),
                                      child: bicikliPodaci[firstIndex]
                                                      ['slikeBiciklis'] !=
                                                  null &&
                                              bicikliPodaci[firstIndex]
                                                      ['slikeBiciklis']
                                                  .isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              child: Image.memory(
                                                base64Decode(
                                                    bicikliPodaci[firstIndex]
                                                            ['slikeBiciklis'][0]
                                                        ['slika']),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.16,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40.0,
                                              ),
                                            ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      color:
                                          const Color.fromARGB(0, 33, 149, 243),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                bicikliPodaci[firstIndex]
                                                        ['naziv'] ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                bicikliPodaci[firstIndex]
                                                            ['cijena'] !=
                                                        null
                                                    ? "${bicikliPodaci[firstIndex]['cijena'].toString()} KM"
                                                    : 'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
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
                          if (secondIndex < bicikliPodaci.length)
                            GestureDetector(
                              onTap: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BicikliPrikaz(
                                        biciklId: bicikliPodaci[secondIndex]
                                            ['biciklId']),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isListaBiciklUcitana = false;
                                  });
                                  getSacuvaniBicikli();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(244, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Dodano zaobljenje ivica
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.16,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            0, 244, 67, 54),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ), // Zaobljene gornje ivice
                                      ),
                                      child: bicikliPodaci[secondIndex]
                                                      ['slikeBiciklis'] !=
                                                  null &&
                                              bicikliPodaci[secondIndex]
                                                      ['slikeBiciklis']
                                                  .isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              child: Image.memory(
                                                base64Decode(
                                                    bicikliPodaci[secondIndex]
                                                            ['slikeBiciklis'][0]
                                                        ['slika']),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.16,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40.0,
                                              ),
                                            ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      color:
                                          const Color.fromARGB(0, 33, 149, 243),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                bicikliPodaci[secondIndex]
                                                        ['naziv'] ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                bicikliPodaci[secondIndex]
                                                            ['cijena'] !=
                                                        null
                                                    ? "${bicikliPodaci[secondIndex]['cijena'].toString()} KM"
                                                    : 'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
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
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                ),
                Row(
                  children: List.generate(
                    (bicikliPodaci.length / itemsPerPage).ceil(),
                    (index) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        child: Text("${index + 1}"),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: currentPage <
                          (bicikliPodaci.length / itemsPerPage).ceil() - 1
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dioSacuvaniDijelova(BuildContext context) {
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
            child: isLogged
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                    color: const Color.fromARGB(0, 68, 137, 255),
                    child: _buildlistaZapisaDijelovi(context),
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
                              MaterialPageRoute(
                                  builder: (context) => const LogIn()),
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

  Widget _buildlistaZapisaDijelovi(BuildContext context) {
    if (!isListaDijeloviUcitana) {
      return Center(
        child: Text("Podatci se ucitavaju, ili nemate sacuvanih podataka"),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      color: Color.fromARGB(0, 244, 67, 54),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.54,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  (dijeloviPodaci.length / 2).ceil().clamp(0, 5),
                  (index) {
                    int firstIndex =
                        index * 2 + currentPageDijelovi * itemsPerPageDijelovi;
                    int secondIndex = firstIndex + 1;
                    if (firstIndex >= dijeloviPodaci.length) return Container();

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.22,
                      color: Color.fromARGB(0, 255, 255, 255),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (firstIndex < dijeloviPodaci.length)
                            GestureDetector(
                              onTap: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DijeloviPrikaz(
                                        dijeloviId: dijeloviPodaci[firstIndex]
                                            ['dijeloviId']),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isListaDijeloviUcitana = false;
                                  });
                                  getSacuvaniDijelovi();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(244, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Dodano zaobljenje ivica
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.16,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            0, 244, 67, 54),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ), // Zaobljene gornje ivice
                                      ),
                                      child: dijeloviPodaci[firstIndex]
                                                      ['slikeDijelovis'] !=
                                                  null &&
                                              dijeloviPodaci[firstIndex]
                                                      ['slikeDijelovis']
                                                  .isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              child: Image.memory(
                                                base64Decode(
                                                    dijeloviPodaci[firstIndex]
                                                            ['slikeDijelovis']
                                                        [0]['slika']),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.16,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40.0,
                                              ),
                                            ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      color:
                                          const Color.fromARGB(0, 33, 149, 243),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                dijeloviPodaci[firstIndex]
                                                        ['naziv'] ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                dijeloviPodaci[firstIndex]
                                                            ['cijena'] !=
                                                        null
                                                    ? "${dijeloviPodaci[firstIndex]['cijena'].toString()} KM"
                                                    : 'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
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
                          if (secondIndex < dijeloviPodaci.length)
                            GestureDetector(
                              onTap: () async {
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DijeloviPrikaz(
                                        dijeloviId: dijeloviPodaci[secondIndex]
                                            ['dijeloviId']),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isListaDijeloviUcitana = false;
                                  });
                                  getSacuvaniDijelovi();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(244, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.16,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            0, 244, 67, 54),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: dijeloviPodaci[secondIndex]
                                                      ['slikeDijelovis'] !=
                                                  null &&
                                              dijeloviPodaci[secondIndex]
                                                      ['slikeDijelovis']
                                                  .isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              child: Image.memory(
                                                base64Decode(
                                                    dijeloviPodaci[secondIndex]
                                                            ['slikeDijelovis']
                                                        [0]['slika']),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.16,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40.0,
                                              ),
                                            ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      color:
                                          const Color.fromARGB(0, 33, 149, 243),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                dijeloviPodaci[secondIndex]
                                                        ['naziv'] ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                dijeloviPodaci[secondIndex]
                                                            ['cijena'] !=
                                                        null
                                                    ? "${dijeloviPodaci[secondIndex]['cijena'].toString()} KM"
                                                    : 'N/A',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
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
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentPageDijelovi > 0
                      ? () {
                          setState(() {
                            currentPageDijelovi--;
                          });
                        }
                      : null,
                ),
                Row(
                  children: List.generate(
                    (dijeloviPodaci.length / itemsPerPageDijelovi).ceil(),
                    (index) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentPageDijelovi = index;
                          });
                        },
                        child: Text("${index + 1}"),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: currentPageDijelovi <
                          (dijeloviPodaci.length / itemsPerPageDijelovi)
                                  .ceil() -
                              1
                      ? () {
                          setState(() {
                            currentPageDijelovi++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
