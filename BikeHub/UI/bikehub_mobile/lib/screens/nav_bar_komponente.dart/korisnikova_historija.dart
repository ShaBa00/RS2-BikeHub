// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, unused_element

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/prijava/log_in.dart';
import 'package:bikehub_mobile/servisi/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class KorisnikovaHistorija extends StatefulWidget {
  @override
  _KorisnikovaHistorijaState createState() => _KorisnikovaHistorijaState();
}

class _KorisnikovaHistorijaState extends State<KorisnikovaHistorija> {
  final KorisnikServis _korisnikService = KorisnikServis();

  String _selectedSection = 'bicikl';
  Future<Map<String, dynamic>?>? futureKorisnik = Future.value(null);
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  int korisnikId = 0;
  bool isLogged = false;
  bool isLoading = true;

  Future<void> _initialize() async {
    final isLoggedIn = await _korisnikService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _korisnikService.getUserInfo();
      korisnikId = int.parse(userInfo['korisnikId']!);

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
          height:
              MediaQuery.of(context).size.height * 0.10, // 10% visine ekrana
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
                          'Historija narudžbi',
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
              customButton(context, 'serviseri', Icons.build, _selectedSection,
                  _updateSection),
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
        return dioHistorijaBicikla(context);
      case 'serviseri':
        return dioHistorijServisa(context);
      case 'dijelovi':
        return dioHistorijDijelova(context);
      default:
        return dioHistorijaBicikla(context);
    }
  }

  Widget dioHistorijaBicikla(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.66, // 53% visine ekrana
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 238, 228),
            Color.fromARGB(255, 6, 93, 73),
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

  Widget dioHistorijServisa(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.66, // 53% visine ekrana
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 33, 217, 238),
            Color.fromARGB(255, 3, 72, 79),
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
}
