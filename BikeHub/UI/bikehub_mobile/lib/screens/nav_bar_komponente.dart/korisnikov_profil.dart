// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const, unnecessary_null_comparison, prefer_final_fields, unused_field, sort_child_properties_last, avoid_print, sized_box_for_whitespace

import 'package:bikehub_mobile/screens/administracija/administracija.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikove_rezervacije.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikovi_proizvodi.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/screens/servis/korisnikov_servis.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_info_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/rezervacije_service.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';

class KorisnikovProfil extends StatefulWidget {
  @override
  _KorisnikovProfilState createState() => _KorisnikovProfilState();
}

class _KorisnikovProfilState extends State<KorisnikovProfil> {
  int korisnikId = 0;
  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);
  Map<String, dynamic>? adresa;
  Map<String, dynamic>? korisnik;
  String activeTitleP = 'home';
  final KorisnikServis _korisnikService = KorisnikServis();
  final AdresaServis _adresaService = AdresaServis();
  final KorisnikInfoServis _korisnikInfoServis = KorisnikInfoServis();
  final RezervacijaServis _rezervacijaServis = RezervacijaServis();

  @override
  initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      futureKorisnik = _korisnikService.isLoggedIn().then((isLoggedIn) async {
        if (isLoggedIn) {
          Map<String, String?> userInfo = await _korisnikService.getUserInfo();
          korisnikId = int.parse(userInfo['korisnikId']!);
          korisnik = await _korisnikService.getKorisnikById(korisnikId);

          if (korisnik != null) {
            adresa = await _adresaService.getAdresa(korisnikId: korisnikId);
          }
          return korisnik;
        }
        return null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            prviDio(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    getActiveWidget(context),
                    // NavBar unutar Expanded da se tastatura može prikazati preko njega
                    const NavBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget prviDio(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.15, // 15% visine ekrana
      color: const Color.fromARGB(0, 68, 137, 255), // Bilo koja pozadina
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width:
                  MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
              height:
                  MediaQuery.of(context).size.height * 0.07, // 7% visine ekrana
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  // dD
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.40, // 40% širine ekrana
                    height: MediaQuery.of(context).size.height *
                        0.07, // 7% visine ekrana
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
                          'Profil',
                          style: TextStyle(fontSize: 20), // Povećan font
                        ),
                      ],
                    ),
                  ),
                  // lD
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.55, // 55% širine ekrana
                    height: MediaQuery.of(context).size.height *
                        0.07, // 7% visine ekrana
                    color: Color.fromARGB(
                        0, 255, 6, 6), // Zamijenite s bojom po želji
                    child: Center(
                      child: activeTitleP == 'home'
                          ? _buildButton('Uredi profil')
                          : _buildButton('Nazad'),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 8), // Prazan prostor ispod bijelog dijela
          ],
        ),
      ),
    );
  }

  Widget getActiveWidget(BuildContext context) {
    switch (activeTitleP) {
      case 'home':
        return drugiDio(context);
      case 'urediP':
        return urediProfil(context);
      default:
        return drugiDio(context);
    }
  }

  Widget drugiDio(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.73, // 73% visine ekrana
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 205, 238, 239),
            Color.fromARGB(255, 165, 196, 210),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50.0),
          topRight: Radius.circular(50.0),
        ),
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: futureKorisnik,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  snapshot.error.toString().contains('Server is not available')
                      ? 'Server nije dostupan'
                      : 'Problem prilikom učitavanja podataka'),
            );
          } else if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Potrebno je prijaviti se'),
                  const SizedBox(height: 16),
                  _buildButton('Prijava'),
                ],
              ),
            );
          } else {
            final korisnik = snapshot.data!;
            return korisnikWidget(context, korisnik);
          }
        },
      ),
    );
  }

  String izmjeneNad = "Lozinku";

  Widget buildButton(String title) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          izmjeneNad = title;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: title == izmjeneNad ? Colors.white : Colors.lightBlue,
          fontSize: 16,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: title == izmjeneNad
            ? Color.fromARGB(255, 87, 202, 255)
            : Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }

  Widget izmjeneNadWidget(String title) {
    switch (title) {
      case "Lozinku":
        return lozinkaWidget();
      case "Adresu":
        return adresaWidget();
      case "Osnovne":
        return osnovneWidget();
      default:
        return lozinkaWidget();
    }
  }

  Widget lozinkaWidget() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.66,
      color: const Color.fromARGB(0, 33, 149, 243),
      child: Center(
          child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 110, 255, 253),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Color.fromARGB(0, 255, 235, 59),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.39,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Color.fromARGB(
                  0, 244, 67, 54), // Bilo koja pozadina za prvi dio
              child: Center(
                child: Column(
                  children: [
                    createInputField("Stara lozinka", true, staraLozinka),
                    createInputField("Nova lozinka", true, lozinka),
                    createInputField("Potvrda lozinke", true, lozinkaPotvrda),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              color: const Color.fromARGB(0, 255, 235, 59),
              child: Center(
                child: izmjenaNadButton("Izmjeni", "Lozinku"),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget adresaWidget() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.66,
      color: const Color.fromARGB(0, 76, 175, 79),
      child: Center(
          child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 110, 255, 253),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Color.fromARGB(0, 255, 235, 59),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.39,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Color.fromARGB(
                  0, 244, 67, 54), // Bilo koja pozadina za prvi dio
              child: Center(
                child: Column(
                  children: [
                    createInputField("Grad", false, grad),
                    createInputField("Postanski broj", false, postanskiBroj),
                    createInputField("Ulica", false, ulica),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              color: const Color.fromARGB(0, 255, 235, 59),
              child: Center(
                child: izmjenaNadButton("Izmjeni", "Adresu"),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget osnovneWidget() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.66,
      color: const Color.fromARGB(0, 244, 67, 54),
      child: Center(
          child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 110, 255, 253),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.43,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Color.fromARGB(
                  0, 244, 67, 54), // Bilo koja pozadina za prvi dio
              child: Center(
                child: Column(
                  children: [
                    createInputField("Username", false, username),
                    createInputField("Email", false, email),
                    createInputField("Ime i prezime", false, imePrezime),
                    createInputField("Telefon", false, telefon),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              color: const Color.fromARGB(0, 255, 235, 59),
              child: Center(
                child: izmjenaNadButton("Izmjeni", "Osnovne"),
              ),
            )
          ],
        ),
      )),
    );
  }

  Widget izmjenaNadButton(String title, String objekt) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            posaljiIzmjene(objekt);
          });
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 87, 202, 255),
        ),
      ),
    );
  }

  void posaljiIzmjene(String objekt) {
    switch (objekt) {
      case "Lozinku":
        _korisnikService
            .izmjeniLozinkuKorisnika(staraLozinka.text, lozinka.text,
                lozinkaPotvrda.text, korisnik?['korisnikId'])
            .then((result) {
          if (result == "Lozinka uspješno izmjenjena") {
            PorukaHelper.prikaziPorukuUspjeha(context,
                "Zbog uspjesne promjene lozinke potrebo je logirati se");
            _korisnikService.logout();
            lozinka.clear();
            lozinkaPotvrda.clear();
            staraLozinka.clear();
            setState(() {
              activeTitleP = "home";
              _initialize();
            });
          } else {
            PorukaHelper.prikaziPorukuGreske(context, result!);
          }
        }).catchError((error) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška: $error");
        });
        break;
      case "Adresu":
        _adresaService
            .promjeniAdresu(
          grad.text,
          postanskiBroj.text,
          ulica.text,
          adresa?['adresaId'],
        )
            .then((result) {
          if (result == "Adresa uspješno izmjenjena") {
            grad.clear();
            postanskiBroj.clear();
            ulica.clear();
            setState(() {
              activeTitleP = "home";
              _initialize();
            });
            PorukaHelper.prikaziPorukuUspjeha(context, result!);
          } else {
            PorukaHelper.prikaziPorukuGreske(context, result!);
          }
        }).catchError((error) {
          PorukaHelper.prikaziPorukuGreske(context, "Greška: $error");
        });
        break;
      case "Osnovne":
        if (username.text.isEmpty &&
            email.text.isEmpty &&
            imePrezime.text.isEmpty &&
            telefon.text.isEmpty) {
          PorukaHelper.prikaziPorukuUpozorenja(
              context, "Potrebno je izmjenuti barem jedan zapis");
        } else {
          if (imePrezime.text.isNotEmpty || telefon.text.isNotEmpty) {
            _korisnikInfoServis
                .promjeniKorisnikInfo(imePrezime.text, telefon.text,
                    korisnik?['korisnikInfos'][0]['korisnikInfoId'])
                .then((result) {
              if (result == "Korisnik Info uspješno izmjenjena") {
                imePrezime.clear();
                telefon.clear();
                setState(() {
                  activeTitleP = "home";
                  _initialize();
                });

                PorukaHelper.prikaziPorukuUspjeha(context, result!);
              } else {
                PorukaHelper.prikaziPorukuGreske(context, result!);
              }
            }).catchError((error) {
              PorukaHelper.prikaziPorukuGreske(context, "Greška: $error");
            });
          }
          if (username.text.isNotEmpty || email.text.isNotEmpty) {
            _korisnikService
                .izmjeniKorisnika(
                    email.text, username.text, korisnik?['korisnikId'])
                .then((result) {
              if (result == "Korisnik uspješno izmjenjen") {
                if (username.text.isNotEmpty) {
                  PorukaHelper.prikaziPorukuUspjeha(context,
                      "Zbog uspjesne promjene username-a potrebo je logirati se");
                  _korisnikService.logout();
                  email.clear();
                  username.clear();
                  setState(() {
                    activeTitleP = "home";
                    _initialize();
                  });
                } else {
                  PorukaHelper.prikaziPorukuUspjeha(context, result!);
                  setState(() {
                    activeTitleP = "home";
                    _initialize();
                  });
                }
              } else {
                PorukaHelper.prikaziPorukuGreske(context, result!);
              }
            }).catchError((error) {
              PorukaHelper.prikaziPorukuGreske(context, "Greška: $error");
            });
          }
        }
        break;

      default:
        break;
    }
  }

  final TextEditingController staraLozinka = TextEditingController();
  final TextEditingController lozinka = TextEditingController();
  final TextEditingController lozinkaPotvrda = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController imePrezime = TextEditingController();
  final TextEditingController telefon = TextEditingController();
  final TextEditingController grad = TextEditingController();
  final TextEditingController postanskiBroj = TextEditingController();
  final TextEditingController ulica = TextEditingController();

  Widget createInputField(
      String title, bool isLozinka, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              width: MediaQuery.of(context).size.width *
                  0.8, // Smanjena širina inputa
              child: TextField(
                controller: controller,
                obscureText: isLozinka,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget urediProfil(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.73,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 251, 251, 251),
                Color.fromARGB(255, 128, 255, 253)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ), // Zaobljene gornje ivice
          ),
          child: Column(
            children: [
              izmjeneNadWidget(izmjeneNad),
              Container(
                //dio za prikaz dugmica
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.07,
                color:
                    const Color.fromARGB(0, 76, 175, 79), // Bilo koja pozadina
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton("Adresu"),
                    SizedBox(width: 10),
                    buildButton("Lozinku"),
                    SizedBox(width: 10),
                    buildButton("Osnovne"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget korisnikWidget(BuildContext context, Map<String, dynamic> korisnik) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.73, // 73% visine ekrana
      color: const Color.fromARGB(0, 3, 168, 244), // Pozadina za prepoznavanje
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height * 0.17, // 20% visine ekrana
            color: Color.fromARGB(0, 244, 67, 54), // Prva pozadina
            child: Column(
              children: [
                //samo Ikona korisnik
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.09,
                        color: Color.fromARGB(
                            0, 33, 149, 243), // Pozadina za prvi podkontenjer
                        child: Center(
                          child: Container(
                            width: 80, // Širina kruga
                            height: 80, // Visina kruga
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 82, 205, 210),
                                  Color.fromARGB(255, 7, 161, 235),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person, // Ikona koja podsjeća na korisnika
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.03,
                        color: Color.fromARGB(
                            0, 255, 68, 58), // Pozadina za drugi podkontenjer
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: InkWell(
                              onTap: () {
                                _korisnikService.logout();
                                setState(() {
                                  _initialize();
                                  activeTitleP = "home";
                                });
                              },
                              child: Icon(
                                Icons.logout,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // username
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.04, // 12% visine ekrana
                  color: Color.fromARGB(
                      0, 76, 175, 79), // Pozadina za drugi podkontenjer
                  child: Center(
                    child: Text(
                      korisnik['username'] ?? 'N/A', // Prikaz korisničkog imena
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // imePrezime, Status, email, broj, grad, ulica
          Container(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height * 0.30, // 28% visine ekrana
            color: Color.fromARGB(0, 76, 175, 79), // Druga pozadina
            child: Center(
              // Dodano za centriranje unutarnjeg kontenjera
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.95, // 95% širine ekrana
                height: MediaQuery.of(context).size.height *
                    0.28, // 28% visine ekrana
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 205, 210),
                      Color.fromARGB(255, 7, 161, 235),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25.0), // Zaobljene ivice
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centriranje djece
                  children: [
                    // imePrezime, Status,
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.90, // 90% širine ekrana
                      height: MediaQuery.of(context).size.height *
                          0.06, // 6% visine ekrana
                      decoration: BoxDecoration(
                        color: Colors.white, // Bijela boja pozadine
                        borderRadius:
                            BorderRadius.circular(12.0), // Zaobljene ivice
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Prvi dio: Ime i prezime korisnika
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person, // Ikona umjesto teksta
                                  size: 20,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                    width: 8), // Razmak između ikone i teksta
                                Text(
                                  getImePrezime(korisnik),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Drugi dio: Verifikovan checkbox
                          Row(
                            children: [
                              const Text(
                                'Verifikovan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                value: isVerifikovan(korisnik),
                                onChanged: (bool? value) {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8), // Razmak između redova
                    //email broj
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.90, // 90% širine ekrana
                      height: MediaQuery.of(context).size.height *
                          0.06, // 6% visine ekrana
                      decoration: BoxDecoration(
                        color: Colors.white, // Bijela boja pozadine
                        borderRadius:
                            BorderRadius.circular(12.0), // Zaobljene ivice
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Prvi dio: Email korisnika
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.email, // Ikona za email
                                  size: 20,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                    width: 8), // Razmak između ikone i teksta
                                Text(
                                  korisnik['email'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Drugi dio: Telefon korisnika
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone, // Ikona za telefon
                                  size: 20,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                    width: 8), // Razmak između ikone i teksta
                                Text(
                                  getTelefon(korisnik),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8), // Razmak između redova
                    //Grad, ulica
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.90, // 90% širine ekrana
                      height: MediaQuery.of(context).size.height *
                          0.06, // 6% visine ekrana
                      decoration: BoxDecoration(
                        color: Colors.white, // Bijela boja pozadine
                        borderRadius:
                            BorderRadius.circular(12.0), // Zaobljene ivice
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on, // Ikona za lokaciju
                              size: 20,
                              color: Colors.black,
                            ),
                            const SizedBox(
                                width: 8), // Razmak između ikone i teksta
                            Text(
                              adresa != null
                                  ? '${adresa?['grad'] ?? 'N/A'}, ${adresa?['ulica'] ?? 'N/A'}, ${adresa?['postanskiBroj'] ?? 'N/A'}'
                                  : 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          //broj proizvoda, serviser
          Container(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height * 0.23, // 23% visine ekrana
            color: const Color.fromARGB(0, 255, 235, 59), // Treća pozadina
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    // Ovdje će ići vaša funkcionalnost
                    print('Kontejner je kliknut!');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.43,
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
                      borderRadius:
                          BorderRadius.circular(10.0), // Zaobljene ivice
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: MediaQuery.of(context).size.height * 0.095,
                          color: const Color.fromARGB(
                              0, 244, 67, 54), // Boja pozadine za prvi dio
                          child: Center(
                            child: _buildButton("Proizvodi"),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: MediaQuery.of(context).size.height * 0.095,
                          color: const Color.fromARGB(
                              0, 33, 149, 243), // Boja pozadine za drugi dio
                          child: Center(
                            child: _buildButton("Rezervacije"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10), // Razmak između dva kontejnera
                //admin serviser
                Container(
                  width: MediaQuery.of(context).size.width * 0.43,
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
                    borderRadius:
                        BorderRadius.circular(10.0), // Zaobljene ivice
                  ),
                  child: korisnik['isAdmin']
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              height:
                                  MediaQuery.of(context).size.height * 0.095,
                              color: const Color.fromARGB(
                                  0, 244, 67, 54), // Prva boja
                              //serviser
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (korisnik['jeServiser'] == 'kreiran') ...[
                                    Text(
                                      'Zahtjev za licencu\nservisera je poslan',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Bijela boja za tekst
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ] else if (korisnik['jeServiser'] ==
                                      null) ...[
                                    Text(
                                      'Postani serviser',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Bijela boja za tekst
                                        fontSize: 14,
                                      ),
                                    ),
                                    _buildButton('Zahtjev'),
                                  ] else ...[
                                    Text(
                                      'Vaš servis',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Bijela boja za tekst
                                        fontSize: 14,
                                      ),
                                    ),
                                    _buildButton('Servis'),
                                  ]
                                ],
                              ),
                            ),
                            //admin
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              height:
                                  MediaQuery.of(context).size.height * 0.095,
                              color: const Color.fromARGB(
                                  0, 76, 175, 79), // Druga boja
                              child: Center(
                                child: _buildButton('Admin'),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: MediaQuery.of(context).size.height * 0.095,
                          color:
                              const Color.fromARGB(0, 244, 67, 54), // Prva boja
                          //serviser
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (korisnik['jeServiser'] == 'kreiran') ...[
                                Text(
                                  'Zahtjev za licencu\nservisera je poslan',
                                  style: TextStyle(
                                    color: Colors.white, // Bijela boja za tekst
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ] else if (korisnik['jeServiser'] == null) ...[
                                Text(
                                  'Postani serviser',
                                  style: TextStyle(
                                    color: Colors.white, // Bijela boja za tekst
                                    fontSize: 14,
                                  ),
                                ),
                                _buildButton('Zahtjev'),
                              ] else ...[
                                Text(
                                  'Vaš servis',
                                  style: TextStyle(
                                    color: Colors.white, // Bijela boja za tekst
                                    fontSize: 14,
                                  ),
                                ),
                                _buildButton('Servis'),
                              ]
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getImePrezime(Map<String, dynamic> korisnik) {
    if (korisnik['korisnikInfos'] != null &&
        korisnik['korisnikInfos'].isNotEmpty) {
      String imePrezime = korisnik['korisnikInfos'][0]['imePrezime'] ?? 'N/A';
      return imePrezime.isNotEmpty ? imePrezime : 'N/A';
    }
    return 'N/A';
  }

  bool isVerifikovan(Map<String, dynamic> korisnik) {
    return korisnik['status'] == 'aktivan';
  }

  String getTelefon(Map<String, dynamic> korisnik) {
    if (korisnik['korisnikInfos'] != null &&
        korisnik['korisnikInfos'].isNotEmpty) {
      String telefon = korisnik['korisnikInfos'][0]['telefon'] ?? 'N/A';
      return telefon.isNotEmpty ? telefon : 'N/A';
    }
    return 'N/A';
  }

  Widget _buildButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
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
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void handleButtonPress(BuildContext context, String title) {
    switch (title) {
      case 'Prijava':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );
        break;

      case 'Rezervacije':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RezervacijeKorisnika(
                    korisnikId: korisnikId,
                  )),
        );
        break;
      case 'Proizvodi':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KorisnikoviProizvodi()),
        );
        break;
      case 'Servis':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KorisnikovServis(
                    korisnikId: korisnikId,
                  )),
        );
        break;
      case 'Zahtjev':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );
        break;
      case 'Admin':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdministracijaPage()),
        );
        break;
      case 'Uredi profil':
        setState(() {
          activeTitleP = "urediP";
        });
        break;
      case 'Nazad':
        setState(() {
          activeTitleP = "home";
        });
        break;
      default:
        PorukaHelper.prikaziPorukuUpozorenja(context, 'Nepoznata radnja.');
    }
  }
}
