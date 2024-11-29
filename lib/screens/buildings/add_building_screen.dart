// screens/buildings/add_building_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/building_provider.dart';

class AddBuildingScreen extends StatefulWidget {
  @override
  _AddBuildingScreenState createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends State<AddBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _location = '';
  int _totalFloors = 1;
  int _unitsPerFloor = 1;
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    try {
      final success =
          await Provider.of<BuildingProvider>(context, listen: false)
              .addBuilding(
        name: _name,
        location: _location,
        totalFloors: _totalFloors,
        unitsPerFloor: _unitsPerFloor,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Building added successfully')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else if (mounted) {
        final error =
            Provider.of<BuildingProvider>(context, listen: false).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to add building')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Building')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Building Name'),
                  enabled: !_isSubmitting,
                  onSaved: (value) => _name = value!.trim(),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please enter a building name'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  enabled: !_isSubmitting,
                  onSaved: (value) => _location = value!.trim(),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please enter a location'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Total Floors'),
                  keyboardType: TextInputType.number,
                  enabled: !_isSubmitting,
                  onSaved: (value) => _totalFloors = int.parse(value!),
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter total floors';
                    final floors = int.tryParse(value!);
                    if (floors == null || floors < 1) {
                      return 'Please enter a valid number of floors';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Units per Floor'),
                  keyboardType: TextInputType.number,
                  enabled: !_isSubmitting,
                  onSaved: (value) => _unitsPerFloor = int.parse(value!),
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter units per floor';
                    final units = int.tryParse(value!);
                    if (units == null || units < 1) {
                      return 'Please enter a valid number of units';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save Building'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
