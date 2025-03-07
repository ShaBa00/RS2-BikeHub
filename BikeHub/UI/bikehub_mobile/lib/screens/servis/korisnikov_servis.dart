// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_element, sized_box_for_whitespace, unused_import, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, use_build_context_synchronously

import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/confirm_prozor.dart';
import 'package:bikehub_mobile/screens/ostalo/kalendar_rezervacije.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/rezervacije_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KorisnikovServis extends StatefulWidget {
  final int korisnikId;

  const KorisnikovServis({super.key, required this.korisnikId});

  @override
  _KorisnikovServisState createState() => _KorisnikovServisState();
}

class _KorisnikovServisState extends State<KorisnikovServis> {
  Map<String, dynamic>? serviser;
  bool loading = true;

  final KorisnikServis _korisnikService = KorisnikServis();
  final ServiserService _serviserService = ServiserService();
  final RezervacijaServis _rezervacijaServis = RezervacijaServis();

  String activeTitleP = 'home';

  @override
  initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final serviserData = await _serviserService.getServiseriDTOByKorisnikId(korisnikId: widget.korisnikId);
      setState(() {
        serviser = serviserData;

        if (serviser != null && serviser?['cijena'] != null) {
          final cijena = serviser?['cijena'];
          if (cijena is num) {
            _cijenaController.text = cijena.toStringAsFixed(2);
          } else {
            _cijenaController.text = "N/A";
          }
        } else {
          _cijenaController.text = "N/A";
        }

        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Sprečava prilagođavanje prilikom prikaza tastature
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: Text(
          'Korisnikov Servis',
          style: TextStyle(
            color: Colors.white, // Boja teksta bijela
          ),
        ),
        backgroundColor: Colors.blueAccent, // Pozadina za AppBar
        iconTheme: IconThemeData(
          color: Colors.white, // Boja ikona bijela
        ),
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 10), () => loading ? 'timeout' : null),
        builder: (context, snapshot) {
          if (loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == 'timeout') {
            return Center(
              child: Text("Problem prilikom dohvatanja podataka"),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.08,
                    color: const Color.fromARGB(0, 244, 67, 54),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: MediaQuery.of(context).size.height * 0.08,
                          color: const Color.fromARGB(0, 33, 149, 243),
                          child: Center(
                            child: Text(
                              serviser?['username'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.height * 0.08,
                          color: Color.fromARGB(0, 255, 10, 67),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildButton(activeTitleP == 'home' ? 'Edit' : (activeTitleP == 'urediS' ? 'Info' : 'Edit')),
                              _buildButton(activeTitleP == 'home' ? 'Dodatno' : (activeTitleP == 'Dodatno' ? 'Info' : 'Dodatno')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6774,
                    color: const Color.fromARGB(0, 76, 175, 79),
                    child: getActiveWidget(context),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  String _statusRezervacije = "Kreirane";

  Widget getActiveWidget(BuildContext context) {
    switch (activeTitleP) {
      case 'home':
        return homeWidget(context);
      case 'urediS':
        return editServiseraWidget(context);
      case 'Dodatno':
        return dodatnoServiseraWidget(context);
      case 'Rezervacija':
        return rezervacijaaWidget(context);
      default:
        return homeWidget(context);
    }
  }

  Widget dodatnoServiseraWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blueAccent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.07,
              color: const Color.fromARGB(0, 68, 137, 255),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.07,
                    color: const Color.fromARGB(0, 244, 67, 54),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _statusRezervacije,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(width: 8), // Razmak između tekstova
                        Text(
                          "Rezervacije",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    color: const Color.fromARGB(0, 255, 235, 59),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _showPopup(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.35,
                            MediaQuery.of(context).size.height * 0.045,
                          ),
                        ),
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 191, 255),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.607,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: loadingLista
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : listContainer(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>>? listaRezervacija;
  int _currentPage = 0;
  int _pageSize = 10;
  int _odabraniId = 0;
  bool loadingLista = true;
  Future<void> getRezervacije(String status) async {
    setState(() {
      loadingLista = true;
    });

    listaRezervacija = await _rezervacijaServis.getRezervacije(status: status, serviserId: serviser?['serviserId']);

    setState(() {
      loadingLista = false;
    });
  }

  Widget listContainer(BuildContext context) {
    if (listaRezervacija == null || listaRezervacija!.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.607,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 238, 239),
              Color.fromARGB(255, 165, 196, 210),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
        ),
        child: Center(
          child: Text(
            'Nema dostupnih rezervacija.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    int startIndex = _currentPage * _pageSize;
    int endIndex = startIndex + _pageSize;
    List currentAdmini = listaRezervacija!.sublist(
      startIndex,
      endIndex > listaRezervacija!.length ? listaRezervacija!.length : endIndex,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.607,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 205, 238, 239),
            Color.fromARGB(255, 165, 196, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentAdmini.length,
              itemBuilder: (context, index) {
                final zapis = currentAdmini[index];
                final String datumKreiranja = zapis['datumRezervacije'];
                final DateTime parsedDate = DateTime.parse(datumKreiranja);
                final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      rezervacijaUcitana = false;
                      _odabraniId = zapis['rezervacijaId'];
                      activeTitleP = "Rezervacija";
                    });
                    await getRezervacija();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                  child: Text('<'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: endIndex < listaRezervacija!.length
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  child: Text('>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget homeWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 205, 238, 239),
            Color.fromARGB(255, 165, 196, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.06,
            color: const Color.fromARGB(0, 255, 235, 59),
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.615,
            color: const Color.fromARGB(0, 33, 149, 243),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 82, 205, 210),
                        Color.fromARGB(255, 7, 161, 235),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025), // Centrira glavni kontejner
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.475,
                        height: MediaQuery.of(context).size.height * 0.1,
                        color: Color.fromARGB(0, 255, 255, 255), // Pozadina za prvi pod-dio
                        child: Center(
                          child: Text(
                            'Cijena: ${getFormattedCijena(serviser?['cijena'])}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255, 255), // Svijetlo plava boja teksta
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.475,
                        height: MediaQuery.of(context).size.height * 0.1,
                        color: const Color.fromARGB(0, 255, 153, 0), // Pozadina za drugi pod-dio
                        child: Center(
                          child: Text(
                            'Ocjena: ${serviser?['ukupnaOcjena'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255, 255), // Svijetlo plava boja teksta
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.415,
                  color: const Color.fromARGB(0, 255, 235, 59), // Pozadina za drugi dio
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.37,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 155, 39, 176), // Bilo koja pozadina za novi dio
                        borderRadius: BorderRadius.circular(20), // Zaobljene ivice
                      ),
                      child: PrikazKalendara(serviserId: serviser?['serviserId']),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.1,
                  color: const Color.fromARGB(0, 76, 175, 79), // Pozadina za treći dio
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 82, 205, 210),
                            Color.fromARGB(255, 7, 161, 235),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.475,
                            height: MediaQuery.of(context).size.height * 0.09,
                            color: const Color.fromARGB(0, 244, 67, 54), // Pozadina za prvi pod-dio
                            child: Center(
                              child: Text(
                                'Broj servisa: ${serviser?['brojServisa'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.475,
                            height: MediaQuery.of(context).size.height * 0.09,
                            color: const Color.fromARGB(0, 76, 175, 79), // Pozadina za drugi pod-dio
                            child: Center(
                              child: Text(
                                serviser?['status'] == 'aktivan'
                                    ? 'Verifikovan'
                                    : (serviser?['status'] == 'obrisan' ? 'Obrisan' : 'Nije verifikovan'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String getFormattedCijena(dynamic cijena) {
    if (cijena == null) {
      return "N/A";
    }

    final double cijenaValue;
    try {
      cijenaValue = double.parse(cijena.toString());
    } catch (e) {
      return "N/A";
    }

    return "${cijenaValue.toStringAsFixed(2)} KM";
  }

  final _cijenaController = TextEditingController();

  Widget editServiseraWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        width: double.infinity,
        color: Color.fromARGB(0, 155, 39, 176), // Pozadina za editServiseraWidget
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06,
              color: Color.fromARGB(0, 86, 243, 33),
              child: Center(
                child: Text(
                  "Moguće je samo promijeniti cijenu ili\nobrisati servis ili ponovo poslati zahtev",
                  style: TextStyle(
                    color: Colors.white, // Bijela boja teksta
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6172,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 205, 238, 239),
                    Color.fromARGB(255, 165, 196, 210),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5172,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 244, 67, 54),
                    ),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 82, 205, 210),
                              Color.fromARGB(255, 7, 161, 235),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.15,
                              color: Color.fromARGB(0, 254, 152, 0),
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                },
                                child: Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    child: TextField(
                                      controller: _cijenaController,
                                      decoration: InputDecoration(
                                        hintText: 'Cijena',
                                        hintStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.05,
                              color: const Color.fromARGB(0, 155, 39, 176),
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  height: MediaQuery.of(context).size.height * 0.04,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      editServisera(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
                                      textStyle: MaterialStateProperty.all<TextStyle>(
                                        TextStyle(fontSize: 18), // Povećan font teksta
                                      ),
                                    ),
                                    child: Text("Izmjeni"),
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
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 76, 175, 79),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: serviser?['status'] == "obrisan"
                            ? Center(
                                child: Text(
                                  "Promjenom cijene saljete zahtjev",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  obrisiServisera(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                    TextStyle(fontSize: 18), // Povećan font teksta
                                  ),
                                ),
                                child: Text("Obriši"),
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
    );
  }

  editServisera(BuildContext context) async {
    String cijenaText = _cijenaController.text;

    if (cijenaText.isEmpty) {
      PorukaHelper.prikaziPorukuGreske(context, "Unesite cijenu.");
      return;
    }
    double? cijena = double.tryParse(cijenaText);
    if (cijena == null) {
      PorukaHelper.prikaziPorukuGreske(context, "Cijena mora biti broj.");
      return;
    }

    try {
      final String? responseMessage = await _serviserService.editServiser(cijena, serviser?['serviserId']);

      if (responseMessage != null) {
        if (responseMessage.contains("uspješno")) {
          _initialize();
          PorukaHelper.prikaziPorukuUspjeha(context, responseMessage);
          setState(() {
            _cijenaController.clear();
            activeTitleP = "home";
          });
        } else {
          PorukaHelper.prikaziPorukuGreske(context, responseMessage);
        }
      } else {
        PorukaHelper.prikaziPorukuGreske(context, "Nepoznata greška.");
      }
    } catch (e) {
      PorukaHelper.prikaziPorukuGreske(context, "Došlo je do greške: $e");
    }
  }

  obrisiServisera(BuildContext context) async {
    bool? confirmed = await ConfirmProzor.prikaziConfirmProzor(context, "Da li ste sigurni da želite obrisati servis?");
    if (confirmed != true) {
      return;
    }
    try {
      final response = await _serviserService.upravljanjeServiserom("obrisan", serviser?['serviserId']);

      if (response.statusCode == 200) {
        _initialize();
        PorukaHelper.prikaziPorukuUspjeha(context, "Serviser uspješno obrisan.");
        setState(() {
          activeTitleP = "home";
        });
      } else {
        PorukaHelper.prikaziPorukuGreske(context, "Neuspješno brisanje servisera: ${response.statusCode}");
      }
    } catch (e) {
      PorukaHelper.prikaziPorukuGreske(context, "Greška pri brisanju servisera: $e");
    }
  }

  late Map<String, dynamic> rezervacija;
  bool rezervacijaUcitana = false;

  Future<void> getRezervacija() async {
    try {
      rezervacija = await _rezervacijaServis.getRezervacijakById(_odabraniId);
      setState(() {
        rezervacijaUcitana = true;
      });
    } catch (e) {
      // Logika za rukovanje greškama može ići ovde
      setState(() {
        rezervacijaUcitana = false;
      });
    }
  }

  Widget rezervacijaaWidget(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 82, 205, 210),
                Color.fromARGB(255, 7, 161, 235),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: rezervacijaUcitana
                ? Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.43,
                        color: const Color.fromARGB(0, 244, 67, 54),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: rezervacijaUcitana
                                    ? Text(
                                        'Termin: ${formatDatumRezervacije(rezervacija['datumRezervacije'])}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: rezervacijaUcitana
                                    ? Text(
                                        'Kreiran: ${formatDatumRezervacije(rezervacija['datumKreiranja'])}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: rezervacijaUcitana
                                    ? Text(
                                        'Ocjena: ${rezervacija['ocjena'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: rezervacijaUcitana
                                    ? Text(
                                        'Status: ${rezervacija['status'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.07,
                        color: const Color.fromARGB(0, 76, 175, 79), // Možete zameniti ovu boju nekom drugom
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (rezervacija['status'] == 'kreiran') ...[
                              _builSetStatusdButton('Aktiviraj', "aktivan"),
                              SizedBox(width: 8.0),
                              _builSetStatusdButton('Vrati', "vracen"),
                            ] else if (rezervacija['status'] == 'aktivan') ...[
                              _builSetStatusdButton('Vrati', "vracen"),
                              SizedBox(width: 8.0),
                              _builSetStatusdButton('Zavrsi', "zavrseno"),
                            ] else if (rezervacija['status'] == 'vracen') ...[
                              _builSetStatusdButton('Aktiviraj', "aktivan"),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _builSetStatusdButton(String title, String status) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        onPressed: () async {
          await setStatusNarudbi(status);
        },
        child: Text(
          title,
          style: TextStyle(
            color: Color.fromARGB(255, 87, 202, 255),
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  setStatusNarudbi(String status) async {
    String poruka = await _rezervacijaServis.upravljanjeRezervacijom(status, _odabraniId);
    if (poruka == "Status uspješno ažuriran") {
      PorukaHelper.prikaziPorukuUspjeha(context, poruka);
      setState(() {
        rezervacijaUcitana = false;
      });
      await getRezervacija();
    } else {
      PorukaHelper.prikaziPorukuGreske(context, poruka);
    }
  }

  String formatDatumRezervacije(String? datumRezervacije) {
    if (datumRezervacije == null) {
      return 'N/A';
    }
    try {
      DateTime parsedDate = DateTime.parse(datumRezervacije);
      return DateFormat('dd MM yyyy').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: const Offset(0.20, 0.049),
          ).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            ),
          ),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.607,
              color: Colors.grey,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.54,
                    color: const Color.fromARGB(0, 33, 149, 243), // Pozadina za prvi dio
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusButton('Kreirane'),
                        _buildStatusButton('Izmijenjene'),
                        _buildStatusButton('Aktivane'),
                        _buildStatusButton('Zavrsene'),
                        _buildStatusButton('Obrisane'),
                        _buildStatusButton('Vracene'),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.067,
                    color: const Color.fromARGB(0, 76, 175, 79),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.height * 0.05),
                        ),
                        child: Text(
                          'Nazad',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 191, 255),
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
      },
    );
  }

  Widget _buildStatusButton(String title) {
    bool isSelected = title == _statusRezervacije;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color.fromARGB(255, 87, 202, 255) : Colors.white,
        ),
        onPressed: () {
          handleButtoStatusnPress(title);
          setState(() {
            Navigator.of(context).pop();
            _showPopup(context);
            _statusRezervacije = title;
          });
        },
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Color.fromARGB(255, 87, 202, 255),
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  handleButtoStatusnPress(String title) async {
    switch (title) {
      case 'Kreirane':
        await getRezervacije("kreiran");
        break;
      case 'Izmijenjene':
        await getRezervacije("izmijenjen");
        break;
      case 'Aktivane':
        await getRezervacije("aktivan");
        break;
      case 'Zavrsene':
        await getRezervacije("zavrseno");
        break;
      case 'Obrisane':
        await getRezervacije("obrisan");
        break;
      case 'Vracene':
        await getRezervacije("vracen");
        break;
      default:
        break;
    }
  }

  Widget _buildButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 87, 202, 255),
        ),
        onPressed: () {
          handleButtonPress(context, title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Future<void> handleButtonPress(BuildContext context, String title) async {
    switch (title) {
      case 'Edit':
        setState(() {
          activeTitleP = "urediS";
        });
        break;
      case 'Info':
        setState(() {
          activeTitleP = "home";
        });
        break;
      case 'Dodatno':
        handleButtoStatusnPress(_statusRezervacije);
        setState(() {
          activeTitleP = "Dodatno";
        });
        break;
      default:
        setState(() {
          activeTitleP = "home";
        });
    }
  }
}
