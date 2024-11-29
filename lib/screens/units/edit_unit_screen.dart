// screens/unit/edit_unit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unit_provider.dart';
import '../../models/unit.dart';

class EditUnitScreen extends StatefulWidget {
  final Unit unit;

  EditUnitScreen({required this.unit});

  @override
  _EditUnitScreenState createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends State<EditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late String _unitName;
  late int _floorNumber;
  late double _rent;
  late int _waterUnitsConsumed;
  late double _waterCost;
  late double _garbageFee;
  late String _status;
  late String _type;

  // Define unit types
  final List<String> _unitTypes = [
    'Single',
    'Double',
    'Bedsitter',
    'One Bedroom',
    'Two Bedroom',
    'Three Bedroom',
    'Studio',
  ];

  @override
  void initState() {
    super.initState();
    _unitName = widget.unit.name;
    _floorNumber = widget.unit.floorNumber;
    _rent = widget.unit.rent;
    _waterUnitsConsumed = widget.unit.waterUnitsConsumed;
    _waterCost = widget.unit.costOfWater;
    _garbageFee = widget.unit.garbageFee;
    _status = widget.unit.status;
    _type = widget.unit.type;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    try {
      final updatedUnitData = {
        'unitName': _unitName,
        'floorNumber': _floorNumber,
        'rent': _rent,
        'waterUnitsConsumed': _waterUnitsConsumed,
        'costOfWater': _waterCost,
        'garbageFee': _garbageFee,
        'status': _status,
        'type': _type,
      };

      await Provider.of<UnitProvider>(context, listen: false)
          .updateUnit(widget.unit.id, updatedUnitData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit updated successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update unit: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteUnit() async {
    try {
      await Provider.of<UnitProvider>(context, listen: false)
          .deleteUnit(widget.unit.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit deleted successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete unit: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Unit: ${widget.unit.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isSubmitting ? null : _deleteUnit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _unitName,
                decoration: InputDecoration(labelText: 'Unit Name'),
                enabled: !_isSubmitting,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter unit name' : null,
                onSaved: (value) => _unitName = value!.trim(),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _floorNumber.toString(),
                decoration: InputDecoration(labelText: 'Floor Number'),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Please enter floor number';
                  if (int.tryParse(value!) == null)
                    return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => _floorNumber = int.parse(value!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: 'Unit Type'),
                items: _unitTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _type = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _rent.toString(),
                decoration: InputDecoration(
                  labelText: 'Rent',
                  prefixText: 'Ksh. ',
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter rent amount';
                  if (double.tryParse(value!) == null)
                    return 'Please enter a valid amount';
                  return null;
                },
                onSaved: (value) => _rent = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _waterUnitsConsumed.toString(),
                decoration: InputDecoration(
                  labelText: 'Water Units Consumed',
                  suffixText: 'units',
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter water units';
                  if (int.tryParse(value!) == null)
                    return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => _waterUnitsConsumed = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _waterCost.toString(),
                decoration: InputDecoration(
                  labelText: 'Water Cost Per Unit',
                  prefixText: 'Ksh. ',
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter water cost';
                  if (double.tryParse(value!) == null)
                    return 'Please enter a valid amount';
                  return null;
                },
                onSaved: (value) => _waterCost = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _garbageFee.toString(),
                decoration: InputDecoration(
                  labelText: 'Garbage Fee',
                  prefixText: 'Ksh. ',
                ),
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter garbage fee';
                  if (double.tryParse(value!) == null)
                    return 'Please enter a valid amount';
                  return null;
                },
                onSaved: (value) => _garbageFee = double.parse(value!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Vacant', 'Occupied']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _status = value!),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveForm,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
