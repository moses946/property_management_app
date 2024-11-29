// screens/tenant/add_tenant_screen.dart

import 'package:flutter/material.dart';
import 'package:property_management_app/models/unit.dart';
import 'package:provider/provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/unit_provider.dart';

class AddTenantScreen extends StatefulWidget {
  final String buildingId;

  AddTenantScreen({required this.buildingId});

  @override
  _AddTenantScreenState createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Unit? _selectedUnit;
  final Map<String, dynamic> _tenantData = {
    'firstName': '',
    'lastName': '',
    'phoneNumber': '',
    'email': '',
    'password': '',
  };

  @override
  void initState() {
    super.initState();
    // Fetch vacant units for this building
    Provider.of<UnitProvider>(context, listen: false)
        .fetchUnitsForBuilding(widget.buildingId);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    _formKey.currentState!.save();

    try {
      // Ensure unit is set before submitting
      if (_selectedUnit == null) {
        throw Exception('Please select a unit');
      }

      final submitData = {
        ..._tenantData,
        // 'unit': _selectedUnit!['_id'], // Send only the unit ID
      };

      await Provider.of<TenantProvider>(context, listen: false)
          .addTenant(submitData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tenant added successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add tenant: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Widget _buildUnitDropdown() {
  //   return Consumer<UnitProvider>(
  //     builder: (context, unitProvider, _) {
  //       if (unitProvider.isLoading) {
  //         return Center(child: CircularProgressIndicator());
  //       }

  //       final vacantUnits = unitProvider.units
  //           .where((unit) => unit.status == 'Vacant')
  //           .toList();

  //       if (vacantUnits.isEmpty) {
  //         return Text('No vacant units available');
  //       }

  //       return DropdownButtonFormField<Map<String, dynamic>>(
  //         decoration: InputDecoration(
  //           labelText: 'Select Unit',
  //           border: OutlineInputBorder(),
  //         ),
  //         value: _selectedUnit,
  //         items: vacantUnits.map((unit) {
  //           final unitData = unit.toJson();
  //           return DropdownMenuItem(
  //             value: unitData,
  //             child: Text(
  //                 '${unit.name} - ${unit.type} (Floor ${unit.floorNumber})'),
  //           );
  //         }).toList(),
  //         validator: (value) => value == null ? 'Please select a unit' : null,
  //         onChanged: _isLoading
  //             ? null
  //             : (value) {
  //                 setState(() {
  //                   _selectedUnit = value;
  //                   _tenantData['unit'] = value;
  //                 });
  //               },
  //       );
  //     },
  //   );
  // }

  Widget _buildUnitDropdown() {
    return Consumer<UnitProvider>(
      builder: (context, unitProvider, _) {
        if (unitProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final vacantUnits = unitProvider.units
            .where((unit) => unit.status == 'Vacant')
            .toList();

        if (vacantUnits.isEmpty) {
          return Text('No vacant units available');
        }

        return DropdownButtonFormField<Unit>(
          decoration: InputDecoration(
            labelText: 'Select Unit',
            border: OutlineInputBorder(),
          ),
          value: _selectedUnit,
          items: vacantUnits.map((unit) {
            return DropdownMenuItem<Unit>(
              value: unit,
              child: Text(
                  '${unit.name} - ${unit.type} (Floor ${unit.floorNumber})'),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select a unit' : null,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() {
                    _selectedUnit = value;
                    _tenantData['unit'] = value!.id; // Assuming unit ID is used
                  });
                },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tenant'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<UnitProvider>(
        builder: (context, unitProvider, _) {
          final hasVacantUnits = unitProvider.units
              .where((unit) => unit.status == 'Vacant')
              .isNotEmpty;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Divider(),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter first name';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                _tenantData['firstName'] = value,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter last name';
                              }
                              return null;
                            },
                            onSaved: (value) => _tenantData['lastName'] = value,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                              prefixText: '+254 ',
                            ),
                            enabled: !_isLoading,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                _tenantData['phoneNumber'] = "+254$value",
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter email';
                              }
                              if (!value!.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) => _tenantData['email'] = value,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_isLoading,
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter password';
                              }
                              if (value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) => _tenantData['password'] = value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit Assignment',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Divider(),
                          SizedBox(height: 16),
                          _buildUnitDropdown(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        (_isLoading || !hasVacantUnits) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      !hasVacantUnits
                          ? 'No Units Available'
                          : _isLoading
                              ? 'Adding...'
                              : 'Add Tenant',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
