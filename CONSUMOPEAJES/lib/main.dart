import 'package:flutter/material.dart';
import 'package:consumodeapis/screens/menu_screen.dart';
import 'package:consumodeapis/screens/listar_peajes_screen.dart';
import 'package:consumodeapis/screens/agregar_peaje_screen.dart';


void main() {
  runApp(MenuApp());
}

class MenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MenuScreen(),
        '/listar_peajes': (context) => ListarPeajesScreen(),
        '/agregar_peaje': (context) => AgregarPeajeScreen(),
        
      },
    );
  }
}
