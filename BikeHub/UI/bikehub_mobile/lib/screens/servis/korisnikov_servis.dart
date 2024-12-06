// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_element, sized_box_for_whitespace, unused_import, prefer_const_literals_to_create_immutables

import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/kalendar_rezervacije.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';

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

  String activeTitleP = 'home';

  @override
  initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final serviserData = await _serviserService.getServiseriDTOByKorisnikId(
          korisnikId: widget.korisnikId);
      setState(() {
        serviser = serviserData;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Expanded(
        child: FutureBuilder(
          future: Future.delayed(
              Duration(seconds: 10), () => loading ? 'timeout' : null),
          builder: (context, snapshot) {
            if (loading) {
              return Center(
                child:
                    CircularProgressIndicator(), // Prikazuje kružić za učitavanje
              );
            } else if (snapshot.data == 'timeout') {
              return Center(
                child: Text(
                    "Problem prilikom dohvatanja podataka"), // Poruka nakon 10 sekundi
              );
            } else {
              return Column(
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
                                color: Colors.white, // Tekst bijele boje
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
                              _buildButton(activeTitleP == 'home'
                                  ? 'Edit'
                                  : (activeTitleP == 'urediS'
                                      ? 'Info'
                                      : 'Edit')),
                              _buildButton("Obriši"),
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
                  const NavBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget getActiveWidget(BuildContext context) {
    switch (activeTitleP) {
      case 'home':
        return homeWidget(context);
      case 'urediS':
        return editServiseraWidget(context);
      default:
        return homeWidget(context);
    }
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
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          0.025), // Centrira glavni kontejner
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.475,
                        height: MediaQuery.of(context).size.height * 0.1,
                        color: Color.fromARGB(
                            0, 255, 255, 255), // Pozadina za prvi pod-dio
                        child: Center(
                          child: Text(
                            'Cijena: ${serviser?['cijena'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255,
                                  255), // Svijetlo plava boja teksta
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.475,
                        height: MediaQuery.of(context).size.height * 0.1,
                        color: const Color.fromARGB(
                            0, 255, 153, 0), // Pozadina za drugi pod-dio
                        child: Center(
                          child: Text(
                            'Ocjena: ${serviser?['ukupnaOcjena'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255,
                                  255), // Svijetlo plava boja teksta
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
                  color: const Color.fromARGB(
                      0, 255, 235, 59), // Pozadina za drugi dio
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.37,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            0, 155, 39, 176), // Bilo koja pozadina za novi dio
                        borderRadius:
                            BorderRadius.circular(20), // Zaobljene ivice
                      ),
                      child:
                          PrikazKalendara(serviserId: serviser?['serviserId']),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.1,
                  color: const Color.fromARGB(
                      0, 76, 175, 79), // Pozadina za treći dio
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
                            color: const Color.fromARGB(
                                0, 244, 67, 54), // Pozadina za prvi pod-dio
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
                            color: const Color.fromARGB(
                                0, 76, 175, 79), // Pozadina za drugi pod-dio
                            child: Center(
                              child: Text(
                                serviser?['status'] == 'aktivan'
                                    ? 'Verifikovan'
                                    : (serviser?['status'] == 'obrisan'
                                        ? 'Obrisan'
                                        : 'Nije verifikovan'),
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

  Widget editServiseraWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.purple, // Pozadina za editServiseraWidget
    );
  }

  Widget _buildButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
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

  void handleButtonPress(BuildContext context, String title) {
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
      default:
        setState(() {
          activeTitleP = "home";
        });
    }
  }
}
