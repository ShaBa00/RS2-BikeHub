// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unused_element, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field, no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, unused_local_variable, use_build_context_synchronously


import 'package:bikehub_desktop/modeli/bicikli/bicikl_model.dart';
import 'package:bikehub_desktop/modeli/dijelovi/dijelovi_model.dart';
import 'package:bikehub_desktop/modeli/korisnik/korisnik_model.dart';
import 'package:bikehub_desktop/modeli/serviseri/serviser_model.dart';
import 'package:bikehub_desktop/screens/administracija/dodatno/image_carousel.dart';
import 'package:bikehub_desktop/services/bicikli/bicikl_service.dart';
import 'package:bikehub_desktop/services/dijelovi/dijelovi_service.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bikehub_desktop/services/serviser/serviser_service.dart';
import 'package:flutter/material.dart';

class AdministracijaP1Prozor extends StatefulWidget {
  const AdministracijaP1Prozor({super.key});

  @override
  _AdministracijaP1ProzorState createState() => _AdministracijaP1ProzorState();
}



class _AdministracijaP1ProzorState extends State<AdministracijaP1Prozor> {
  String _selectedSection = 'Home';
  bool _isLoading = true;

  int odabraniId=0;

  List _prikazaniKorisnici = [];
  int _currentPageKorisnik = 0;
  int _pageSizeKorisnik = 5;
  int _brojPrikazanihKorisnika = 0;
  String _selectedStatus = 'Kreirani';
  List _listaKorisnika = [];
  int _countKorisnik = 0;

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

  List _prikazaniDijelovi = [];
  int _currentPageDijelovi = 0;
  int _pageSizeDijelovi = 5;
  int _brojPrikazanihDijelova = 0;
  String _selectedStatusDijelova = 'Kreirani';
  List _listaDijelova = [];
  int _countDijelovi = 0;

  List _prikazaniServiseri = [];
  int _currentPageServisera = 0;
  int _pageSizeServisera = 5;
  int _brojPrikazanihServisera = 0;
  String _selectedStatusServisera = 'Kreirani';
  List _listaServisera = [];
  int _countServisera = 0;

  String _username="";
  final KorisnikService _korisnikService = KorisnikService();
  final BiciklService _bicikliService = BiciklService();
  final DijeloviService _dijeloviService = DijeloviService();
  final ServiserService _serviserService = ServiserService();

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
    await _dijeloviService.getDijelovi(status: '', isSlikaIncluded: false, page: null, pageSize: null);
    await _serviserService.getServiseriDTO(status: '', page: null, pageSize: null);
    setState(() {
      _listaKorisnika = _korisnikService.listaKorisnika;
      _countKorisnik = _korisnikService.countKorisnika;
      _listaBicikala = _bicikliService.listaBicikala;
      _countBicikl = _bicikliService.count;
      _listaDijelova = _dijeloviService.listaDijelova;
      _countDijelovi = _dijeloviService.count;
      _listaAdministratora = _korisnikService.listaAdministratora;
      _countAdministratora = _listaAdministratora.length;
      _listaServisera = _serviserService.listaServisra;
      _countAdministratora = _listaServisera.length;
      _isLoading = false;
    });    
    await _filterKorisnici("Kreirani");
    await _filterBicikli("Kreirani");
    await _filterDijelovi("Kreirani");
    await _filterServiseri("Kreirani");
  }

  void _loadAdministratori(int page) {
    setState(() {
      _currentPageAdministrator = page;
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
  
  _filterDijelovi(String status) async{
    String _status;
    _currentPageDijelovi=0;
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
      _selectedStatusDijelova = status;
      _prikazaniDijelovi = _listaDijelova.where((dio) => dio['status'] == _status).toList();
      _brojPrikazanihDijelova = _prikazaniDijelovi.length;
    });
  }
  
  _filterServiseri(String status) async{
    String _status;
    _currentPageServisera=0;
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
      _selectedStatusServisera = status;
      _prikazaniServiseri = _listaServisera.where((serviser) => serviser['status'] == _status).toList();
      _brojPrikazanihServisera = _prikazaniServiseri.length;
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
                      _buildNavButton('Serviseri'),
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
      case 'Korisnik info':
        return _buildKorisnikInfo();
      case 'Bicikli info':
        return _buildBicikliInfo();
      case 'Dijelovi info':
        return _buildDijeloviInfo();
      case 'Serviseri':
        return _buildServiseri();
      case 'Serviser info':
        return _buildServiserInfo();
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
                                  Icons.supervised_user_circle_rounded,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    korisnik['username'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    korisnik['email'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    korisnik['status'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      odabraniId=korisnik['korisnikId'];
                                      _selectedSection = "Korisnik info";
                                    });
                                  },
                                  child: Text('Više informacija'),
                                ),
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
                                Expanded(
                                  child: Text(
                                    bicikl['naziv'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    bicikl['cijena'].toString(),
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    bicikl['status'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(()  {
                                      odabraniId=bicikl['biciklId'];
                                      _selectedSection = "Bicikli info";
                                    });
                                  },
                                  child: Text('Više informacija'),
                                ),
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
    int startIndex = _currentPageDijelovi * _pageSizeDijelovi;
    int endIndex = startIndex + _pageSizeDijelovi;
    List currentDijelovi = _prikazaniDijelovi.sublist(
      startIndex,
      endIndex > _prikazaniDijelovi.length ? _prikazaniDijelovi.length : endIndex,
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
                      'Dijelovi',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    _buildStatusButtonDijelovi('Kreirani'),
                    _buildStatusButtonDijelovi('Izmijenjeni'),
                    _buildStatusButtonDijelovi('Aktivni'),
                    _buildStatusButtonDijelovi('Obrisani'),
                    _buildStatusButtonDijelovi('Vraceni'),
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
                  itemCount: currentDijelovi.length,
                  itemBuilder: (context, index) {
                    final dijelovi = currentDijelovi[index];
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
                                  Icons.construction,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dijelovi['naziv'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dijelovi['cijena'].toString(),
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    dijelovi['status'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      odabraniId=dijelovi['dijeloviId'];
                                      _selectedSection = "Dijelovi info";
                                    });
                                  },
                                  child: Text('Više informacija'),
                                ),
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
                    onPressed: _currentPageDijelovi > 0
                        ? () {
                            setState(() {
                              _currentPageDijelovi--;
                            });
                          }
                        : null,
                    child: Text('<'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: endIndex < _prikazaniDijelovi.length
                        ? () {
                            setState(() {
                              _currentPageDijelovi++;
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

  Widget _buildServiseri() {
    int startIndex = _currentPageServisera * _pageSizeServisera;
    int endIndex = startIndex + _pageSizeServisera;
    List currentServiser = _prikazaniServiseri.sublist(
      startIndex,
      endIndex > _prikazaniServiseri.length ? _prikazaniServiseri.length : endIndex,
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
                      'Serviseri',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                    _buildStatusButtonServiseri('Kreirani'),
                    _buildStatusButtonServiseri('Izmijenjeni'),
                    _buildStatusButtonServiseri('Aktivni'),
                    _buildStatusButtonServiseri('Obrisani'),
                    _buildStatusButtonServiseri('Vraceni'),
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
                  itemCount: currentServiser.length,
                  itemBuilder: (context, index) {
                    final serviseri = currentServiser[index];
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
                                  Icons.miscellaneous_services,
                                  size: 24,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    serviseri['username'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    serviseri['grad'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    serviseri['status'],
                                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      odabraniId=serviseri['serviserId'];
                                      _selectedSection = "Serviser info";
                                    });
                                  },
                                  child: Text('Više informacija'),
                                ),
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
                    onPressed: _currentPageServisera > 0
                        ? () {
                            setState(() {
                              _currentPageServisera--;
                            });
                          }
                        : null,
                    child: Text('<'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: endIndex < _prikazaniServiseri.length
                        ? () {
                            setState(() {
                              _currentPageServisera++;
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

  final _usernameController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();
  final _emailController = TextEditingController();
  
  void dodajAdministratora() async {
    if (_usernameController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati username");
      return;
    }
    if (_lozinkaController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati lozinku");
      return;
    }
    if (_lozinkaPotvrdaController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati potvrdenu lozinku");
      return;
    }
    if (_lozinkaController.text != _lozinkaPotvrdaController.text) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Lozinka i potvrdena lozinka moraju biti iste");
      return;
    }
    if (_emailController.text.isEmpty) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Potrebno je dodati email");
      return;
    }

    KorisnikModel noviAdministrator = KorisnikModel(
      korisnikId: 0,
      username: _usernameController.text,
      staraLozinka: "",
      lozinka: _lozinkaController.text,
      lozinkaPotvrda: _lozinkaPotvrdaController.text,
      email: _emailController.text,
      stanje: "",
      ak: 0,
      isAdmin: true,
    );

    try {
      final responseMessage = await _korisnikService.postAdmina(noviAdministrator);
      if (responseMessage == "Administrator uspješno dodan") {
        PorukaHelper.prikaziPorukuUspjeha(context, responseMessage!);
        _usernameController.clear();
        _lozinkaController.clear();
        _lozinkaPotvrdaController.clear();
        _emailController.clear();
      } else {
        PorukaHelper.prikaziPorukuUpozorenja(context, responseMessage ?? "Došlo je do greške prilikom dodavanja administratora");
      }
    } catch (e) {
      PorukaHelper.prikaziPorukuUpozorenja(context, "Došlo je do greške: $e");
    }
}

  Widget _buildDodajAdministratora() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.553,
      child: Column(
        children: [
          Expanded(
            flex: 15,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 33, 149, 243), // Dodajte boju za vizualizaciju
              child: Center(
                child: Text(
                  'Dodavanje novog administratora',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 85,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(0, 76, 175, 79), // Dodajte boju za vizualizaciju
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 82, 205, 210),
                        Color.fromARGB(255, 7, 161, 235),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07, 
                        width: MediaQuery.of(context).size.width * 0.18, // Smanjena širina TextField-a
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07, 
                        width: MediaQuery.of(context).size.width * 0.18, // Smanjena širina TextField-a
                        child: TextField(
                          controller: _lozinkaController,
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07, 
                        width: MediaQuery.of(context).size.width * 0.18, // Smanjena širina TextField-a
                        child: TextField(
                          controller: _lozinkaPotvrdaController,
                          decoration: InputDecoration(
                            labelText: 'Potvrda Lozinke',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07, 
                        width: MediaQuery.of(context).size.width * 0.18, // Smanjena širina TextField-a
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: dodajAdministratora,
                        child: Text('Dodaj'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  promjeniStatus(String status, String objekat)async{
    String _status;

    switch (status) {
      case "Aktiviraj":
        _status = "aktivan";
        break;
      case "Vrati":
        _status = "vracen";
        break;
      case "Obrisi":
        _status = "obrisan";
        break;
      default:
        return;
    }
    if(objekat=="Korisnik"){
      KorisnikModel korisnik = KorisnikModel(
        korisnikId: odabraniId,
        username: '',
        staraLozinka: '',
        lozinka: '',
        lozinkaPotvrda: '',
        email: '',
        stanje: _status,
        ak: 1,
        isAdmin: false,
      );
      try {
        await _korisnikService.upravljanjeKorisnikom(korisnik);
        PorukaHelper.prikaziPorukuUspjeha(context, "Korisnik uspješno azuriran.");
        await _fetchPodatci();  
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju korisnika: $e");
      }
    }
    if(objekat=="Bicikl"){
        Bicikl bicikl = Bicikl(
        biciklId:odabraniId,
        naziv:"",
        cijena:0,
        velicinaRama: "",
        velicinaTocka: "",
        brojBrzina: 0,
        kategorijaId: 0,
        kolicina: 0,
        korisnikId: 0,
        stanje: _status,
        ak: 1,
      );
      try {
        await _bicikliService.upravljanjeBiciklom(bicikl);
        PorukaHelper.prikaziPorukuUspjeha(context, "Bicikl uspješno azuriran.");
        await _fetchPodatci();  
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju bicikla: $e");
      }
    }
    if(objekat=="Dijelovi"){
        Dijelovi dijelovi = Dijelovi(
        dijeloviId:odabraniId,
        naziv:"",
        cijena:0,
        opis: "",
        kategorijaId: 0,
        kolicina: 0,
        korisnikId: 0,
        stanje: _status,
        ak: 1,
      );
      try {
        await _dijeloviService.upravljanjeDijelom(dijelovi);
        PorukaHelper.prikaziPorukuUspjeha(context, "Dijelovi uspješno azurirani.");
        await _fetchPodatci();  
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju Dijelova: $e");
      }
    }
    if(objekat=="Serviser"){
      ServiserModel serviser = ServiserModel(
        korisnikId: 0,
        username: '',
        stanje: _status,
        ak: 1, 
        serviserId: odabraniId, 
        brojServisa: 0, 
        cijena: 0, 
        ukupnaOcjena: 0, 
        grad: '',
      );
      try {
        await _serviserService.upravljanjeServiserom(serviser);
        PorukaHelper.prikaziPorukuUspjeha(context, "Serviser uspješno azuriran.");
        await _fetchPodatci();  
      } catch (e) {
        PorukaHelper.prikaziPorukuGreske(context, "Greška pri azuriranju servisera: $e");
      }
    }
  }

  Widget _buildKorisnikInfo() {
    return FutureBuilder(
      future: _korisnikService.getKorisnikByID(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja korisnika',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              'Korisnik nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var korisnik = snapshot.data as Map;
          var korisnikInfo = korisnik['korisnikInfos'] != null && korisnik['korisnikInfos'].isNotEmpty
          ? korisnik['korisnikInfos'][0]
          : {};
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)), // Zaobljene ivice za cijeli dio
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243), // Pozadina za "GorniDio"
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15), // Zaobljene gornje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Username', korisnik['username'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('User ID', korisnik['korisnikId'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Admin', korisnik['isAdmin'] ? 'True' : 'False'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('', korisnik['email'] ?? 'null'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Ime i Prezime', korisnikInfo['imePrezime'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Telefon', korisnikInfo['telefon'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Broj Narudbi', korisnikInfo['brojNarudbi'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Broj Servisa', korisnikInfo['brojServisa'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Status info', korisnikInfo['status'] ?? 'null'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Broj Proizvoda', korisnik['brojProizvoda'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Broj Rezervacija', korisnik['brojRezervacija'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Serviser', korisnik['jeServiser'] ?? false ? 'True' : 'False'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Status korisnika', korisnik['status'] ?? 'null'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //dugmici
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 0), // Pozadina za "DonjiDio"
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15), // Zaobljene donje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (korisnik['status'] == "kreiran" || korisnik['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Korisnik"),
                                SizedBox(width: 10),
                              ],
                              if (korisnik['status'] != "obrisan") ...[
                                if (korisnik['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Korisnik"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Korisnik"),
                              ],
                            ],
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
      },
    );
  }

  Widget _buildBicikliInfo() {
    return FutureBuilder(
      future: _bicikliService.getBiciklById(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError ) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja bicikla',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null) )  {
          return Center(
            child: Text(
              'Biciklo nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var bicikl = snapshot.data as Map;
          var slikeBiciklis= bicikl['slikeBiciklis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)), // Zaobljene ivice za cijeli dio
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243), // Pozadina za "GorniDio"
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15), // Zaobljene gornje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', bicikl['naziv']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Cijena', bicikl['cijena']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Velicina Rama', bicikl['velicinaRama']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Velicina Tocka', bicikl['velicinaTocka']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child:  Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeBiciklis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Broj Brzina', bicikl['brojBrzina']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Kolicina', bicikl['kolicina']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Kategorija Id', bicikl['kategorijaId']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Status bicikla', bicikl['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79), // Pozadina za "DonjiDio"
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15), // Zaobljene donje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (bicikl['status'] == "kreiran" || bicikl['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Bicikl"),
                                SizedBox(width: 10),
                              ],
                              if (bicikl['status'] != "obrisan") ...[
                                if (bicikl['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Bicikl"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Bicikl"),
                              ],
                            ],
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
      },
    );
  }

  Widget _buildDijeloviInfo() {
    return FutureBuilder(
      future: _dijeloviService.getDijeloviById(odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError ) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja dijela',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if ((!snapshot.hasData || snapshot.data == null) )  {
          return Center(
            child: Text(
              'Dio nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var dio = snapshot.data as Map;
          var slikeDijelovis= dio['slikeDijelovis'];
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)), // Zaobljene ivice za cijeli dio
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243), // Pozadina za "GorniDio"
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15), // Zaobljene gornje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Naziv', dio['naziv']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Cijena', dio['cijena']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Kolicina', dio['kolicina']),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child:  Container(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: ImageCarousel(
                                    slikeBiciklis: slikeDijelovis,
                                    initialIndex: 0,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('KategorijaId', dio['kategorijaId']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Status dijela', dio['status']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 79), // Pozadina za "DonjiDio"
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15), // Zaobljene donje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dio['status'] == "kreiran" || dio['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Dijelovi"),
                                SizedBox(width: 10),
                              ],
                              if (dio['status'] != "obrisan") ...[
                                if (dio['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Dijelovi"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Dijelovi"),
                              ],
                            ],
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
      },
    );
  }

  Widget _buildServiserInfo() {
    return FutureBuilder(
      future: _serviserService.getServiserDtoByKorisnikId(serviserId:  odabraniId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Greska prilikom pronalazenja servisera',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              'Serviser nije pronađen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        } else {
          var serviser = snapshot.data as Map;
          return Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 236, 230, 230),
                        Color.fromARGB(255, 188, 188, 188),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)), // Zaobljene ivice za cijeli dio
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.54 * 0.8,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 33, 149, 243), // Pozadina za "GorniDio"
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15), // Zaobljene gornje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Username', serviser['username'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Serviser Id', serviser['serviserId'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('User ID', serviser['korisnikId'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Grad', serviser['grad'] ?? 'null'),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.22,
                                height: MediaQuery.of(context).size.height * 0.45 * 0.8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 82, 205, 210),
                                      Color.fromARGB(255, 7, 161, 235),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDetailContainer('Cijena', serviser['cijena'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Broj servisa', serviser['brojServisa'] ?? 'null'),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Ukupna ocjena', serviser['ukupnaOcjena']),
                                    SizedBox(height: MediaQuery.of(context).size.height *0.008,),
                                    _buildDetailContainer('Status servisera', serviser['status'] ?? 'null'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //dugmici
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.15 * 0.45,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(0, 76, 175, 0), // Pozadina za "DonjiDio"
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(15), // Zaobljene donje ivice
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (serviser['status'] == "kreiran" || serviser['status'] == "izmijenjen") ...[
                                _buildSetStatusButton("Aktiviraj", "Serviser"),
                                SizedBox(width: 10),
                              ],
                              if (serviser['status'] != "obrisan") ...[
                                if (serviser['status'] != "vracen") ...[
                                  _buildSetStatusButton("Vrati", "Serviser"),
                                  SizedBox(width: 10),
                                ],
                                _buildSetStatusButton("Obrisi", "Serviser"),
                              ],
                            ],
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
      },
    );
  }

  Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.19,
      height: MediaQuery.of(context).size.height * 0.05,
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.005),
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
          AutoSizeText(
            '$label ',
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            minFontSize: 8,
            stepGranularity: 1,
          ),
          AutoSizeText(
            '$value',
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            minFontSize: 8,
            stepGranularity: 1,
          ),
        ],
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

  Widget _buildSetStatusButton(String status, String objekat) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.07,
      height: MediaQuery.of(context).size.height * 0.04,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedSection == status
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () async {
          await promjeniStatus(status,objekat);
        },
        child: Text(
          status,
          style: TextStyle(
            color: _selectedSection == status ? Colors.white : Colors.blue,
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

  Widget _buildStatusButtonDijelovi(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusDijelova == title
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterDijelovi(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusDijelova == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

    Widget _buildStatusButtonServiseri(String title) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedStatusServisera == title
              ? Color.fromARGB(255, 87, 202, 255)
              : const Color.fromARGB(255, 242, 242, 242),
        ),
        onPressed: () {
          _filterServiseri(title);
        },
        child: Text(
          title,
          style: TextStyle(
            color: _selectedStatusServisera == title ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }
}