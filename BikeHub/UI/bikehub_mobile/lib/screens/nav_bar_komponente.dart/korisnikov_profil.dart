// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const, unnecessary_null_comparison

import 'package:bikehub_mobile/screens/administracija/administracija.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/servisi/korisnik/adresa_service.dart';
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

  @override
  initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      futureKorisnik = KorisnikServis().isLoggedIn().then((isLoggedIn) async {
        if (isLoggedIn) {
          Map<String, String?> userInfo = await KorisnikServis().getUserInfo();
          korisnikId = int.parse(userInfo['korisnikId']!);
          final korisnik = await KorisnikServis().getKorisnikById(korisnikId);

          if (korisnik != null) {
            adresa = await AdresaServis().getAdresa(korisnikId: korisnikId);
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
        color: Colors.blueAccent, // Bilo koja pozadina
        child: Column(
          children: <Widget>[
            prviDio(context),
            drugiDio(context),
            // navBar
            const NavBar(),
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
                        0, 255, 6, 6), // Zamijenite s bojom po želj
                    child: Center(
                      child: _buildButton('Uredi profil'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8), // Prazan prostor ispod bijelog dijela
          ],
        ),
      ),
    );
  }

//DIO ZA PRIKAZIVANJE PODATAKA

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
                  height: MediaQuery.of(context).size.height *
                      0.12, // 13% visine ekrana
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
                                  ? '${adresa?['grad'] ?? 'N/A'}, ${adresa?['ulica'] ?? 'N/A'}'
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
                    // ignore: avoid_print
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Broj proizvoda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Bijela boja za tekst
                          ),
                        ),
                        Text(
                          korisnik != null && korisnik['brojProizvoda'] != null
                              ? korisnik['brojProizvoda'].toString()
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
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
      width: MediaQuery.of(context).size.width * 0.34,
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
      case 'Servis':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
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
        PorukaHelper.prikaziPorukuUspjeha(context, 'Profil uspješno uređen!');
        break;
      default:
        PorukaHelper.prikaziPorukuUpozorenja(context, 'Nepoznata radnja.');
    }
  }
}
