// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields, unused_field, unused_element

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:flutter/material.dart';

class KorisnikoviProizvodi extends StatefulWidget {
  @override
  _KorisnikoviProizvodiState createState() => _KorisnikoviProizvodiState();
}

class _KorisnikoviProizvodiState extends State<KorisnikoviProizvodi> {
  String _selectedSection = 'bicikl';

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
                          'Vaši proizvodi',
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
        return dioHistorijaBicikla(context);
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
          width: MediaQuery.of(context).size.width * 0.9, // 90% širine ekrana
          height: MediaQuery.of(context).size.height * 0.6, // 50% visine ekrana
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
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
          width: MediaQuery.of(context).size.width * 0.9, // 90% širine ekrana
          height: MediaQuery.of(context).size.height * 0.6, // 50% visine ekrana
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 188, 188, 188),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
          ),
        ),
      ),
    );
  }
}
