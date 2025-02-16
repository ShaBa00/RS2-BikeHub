// ignore_for_file: unused_import, prefer_const_constructors, library_private_types_in_public_api, unused_field, unused_element, prefer_final_fields, prefer_const_literals_to_create_immutables, avoid_print, prefer_if_null_operators, sized_box_for_whitespace

import 'package:bikehub_mobile/screens/prikaz/serviser_prikaz.dart';
import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_mobile/screens/glavni_prozor.dart';
import 'package:bikehub_mobile/screens/nav_bar.dart';

class ServiseriPretraga extends StatefulWidget {
  const ServiseriPretraga({super.key});

  @override
  _ServiseriPretragastate createState() => _ServiseriPretragastate();
}

class _ServiseriPretragastate extends State<ServiseriPretraga> with SingleTickerProviderStateMixin {
  bool isPopupVisibleFilter = false;
  bool isPopupVisibleSort = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final ServiserService _serviserService = ServiserService();

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

  List<dynamic> listaServisera = [];
  bool loading = true;
  int _brojServisera = 0;
  int _trenutnaStranica = 0;
  final int _velicinaStranice = 1;

  _initialize() async {
    try {
      await _serviserService.getServiseriDTO(
        page: _trenutnaStranica,
        pageSize: _velicinaStranice,
        status: "aktivan",
      ); //)
      listaServisera = _serviserService.listaServisera;
      _brojServisera = _serviserService.countServisera;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  nextPage() async {
    if ((_trenutnaStranica + 1) * _velicinaStranice < _brojServisera) {
      setState(() {
        _trenutnaStranica++;
      });
      getServiseriSort();
    }
  }

  previousPage() async {
    if (_trenutnaStranica > 0) {
      setState(() {
        _trenutnaStranica--;
      });
      getServiseriSort();
    }
  }

  void _togglePopupFilter() {
    if (!mounted) return;
    setState(() {
      if (isPopupVisibleSort) {
        _togglePopupSort(); // Zatvori drugi popup ako je prikazan
      }
      if (isPopupVisibleFilter) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      isPopupVisibleFilter = !isPopupVisibleFilter;
    });
  }

  void _togglePopupSort() {
    if (!mounted) return;
    setState(() {
      if (isPopupVisibleFilter) {
        _togglePopupFilter(); // Zatvori drugi popup ako je prikazan
      }
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
    _controller.dispose(); // Zatvara AnimationController da spriječi curenje memorije
    super.dispose();
  }

  //dodatno za prikaz podataka
  String selectedValue = "";
  int pocetnaCijena = 0;
  int krajnjaCijena = 100;
  int pocetniBrojServisa = 0;
  int krajnjiBrojServisa = 100;
  int pocetnaOcjena = 0;
  int krajnjaOcjena = 5;
  //---------------------

  getServiseriSort() async {
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
    setState(() {
      loading = true;
    });
    try {
      await _serviserService.getServiseriDTO(
        page: _trenutnaStranica + 1,
        pageSize: _velicinaStranice,
        status: "aktivan",
        sortOrder: sortOrder,
        pocetnaCijena: pocetnaCijena.toDouble(),
        krajnjaCijena: krajnjaCijena.toDouble(),
        pocetniBrojServisa: pocetniBrojServisa,
        krajnjiBrojServisa: krajnjiBrojServisa,
        pocetnaOcjena: pocetnaOcjena.toDouble(),
        krajnjaOcjena: krajnjaOcjena.toDouble(),
      );
      listaServisera = _serviserService.listaServisera;
      _brojServisera = _serviserService.countServisera;
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  TextEditingController _controllerNaziv = TextEditingController();

  getZapisNaziv() async {
    setState(() {
      loading = true;
      pocetnaCijena = 0;
      krajnjaCijena = 100;
      pocetniBrojServisa = 0;
      krajnjiBrojServisa = 100;
      pocetnaOcjena = 0;
      krajnjaOcjena = 5;
    });
    String naziv = _controllerNaziv.text;
    if (naziv.isEmpty) {
      return;
    }
    try {
      setState(() {
        loading = true;
      });
      await _serviserService.getServiseriDTO(
        page: _trenutnaStranica + 1,
        pageSize: _velicinaStranice,
        status: "aktivan",
        username: naziv,
      );
    } finally {
      setState(() {
        listaServisera = _serviserService.listaServisera;
        _brojServisera = _serviserService.countServisera;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Sakrij tastaturu kada se klikne na bilo koji dio prozora
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
          height: MediaQuery.of(context).size.height * 0.12, // 10% visine ekrana
          color: const Color.fromARGB(0, 244, 67, 54), // Zamijenite s bojom po želji
          alignment: Alignment.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85, // 85% širine ekrana
            height: MediaQuery.of(context).size.height * 0.06, // Smanjena visina search bara
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
          height: MediaQuery.of(context).size.height * 0.11, // 11% visine ekrana
          color: const Color.fromARGB(0, 255, 235, 59), // Zamijenite s bojom po želji
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95, // 95% širine ekrana
              height: MediaQuery.of(context).size.height * 0.09, // 9% visine ekrana
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  // dD
                  Container(
                    width: MediaQuery.of(context).size.width * 0.40, // 40% širine ekrana
                    height: MediaQuery.of(context).size.height * 0.09, // 9% visine ekrana
                    color: const Color.fromARGB(0, 244, 67, 54), // Zamijenite s bojom po želji
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black), // Ikone crne boje
                          iconSize: 24.0, // Veličina ikone
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const GlavniProzor()),
                            );
                          },
                        ),
                        const Text('Serviseri', style: TextStyle(fontSize: 20)), // Povećan font
                      ],
                    ),
                  ),
                  // lD
                  Container(
                    width: MediaQuery.of(context).size.width * 0.55, // 55% širine ekrana
                    height: MediaQuery.of(context).size.height * 0.09, // 9% visine ekrana
                    color: const Color.fromARGB(0, 33, 149, 243), // Zamijenite s bojom po želji
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
                            width: MediaQuery.of(context).size.width * 0.24, // Smanjena širina dugmića
                            height: MediaQuery.of(context).size.height * 0.07, // 7% visine ekrana
                            alignment: Alignment.center,
                            child: const Text(
                              'Poredaj',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 2.0, // Plava linija između dugmića
                          height: MediaQuery.of(context).size.height * 0.07, // Visina linije
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
                            width: MediaQuery.of(context).size.width * 0.24, // Smanjena širina dugmića
                            height: MediaQuery.of(context).size.height * 0.07, // 7% visine ekrana
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
          color: Color.fromARGB(0, 76, 175, 79),
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.58,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: SingleChildScrollView(
                        child: Column(
                          children: listaServisera.map((serviser) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ServiserPrikaz(serviserId: serviser['serviserId'])),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: MediaQuery.of(context).size.height * 0.06,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.height * 0.06,
                                      color: const Color.fromARGB(0, 33, 149, 243),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            serviser['grad'] != null ? serviser['grad'] : "N/A",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.height * 0.06,
                                      color: const Color.fromARGB(0, 76, 175, 79),
                                      child: Center(
                                        child: Text(
                                          serviser['username'] != null ? serviser['username'] : "N/A",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.height * 0.06,
                                      color: const Color.fromARGB(0, 255, 153, 0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            serviser['cijena'] != null ? serviser['cijena'].toString() : "N/A",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.07,
                      color: const Color.fromARGB(0, 76, 175, 79),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                previousPage();
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
                              onTap: () {
                                nextPage();
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
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: Center(
                                  child: Text(
                                    "Cijena",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: RangeSlider(
                                  values: RangeValues(pocetnaCijena.toDouble(), krajnjaCijena.toDouble()),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
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
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: Center(
                                  child: Text(
                                    "Broj servisa",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: RangeSlider(
                                  values: RangeValues(pocetniBrojServisa.toDouble(), krajnjiBrojServisa.toDouble()),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  labels: RangeLabels(
                                    pocetniBrojServisa.toString(),
                                    krajnjiBrojServisa.toString(),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      pocetniBrojServisa = values.start.round();
                                      krajnjiBrojServisa = values.end.round();
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
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: Center(
                                  child: Text(
                                    "Ocjena",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.height * 0.06,
                                child: RangeSlider(
                                  values: RangeValues(pocetnaOcjena.toDouble(), krajnjaOcjena.toDouble()),
                                  min: 0,
                                  max: 5,
                                  divisions: 5,
                                  labels: RangeLabels(
                                    pocetnaOcjena.toString(),
                                    krajnjaOcjena.toString(),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      pocetnaOcjena = values.start.round();
                                      krajnjaOcjena = values.end.round();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          setState(() {
                            _trenutnaStranica = 0;
                          });
                          await getServiseriSort();
                          _togglePopupFilter();
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
                              width: MediaQuery.of(context).size.width * 0.5, // Ograničavanje širine
                              child: DropdownButtonFormField<String>(
                                value: selectedValue.isNotEmpty ? selectedValue : null, // Omogućavanje praznog odabira
                                onChanged: (String? newValue) {
                                  selectedValue = newValue ?? ''; // Postavljanje prazne vrijednosti ako je odabrano prazno
                                },
                                items: ["", "CIJENA RASTUCA", "CIJENA OPADAJUCA"].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.isNotEmpty ? value.toUpperCase() : "Prazno",
                                      style: TextStyle(
                                        color: value.isNotEmpty ? Colors.black : Colors.grey,
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
                          setState(() {
                            _trenutnaStranica = 0;
                          });
                          await getServiseriSort();
                          _togglePopupSort();
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
