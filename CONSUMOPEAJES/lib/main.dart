import 'package:consumodeapis/screens/agregar_peaje_screen.dart';
import 'package:consumodeapis/screens/editar_peaje_screen.dart';
import 'package:consumodeapis/screens/listar_peajes_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu App de Peajes',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ListarPeajesScreen(),
        '/listar_peajes': (context) => ListarPeajesScreen(),
        '/agregar_peaje': (context) => AgregarPeajeScreen(),
        '/editar_peaje': (context) => EditarPeajeScreen(),
      },
    );
  }
}
