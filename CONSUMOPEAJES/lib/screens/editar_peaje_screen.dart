import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'listar_peajes_screen.dart'; // Importa la clase Peaje

class EditarPeajeScreen extends StatefulWidget {
  @override
  _EditarPeajeScreenState createState() => _EditarPeajeScreenState();
}

class _EditarPeajeScreenState extends State<EditarPeajeScreen> {
  final _formKey = GlobalKey<FormState>();
  late Peaje peaje;
  late TextEditingController _placaController;
  late TextEditingController _nombrePeajeController;
  late TextEditingController _idCategoriaTarifaController;
  late TextEditingController _valorController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    peaje = ModalRoute.of(context)!.settings.arguments as Peaje;
    _placaController = TextEditingController(text: peaje.placa);
    _nombrePeajeController = TextEditingController(text: peaje.nombrePeaje);
    _idCategoriaTarifaController = TextEditingController(text: peaje.idCategoriaTarifa);
    _valorController = TextEditingController(text: peaje.valor.toString());
  }

  Future<void> actualizarPeaje() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/Peaje/${peaje.id}');
      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'your-user-agent',
            'Authorization': 'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
          },
          body: json.encode({
            'placa': _placaController.text,
            'nombrepeaje': _nombrePeajeController.text,
            'idcategoriatarifa': _idCategoriaTarifaController.text,
            'valor': int.parse(_valorController.text),
          }),
        );

        if (response.statusCode == 200) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el peaje: ${response.statusCode}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excepción al actualizar el peaje: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Editar Peaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(labelText: 'Placa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la placa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nombrePeajeController,
                decoration: InputDecoration(labelText: 'Nombre del Peaje'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del peaje';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idCategoriaTarifaController,
                decoration: InputDecoration(labelText: 'ID Categoría Tarifa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la ID de categoría de tarifa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el valor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: actualizarPeaje,
                child: Text('Actualizar Peaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
