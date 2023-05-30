import 'package:assistant_tfg/themes/theme.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(height: 20,),
            ListTile(
              
              title: const Text('Item 1',style: TextStyle(color: Colors.white),),
              onTap: () {
                // Aquí puedes agregar la acción que se ejecutará al presionar el Item 1.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2',style: TextStyle(color: Colors.white),),
              onTap: () {
                // Aquí puedes agregar la acción que se ejecutará al presionar el Item 2.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
