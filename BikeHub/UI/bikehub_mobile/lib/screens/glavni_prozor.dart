// ignore_for_file: prefer_const_constructors, avoid_print, library_private_types_in_public_api, unused_field, unused_element, no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:bikehub_mobile/screens/dodavanje/dodaj_novi.dart';
import 'package:bikehub_mobile/screens/pretrage/bicikl_pretraga.dart';
import 'package:bikehub_mobile/screens/pretrage/dijelovi_pretraga.dart';
import 'package:bikehub_mobile/screens/pretrage/serviseri_pretraga.dart';
import 'package:bikehub_mobile/screens/prikaz/bicikli_prikaz.dart';
import 'package:bikehub_mobile/screens/prikaz/dijelovi_prikaz.dart';
import 'package:bikehub_mobile/servisi/bicikli/bicikl_service.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';

class GlavniProzor extends StatefulWidget {
  const GlavniProzor({super.key});

  @override
  _GlavniProzorState createState() => _GlavniProzorState();
}

class _GlavniProzorState extends State<GlavniProzor> {
  final BiciklService _biciklService = BiciklService();

  List<dynamic> listaZapisa = [];
  bool loadingZapisi = true;

  _initialize() async {
    try {
      listaZapisa = await _biciklService.getPromotedItems();
    } finally {
      if (mounted) {
        setState(() {
          listaZapisa;
          loadingZapisi = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
            child: Column(
              children: <Widget>[
                dioPretrage(context),
                dioPromovisanih(context),
                dioNovi(context),
                const NavBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dioPretrage(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.13,
          color: const Color.fromARGB(0, 255, 235, 59),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.06,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Center(
                  child: Text(
                    "Promovisi svoj proizvod",
                    style: TextStyle(color: Color.fromARGB(255, 0, 191, 255)),
                  ),
                ),
              ),
            ),
          ),
        ),
        //dP
        Container(
          width: MediaQuery.of(context).size.width, // 100% širine ekrana
          height: MediaQuery.of(context).size.height * 0.12, // 15% visine ekrana
          color: const Color.fromARGB(0, 255, 153, 0), // Zamijenite s bojom po želji
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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.53,
      color: const Color.fromARGB(0, 76, 175, 79),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
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
          child: Center(
            child: loadingZapisi
                ? CircularProgressIndicator() // Kružic za učitavanje
                : Column(
                    children: [_buildListaZapisa(context)],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaZapisa(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      color: const Color.fromARGB(0, 244, 67, 54),
      child: loadingZapisi
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: List.generate(
                  (listaZapisa.length / 2).ceil().clamp(0, 3),
                  (index) {
                    int firstIndex = index * 2;
                    int secondIndex = firstIndex + 1;

                    Widget _buildItem(Map<String, dynamic> item) {
                      bool isBicikl = item.containsKey('biciklId');
                      String naziv = item['naziv'] ?? 'N/A';
                      String cijena = item['cijena'] != null ? getFormattedCijena(item['cijena']) : 'N/A';

                      List slike = item['slike'] ?? [];

                      return GestureDetector(
                        onTap: () {
                          if (isBicikl) {
                            int biciklId = item['biciklId'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BicikliPrikaz(biciklId: biciklId),
                              ),
                            );
                          } else {
                            int dijeloviId = item['dijeloviId'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DijeloviPrikaz(dijeloviId: dijeloviId),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(244, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.height * 0.16,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(229, 244, 67, 54),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                ),
                                child: slike.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                        child: Image.memory(
                                          base64Decode(slike[0]['slika']),
                                          width: MediaQuery.of(context).size.width * 0.4,
                                          height: MediaQuery.of(context).size.height * 0.16,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 40.0,
                                        ),
                                      ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.height * 0.04,
                                color: const Color.fromARGB(0, 33, 149, 243),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          naziv,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          cijena,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
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
                      );
                    }

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.22,
                      color: const Color.fromARGB(0, 255, 255, 255),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (firstIndex < listaZapisa.length) _buildItem(listaZapisa[firstIndex]),
                          if (secondIndex < listaZapisa.length) _buildItem(listaZapisa[secondIndex]),
                        ],
                      ),
                    );
                  },
                ),
              ),
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

  Widget dioNovi(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // 100% širine ekrana
      height: MediaQuery.of(context).size.height * 0.10, // 10% visine ekrana
      color: const Color.fromARGB(0, 33, 149, 243), // Zamijenite s bojom po želji
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
