import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Peaje {
  final int id;
  final String placa;
  final String nombrePeaje;
  final String idCategoriaTarifa;
  final DateTime fechaRegistro;
  final int valor;

  Peaje({
    required this.id,
    required this.placa,
    required this.nombrePeaje,
    required this.idCategoriaTarifa,
    required this.fechaRegistro,
    required this.valor,
  });

  factory Peaje.fromJson(Map<String, dynamic> json) {
    return Peaje(
      id: json['id'],
      placa: json['placa'],
      nombrePeaje: json['nombrepeaje'],
      idCategoriaTarifa: json['idcategoriatarifa'],
      fechaRegistro: DateTime.parse(json['fecharegistro']),
      valor: json['valor'],
    );
  }
}

class ListarPeajesScreen extends StatefulWidget {
  @override
  _ListarPeajesScreenState createState() => _ListarPeajesScreenState();
}

class _ListarPeajesScreenState extends State<ListarPeajesScreen> {
  List<Peaje> peajes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    cargarPeajes();
  }

  Future<void> cargarPeajes() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/Peaje');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'your-user-agent',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List) {
          setState(() {
            peajes = jsonData.map((item) => Peaje.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'La respuesta de la API no es una lista.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los peajes: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Excepción al cargar los peajes: $e';
      });
    }
  }

  Future<void> eliminarPeaje(int id) async {
    final url = Uri.parse('http://jpnet08-001-site1.htempurl.com/SENA/Peaje/$id');
    try {
      final response = await http.delete(url, headers: {
        'User-Agent': 'your-user-agent',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('11178839:60-dayfreetrial')),
      });

      if (response.statusCode == 204) {
        setState(() {
          peajes.removeWhere((peaje) => peaje.id == id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar el peaje: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excepción al eliminar el peaje: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Peajes'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarPeajes,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: peajes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.green[200],
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(peajes[index].nombrePeaje),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Placa: ${peajes[index].placa}'),
                              Text('Fecha de Registro: ${peajes[index].fechaRegistro.toLocal()}'),
                              Text('Valor: \$${peajes[index].valor}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/editar_peaje',
                                    arguments: peajes[index],
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmar eliminación'),
                                        content: Text('¿Estás seguro de que quieres eliminar este peaje?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Eliminar'),
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm) {
                                    eliminarPeaje(peajes[index].id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pushNamed(context, '/agregar_peaje');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
