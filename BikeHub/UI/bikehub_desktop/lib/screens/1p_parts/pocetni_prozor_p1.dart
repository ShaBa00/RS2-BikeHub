import 'package:flutter/material.dart';

class PocetniProzorP1 extends StatelessWidget {
  const PocetniProzorP1({super.key, required void Function() onToggleDisplay, required bool showBicikli});

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
                            children: [
                              _buildResponsiveButton2(context, 'Log in'),
                              _buildResponsiveButton2(context, 'Sign up'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pretraži...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                      cursorHeight: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildResponsiveButton(context, 'Bicikl'),
                    const SizedBox(width: 10), // Smanjen razmak između dugmadi
                    _buildResponsiveButton(context, 'Dijelovi'),
                  ],
                ),
              ],
            ),
          ),
        ),
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

IconButton _buildIconButton(BuildContext context, IconData icon) {
  return IconButton(
    icon: Icon(icon),
    color: Colors.white,
    onPressed: () {},
    iconSize: MediaQuery.of(context).size.width * 0.018,
    padding: EdgeInsets.zero,
    splashRadius: MediaQuery.of(context).size.width * 0.004,
    splashColor: Colors.white.withOpacity(0.2),
    constraints: BoxConstraints(
      minWidth: MediaQuery.of(context).size.width * 0.0265,
      minHeight: MediaQuery.of(context).size.width * 0.0265,
    ),
    style: IconButton.styleFrom(
      backgroundColor: icon == Icons.home
          ? const Color.fromARGB(255, 7, 181, 255)
          : const Color.fromARGB(255, 9, 72, 138), 
    ),
  );
}

  Widget _buildResponsiveButton(BuildContext context, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.09, 
      height: MediaQuery.of(context).size.height * 0.035,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 9, 72, 138),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
    Widget _buildResponsiveButton2(BuildContext context, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.066, // Smanjena širina dugmadi
      height: MediaQuery.of(context).size.height * 0.035, // Visina dugmadi kao procenat visine ekrana
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 9, 72, 138),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}