import 'package:bikehub_desktop/screens/dijelovi/dijelovi_prikaz.dart';
import 'package:flutter/material.dart';
import '../../services/dijelovi/dijelovi_service.dart'; 
import '../../services/kategorije/kategorija_service.dart';
import 'package:bikehub_desktop/services/adresa/adresa_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class DijeloviProzor extends StatefulWidget {
  const DijeloviProzor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DijeloviProzorState createState() => _DijeloviProzorState();
}

class _DijeloviProzorState extends State<DijeloviProzor> {

  final DijeloviService dijeloviService = DijeloviService();
  final KategorijaServis kategorijaServis = KategorijaServis();
  final AdresaService adresaService = AdresaService();
  RangeValues _currentRangeValues = const RangeValues(0, 1500);
  double pocetnaCijena = 0;
  double krajnjaCijena = 1500;
  String? naziv;
  int? selectedKategorijaId;
  int? kategorijaId;
  int? selectedGradId;

  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadDijelovi();
    kategorijaServis.getDijeloviKategorije();
    adresaService.getGradKorisniciDto();
  }

  Future<void> _loadDijelovi() async {
    List<int>? korisniciId;
    if(selectedGradId!=null){
      final selectedGrad = adresaService.listaGradKorisniciDto.value
      .firstWhere((adresa) => adresa['GradId'] == selectedGradId, orElse: () => <String, dynamic>{});

      List<int>? korisniciIds;
      // ignore: unnecessary_null_comparison
      if (selectedGrad != null) {
        korisniciIds = List<int>.from(selectedGrad['KorisnikIds']);
        korisniciId=korisniciIds;
      }
    }
    final dijelovi = await dijeloviService.getDijelovi(
      naziv: naziv,
      pocetnaCijena: pocetnaCijena,
      krajnjaCijena: krajnjaCijena,
      page: _currentPage,
      pageSize: _pageSize,
      kategorijaId: selectedKategorijaId,
      korisniciId: korisniciId, 
    );
    dijeloviService.lista_ucitanih_dijelova.value = dijelovi;
  }

  void _nextPage() async{
    if(dijeloviService.count>(_pageSize*(_currentPage+1))){
      if (dijeloviService.lista_ucitanih_dijelova.value.length == _pageSize) {
        _currentPage++;      
        _loadDijelovi();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadDijelovi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0), 
        child: Container(
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
          child: AppBar(
            title: const Text('Dijelovi'),
            backgroundColor: Colors.transparent, 
            elevation: 0, 
          ),
        ),
      ),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: kategorijaServis.lista_ucitanih_d_kategorija,
                      builder: (context, kategorije, _) {
                        return InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.blueAccent, // Boja pozadine
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: selectedKategorijaId,
                              hint: const Text("Sve Kategorije", style: TextStyle(color: Colors.white)),
                              isExpanded: true,
                              dropdownColor: Colors.blueAccent, 
                              style: const TextStyle(color: Colors.white),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Sve Kategorije"),
                                ),
                                ...kategorije.map((kategorija) {
                                  return DropdownMenuItem<int>(
                                    value: kategorija['kategorijaId'],
                                    child: Text(kategorija['naziv']),
                                  );
                                // ignore: unnecessary_to_list_in_spreads
                                }).toList(),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  selectedKategorijaId = newValue;
                                });
                                _currentPage=0;
                                _loadDijelovi();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: adresaService.listaGradKorisniciDto,
                      builder: (context, adrese, _) {
                        return InputDecorator(
                          decoration: const InputDecoration(
                            labelText: '',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.blueAccent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: selectedGradId,
                              hint: const Text("Svi gradovi", style: TextStyle(color: Colors.white)),
                              isExpanded: true,
                              dropdownColor: Colors.blueAccent,
                              style: const TextStyle(color: Colors.white),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Svi gradovi"),
                                ),
                                ...adrese.map((adresa) {
                                  return DropdownMenuItem<int>(
                                    value: adresa['GradId'],
                                    child: Text(adresa['Grad']),
                                  );
                                // ignore: unnecessary_to_list_in_spreads
                                }).toList(),
                              ],
                              onChanged: (newValue) async {
                                setState(() {
                                  selectedGradId = newValue;
                                });
                                _currentPage = 0;
                                await _loadDijelovi();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Naziv',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.blueAccent,
                      ),
                      onChanged: (value) {
                        naziv = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    RangeSlider(
                      values: _currentRangeValues,
                      min: 0,
                      max: 1500,
                      divisions: 15,
                      labels: RangeLabels(
                        _currentRangeValues.start.round().toString(),
                        _currentRangeValues.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                          pocetnaCijena = values.start;
                          krajnjaCijena = values.end;
                        });
                        _currentPage = 0;
                        _loadDijelovi();
                      },
                    ),
                    const Text('Cijena:'),
                    Text(
                      'Od: ${_currentRangeValues.start.round()} do: ${_currentRangeValues.end.round()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        _currentPage = 0; 
                        await _loadDijelovi();
                      },
                      child: const Text('Pretraži'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Desni dio - Prikaz bicikala
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: double.infinity,
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
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: dijeloviService.lista_ucitanih_dijelova,
              builder: (context, dijelovi, _) {
                return dijelovi.isEmpty
                    ? const Center(
                        child: Text(
                          'Nema proizvoda koji odgovaraju filterima.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 12.0,
                                crossAxisSpacing: 12.0,
                              ),
                              itemCount: dijelovi.length,
                              itemBuilder: (context, index) {
                                final item = dijelovi[index];
                                final naziv = item['naziv'] ?? 'Nepoznato';
                                final cijena = item['cijena'] ?? 0;
                                final dijeloviId = item['dijeloviId'] ?? 0;
                                final korisnikId = item['korisnikId'] ?? 0;
                                Uint8List? imageBytes;
                                if (item['slikeDijelovis'] != null && item['slikeDijelovis'].isNotEmpty) {
                                  final base64Image = item['slikeDijelovis'][0]['slika'];
                                  imageBytes = base64Decode(base64Image);
                                }
                                return  MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DijeloviPrikaz(dioId: dijeloviId, korisnikId: korisnikId),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(12.0),
                                                topRight: Radius.circular(12.0),
                                              ),
                                              child: imageBytes != null
                                                  ? Image.memory(
                                                      imageBytes,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(Icons.image_not_supported, size: 50),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Text('Cijena: $cijena KM'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _previousPage,
                              ),
                              Text('Strana ${_currentPage + 1}'),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _nextPage,
                              ),
                            ],
                          ),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}