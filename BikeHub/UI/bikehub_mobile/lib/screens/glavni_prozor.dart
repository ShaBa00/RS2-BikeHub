// ignore_for_file: prefer_const_constructors

import 'package:bikehub_mobile/screens/dodavanje/dodaj_novi.dart';
import 'package:bikehub_mobile/screens/pretrage/bicikl_pretraga.dart';
import 'package:bikehub_mobile/screens/pretrage/dijelovi_pretraga.dart';
import 'package:bikehub_mobile/screens/pretrage/serviseri_pretraga.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';

class GlavniProzor extends StatelessWidget {
  const GlavniProzor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Dodano za izbjegavanje overflow-a
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 238, 239),
              Color.fromARGB(255, 165, 196, 210),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          // Dodano za omogućavanje skrolanja
          child: Column(
            children: <Widget>[
              //glavniDio
              dioPretrage(context),
              dioPromovisanih(context),
              dioNovi(context),
              //navBar
              const NavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dioPretrage(BuildContext context) {
    return Column(
      children: [
        //gP
        Container(
          width: MediaQuery.of(context).size.width, // 100% širine ekrana
          height:
              MediaQuery.of(context).size.height * 0.13, // 10% visine ekrana
          color: const Color.fromARGB(
              0, 255, 235, 59), // Zamijenite s bojom po želji
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.85, // 85% širine ekrana
              height: MediaQuery.of(context).size.height *
                  0.06, // Smanjena visina search bara
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pretrazi proizvode',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Trenutno na onPressed ne radi ništa
                    },
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
              customButton(context, 'bicikl', Icons.directions_bike),
              customButton(context, 'serviseri', Icons.build),
              customButton(context, 'dijelovi', Icons.handyman),
            ],
          ),
        ),
      ],
    );
  }

  //dugmici za pretraku Bicikla, dijela i servisera
  Widget customButton(BuildContext context, String title, IconData icon) {
    return Container(
      width: 70.0, // Povećanje veličine dugmića
      height: 70.0, // Povećanje veličine dugmića
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 205, 210),
            Color.fromARGB(255, 7, 161, 235),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white), // Ikone bijele boje
        iconSize: 30.0, // Povećanje veličine ikone
        onPressed: () {
          osnovnaNavigacija(context, title);
        },
      ),
    );
  }

  void osnovnaNavigacija(BuildContext context, String title) {
    switch (title) {
      case 'bicikl':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BiciklPretraga()),
        );
        break;
      case 'serviseri':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServiseriPretraga()),
        );
        break;
      case 'dijelovi':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DijeloviPretraga()),
        );
        break;
      case 'dodavanje':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DodajNovi()),
        );
        break;
      default:
        PorukaHelper.prikaziPorukuGreske(context, 'Nepoznata opcija');
        break;
    }
  }

  Widget dioPromovisanih(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.53, // 53% visine ekrana
      color:
          const Color.fromARGB(0, 76, 175, 79), // Zamijenite s bojom po želji
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% širine ekrana
          height: MediaQuery.of(context).size.height * 0.5, // 50% visine ekrana
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

  Widget dioNovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.10, // 10% visine ekrana
      color:
          const Color.fromARGB(0, 33, 149, 243), // Zamijenite s bojom po želji
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: customButton(context, 'dodavanje', Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
