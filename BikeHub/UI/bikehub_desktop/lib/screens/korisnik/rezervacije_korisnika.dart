// ignore_for_file: use_build_context_synchronously

import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/services/serviser/rezervacija_servisa_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RezervacijeKorisnika extends StatefulWidget {
  const RezervacijeKorisnika({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RezervacijeKorisnikaState createState() => _RezervacijeKorisnikaState();
}

class _RezervacijeKorisnikaState extends State<RezervacijeKorisnika> {
  
  late final int korisnikId;
  
  final RezervacijaServisaService _rezervacijaServisaService = RezervacijaServisaService();
  final KorisnikService korisnikService = KorisnikService();

  bool isZavrseneSelected = false;
  String zadnjiStatus = "kreiran";
  List<Map<String, dynamic>>? rezervacijeList;
  int _currentPage = 0;
  final int _pageSize = 5;

  int? rezervacijaID;
  int? ocjena;

  void getKorisnikID() async {
    var korisnik = await korisnikService.getUserInfo();
    if (korisnik['korisnikId'] != null) {
      korisnikId = int.parse(korisnik['korisnikId']!);
      tipRezervacije(zadnjiStatus);
    } else {
      // Rukovanje slučajem kada korisnikId nije dostupan
      PorukaHelper.prikaziPorukuUpozorenja(context, "Neuspješno dohvaćanje korisničkih podataka.");
    }
  }

  void _nextPage() {
    if(_rezervacijaServisaService.count>(_pageSize*(_currentPage+1))){
       if(_rezervacijaServisaService.lista_ucitanih_rezervacija.value.length==_pageSize){
          _currentPage++;
          tipRezervacije(zadnjiStatus);
        }
      }
    }
  
  void _previousPage() {
    if (_currentPage > 0) 
    {
      _currentPage--;
      tipRezervacije(zadnjiStatus);
    }
  }

  void postaviStanje(int idRezervacije, String stanje) async{
    try {
      bool result = await _rezervacijaServisaService.postaviStanje(idRezervacije, stanje);
      if (result) {        
        tipRezervacije(zadnjiStatus);

        //print('Rezervacija uspješno ažurirana.');
      } else {
        //print('Ažuriranje rezervacije nije uspjelo.');
      }
    } catch (e) {
      //print('Greška pri ažuriranju rezervacije: $e');
    }
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void tipRezervacije(String _status) async {

    if (korisnikId == 0) {
      //logger.e('Serviser ID nije pronađen u serviserData');
      return;
    }

    zadnjiStatus=_status;

    
    final data = await _rezervacijaServisaService.getRezervacije(
      korisnikId: korisnikId,
      status: zadnjiStatus,
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (data != null && data['resultsList'] != null) {
      setState(() {
        rezervacijeList = List<Map<String, dynamic>>.from(data['resultsList']);
      });
    } else {
      //logger.e('Greška pri dohvatanju rezervacija servisa ili rezultati nisu pronađeni.');
    }
  }

  void obrisi(int rezervacijaID) async {
    bool success = await _rezervacijaServisaService.postaviStanje(rezervacijaID, "obrisan");

    if (success) {
      PorukaHelper.prikaziPorukuUspjeha(context, "Rezervacija uspješno obrisana.");
      tipRezervacije(zadnjiStatus);
    } else {
      PorukaHelper.prikaziPorukuGreske(context, "Greška pri brisanju rezervacije.");
    }

  }

  @override
  void initState() {
    super.initState();
    getKorisnikID();
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }

  void dodajOcjenu(int ocjena,int rezervacijaID) async{
  try {
    await _rezervacijaServisaService.dodajOcjenu(rezervacijaID, ocjena);
    PorukaHelper.prikaziPorukuUspjeha(context, "Ocjena $ocjena je uspješno dodana");
    tipRezervacije(zadnjiStatus);
    } catch (e) {
    PorukaHelper.prikaziPorukuGreske(context, "Greška prilikom dodavanja ocjene: $e");
  }
  }

  void showRatingDialog(BuildContext context, int rezervacijaId) {
    int? odabranaOcjena;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade900,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: odabranaOcjena,
                    hint: const Text(
                       "Ocijenite",
                      style: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Colors.blue.shade900,
                    items: [1, 2, 3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          value.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        odabranaOcjena = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Zatvara pop-up
                      if (odabranaOcjena != null) {
                        dodajOcjenu(odabranaOcjena!, rezervacijaId); // Poziva novu funkciju
                      }
                    },
                    child: const Text("Dodaj ocjenu"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rezervacije'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 92, 225, 230),
              Color.fromARGB(255, 7, 181, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                // ignore: sized_box_for_whitespace
                Container(
                  height: MediaQuery.of(context).size.height * 0.085,
                  width: double.infinity,
                  // P1 content here
                  child: Row(
                    children: [
                      //GISL
                      // ignore: sized_box_for_whitespace
                      Container(
                        width: MediaQuery.of(context).size.width * 0.67,
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 30), 
                            ElevatedButton(
                              onPressed: () {
                                _currentPage=0;
                                tipRezervacije("kreiran");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: zadnjiStatus=="kreiran" ? Colors.blue : Colors.grey,
                              ),
                              child: const Text('Zahtjevi'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                _currentPage=0;
                                tipRezervacije("aktivan");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: zadnjiStatus=="aktivan" ? Colors.blue : Colors.grey,
                              ),
                              child: const Text('Aktivne'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(                                        
                            onPressed: () {
                              _currentPage=0;
                              tipRezervacije("zavrseno");
                            },                                      
                            style: ElevatedButton.styleFrom(
                                backgroundColor: zadnjiStatus=="zavrseno" ? Colors.blue : Colors.grey,
                            ),
                              child: const Text('Završene'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(                                        
                            onPressed: () {
                              _currentPage=0;
                              tipRezervacije("vracen");
                            },                                      
                            style: ElevatedButton.styleFrom(
                                backgroundColor: zadnjiStatus=="vracen" ? Colors.blue : Colors.grey,
                            ),
                              child: const Text('Vracene'),
                            ),
                          ],
                        ),
                      ),
                      //GISD
                      // ignore: sized_box_for_whitespace
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: double.infinity,
                        child: isZavrseneSelected == false
                            ? _buildDetailContainer('Broj zahtjeva', _rezervacijaServisaService.count,0.002)
                            : _buildDetailContainer('Broj zavrsenih', _rezervacijaServisaService.count,0.002),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // ignore: sized_box_for_whitespace
                  child: Container(
                    width: double.infinity,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.765, // 90% of 85% width
                        height: MediaQuery.of(context).size.height * 0.7225, // 85% of 85% height
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 255, 255, 255),
                              Color.fromARGB(255, 188, 188, 188),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.59,
                          width: double.infinity,
                          child: Column(
                            children: [
                              // PC
                              Container(
                                height: MediaQuery.of(context).size.height * 0.661,
                                width: double.infinity,
                                color: Colors.transparent,
                                child: rezervacijeList != null && rezervacijeList!.isNotEmpty
                                    ? buildRezervacijeList()
                                    : const Center(child: Text("Nema dostupnih rezervacija")),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height * 0.059, // 10% of DIS's height
                                width: double.infinity,
                                color: Colors.transparent, // Providna pozadina
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _previousPage,
                                      child: const Text('<'),
                                    ),
                                    const SizedBox(width: 8), // Razmak između dugmića
                                    ElevatedButton(
                                      onPressed: _nextPage,
                                      child: const Text('>'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
  Widget _buildDetailContainer(String label, dynamic value, double sirina) {
    return Container(
      width: MediaQuery.of(context).size.width * sirina,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(        
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ',
            // ignore: prefer_const_constructors
            style: TextStyle(color: Colors.white),
          ),   
          Text(
            '$value',
            style: const TextStyle(color: Colors.white),
          ),                           
        ],
      ),
    );
  }
  Widget buildRezervacijeList() {
    final rezervacije = rezervacijeList ?? [];

    return ListView.builder(
      itemCount: rezervacije.length,
      itemBuilder: (context, index) {
        final rezervacija = rezervacije[index];

      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 92, 225, 230),
              Color.fromARGB(255, 7, 181, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ignore: sized_box_for_whitespace
            Container(
              width: MediaQuery.of(context).size.width * 0.5, 
              child: Column(
                children: [
                  // ignore: sized_box_for_whitespace
                  Container(
                    height: MediaQuery.of(context).size.height * 0.048,
                    child: Row(
                      children: [
                        const SizedBox(width: 10.0),
                        _buildDetailContainer('Serviser ID', {rezervacija['serviserId']},0.1),
                        const SizedBox(width: 10.0),
                        _buildDetailContainer('Datum kreiranja', formatDate(rezervacija['datumKreiranja']),0.18),
                        const SizedBox(width: 10.0),
                        if (rezervacija['status'] == 'zavrseno' && rezervacija['ocjena'] != null)
                          _buildDetailContainer('Ocjena', {rezervacija['ocjena']},0.08),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // ignore: sized_box_for_whitespace
                  Container(
                    height: MediaQuery.of(context).size.height * 0.048, // 50% of KL's height
                    child: Row(
                    children: [
                      const SizedBox(width: 10.0),
                      _buildDetailContainer('Status', rezervacija['status'], 0.1),
                      const SizedBox(width: 10.0),
                      _buildDetailContainer('Datum', formatDate(rezervacija['datumRezervacije']), 0.18),
                      const SizedBox(width: 10.0),
                    ],
                    ),
                  ),
                ],
              ),
            ),
            // ignore: sized_box_for_whitespace
            Container(
              width: MediaQuery.of(context).size.width * 0.2, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rezervacija['status'] == 'kreiran')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            obrisi(rezervacija['rezervacijaId']);
                          },
                          child: const Text('Obriši'),
                        ),
                      ],
                    ),
                  const SizedBox(width: 8),
                  if (rezervacija['status'] == 'zavrseno' &&
                   (rezervacija['ocjena'] == null || rezervacija['ocjena']==0) )
                    ElevatedButton(
                      onPressed: () {
                        showRatingDialog(context,rezervacija['rezervacijaId']);
                        //postaviStanje(rezervacija['rezervacijaId'],"zavrseno");
                        },
                      child: const Text('Dodaj ocjenu'),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }
}
