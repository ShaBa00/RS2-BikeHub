import 'package:bikehub_desktop/services/serviser/rezervacija_servisa_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../services/serviser/serviser_service.dart';
import 'package:table_calendar/table_calendar.dart';

class ServiserPrikaz extends StatefulWidget {
  final int serviserId;
  final int korisnikId;
  //final RezervacijaServisaService rezervacijaServisaService;
  
  // ignore: use_super_parameters
  const ServiserPrikaz({
    Key? key,
    required this.serviserId,
    required this.korisnikId,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ServiserPrikazState createState() => _ServiserPrikazState();
}

class _ServiserPrikazState extends State<ServiserPrikaz> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<int> slobodniDani = [];
  String? odabraniDatum="YYYY-MM-DD";
  DateTime newfocusedDay = DateTime.now();
  final ServiserService _serviserService = ServiserService();
  final Logger logger = Logger();
  Map<String, dynamic>? serviserDetalji;

  @override
  void initState() {
    super.initState();
    _fetchServiserDetalji();
    fetchSlobodniDani(selectedMonth, selectedYear);
  }
  Future<void> fetchSlobodniDani(int month, int year) async {
    selectedMonth=month;
    selectedYear=year;
    try {
      final days = await RezervacijaServisaService().getSlobodniDani(
        serviserId: widget.serviserId,
        mjesec: month,
        godina: year,
      );
      setState(() {
        // ignore: unnecessary_cast
        slobodniDani = days as List<int>;
      });
    } catch (e) {
      logger.e('Greška prilikom učitavanja slobodnih dana: $e');
    }
  }


  Future<void> _fetchServiserDetalji() async {
    try {
      final List<Map<String, dynamic>> serviseri = await _serviserService.getServiseriDTO(
        korisniciId: [widget.korisnikId],
      );
      if (serviseri.isNotEmpty) {
        setState(() {
          serviserDetalji = serviseri.firstWhere(
            (serviser) => serviser['serviserId'] == widget.serviserId,
            orElse: () => {},
          );
        });
      }
    } catch (e) {
      logger.e('Greška prilikom učitavanja detalja servisera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    //final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    // ignore: unused_local_variable
    //final startDay = DateTime(selectedYear, selectedMonth, 1).weekday;
    
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Detalji o Serviseru'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Row(
          children: [
            // Lijevi dio
            Expanded(
              flex: 25,
              child: Container(
                color: Colors.transparent, 
                padding: const EdgeInsets.all(16.0),
                child: serviserDetalji != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailContainer('Username', serviserDetalji?['username'] ?? 'Username nije pronađen'),
                          _buildDetailContainer('Grad', serviserDetalji?['grad'] ?? 'Grad nije pronađen'),
                          _buildDetailContainer('Broj servisa', serviserDetalji?['brojServisa']?.toString() ?? 'Broj servisa nije pronađen'),
                          _buildDetailContainer('Ukupna ocjena', serviserDetalji?['ukupnaOcjena']?.toString() ?? 'Ocjena nije pronađena'),
                          _buildDetailContainer('Cijena', serviserDetalji?['cijena']?.toString() ?? 'Cijena nije pronađena'),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            // Desni dio - placeholder
            Expanded(
              flex: 75,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Gornji dio - kalendar
                    Expanded(
                      flex: 50,
                      child: SizedBox(                        
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.7, 
                      child: TableCalendar(
                          shouldFillViewport: true,
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: newfocusedDay,
                          selectedDayPredicate: (day) => isSameDay(day, newfocusedDay),
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          onDaySelected: (selectedDate, focusedDate) {
                            setState(() {
                              newfocusedDay = selectedDate;
                              odabraniDatum = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                            });
                          },
                          onPageChanged: (focusedDate) {
                            setState(() {
                              newfocusedDay = focusedDate;
                              selectedMonth = focusedDate.month;
                              selectedYear = focusedDate.year;
                            });
                            fetchSlobodniDani(selectedMonth, selectedYear);
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              bool isSlobodanDan = slobodniDani.contains(day.day);
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSlobodanDan ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              bool isSlobodanDan = slobodniDani.contains(day.day);
                              return Container(
                                margin: const EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSlobodanDan ? Colors.green[700] : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Donji dio - prikaz odabranog datuma i dugme "Rezervisi"
                    Expanded(
                      flex: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                width: MediaQuery.of(context).size.width * 0.2 ,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1), 
                                  border: Border(
                                    left: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                    right: BorderSide(color: Colors.blue.shade900, width: 2.0),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Odabrani datum: ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      '$odabraniDatum',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: () {
                                
                              },
                              child: const Text("Rezervisi"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContainer(String label, dynamic value) {
    double marginBottom = MediaQuery.of(context).size.height * 0.04;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), 
        border: Border(
          left: BorderSide(color: Colors.blue.shade900, width: 2.0),
          bottom: BorderSide(color: Colors.blue.shade900, width: 2.0),
          right: BorderSide(color: Colors.blue.shade900, width: 2.0),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(bottom: marginBottom), // Razmak između kontejnera
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: ',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Podebljan tekst
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Podebljan tekst
          ),
        ],
      ),
    );
  }
}
