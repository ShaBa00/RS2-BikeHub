// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:bikehub_desktop/screens/bicikli/bicikl_dodaj.dart';
import 'package:bikehub_desktop/screens/dijelovi/dijelovi_dodaj.dart';
import 'package:bikehub_desktop/screens/korisnik/profil_prozor.dart';
import 'package:bikehub_desktop/screens/korisnik/sacuvani_proizvodi.dart';
import 'package:bikehub_desktop/screens/ostalo/poruka_helper.dart';
import 'package:bikehub_desktop/screens/prijava/log_in_prozor.dart';
import 'package:bikehub_desktop/screens/prijava/sign_up_prozor.dart';
import 'package:flutter/material.dart';
import '../bicikli/bicikl_prozor.dart';
import '../dijelovi/dijelovi_prozor.dart';
import '../serviser/servis_prozor.dart';
import '../../services/korisnik/korisnik_service.dart';

class PocetniProzorP1 extends StatefulWidget {
  const PocetniProzorP1({super.key, required this.onToggleDisplay, required this.showBicikli});

  final VoidCallback onToggleDisplay;
  final bool showBicikli;

  @override
  // ignore: library_private_types_in_public_api
  _PocetniProzorP1State createState() => _PocetniProzorP1State();
}

class _PocetniProzorP1State extends State<PocetniProzorP1> {
  final KorisnikService korisnikService = KorisnikService();
  bool isLoggedIn = false;
  int korisnikId = 0;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didUpdateWidget(covariant PocetniProzorP1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await korisnikService.isLoggedIn();
    if (isLoggedIn) {
      var korisnik = await korisnikService.getUserInfo();
      korisnikId = int.parse(korisnik['korisnikId'] as String); // Pretvara String u int
    } else {
      isLoggedIn = false;
    }
    setState(() {});
  }

  Future<void> _logout() async {
    await korisnikService.logout();
    setState(() {
      isLoggedIn = false;
    });
    PorukaHelper.prikaziPorukuUspjeha(context, 'Uspješno ste se odjavili!');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: const Color.fromARGB(255, 92, 225, 230),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ..._buildIconButtons(context),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: const Color.fromARGB(255, 92, 225, 230),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: const Color.fromARGB(255, 92, 225, 230),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: isLoggedIn
                                ? [
                                    _buildResponsiveButton3(context, 'Sign out', _logout),
                                  ]
                                : [
                                    _buildResponsiveButton3(context, 'Log in', () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LogInProzor(onLogin: _checkLoginStatus),
                                        ),
                                      );
                                      _checkLoginStatus();
                                    }),
                                    _buildResponsiveButton3(context, 'Sign up', () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUpProzor(onLogin: _checkLoginStatus),
                                        ),
                                      );
                                    }),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Container(
            color: const Color.fromARGB(255, 92, 225, 230),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResponsiveButton(context, 'Bicikl'),
                const SizedBox(width: 10),
                _buildResponsiveButton(context, 'Dijelovi'),
                const SizedBox(width: 10),
                _buildResponsiveButton(context, 'Serviseri'),
              ],
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildIconButtons(BuildContext context) {
    return [
      _buildIconButton(context, Icons.home),
      _buildIconButton(context, Icons.person),
      _buildIconButton(context, Icons.bookmark),
      _buildIconButton(context, Icons.add),
    ];
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    if (icon == Icons.add) {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 9, 72, 138),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: PopupMenuButton<String>(
          icon: Icon(icon, color: Colors.white),
          onSelected: (String result) async {
            final isLoggedIn = await KorisnikService().isLoggedIn();
            if (result == 'Bicikl') {
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BiciklDodajProzor()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogInProzor(
                      onLogin: _checkLoginStatus,
                    ),
                  ),
                );
              }
            } else if (result == 'Dijelovi') {
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DijeloviDodajProzor()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogInProzor(
                      onLogin: _checkLoginStatus,
                    ),
                  ),
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Bicikl',
              child: Text('Bicikl'),
            ),
            const PopupMenuItem<String>(
              value: 'Dijelovi',
              child: Text('Dijelovi'),
            ),
          ],
        ),
      );
    } else {
      return IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: () async {
          final isLoggedIn = await KorisnikService().isLoggedIn();

          if (icon == Icons.person) {
            if (isLoggedIn) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilProzor(korisnikId: korisnikId)),
              );
            } else {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogInProzor(
                    onLogin: _checkLoginStatus,
                  ),
                ),
              );
            }
          } else if (icon == Icons.bookmark) {
            if (isLoggedIn) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SacuvaniProizvodiProzor()),
              );
            } else {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LogInProzor(
                    onLogin: _checkLoginStatus,
                  ),
                ),
              );
            }
          }
        },
        iconSize: MediaQuery.of(context).size.width * 0.018,
        padding: EdgeInsets.zero,
        splashRadius: MediaQuery.of(context).size.width * 0.004,
        splashColor: Colors.white.withOpacity(0.2),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.0265,
          minHeight: MediaQuery.of(context).size.width * 0.0265,
        ),
        style: IconButton.styleFrom(
          backgroundColor: icon == Icons.home ? const Color.fromARGB(255, 7, 181, 255) : const Color.fromARGB(255, 9, 72, 138),
        ),
      );
    }
  }

  Widget _buildResponsiveButton(BuildContext context, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.09,
      height: MediaQuery.of(context).size.height * 0.035,
      child: ElevatedButton(
        onPressed: () {
          // Navigacija na osnovu oznake dugmeta
          if (label == 'Bicikl') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BiciklProzor()),
            );
          } else if (label == 'Dijelovi') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DijeloviProzor()),
            );
          } else if (label == 'Serviseri') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServiserProzor()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 9, 72, 138),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildResponsiveButton3(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.086,
      height: MediaQuery.of(context).size.height * 0.065,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 9, 72, 138),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
