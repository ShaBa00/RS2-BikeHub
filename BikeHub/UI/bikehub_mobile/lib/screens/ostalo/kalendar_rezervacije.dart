// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors

import 'package:bikehub_mobile/servisi/korisnik/serviser_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PrikazKalendara extends StatefulWidget {
  final int serviserId;

  const PrikazKalendara({super.key, required this.serviserId});

  @override
  _PrikazKalendaraState createState() => _PrikazKalendaraState();
}

class _PrikazKalendaraState extends State<PrikazKalendara> {
  late int odabraniMjesec;
  late int odabranaGodina;
  List<int> slobodniDani = [];
  bool loading = true;
  final ServiserService _serviserService = ServiserService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    odabraniMjesec = now.month;
    odabranaGodina = now.year;
    fetchPodatci();
  }

  Future<void> fetchPodatci() async {
    try {
      List<int> dani = await _serviserService.getSlobodniDani(
        serviserId: widget.serviserId,
        mjesec: odabraniMjesec,
        godina: odabranaGodina,
      );
      setState(() {
        slobodniDani = dani;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      // Handle error
    }
  }

  void onPageChanged(DateTime focusedDay) {
    setState(() {
      odabraniMjesec = focusedDay.month;
      odabranaGodina = focusedDay.year;
      loading = true;
    });
    fetchPodatci();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.37,
          color: const Color.fromARGB(0, 96, 125, 139), // Bilo koja pozadina
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.37,
                      color: const Color.fromARGB(0, 244, 67, 54),
                      child: Transform.scale(
                        scale: 0.98, // Faktor skaliranja za cijeli kalendar
                        child: SingleChildScrollView(
                          child: TableCalendar(
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2100),
                            focusedDay:
                                DateTime(odabranaGodina, odabraniMjesec),
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month'
                            },
                            onPageChanged: onPageChanged,
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final isSlobodanDan =
                                    slobodniDani.contains(day.day);
                                return Container(
                                  width: 40, // Smanjena širina dana
                                  height: 40, // Smanjena visina dana
                                  margin: const EdgeInsets.all(4.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSlobodanDan
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
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
  }
}
