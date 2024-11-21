// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_element, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, no_leading_underscores_for_local_identifiers

import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class AdministracijaP1Prozor extends StatefulWidget {
  const AdministracijaP1Prozor({super.key});

  @override
  _AdministracijaP1ProzorState createState() => _AdministracijaP1ProzorState();
}



class _AdministracijaP1ProzorState extends State<AdministracijaP1Prozor> {
  String _selectedSection = 'Home';
  bool _isLoading = true;

  List _listaDijelova = [];
  int _countDijelovi = 0;

  List _listaAdministratora = [];
  int _countAdministratora = 0;
  int _currentPageAdministrator = 0;
  int _pageSizeAdministrator = 4;

  List _prikazaniBicikli = [];
  int _currentPageBicikli = 0;
  int _pageSizeBicikli = 5;
  int _brojPrikazanihBicikli = 0;
  String _selectedStatusBicikli = 'Kreirani';
  List _listaBicikala = [];
  int _countBicikl = 0;

  List _prikazaniKorisnici = [];
  int _currentPageKorisnik = 0;
  int _pageSizeKorisnik = 5;
  int _brojPrikazanihKorisnika = 0;
  String _selectedStatus = 'Kreirani';
  List _listaKorisnika = [];
  int _countKorisnik = 0;

  String _username="";
  final KorisnikService _korisnikService = KorisnikService();
  final BiciklService _bicikliService = BiciklService();
  final DijeloviService _dijeloviService = DijeloviService();

  @override
  void initState() {
    super.initState();
    _fetchPodatci();
  }

  Future _fetchPodatci() async {
    final credentials = await _korisnikService.getCredentials();
    _username = credentials['username']!;
    await _korisnikService.getKorisniks(status: '');
    await _bicikliService.getBicikli(status: '',isSlikaIncluded: false, page: null, pageSize: null);
    await _dijeloviService.getDijelovi(status: '', page: 0, pageSize: 5);
    setState(() {
      _listaKorisnika = _korisnikService.listaKorisnika;
      _countKorisnik = _korisnikService.countKorisnika;
      _listaBicikala = _bicikliService.listaBicikala;
      _countBicikl = _bicikliService.count;
      _listaDijelova = _dijeloviService.listaDijelova;
      _countDijelovi = _dijeloviService.count;
      _listaAdministratora = _korisnikService.listaAdministratora;
      _countAdministratora = _listaAdministratora.length;
      _isLoading = false;
    });    
    await _filterKorisnici("Kreirani");
    await _filterBicikli("Kreirani");
  }

  void _loadAdministratori(int page) {
    setState(() {
      _currentPageAdministrator = page;
    });
  }

  _filterBicikli(String status) async{
    String _status;
    _currentPageBicikli=0;
    switch (status) {
      case 'Kreirani':
        _status = 'kreiran';
        break;
      case 'Izmijenjeni':
        _status = 'izmijenjen';
        break;
      case 'Aktivni':
        _status = 'aktivan';
        break;
      case 'Obrisani':
        _status = 'obrisan';
        break;
      case 'Vraceni':
        _status = 'vracen';
        break;
      default:
        _status = '';
    }

    setState(() {
      _selectedStatusBicikli = status;
      _prikazaniBicikli = _listaBicikala.where((bicikl) => bicikl['status'] == _status).toList();
      _brojPrikazanihBicikli = _prikazaniBicikli.length;
    });
  }
  _filterKorisnici(String status) async{
    String _status;
    _currentPageKorisnik=0;
    switch (status) {
      case 'Kreirani':
        _status = 'kreiran';
        break;
      case 'Izmijenjeni':
        _status = 'izmijenjen';
        break;
      case 'Aktivni':
        _status = 'aktivan';
        break;
      case 'Obrisani':
        _status = 'obrisan';
        break;
      case 'Vraceni':
        _status = 'vracen';
        break;
      default:
        _status = '';
    }

    setState(() {
      _selectedStatus = status;
      _prikazaniKorisnici = _listaKorisnika.where((korisnik) => korisnik['status'] == _status).toList();
      _brojPrikazanihKorisnika = _prikazaniKorisnici.length;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: Text('Administracija'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  body: Row(
                    children: [
                      _buildNavDio(),
                      _buildSadrzajDio(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildNavDio() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.95,
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.13,
            child: Center(
              child: Text(
                'BikeHub',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          //DonjiDio
          Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.70,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.lightBlue,
                width: 1.0,
              ),
            ),
          ),
            child: Column(
              children: [
                //Dugmici
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.55,
                  color: const Color.fromARGB(0, 68, 137, 255),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavButton('Home'),
                      SizedBox(height: 15),
                      _buildNavButton('Korisnici'),
                      SizedBox(height: 15),
                      _buildNavButton('Bicikli'),
                      SizedBox(height: 15),
                      _buildNavButton('Dijelovi'),
                      SizedBox(height: 15),
                      _buildNavButton('Dodaj Administratora'),
                    ],
                  ),
                ),
                //prazniDIo
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.10,
                  color: Color.fromARGB(0, 105, 240, 175),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSadrzajDio() {
  var visina = MediaQuery.of(context).size.height;
  return Container(
    width: MediaQuery.of(context).size.width * 0.75,
    height: visina,
    color: Color.fromARGB(0, 254, 0, 0),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: visina * 0.13,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Administrator: $_username',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _buildCentralniDio(visina),
        _buildAdministratori(visina),
      ],
    ),
  );
}

  Widget _buildCentralniDio(var visina) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 249, 238, 238),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _getCentralniDioContent(),
      ),
    );
  }

  Widget _buildAdministratori(var visina) {
    int startIndex = _currentPageAdministrator * _pageSizeAdministrator;
    int endIndex = startIndex + _pageSizeAdministrator;
    List currentAdministratori = _listaAdministratora.sublist(
      startIndex,
      endIndex > _listaAdministratora.length ? _listaAdministratora.length : endIndex,
    );

    return Container(
      width: double.infinity,
      height: visina * 0.25,
      color: Color.fromARGB(0, 38, 255, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: visina * 0.05,
            color: const Color.fromARGB(0, 33, 149, 243),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Administratori:',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 76, 175, 79),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      itemCount: currentAdministratori.length,
                      itemBuilder: (context, index) {
                        final admin = currentAdministratori[index];
                        final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                        return Column(
                          children: [
                            if (index != 0) SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                color: backgroundColor,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 24,
                                          color: Colors.grey[700],
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          admin['username'],
                                          style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(
                                      admin['email'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacer(),
                                    Text(
                                      admin['status'],
                                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                    SizedBox(width: 10)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPageAdministrator > 0
                            ? () {
                                _loadAdministratori(_currentPageAdministrator - 1);
                              }
                            : null,
                        child: Text('<'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: endIndex < _listaAdministratora.length
                            ? () {
                                _loadAdministratori(_currentPageAdministrator + 1);
                              }
                            : null,
                        child: Text('>'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCentralniDioContent() {
    switch (_selectedSection) {
      case 'Home':
        return _buildHome();
      case 'Korisnici':
        return _buildKorisnici();
      case 'Bicikli':
        return _buildBicikli();
      case 'Dijelovi':
        return _buildDijelovi();
      case 'Dodaj Administratora':
        return _buildDodajAdministratora();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Korisnici';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.19,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 205, 210),
                      Color.fromARGB(255, 7, 161, 235),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Korisnici',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countKorisnik\nBroj korisnika',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Bicikli';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.19,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 205, 210),
                      Color.fromARGB(255, 7, 161, 235),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Bicikli',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countBicikl\nBroj bicikala',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSection = 'Dijelovi';
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.19,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 82, 205, 210),
                      Color.fromARGB(255, 7, 161, 235),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.065,
                      height: MediaQuery.of(context).size.height * 0.065,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          'Dijelovi',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.150,
                      child: Center(
                        child: Text(
                          '$_countDijelovi\nBroj dijelova',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKorisnici() {
    int startIndex = _currentPageKorisnik * _pageSizeKorisnik;
    int endIndex = startIndex + _pageSizeKorisnik;
    List currentKorisnici = _prikazaniKorisnici.sublist(
      startIndex,
      endIndex > _prikazaniKorisnici.length ? _prikazaniKorisnici.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200], 
            child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Korisnici',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    _buildStatusButton('Kreirani'),
                    _buildStatusButton('Izmijenjeni'),
                    _buildStatusButton('Aktivni'),
                    _buildStatusButton('Obrisani'),
                    _buildStatusButton('Vraceni'),
                  ],
                ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300], 
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.05,
                color: const Color.fromARGB(0, 33, 149, 243),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: currentKorisnici.length,
                  itemBuilder: (context, index) {
                    final korisnik = currentKorisnici[index];
                    final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                    return Column(
                      children: [
                        if (index != 0) SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: backgroundColor,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  korisnik['username'],
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                Spacer(),
                                Text(
                                  korisnik['email'],
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                Spacer(),
                                Text(
                                  korisnik['status'],
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement your logic for "Više informacija" button
                                    },
                                    child: Text('Više informacija'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPageKorisnik > 0
                        ? () {
                            setState(() {
                              _currentPageKorisnik--;
                            });
                          }
                        : null,
                    child: Text('<'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: endIndex < _prikazaniKorisnici.length
                        ? () {
                            setState(() {
                              _currentPageKorisnik++;
                            });
                          }
                        : null,
                    child: Text('>'),
                  ),
                ],
              ),
              SizedBox(height: 2),
            ],
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildBicikli() {
    int startIndex = _currentPageBicikli * _pageSizeBicikli;
    int endIndex = startIndex + _pageSizeBicikli;
    List currentBicikli = _prikazaniBicikli.sublist(
      startIndex,
      endIndex > _prikazaniBicikli.length ? _prikazaniBicikli.length : endIndex,
    );
    return Column(
      children: [
        Expanded(
          flex: 15,
          child: Container(
            width: double.infinity,
            color: Colors.grey[200], 
            child: 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Bicikli',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    _buildStatusButtonBicikl('Kreirani'),
                    _buildStatusButtonBicikl('Izmijenjeni'),
                    _buildStatusButtonBicikl('Aktivni'),
                    _buildStatusButtonBicikl('Obrisani'),
                    _buildStatusButtonBicikl('Vraceni'),
                  ],
                ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            width: double.infinity,
            color: Colors.grey[300], 
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.05,
                color: const Color.fromARGB(0, 33, 149, 243),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: currentBicikli.length,
                  itemBuilder: (context, index) {
                    final bicikl = currentBicikli[index];
                    final backgroundColor = Color.fromARGB(255, 235, 237, 237);

                    return Column(
                      children: [
                        if (index != 0) SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: backgroundColor,
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pedal_bike,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  bicikl['naziv'],
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                Spacer(),
                                Text(
                                  bicikl['kolicina'].toString(),
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                Spacer(),
                                Text(
                                  bicikl['status'],
                                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement your logic for "Više informacija" button
                                    },
                                    child: Text('Više informacija'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPageBicikli > 0
                        ? () {
                            setState(() {
                              _currentPageBicikli--;
                            });
                          }
                        : null,
                    child: Text('<'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: endIndex < _prikazaniBicikli.length
                        ? () {
                            setState(() {
                              _currentPageBicikli++;
                            });
                          }
                        : null,
                    child: Text('>'),
                  ),
                ],
              ),
              SizedBox(height: 2),
            ],
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildDijelovi() {
    return Center(
      child: Text(
        'Dijelovi',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildDodajAdministratora() {
    return Center(
      child: Text(
        'Dodaj Administratora',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildNavButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.14,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedSection == title
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          setState(() {
            _selectedSection = title;
          });
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedSection == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatus == title
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterKorisnici(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatus == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtonBicikl(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusBicikli == title
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterBicikli(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusBicikli == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }
}