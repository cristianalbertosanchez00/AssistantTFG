import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menú'),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Aquí puedes agregar la acción que se ejecutará al presionar el Item 1.
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Aquí puedes agregar la acción que se ejecutará al presionar el Item 2.
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
