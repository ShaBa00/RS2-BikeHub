// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, use_build_context_synchronously, unused_import, unused_field, prefer_final_fields

import 'package:bikehub_mobile/screens/nav_bar.dart';
import 'package:bikehub_mobile/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_mobile/servisi/korisnik/rezervacije_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RezervacijeKorisnika extends StatefulWidget {
  final int korisnikId;

  const RezervacijeKorisnika({super.key, required this.korisnikId});

  @override
  _RezervacijeKorisnikaState createState() => _RezervacijeKorisnikaState();
}

class _RezervacijeKorisnikaState extends State<RezervacijeKorisnika> {
  bool prikazRezervacija = false;
  bool zapisUcitan = false;
  List<Map<String, dynamic>>? listaRezervacija;
  String statusRezervacije = "kreiran";
  String status = "Kreirane";
  String odabraniProzor = "home";
  final RezervacijaServis _rezervacijaServis = RezervacijaServis();

  @override
  void initState() {
    super.initState();
    getRezervacije(statusRezervacije);
  }

  getRezervacije(String st) async {
    setState(() {
      prikazRezervacija = false;
    });
    listaRezervacija = await _rezervacijaServis.getRezervacije(status: st, korisnikId: widget.korisnikId);

    setState(() {
      prikazRezervacija = true;
    });
  }

  Widget buildContent() {
    return prikazRezervacija
        ? Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.07,
                color: const Color.fromARGB(0, 76, 175, 79), // Pozadina za prvi kontejner
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.07,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina za prvi unutarnji kontejner
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.07,
                      color: Colors.blue, // Pozadina za drugi unutarnji kontejner
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _showPopup(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Boja pozadine dugmeta
                            minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.4,
                              MediaQuery.of(context).size.height * 0.05,
                            ),
                          ),
                          child: Text(
                            'Status',
                            style: TextStyle(color: Colors.blue), // Boja teksta
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
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
                child: prikazRezervacija
                    ? listContainer(context)
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  int _currentPage = 0;
  int _pageSize = 10;
  int _odabraniId = 0;

  Widget listContainer(BuildContext context) {
    if (listaRezervacija == null || listaRezervacija!.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.607,
        width: MediaQuery.of(context).size.width,
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
        child: Center(
          child: Text(
            'Nema dostupnih rezervacija.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    int startIndex = _currentPage * _pageSize;
    int endIndex = startIndex + _pageSize;
    List currentAdmini = listaRezervacija!.sublist(
      startIndex,
      endIndex > listaRezervacija!.length ? listaRezervacija!.length : endIndex,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.607,
      width: MediaQuery.of(context).size.width,
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
            height: MediaQuery.of(context).size.height * 0.02,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentAdmini.length,
              itemBuilder: (context, index) {
                final zapis = currentAdmini[index];
                final String datumKreiranja = zapis['datumRezervacije'];
                final DateTime parsedDate = DateTime.parse(datumKreiranja);
                final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
                return GestureDetector(
                  onTap: () async {
                    if (zapis['status'] == 'zavrseno') {
                      setState(() {
                        zapisUcitan = false;
                        odabraniProzor = "rezervacija";
                        _odabraniId = zapis['rezervacijaId'];
                      });
                      await getRezervacija();
                    } else {
                      if (zapis['status'] == 'kreiran' || zapis['status'] == 'izmijenjen' || zapis['status'] == 'vracen') {
                        setState(() {
                          zapisUcitan = false;
                          odabraniProzor = "rezervacija";
                          _odabraniId = zapis['rezervacijaId'];
                        });
                        await getRezervacija();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nije dozvoljeno otvoriti ove rezervacije'),
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 25.0 : 8.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                  child: Text('<'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: endIndex < listaRezervacija!.length
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                  child: Text('>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: const Offset(0.20, 0.01),
          ).animate(
            CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeInOut,
            ),
          ),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.69,
              color: Colors.grey,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.62,
                    color: Color.fromARGB(0, 33, 149, 243), // Pozadina za prvi dio
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusButton('Kreirane'),
                        _buildStatusButton('Izmijenjene'),
                        _buildStatusButton('Aktivane'),
                        _buildStatusButton('Zavrsene'),
                        _buildStatusButton('Obrisane'),
                        _buildStatusButton('Vracene'),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.07,
                    color: Color.fromARGB(0, 76, 175, 79),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.height * 0.05),
                        ),
                        child: Text(
                          'Nazad',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 191, 255),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(String title) {
    bool isSelected = title == status;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color.fromARGB(255, 87, 202, 255) : Colors.white,
        ),
        onPressed: () {
          handleButtoStatusnPress(title);
          setState(() {
            Navigator.of(context).pop();
            _showPopup(context);
            status = title;
          });
        },
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Color.fromARGB(255, 87, 202, 255),
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  handleButtoStatusnPress(String title) async {
    switch (title) {
      case 'Kreirane':
        await getRezervacije("kreiran");
        break;
      case 'Izmijenjene':
        await getRezervacije("izmijenjen");
        break;
      case 'Aktivane':
        await getRezervacije("aktivan");
        break;
      case 'Zavrsene':
        await getRezervacije("zavrseno");
        break;
      case 'Obrisane':
        await getRezervacije("obrisan");
        break;
      case 'Vracene':
        await getRezervacije("vracen");
        break;
      default:
        break;
    }
  }

  late Map<String, dynamic> rezervacija;

  Future<void> getRezervacija() async {
    try {
      rezervacija = await _rezervacijaServis.getRezervacijakById(_odabraniId);
      setState(() {
        zapisUcitan = true;
      });
    } catch (e) {
      setState(() {
        zapisUcitan = false;
      });
    }
  }

  Widget getActiveWidget(BuildContext context) {
    switch (odabraniProzor) {
      case 'home':
        return buildContent();
      case 'rezervacija':
        return buildRezervacija();
      default:
        return buildContent();
    }
  }

  String? odabranaOcjena;

  Widget buildRezervacija() {
    if (!zapisUcitan) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 238, 239),
              Color.fromARGB(255, 165, 196, 210),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  // Prvi kontejner
                  width: MediaQuery.of(context).size.width * 0.77,
                  height: MediaQuery.of(context).size.height * 0.065,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(0, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          odabraniProzor = "home";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue, // Boja pozadine dugmeta
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.4,
                          MediaQuery.of(context).size.height * 0.055,
                        ),
                      ),
                      child: Text(
                        'Nazad',
                        style: TextStyle(color: Colors.white), // Boja teksta
                      ),
                    ),
                  )),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.77,
                height: MediaQuery.of(context).size.height * 0.33,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 205, 210),
                      Color.fromARGB(255, 7, 161, 235),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.77,
                      height: MediaQuery.of(context).size.height * 0.075,
                      color: const Color.fromARGB(0, 244, 67, 54), // Pozadina za prvi kontejner
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(0, 255, 255, 255), // Pozadina unutarnjeg kontejnera
                            borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            border: Border(
                              bottom: BorderSide(color: Colors.white),
                              right: BorderSide(color: Colors.white),
                              left: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              rezervacija['ocjena'] != null ? 'Ocjena: ${rezervacija['ocjena'].toString()}' : 'Nema ocjene',
                              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 253, 253, 253)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.77,
                      height: MediaQuery.of(context).size.height * 0.075,
                      color: const Color.fromARGB(0, 76, 175, 79), // Pozadina za drugi kontejner
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 255, 255, 255), // Pozadina unutarnjeg kontejnera
                            borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                            border: Border(
                              bottom: BorderSide(color: Colors.white),
                              right: BorderSide(color: Colors.white),
                              left: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              rezervacija['datumRezervacije'] != null
                                  ? 'Datum: ${DateFormat('dd MM yyyy').format(DateTime.parse(rezervacija['datumRezervacije']))}'
                                  : 'N/A',
                              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 252, 252, 252)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (rezervacija['status'] == 'izmijenjen' || rezervacija['status'] == 'vracen' || rezervacija['status'] == 'kreiran')
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.075,
                        color: const Color.fromARGB(0, 255, 235, 59), // Pozadina za četvrti kontejner
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              obrisiRezervaciju();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Obriši',
                                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.075,
                        color: const Color.fromARGB(0, 33, 149, 243), // Pozadina za treći kontejner
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.065,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(0, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                              border: Border(
                                bottom: BorderSide(color: Colors.white),
                                right: BorderSide(color: Colors.white),
                                left: BorderSide(color: Colors.white),
                              ),
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                value: odabranaOcjena,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                underline: Container(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    odabranaOcjena = newValue!;
                                  });
                                },
                                items: <String>['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                hint: Text(
                                  'Ocjena',
                                  style: TextStyle(color: Colors.black), // Promijenjeno na crni tekst
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.77,
                        height: MediaQuery.of(context).size.height * 0.075,
                        color: const Color.fromARGB(0, 255, 235, 59), // Pozadina za četvrti kontejner
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              ocjeniRezervaciju();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.height * 0.065,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0), // Zaobljene ivice
                                border: Border(
                                  bottom: BorderSide(color: Colors.white),
                                  right: BorderSide(color: Colors.white),
                                  left: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Ocjeni',
                                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  obrisiRezervaciju() async {
    try {
      String uspjesno = await _rezervacijaServis.upravljanjeRezervacijom(
        "obrisan",
        _odabraniId,
      );
      if (uspjesno == "Status uspješno ažuriran") {
        await getRezervacije(statusRezervacije);
        setState(() {
          odabraniProzor = "home";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rezervacija uspješno obrisana.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Neuspješno brisanje rezervacije.',
              style: TextStyle(color: Colors.white), // Boja teksta
            ),
            backgroundColor: Colors.red, // Boja pozadine
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri brisanju rezervacije: $e'),
        ),
      );
    }
  }

  ocjeniRezervaciju() async {
    if (odabranaOcjena == null || int.tryParse(odabranaOcjena!) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odaberite ocjenu'),
        ),
      );
      return;
    }

    int ocjena = int.parse(odabranaOcjena!);
    if (ocjena < 1 || ocjena > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odaberite ocjenu između 1 i 5'),
        ),
      );
      return;
    }

    try {
      bool uspjesno = await _rezervacijaServis.setRezervacija(
        rezervacijaId: _odabraniId,
        ocjena: ocjena,
      );
      if (uspjesno) {
        setState(() {
          odabraniProzor = "home";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rezervacija uspješno ocijenjena.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Neuspješno ocjenjivanje rezervacije.',
              style: TextStyle(color: Colors.white), // Boja teksta
            ),
            backgroundColor: Colors.red, // Boja pozadine
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri ocjenjivanju rezervacije: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rezervacije Korisnika',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.77,
                color: Colors.blueAccent,
                child: getActiveWidget(context),
              ),
            ),
          ),
          const NavBar(),
        ],
      ),
    );
  }
}
