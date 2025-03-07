import 'package:bikehub_desktop/screens/serviser/servis_prikaz.dart';
import 'package:flutter/material.dart';
import 'package:bikehub_desktop/services/adresa/adresa_service.dart';
import '../../services/serviser/serviser_service.dart';

class ServiserProzor extends StatefulWidget {
  const ServiserProzor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ServiserProzorState createState() => _ServiserProzorState();
}

class _ServiserProzorState extends State<ServiserProzor> {
  final AdresaService adresaService = AdresaService();
  final ServiserService serviserService = ServiserService();
  String? username;
  double cijenaOd = 0;
  double cijenaDo = 1000;
  RangeValues _cijenaRange = const RangeValues(0, 1000);
  int brojServisaOd = 0;
  int brojServisaDo = 100;
  RangeValues _brojServisaRange = const RangeValues(0, 100);
  double ukupnaOcjenaOd = 0;
  double ukupnaOcjenaDo = 5;
  RangeValues _ukupnaOcjenaRange = const RangeValues(0, 5);
  int? selectedGradId;
  int _currentPage = 1;
  final int _pageSize = 5;

  @override
  // ignore: must_call_super
  void initState() {
    adresaService.getGradKorisniciDto();
    serviserService.getServiseriDTO(status: "aktivan");
  }

  Future<void> _loadServisere() async {
    List<int>? korisniciId;
    if (selectedGradId != null) {
      final selectedGrad =
          adresaService.listaGradKorisniciDto.value.firstWhere((adresa) => adresa['GradId'] == selectedGradId, orElse: () => <String, dynamic>{});

      List<int>? korisniciIds;
      // ignore: unnecessary_null_comparison
      if (selectedGrad != null) {
        korisniciIds = List<int>.from(selectedGrad['KorisnikIds']);
        korisniciId = korisniciIds;
      }
    }
    final serviseri = await serviserService.getServiseriDTO(
      username: username,
      pocetnaCijena: cijenaOd,
      krajnjaCijena: cijenaDo,
      pocetniBrojServisa: brojServisaOd,
      krajnjiBrojServisa: brojServisaDo,
      pocetnaOcjena: ukupnaOcjenaOd,
      krajnjaOcjena: ukupnaOcjenaDo,
      page: _currentPage,
      pageSize: _pageSize,
      korisniciId: korisniciId,
    );
    serviserService.listaUcitanihServisera.value = serviseri;
  }

  void _nextPage() {
    if (serviserService.count > (_pageSize * (_currentPage))) {
      if (serviserService.listaUcitanihServisera.value.length == _pageSize) {
        _currentPage++;
        _loadServisere();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadServisere();
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
            title: const Text('Serviseri'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Row(
        children: [
          // Lijevi dio za pretragu
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Korisničko ime',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.blueAccent,
                    ),
                    onChanged: (value) {
                      username = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Cijena", style: TextStyle(color: Colors.white)),
                  RangeSlider(
                    values: _cijenaRange,
                    min: 0,
                    max: 1000,
                    divisions: 10,
                    labels: RangeLabels(
                      cijenaOd.toStringAsFixed(0),
                      cijenaDo.toStringAsFixed(0),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _cijenaRange = values;
                        cijenaOd = values.start;
                        cijenaDo = values.end;
                      });
                      _currentPage = 1;
                      _loadServisere();
                    },
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${getFormattedCijenaa(cijenaOd)} - ${getFormattedCijena(cijenaDo)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("Broj Servisa", style: TextStyle(color: Colors.white)),
                  RangeSlider(
                    values: _brojServisaRange,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    labels: RangeLabels(
                      brojServisaOd.toString(),
                      brojServisaDo.toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _brojServisaRange = values;
                        brojServisaOd = values.start.round();
                        brojServisaDo = values.end.round();
                      });
                      _currentPage = 1;
                      _loadServisere();
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Ukupna Ocjena", style: TextStyle(color: Colors.white)),
                  RangeSlider(
                    values: _ukupnaOcjenaRange,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    labels: RangeLabels(
                      ukupnaOcjenaOd.toStringAsFixed(1),
                      ukupnaOcjenaDo.toStringAsFixed(1),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _ukupnaOcjenaRange = values;
                        ukupnaOcjenaOd = values.start;
                        ukupnaOcjenaDo = values.end;
                      });
                      _currentPage = 1;
                      _loadServisere();
                    },
                  ),
                  const SizedBox(height: 16),
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
                              _currentPage = 1;
                              await _loadServisere();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      _currentPage = 1;
                      await _loadServisere();
                    },
                    child: const Text('Pretraži'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
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
                      valueListenable: serviserService.listaUcitanihServisera,
                      builder: (context, serviseri, _) {
                        if (serviseri.isEmpty) {
                          return const Center(
                            child: Text(
                              'Nema servisera koji odgovaraju filterima.',
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: serviseri.length,
                          itemBuilder: (context, index) {
                            final serviser = serviseri[index];
                            bool isHovering = false; // Varijabla za praćenje hover stanja

                            return StatefulBuilder(
                              // Koristimo StatefulBuilder da pratimo stanje hovera
                              builder: (context, setState) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ServiserPrikaz(
                                          serviserId: serviser['serviserId'],
                                          korisnikId: serviser['korisnikId'],
                                        ),
                                      ),
                                    );
                                  },
                                  onHover: (hovering) {
                                    setState(() {
                                      isHovering = hovering; // Ažuriramo stanje hovera
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isHovering
                                            ? [
                                                const Color.fromARGB(255, 72, 205, 210), // Boje u hover stanju
                                                const Color.fromARGB(255, 5, 161, 235),
                                              ]
                                            : [
                                                const Color.fromARGB(255, 92, 225, 230), // Originalne boje
                                                const Color.fromARGB(255, 7, 181, 255),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: isHovering
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3), // Sjena kad je hover
                                              ),
                                            ]
                                          : [],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.build, size: 24, color: Colors.white),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            serviser['username'] ?? 'N/A',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Broj servisa: ${serviser['brojServisa'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Ocjena: ${serviser['ukupnaOcjena'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Grad: ${serviser['grad'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            getFormattedCijena(serviser['cijena']),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousPage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getFormattedCijenaa(double cijena) {
    return "${cijena.toStringAsFixed(2)} KM";
  }

  String getFormattedCijena(dynamic cijena) {
    if (cijena == null) {
      return "Cijena nije pronađena";
    }

    final double cijenaValue;
    try {
      cijenaValue = double.parse(cijena.toString());
    } catch (e) {
      return "Cijena nije pronađena";
    }

    return "${cijenaValue.toStringAsFixed(2)} KM";
  }
}
