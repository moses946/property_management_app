import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tenant.dart';
import '../../providers/tenant_provider.dart';

class EditTenantScreen extends StatefulWidget {
  final Tenant tenant;

  EditTenantScreen({required this.tenant});

  @override
  _EditTenantScreenState createState() => _EditTenantScreenState();
}

class _EditTenantScreenState extends State<EditTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Map<String, dynamic> _tenantData;

  @override
  void initState() {
    super.initState();
    _tenantData = {
      'firstName': widget.tenant.firstName,
      'lastName': widget.tenant.lastName,
      'phoneNumber': widget.tenant.phoneNumber,
      'email': widget.tenant.email,
      'tenancyStatus': widget.tenant.tenancyStatus,
    };
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    _formKey.currentState!.save();

    try {
      final tenantProvider =
          Provider.of<TenantProvider>(context, listen: false);
      await tenantProvider.updateTenant(widget.tenant.id, _tenantData);

      // Refresh the tenant list for the building
      await tenantProvider.fetchBuildingTenants(widget.tenant.buildingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tenant updated successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update tenant: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tenant'),
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
      body: SingleChildScrollView(
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
                        initialValue: _tenantData['firstName'],
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
                        onSaved: (value) => _tenantData['firstName'] = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _tenantData['lastName'],
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
                        initialValue: _tenantData['phoneNumber'],
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
                          // Add phone number validation if needed
                          return null;
                        },
                        onSaved: (value) => _tenantData['phoneNumber'] = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: _tenantData['email'],
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
                        'Tenancy Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Divider(),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _tenantData['tenancyStatus'],
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['active', 'vacated'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _tenantData['tenancyStatus'] = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isLoading ? 'Updating...' : 'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Add any cleanup here if needed
    super.dispose();
  }
}
