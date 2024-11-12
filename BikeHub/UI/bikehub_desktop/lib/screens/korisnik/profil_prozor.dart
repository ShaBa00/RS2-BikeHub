// ignore_for_file: sort_child_properties_last

import 'package:bikehub_desktop/screens/korisnik/korisnik_proizvodi_prikaz.dart';
import 'package:bikehub_desktop/screens/serviser/serviser_profil.dart';
import 'package:bikehub_desktop/services/korisnik/korisnik_service.dart';
import 'package:flutter/material.dart';

class ProfilProzor extends StatefulWidget {
  final int korisnikId;
  const ProfilProzor({super.key, required this.korisnikId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilProzorState createState() => _ProfilProzorState();
}
class _ProfilProzorState extends State<ProfilProzor> {
  final KorisnikService korisnikService = KorisnikService();
  Map<String, dynamic>? korisnik;

  @override
  void initState() {
    super.initState();
    _fetchKorisnik();
  }

  Future<void> _fetchKorisnik() async {
    korisnik = await korisnikService.getKorisnikByID(widget.korisnikId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (korisnik == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil'),backgroundColor: const Color.fromARGB(255, 92, 225, 230),),
        body: const Center(
          child: CircularProgressIndicator(), // Prikazuje se dok se podaci učitavaju
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),        
        backgroundColor: const Color.fromARGB(255, 92, 225, 230),
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
            width: screenWidth * 0.65,
            height: screenHeight * 0.65,
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
                // 1. red 
                Container(
                  height: screenHeight * 0.65 * 0.2,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: korisnik != null
                      ? _buildDetailContainer("Username", korisnik!['username'])
                      : const CircularProgressIndicator(), 
                ),
                // 2. red 
                Expanded(
                  child: Column(
                    children: [
                      // 1. red drugog reda 
                      // ignore: sized_box_for_whitespace
                      Container(
                        height: screenHeight * 0.65 * 0.8 * 0.8,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Prva kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center, 
                                        children: [
                                          _buildDetailContainer("Email", korisnik!['email']),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer(
                                            "Ime i Prezime", 
                                            korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['imePrezime'] : 'N/A'
                                          ),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer(
                                            "Telefon", 
                                            korisnik!['korisnikInfos'].isNotEmpty ? korisnik!['korisnikInfos'][0]['telefon'] : 'N/A'
                                          ),
                                        ],
                                      )
                                    : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Druga kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: korisnik != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center, 
                                        children: [
                                          _buildDetailContainer("Broj Proizvoda", korisnik!['brojProizvoda']),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                // ignore: prefer_const_constructors
                                                MaterialPageRoute(builder: (context) =>  KorisnikProizvodiPrikaz()),
                                              );
                                            },
                                            child: const Text("Pogledaj proizvode"),
                                          ),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer("Ukupna Kolicina", korisnik!['ukupnaKolicina']),
                                          const SizedBox(height: 20),
                                          _buildDetailContainer("Status", korisnik!['status']),
                                        ],
                                      )
                                    : const CircularProgressIndicator(),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            // Treća kolona
                            Container(
                              height: double.infinity,
                              width: screenWidth * 0.65 * 0.25,
                              alignment: Alignment.center,
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDetailContainer("Admin Status", korisnik!['isAdmin'] ? "Jeste admin" : "Nije admin"),
                                if (korisnik!['isAdmin'])                                   
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Za sada dugme ne radi ništa
                                    },
                                    child: const Text("Administracije"),
                                  ),

                                const SizedBox(height: 20), 

                                // Prikaz za jeServiser
                                _buildDetailContainer("Serviser Status", korisnik!['jeServiser'] ? "Jeste serviser" : "Nije serviser"),
                                const SizedBox(height: 20), 
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        // ignore: prefer_const_constructors
                                        MaterialPageRoute(builder: (context) => ServiserProfil()),
                                      );
                                    },
                                    child: const Text("Serviser"),
                                  ),
                              ],
                            ),
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      // 2. red drugog reda - 20% visine 2. reda
                      Container(
                        height: screenHeight * 0.65 * 0.8 * 0.2,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Akcija za dugme "Uredi"
                            },
                            child: const Text("Uredi"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Akcija za dugme "Obrisi"
                            },
                            child: const Text("Obrisi"),
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
    );
  }
    Widget _buildDetailContainer(String label, dynamic value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.15,
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
}
