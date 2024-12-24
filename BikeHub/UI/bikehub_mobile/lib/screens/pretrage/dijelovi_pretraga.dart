// ignore_for_file: unused_import, prefer_const_constructors, library_private_types_in_public_api, unused_field, unused_element, prefer_final_fields, empty_catches, sized_box_for_whitespace

import 'dart:convert';

import 'package:bikehub_mobile/screens/prikaz/dijelovi_prikaz.dart';
import 'package:bikehub_mobile/servisi/dijelovi/dijelovi_service.dart';
import 'package:bikehub_mobile/servisi/kategorije/kategorija_service.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';

class DijeloviPretraga extends StatefulWidget {
  const DijeloviPretraga({super.key});

  @override
  _DijeloviPretragaState createState() => _DijeloviPretragaState();
}

class _DijeloviPretragaState extends State<DijeloviPretraga>
    with SingleTickerProviderStateMixin {
  bool isPopupVisibleFilter = false;
  bool isPopupVisibleSort = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final KategorijaServis _kategorijaServis = KategorijaServis();

  @override
  void initState() {
    super.initState();
    _initialize();
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
    _controllerNaziv.dispose();
    _controller
        .dispose(); // Zatvara AnimationController da spriječi curenje memorije
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Sakrij tastaturu kada se klikne na bilo koji dio prozora
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Dodano svojstvo
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
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // gD
                          gD(context),
                          // dD
                          dD(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: const NavBar(), // Postavlja NavBar na dno
              ),
            ],
          ),
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
                Expanded(
                  child: TextField(
                    controller: _controllerNaziv,
                    decoration: InputDecoration(
                      hintText: 'Pretraži proizvode',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    getZapisNaziv();
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
                        const Text('Dijelovi',
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
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.65,
          color: Color.fromARGB(0, 76, 175, 79),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.59,
                color: const Color.fromARGB(
                    0, 244, 67, 54), // Zamijenite s bojom po želji
                child: Center(
                  child: loadingZapisi
                      ? CircularProgressIndicator() // Kružic za učitavanje
                      : Column(
                          children: [_buildlistaZapisa(context)],
                        ),
                ),
              ),

              //dugmici
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.06,
                color: const Color.fromARGB(
                    0, 33, 149, 243), // Zamijenite s bojom po želji
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await previousPage();
                        },
                        child: Container(
                          color: const Color.fromARGB(35, 3, 168, 244),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await nextPage();
                        },
                        child: Container(
                          color: const Color.fromARGB(35, 3, 168, 244),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
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
        _buildPopupFilter(context),
        _buildPopupSort(context),
      ],
    );
  }

  //dodatno za prikaz podataka
  final DijeloviService _dijeloviService = DijeloviService();

  List<dynamic> listaZapisa = [];
  bool loadingZapisi = true;
  String selectedValue = "";
  int _brojZapisa = 0;
  int _trenutnaStranica = 0;
  final int _velicinaStranice = 10;

  _initialize() async {
    try {
      await _getKategorije();
      await _dijeloviService.getDijelovis(
        page: _trenutnaStranica,
        pageSize: _velicinaStranice,
        isSlikaIncluded: true,
        //status: "aktivan",
      );
      listaZapisa = _dijeloviService.listaDijelova;
      _brojZapisa = _dijeloviService.countDijelova;
    } finally {
      if (mounted) {
        setState(() {
          loadingZapisi = false;
        });
      }
    }
  }

  nextPage() async {
    if ((_trenutnaStranica + 1) * _velicinaStranice < _brojZapisa) {
      setState(() {
        _trenutnaStranica++;
      });
      getZapisi();
    }
  }

  previousPage() async {
    if (_trenutnaStranica > 0) {
      setState(() {
        _trenutnaStranica--;
      });
      getZapisi();
    }
  }

  getZapisi() async {
    int? kategorijaId = _odabranaKategorija?['kategorijaId'];
    String sortOrder = "";

    switch (selectedValue) {
      case "":
        sortOrder = "";
        break;
      case "CIJENA RASTUCA":
        sortOrder = "asc";
        break;
      case "CIJENA OPADAJUCA":
        sortOrder = "desc";
        break;
      default:
        sortOrder = "";
    }
    try {
      setState(() {
        loadingZapisi = true;
      });
      await _dijeloviService.getDijelovis(
        page: _trenutnaStranica,
        pageSize: _velicinaStranice,
        isSlikaIncluded: true,
        sortOrder: sortOrder,
        pocetnaCijena: pocetnaCijena.toDouble(),
        krajnjaCijena: krajnjaCijena.toDouble(),
        kategorijaId: kategorijaId,
        //status: "aktivan",
      );
      listaZapisa = _dijeloviService.listaDijelova;
      _brojZapisa = _dijeloviService.countDijelova;
    } finally {
      setState(() {
        loadingZapisi = false;
      });
    }
  }

  TextEditingController _controllerNaziv = TextEditingController();

  getZapisNaziv() async {
    setState(() {
      loadingZapisi = true;
      pocetnaCijena = 0;
      krajnjaCijena = 2000;
      selectedRam = "";
      selectedVelicina = "";
      brojBrzina = 0;
    });
    String naziv = _controllerNaziv.text;
    if (naziv.isEmpty) {
      return;
    }
    String sortOrder = "";
    try {
      setState(() {
        loadingZapisi = true;
      });
      await _dijeloviService.getDijelovis(
        page: _trenutnaStranica,
        pageSize: _velicinaStranice,
        isSlikaIncluded: true,
        sortOrder: sortOrder,
        naziv: naziv,
        pocetnaCijena: pocetnaCijena.toDouble(),
        krajnjaCijena: krajnjaCijena.toDouble(),
        //status: "aktivan",
      );
    } finally {
      setState(() {
        listaZapisa = _dijeloviService.listaDijelova;
        _brojZapisa = _dijeloviService.countDijelova;
        loadingZapisi = false;
      });
    }
  }

  Widget _buildlistaZapisa(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.59,
      color: const Color.fromARGB(0, 244, 67, 54),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            (listaZapisa.length / 2).ceil().clamp(0, 5),
            (index) {
              int firstIndex = index * 2;
              int secondIndex = firstIndex + 1;
              return Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.22,
                color: Color.fromARGB(0, 255, 255, 255),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (firstIndex < listaZapisa.length)
                      GestureDetector(
                        onTap: () {
                          int dijeloviId =
                              listaZapisa[firstIndex]['dijeloviId'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DijeloviPrikaz(dijeloviId: dijeloviId),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(244, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.16,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(0, 244, 67, 54),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                ),
                                child: listaZapisa[firstIndex]
                                                ['slikeDijelovis'] !=
                                            null &&
                                        listaZapisa[firstIndex]
                                                ['slikeDijelovis']
                                            .isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                        child: Image.memory(
                                          base64Decode(listaZapisa[firstIndex]
                                              ['slikeDijelovis'][0]['slika']),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.16,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 40.0,
                                        ),
                                      ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                color: const Color.fromARGB(0, 33, 149, 243),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          listaZapisa[firstIndex]['naziv'] ??
                                              'N/A',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          listaZapisa[firstIndex]['cijena'] !=
                                                  null
                                              ? "${listaZapisa[firstIndex]['cijena'].toString()} KM"
                                              : 'N/A',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
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
                      ),
                    if (secondIndex < listaZapisa.length)
                      GestureDetector(
                        onTap: () {
                          int dijeloviId =
                              listaZapisa[secondIndex]['dijeloviId'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DijeloviPrikaz(dijeloviId: dijeloviId),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(244, 255, 255, 255),
                            borderRadius: BorderRadius.circular(
                                10.0), // Dodano zaobljenje ivica
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.16,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(0, 244, 67, 54),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ), // Zaobljene gornje ivice
                                ),
                                child: listaZapisa[secondIndex]
                                                ['slikeDijelovis'] !=
                                            null &&
                                        listaZapisa[secondIndex]
                                                ['slikeDijelovis']
                                            .isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                        child: Image.memory(
                                          base64Decode(listaZapisa[secondIndex]
                                              ['slikeDijelovis'][0]['slika']),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.16,
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
                                width: MediaQuery.of(context).size.width * 0.45,
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                color: const Color.fromARGB(0, 33, 149, 243),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          listaZapisa[secondIndex]['naziv'] ??
                                              'N/A',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          listaZapisa[secondIndex]['cijena'] !=
                                                  null
                                              ? "${listaZapisa[secondIndex]['cijena'].toString()} KM"
                                              : 'N/A',
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
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
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  //---------------------

  int pocetnaCijena = 0;
  int krajnjaCijena = 2000;
  String selectedRam = "";
  String selectedVelicina = "";
  int brojBrzina = 0;

  List<Map<String, dynamic>>? _kategorije;
  Map<String, dynamic>? _odabranaKategorija;

  Future<void> _getKategorije() async {
    try {
      final kategorije = await _kategorijaServis.getKategorije(
        isBikeKategorija: false,
      );
      if (kategorije != null && kategorije.isNotEmpty) {
        setState(() {
          _kategorije = kategorije;
          _odabranaKategorija = null;
        });
      }
    } catch (e) {}
  }

  Widget _buildPopupFilter(BuildContext context) {
    return isPopupVisibleFilter
        ? SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        color: const Color.fromARGB(0, 33, 149, 243),
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    child: Center(
                                      child: Text(
                                        "Cijena",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    child: RangeSlider(
                                      values: RangeValues(
                                          pocetnaCijena.toDouble(),
                                          krajnjaCijena.toDouble()),
                                      min: 0,
                                      max: 2000,
                                      divisions: 200,
                                      labels: RangeLabels(
                                        pocetnaCijena.toString(),
                                        krajnjaCijena.toString(),
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          pocetnaCijena = values.start.round();
                                          krajnjaCijena = values.end.round();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    child: Center(
                                      child: Text(
                                        "Kategorija",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6650A5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _odabranaKategorija != null
                                            ? _odabranaKategorija!['naziv'] ??
                                                'N/A'
                                            : null,
                                        hint: Text(
                                          "prazno",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        icon: Icon(Icons.arrow_downward,
                                            color: Colors.white),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(color: Colors.white),
                                        dropdownColor: Color(0xFF6650A5),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _odabranaKategorija =
                                                _kategorije?.firstWhere(
                                                    (kategorija) =>
                                                        kategorija['naziv'] ==
                                                        newValue,
                                                    orElse: () =>
                                                        {'naziv': 'N/A'});
                                          });
                                        },
                                        items: _kategorije
                                                ?.map<DropdownMenuItem<String>>(
                                                    (kategorija) {
                                              return DropdownMenuItem<String>(
                                                value: kategorija['naziv'] ??
                                                    'N/A',
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.04,
                                                  child: Center(
                                                    child: Text(
                                                      kategorija['naziv'] ??
                                                          'N/A',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList() ??
                                            [],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: const Color.fromARGB(0, 76, 175, 79),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          _togglePopupFilter();
                          setState(() {
                            _trenutnaStranica = 0;
                          });
                          await getZapisi();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.54,
                            MediaQuery.of(context).size.height * 0.05,
                          ),
                          foregroundColor: Colors.lightBlue,
                          backgroundColor: Colors.white,
                        ),
                        child: const Text('Primjeni filter'),
                      ),
                    ),
                  ),
                ],
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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 82, 205, 210),
                    Color.fromARGB(255, 7, 161, 235),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.55,
                    color: const Color.fromARGB(0, 33, 149, 243),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Poredaj po cijeni",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Center(
                            // Centriranje dropdown-a
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.5, // Ograničavanje širine
                              child: DropdownButtonFormField<String>(
                                value: selectedValue.isNotEmpty
                                    ? selectedValue
                                    : null, // Omogućavanje praznog odabira
                                onChanged: (String? newValue) {
                                  selectedValue = newValue ??
                                      ''; // Postavljanje prazne vrijednosti ako je odabrano prazno
                                },
                                items: [
                                  "",
                                  "CIJENA RASTUCA",
                                  "CIJENA OPADAJUCA"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.isNotEmpty
                                          ? value.toUpperCase()
                                          : "Prazno",
                                      style: TextStyle(
                                        color: value.isNotEmpty
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: TextStyle(color: Colors.black),
                                dropdownColor: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: const Color.fromARGB(0, 76, 175, 79),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          _togglePopupSort();
                          setState(() {
                            _trenutnaStranica = 0;
                          });
                          await getZapisi();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.lightBlue,
                          backgroundColor: Colors.white,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.54,
                            MediaQuery.of(context).size.height * 0.05,
                          ),
                        ),
                        child: const Text('Primjeni sort'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
