// ignore_for_file: unused_import, prefer_const_constructors, library_private_types_in_public_api, unused_field, unused_element, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';

class ServiseriPretraga extends StatefulWidget {
  const ServiseriPretraga({super.key});

  @override
  _ServiseriPretragastate createState() => _ServiseriPretragastate();
}

class _ServiseriPretragastate extends State<ServiseriPretraga>
    with SingleTickerProviderStateMixin {
  bool isPopupVisibleFilter = false;
  bool isPopupVisibleSort = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.45, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _togglePopupFilter() {
    if (!mounted) return; // Provjera da li je widget još uvijek montiran
    setState(() {
      if (isPopupVisibleFilter) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      isPopupVisibleFilter = !isPopupVisibleFilter;
    });
  }

  void _togglePopupSort() {
    if (!mounted) return; // Provjera da li je widget još uvijek montiran
    setState(() {
      if (isPopupVisibleSort) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      isPopupVisibleSort = !isPopupVisibleSort;
    });
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Zatvara AnimationController da spriječi curenje memorije
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          children: <Widget>[
            // gD
            gD(context),
            // dD
            dD(context),
            // navBar
            const NavBar(),
          ],
        ),
      ),
    );
  }

  Widget gD(BuildContext context) {
    return Column(
      children: [
        // Prvi dio
        Container(
          width: double.infinity,
          height:
              MediaQuery.of(context).size.height * 0.12, // 10% visine ekrana
          color: const Color.fromARGB(
              0, 244, 67, 54), // Zamijenite s bojom po želji
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
        // Drugi dio
        Container(
          width: double.infinity,
          height:
              MediaQuery.of(context).size.height * 0.11, // 11% visine ekrana
          color: const Color.fromARGB(
              0, 255, 235, 59), // Zamijenite s bojom po želji
          child: Center(
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
              height:
                  MediaQuery.of(context).size.height * 0.09, // 9% visine ekrana
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
                        const Text('Serviseri',
                            style: TextStyle(fontSize: 20)), // Povećan font
                      ],
                    ),
                  ),
                  // lD
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.55, // 55% širine ekrana
                    height: MediaQuery.of(context).size.height *
                        0.09, // 9% visine ekrana
                    color: const Color.fromARGB(
                        0, 33, 149, 243), // Zamijenite s bojom po želji
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _togglePopupSort,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                0.24, // Smanjena širina dugmića
                            height: MediaQuery.of(context).size.height *
                                0.07, // 7% visine ekrana
                            alignment: Alignment.center,
                            child: const Text(
                              'Poredaj',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 2.0, // Plava linija između dugmića
                          height: MediaQuery.of(context).size.height *
                              0.07, // Visina linije
                          color: Colors.blue,
                        ),
                        ElevatedButton(
                          onPressed: _togglePopupFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                0.24, // Smanjena širina dugmića
                            height: MediaQuery.of(context).size.height *
                                0.07, // 7% visine ekrana
                            alignment: Alignment.center,
                            child: const Text(
                              'Filtriraj',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget dD(BuildContext context) {
    return Stack(
      children: [
        // Prvi dio
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.65,
          color: Color.fromARGB(0, 76, 175, 79), // Zamijenite s bojom po želji
        ),
        // Drugi dio (pop-up)
        _buildPopupFilter(context),
        _buildPopupSort(context),
      ],
    );
  }

  Widget _buildPopupFilter(BuildContext context) {
    return isPopupVisibleFilter
        ? SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.65,
              color: const Color.fromARGB(
                  255, 255, 69, 58), // Zamijenite s bojom po želji
              child: Center(
                child: ElevatedButton(
                  onPressed: _togglePopupFilter,
                  child: const Text('Primjeni filter'),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _buildPopupSort(BuildContext context) {
    return isPopupVisibleSort
        ? SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.65,
              color: Color.fromARGB(
                  255, 58, 255, 91), // Zamijenite s bojom po želji
              child: Center(
                child: ElevatedButton(
                  onPressed: _togglePopupSort,
                  child: const Text('Primjeni sort'),
                ),
              ),
            ),
          )
        : Container();
  }
}
