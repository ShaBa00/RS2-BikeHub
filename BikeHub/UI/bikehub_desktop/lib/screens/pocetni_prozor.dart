import 'package:flutter/material.dart';
import '1p_parts/pocetni_prozor_p1.dart';
import '1p_parts/pocetni_prozor_p2.dart';

class PocetniProzor extends StatefulWidget {
  const PocetniProzor({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PocetniProzorState createState() => _PocetniProzorState();
}

class _PocetniProzorState extends State<PocetniProzor> {
  bool showBicikli = true;

  void toggleDisplay() {
    setState(() {
      showBicikli = !showBicikli;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: PocetniProzorP1(
              onToggleDisplay: toggleDisplay,
              showBicikli: showBicikli,
            ),
          ),
          Expanded(
            flex: 8,
            child: PocetniProzorP2(
              showBicikli: showBicikli,
            ),
          ),
        ],
      ),
    );
  }
}
