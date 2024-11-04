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
  int? selectedDay;
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
  void onMonthChanged(DateTime focusedDay) {
    setState(() {
      selectedMonth = focusedDay.month;
      selectedYear = focusedDay.year;
      fetchSlobodniDani(selectedMonth, selectedYear);
    });
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
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    // ignore: unused_local_variable
    final startDay = DateTime(selectedYear, selectedMonth, 1).weekday;
    
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
              flex: 25, // 35% širine
              child: Container(
                color: Colors.transparent, // Providan za prikaz pozadine
                padding: const EdgeInsets.all(16.0),
                child: serviserDetalji != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailContainer('Username', serviserDetalji!['username']),
                          const SizedBox(height: 20.0), 
                          _buildDetailContainer('Grad', serviserDetalji!['grad']),
                          const SizedBox(height: 20.0),
                          _buildDetailContainer('Broj servisa', serviserDetalji!['brojServisa']),
                          const SizedBox(height: 20.0),
                          _buildDetailContainer('Ukupna ocjena', serviserDetalji!['ukupnaOcjena']),
                          const SizedBox(height: 20.0),
                          _buildDetailContainer('Cijena', serviserDetalji!['cijena']),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            // Desni dio - placeholder
            Expanded(
              flex: 75, // 75% širine
              child: Container(
                color: Colors.transparent, 
                child: Center(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    onDaySelected: (selectedDay, focusedDay) {
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContainer(String label, dynamic value) {
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: ',
              style: const TextStyle(color: Colors.white),
            ),
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
