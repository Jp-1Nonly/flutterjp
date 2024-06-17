import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peaje {
  final String idPeaje;
  final String nombrePeaje;
  final String idCategoriaTarifa;
  final String valor;

  Peaje({
    required this.idPeaje,
    required this.nombrePeaje,
    required this.idCategoriaTarifa,
    required this.valor,
  });

  factory Peaje.fromJson(Map<String, dynamic> json) {
    return Peaje(
      idPeaje: json['idpeaje'],
      nombrePeaje: json['peaje'],
      idCategoriaTarifa: json['idcategoriatarifa'],
      valor: json['valor'],
    );
  }
}

class AgregarPeajeScreen extends StatefulWidget {
  @override
  _AgregarPeajeScreenState createState() => _AgregarPeajeScreenState();
}

class _AgregarPeajeScreenState extends State<AgregarPeajeScreen> {
  String? _selectedPeaje;
  String? _selectedCategoriaTarifa;
  String? _valorPeaje;
  String? _placa;

  List<String> _categoriaTarifaOptions = ['I', 'II', 'III', 'IV', 'V'];
  List<Peaje> _peajes = [];

  TextEditingController _valorController = TextEditingController();
  TextEditingController _placaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPeajes();
  }

  Future<void> _fetchPeajes() async {
    final url = Uri.parse('https://www.datos.gov.co/resource/7gj8-j6i3.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;

        setState(() {
          _peajes = jsonData.map((item) => Peaje.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load peajes');
      }
    } catch (e) {
      print('Error fetching peajes: $e');
    }
  }

  void _onPeajeSelected(String? peaje) {
    setState(() {
      _selectedPeaje = peaje;
      _valorPeaje = _calculateValor(peaje, _selectedCategoriaTarifa);
      _valorController.text = _valorPeaje ?? '';
    });
  }

  void _onCategoriaTarifaSelected(String? categoria) {
    setState(() {
      _selectedCategoriaTarifa = categoria;
      _valorPeaje = _calculateValor(_selectedPeaje, categoria);
      _valorController.text = _valorPeaje ?? '';
    });
  }

  String? _calculateValor(String? peaje, String? categoria) {
    if (peaje != null && categoria != null) {
      final peajeSeleccionado = _peajes.firstWhere(
        (p) => p.nombrePeaje == peaje && p.idCategoriaTarifa == categoria,
        orElse: () => Peaje(
            idPeaje: '', nombrePeaje: '', idCategoriaTarifa: '', valor: ''),
      );

      return peajeSeleccionado.valor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Agregar Peaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPeaje,
              hint: Text('Seleccione el nombre del peaje'),
              items: _peajes.map((peaje) {
                return DropdownMenuItem<String>(
                  value: peaje.nombrePeaje,
                  child: Text(peaje.nombrePeaje),
                );
              }).toList(),
              onChanged: _onPeajeSelected,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategoriaTarifa,
              hint: Text('Seleccione la categoría tarifa'),
              items: _categoriaTarifaOptions.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: _onCategoriaTarifaSelected,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _valorController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Valor',
                hintText: 'Autocompletado',
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _placaController,
              decoration: InputDecoration(
                labelText: 'Placa',
                hintText: 'Ingrese la placa',
              ),
              onChanged: (value) {
                setState(() {
                  _placa = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedPeaje != null &&
                    _selectedCategoriaTarifa != null &&
                    _placa != null) {
                  final url = Uri.parse(
                      'https://www.datos.gov.co/resource/7gj8-j6i3.json');

                  http.get(url).then((response) {
                    if (response.statusCode == 200) {
                      final List<dynamic> data = json.decode(response.body);

                      // Buscar el peaje seleccionado y categoría tarifa en los datos obtenidos
                      var selectedPeajeData = data.firstWhere(
                        (element) =>
                            element['peaje'] == _selectedPeaje &&
                            element['idcategoriatarifa'] ==
                                _selectedCategoriaTarifa,
                        orElse: () => null,
                      );

                      if (selectedPeajeData != null) {
                        // Obtener y asignar el valor del peaje
                        String valor = selectedPeajeData['valor'].toString();

                        // Preparar los datos a enviar
                        final Map<String, dynamic> newData = {
                          'placa': _placa!,
                          'nombrepeaje': _selectedPeaje!,
                          'idcategoriatarifa': _selectedCategoriaTarifa!,
                          'valor': valor,
                        };

                        // URL para guardar el peaje en tu API local
                        final saveUrl = Uri.parse(
                            'http://jpnet08-001-site1.htempurl.com/SENA/Peaje');

                        try {
                          http.post(saveUrl,
                              body: json.encode(newData),
                              headers: {
                                'Content-Type': 'application/json',
                                'User-Agent': 'your-user-agent',
                                'Authorization': 'Basic ' +
                                    base64Encode(utf8
                                        .encode('11178839:60-dayfreetrial')),
                              }).then((response) {
                            if (response.statusCode == 201) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Peaje guardado correctamente')),
                              );
                              // Limpiar campos o realizar otra acción después de guardar
                              _placaController.clear();
                              setState(() {
                                _selectedPeaje = null;
                                _selectedCategoriaTarifa = null;
                                _valorPeaje = null;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error al guardar el peaje: ${response.statusCode}')),
                              );
                            }
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al procesar la solicitud: $error')),
                            );
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Excepción al guardar el peaje: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'No se encontró el valor del peaje para la categoría tarifa seleccionada')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Error al obtener los datos del peaje: ${response.statusCode}')),
                      );
                    }
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error al procesar la solicitud: $error')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Debe seleccionar un peaje y una categoría tarifa, y ingresar la placa')),
                  );
                }
              },
              child: Text('Guardar Peaje'),
            ),
          ],
        ),
      ),
    );
  }
}
