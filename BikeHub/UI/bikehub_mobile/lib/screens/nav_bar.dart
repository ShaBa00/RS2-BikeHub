// ignore_for_file: library_private_types_in_public_api

import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikov_profil.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikova_historija.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikovi_proizvodi.dart';
import 'package:bikehub_mobile/screens/nav_bar_komponente.dart/korisnikovi_sacuvani.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.12, // 12% visine ekrana
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 188, 188, 188),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navBarButton(context, 'historija', Icons.history),
          navBarButton(context, 'sacuvani', Icons.bookmark),
          navBarButton(context, 'home', Icons.home),
          navBarButton(context, 'profil', Icons.person),
          navBarButton(context, 'proizvodi', Icons.store),
        ],
      ),
    );
  }

  Widget navBarButton(BuildContext context, String title, IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      iconSize: 35.0, // Povećanje veličine ikone
      padding: const EdgeInsets.all(16.0), // Povećanje širine dugmića
      onPressed: () {
        navigacija(context, title);
      },
    );
  }

  void navigacija(BuildContext context, String title) {
    switch (title) {
      case 'historija':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KorisnikovaHistorija()),
        );
        break;
      case 'sacuvani':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KoriskinoviSacuvai()),
        );
        break;
      case 'home':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GlavniProzor()),
        );
        break;
      case 'profil':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KorisnikovProfil()),
        );
        break;
      case 'proizvodi':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KorisnikoviProizvodi()),
        );
        break;
      default:
        PorukaHelper.prikaziPorukuGreske(context, 'Nepoznata opcija');
        break;
    }
  }
}
