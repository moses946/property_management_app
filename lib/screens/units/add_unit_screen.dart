// screens/unit/add_unit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unit_provider.dart';

class AddUnitScreen extends StatefulWidget {
  final String buildingId;

  AddUnitScreen({required this.buildingId});

  @override
  _AddUnitScreenState createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends State<AddUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Initialize with default values
  final Map<String, dynamic> _unitData = {
    'unitName': '',
    'floorNumber': 1,
    'type': 'Single',
    'rent': 0.0,
    'waterUnitsConsumed': 0,
    'costOfWater': 0.0,
    'garbageFee': 0.0,
    'status': 'Vacant',
  };

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    try {
      // Add building ID to the unit data
      _unitData['building'] = widget.buildingId;

      print(_unitData);

      await Provider.of<UnitProvider>(context, listen: false)
          .addUnit(_unitData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit added successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add unit: ${e.toString()}')),
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
      appBar: AppBar(title: Text('Add Unit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Unit Name',
                    hintText: 'e.g., Unit 101',
                  ),
                  enabled: !_isSubmitting,
                  onSaved: (value) => _unitData['unitName'] = value?.trim(),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please enter a unit name'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Floor Number',
                    hintText: 'Enter floor number',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _unitData['floorNumber'] = int.tryParse(value!) ?? 1,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter floor number';
                    final floor = int.tryParse(value!);
                    if (floor == null || floor < 1) {
                      return 'Please enter a valid floor number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Unit Type'),
                  value: _unitData['type'],
                  items: [
                    'Single',
                    'Double',
                    'Bedsitter',
                    'One Bedroom',
                    'Two Bedroom'
                  ]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() => _unitData['type'] = value);
                        },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Rent Amount',
                    hintText: 'Enter monthly rent',
                    prefixText: 'Ksh. ',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _unitData['rent'] = double.tryParse(value!) ?? 0.0,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter rent amount';
                    final rent = double.tryParse(value!);
                    if (rent == null || rent < 0) {
                      return 'Please enter a valid rent amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Initial Water Meter Reading',
                    hintText: 'Enter current water meter reading',
                    suffixText: 'units',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _unitData['waterUnitsConsumed'] =
                      int.tryParse(value!) ?? 0,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter water meter reading';
                    }
                    final units = int.tryParse(value!);
                    if (units == null || units < 0) {
                      return 'Please enter a valid meter reading';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Water Cost Per Unit',
                    hintText: 'Enter cost per unit of water',
                    prefixText: 'Ksh. ',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _unitData['costOfWater'] = double.tryParse(value!) ?? 0.0,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter water cost';
                    }
                    final cost = double.tryParse(value!);
                    if (cost == null || cost < 0) {
                      return 'Please enter a valid water cost';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Garbage Fee',
                    hintText: 'Enter monthly garbage fee',
                    prefixText: 'Ksh. ',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _unitData['garbageFee'] = double.tryParse(value!) ?? 0.0,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter garbage fee';
                    }
                    final fee = double.tryParse(value!);
                    if (fee == null || fee < 0) {
                      return 'Please enter a valid garbage fee';
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
                      : Text('Add Unit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
