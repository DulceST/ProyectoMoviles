import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles/screens/location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? _selectedLocation;
  DateTime? _selectedStartDate;

  void _addEvent() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null && _selectedStartDate != null) {
      final name = _nameController.text;
      final days = int.tryParse(_daysController.text) ?? 0;
      final description = _descriptionController.text;

      try {
        await FirebaseFirestore.instance.collection('recycling_events').add({
          'name': name,
          'duration_days': days,
          'description': description,
          'location': {
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
          },
          'start_date': _selectedStartDate,
          'created_at': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Evento agregado exitosamente!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedLocation = null;
          _selectedStartDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el evento: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos de Reciclaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del evento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _daysController,
                decoration: InputDecoration(labelText: 'Duración (días)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la duración del evento';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickLocation,
                child: Text(
                  _selectedLocation == null
                      ? 'Seleccionar Ubicación'
                      : 'Ubicación Seleccionada',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickStartDate,
                child: Text(
                  _selectedStartDate == null
                      ? 'Seleccionar Fecha de Inicio'
                      : 'Fecha de Inicio: ${_selectedStartDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEvent,
                child: Text('Agregar Evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}