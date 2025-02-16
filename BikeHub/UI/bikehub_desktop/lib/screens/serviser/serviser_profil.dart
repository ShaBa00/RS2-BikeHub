// ignore_for_file: sized_box_for_whitespace, unused_field, prefer_const_constructors

import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/services/serviser/rezervacija_servisa_service.dart';
import 'package:bikehub_desktop/services/serviser/serviser_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServiserProfil extends StatefulWidget {
  const ServiserProfil({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ServiserProfilState createState() => _ServiserProfilState();
}

class _ServiserProfilState extends State<ServiserProfil> {
  final KorisnikService _korisnikService = KorisnikService();
  final ServiserService _serviserService = ServiserService();
  final RezervacijaServisaService _rezervacijaServisaService = RezervacijaServisaService();

  Map<String, dynamic>? serviserData;

  bool isZavrseneSelected = false;
  bool isAktivneSelected = false;
  String zadnjiStatus = "kreiran";

  List<Map<String, dynamic>>? rezervacijeList;

  int _currentPage = 0;
  final int _pageSize = 5;

  void _nextPage() {
    if (_rezervacijaServisaService.count > (_pageSize * (_currentPage + 1))) {
      if (_rezervacijaServisaService.lista_ucitanih_rezervacija.value.length == _pageSize) {
        _currentPage++;
        tipRezervacije(zadnjiStatus);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      tipRezervacije(zadnjiStatus);
    }
  }

  void postaviStanje(int idRezervacije, String stanje) async {
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
    if (serviserData == null || serviserData!['serviserId'] == null) {
      //logger.e('Serviser ID nije pronađen u serviserData');
      return;
    }

    zadnjiStatus = _status;

    // Pozovi getRezervacije i prosledi serviserId i status
    final serviserId = serviserData!['serviserId'];
    final data = await _rezervacijaServisaService.getRezervacije(
      serviserId: serviserId,
      status: _status,
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

  @override
  void initState() {
    super.initState();
    _loadServiserData();
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(parsedDate);
  }

  Future<void> _loadServiserData() async {
    try {
      final userInfo = await _korisnikService.getUserInfo();
      final korisnikId = int.tryParse(userInfo['korisnikId'] ?? '');

      if (korisnikId != null) {
        final serviseri = await _serviserService.getServiseriDTO(korisnikId: korisnikId);
        if (serviseri.isNotEmpty) {
          setState(() {
            serviserData = serviseri.first;
            tipRezervacije("kreiran");
          });
        }
      }
    } catch (e) {
      //Logger().e('Greška pri učitavanju podataka o serviseru: $e');
    }
  }

  Widget buildRezervacijeList() {
    final rezervacije = rezervacijeList ?? [];

    return ListView.builder(
      itemCount: rezervacije.length,
      itemBuilder: (context, index) {
        final rezervacija = rezervacije[index];

        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
              Container(
                width: MediaQuery.of(context).size.width * 0.66,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.048,
                      child: Row(
                        children: [
                          const SizedBox(width: 10.0),
                          _buildDetailContainer('Serviser ID', {rezervacija['serviserId']}, 0.18),
                          const SizedBox(width: 10.0),
                          _buildDetailContainer('Datum kreiranja', formatDate(rezervacija['datumKreiranja']), 0.18),
                          const SizedBox(width: 10.0),
                          _buildDetailContainer('Datum ', formatDate(rezervacija['datumRezervacije']), 0.18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.048, // 50% of KL's height
                      child: Row(
                        children: [
                          const SizedBox(width: 10.0),
                          _buildDetailContainer('Status', {rezervacija['status']}, 0.18),
                          const SizedBox(width: 10.0),
                          if (rezervacija['status'] == 'zavrseno' && rezervacija['ocjena'] != null)
                            _buildDetailContainer('Ocjena', {rezervacija['ocjena']}, 0.18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.14,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (rezervacija['status'] == 'kreiran')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              postaviStanje(rezervacija['rezervacijaId'], "aktivan");
                            },
                            child: Text(
                              'Aktiviraj',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Razmak između dugmadi
                          ElevatedButton(
                            onPressed: () {
                              postaviStanje(rezervacija['rezervacijaId'], "vracen");
                            },
                            child: Text(
                              'Vrati',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 8),
                    if (rezervacija['status'] == 'aktivan')
                      ElevatedButton(
                        onPressed: () {
                          postaviStanje(rezervacija['rezervacijaId'], "zavrseno");
                        },
                        child: Text(
                          'Završi',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil servisera'),
        flexibleSpace: Container(
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
        ),
      ),
      //Glavni dio
      body: Container(
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
        child: Center(
          //CD
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              children: [
                //GD
                Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  width: double.infinity,
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
                  child: Row(
                    children: [
                      //RL
                      Container(
                        width: MediaQuery.of(context).size.width * 0.72, // 70% of GD's width
                        height: double.infinity,
                        child: serviserData != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 30.0),
                                  _buildDetailContainer('Username', serviserData?['username'] ?? 'Username nije pronađen', 0.12),
                                  const SizedBox(width: 10.0),
                                  _buildDetailContainer(
                                      'Broj servisa', serviserData?['brojServisa']?.toString() ?? 'Broj servisa nije pronađen', 0.12),
                                  const SizedBox(width: 10.0),
                                  _buildDetailContainer('Ocjena', serviserData?['ukupnaOcjena']?.toString() ?? 'Ocjena nije pronađena', 0.12),
                                  const SizedBox(width: 10.0),
                                  _buildDetailContainer('Cijena', serviserData?['cijena']?.toString() ?? 'Cijena nije pronađena', 0.12),
                                  const SizedBox(width: 10.0),
                                  _buildDetailContainer('Grad', serviserData?['grad'] ?? 'Grad nije pronađen', 0.12),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      //RD
                      Container(
                        width: MediaQuery.of(context).size.width * 0.17, // 30% of GD's width
                        height: double.infinity,
                        child: serviserData != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(width: 30.0),
                                  _buildDetailContainer('Status', serviserData?['status'] ?? 'Status nije pronađen', 0.12),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
                //DD
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.675,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.blue), // Boja bordera
                      ),
                      child: Column(
                        children: [
                          //GIS
                          Container(
                            height: MediaQuery.of(context).size.height * 0.065,
                            width: double.infinity,
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
                            child: Row(
                              children: [
                                //GISL
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.67,
                                  height: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 30),
                                      ElevatedButton(
                                        onPressed: () {
                                          _currentPage = 0;
                                          tipRezervacije("kreiran");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              zadnjiStatus == "kreiran" ? Color.fromARGB(255, 87, 202, 255) : Color.fromARGB(255, 242, 242, 242),
                                        ),
                                        child: Text(
                                          'Zahtjevi',
                                          style: TextStyle(
                                            color: zadnjiStatus == "kreiran" ? Colors.white : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          _currentPage = 0;
                                          tipRezervacije("aktivan");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              zadnjiStatus == "aktivan" ? Color.fromARGB(255, 87, 202, 255) : Color.fromARGB(255, 242, 242, 242),
                                        ),
                                        child: Text(
                                          'Aktivne',
                                          style: TextStyle(
                                            color: zadnjiStatus == "aktivan" ? Colors.white : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          _currentPage = 0;
                                          tipRezervacije("zavrseno");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              zadnjiStatus == "zavrseno" ? Color.fromARGB(255, 87, 202, 255) : Color.fromARGB(255, 242, 242, 242),
                                        ),
                                        child: Text(
                                          'Završene',
                                          style: TextStyle(
                                            color: zadnjiStatus == "zavrseno" ? Colors.white : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          _currentPage = 0;
                                          tipRezervacije("vracen");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              zadnjiStatus == "vracen" ? Color.fromARGB(255, 87, 202, 255) : const Color.fromARGB(255, 242, 242, 242),
                                        ),
                                        child: Text(
                                          'Vracene',
                                          style: TextStyle(
                                            color: zadnjiStatus == "vracen" ? Colors.white : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //GISD
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.17,
                                  height: double.infinity,
                                  child: isZavrseneSelected == false
                                      ? _buildDetailContainer('Broj zahtjeva', _rezervacijaServisaService.count, 0.002)
                                      : _buildDetailContainer('Broj zavrsenih', _rezervacijaServisaService.count, 0.002),
                                ),
                              ],
                            ),
                          ),
                          //DIS
                          Container(
                            height: MediaQuery.of(context).size.height * 0.59,
                            width: double.infinity,
                            child: Column(
                              children: [
                                //PC
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.531,
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
                        ],
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
}
