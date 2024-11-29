// screens/tenant/view_tenant_screen.dart

import 'package:flutter/material.dart';
import 'package:property_management_app/models/payment.dart';
import 'package:provider/provider.dart';
import '../../providers/tenant_provider.dart';
import 'edit_tenant_screen.dart';
import 'package:intl/intl.dart';
import "../../models/tenant.dart";

class ViewTenantScreen extends StatelessWidget {
  final String tenantId;

  ViewTenantScreen({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TenantProvider>(
      builder: (context, tenantProvider, _) {
        final tenant = tenantProvider.getTenantById(tenantId);

        if (tenant == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Tenant Details')),
            body: Center(child: Text('Tenant not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${tenant.firstName} ${tenant.lastName}'),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  if (tenant.tenancyStatus == 'active')
                    PopupMenuItem(
                      value: 'vacate',
                      child: ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Mark as Vacated'),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => EditTenantScreen(tenant: tenant),
                        ),
                      );
                      if (result == true) {
                        await tenantProvider
                            .fetchBuildingTenants(tenant.unitId);
                      }
                      break;
                    case 'vacate':
                      _showVacateConfirmDialog(context, tenant, tenantProvider);
                      break;
                    case 'delete':
                      _showDeleteConfirmDialog(context, tenant, tenantProvider);
                      break;
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  context,
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow(
                        'Name', '${tenant.firstName} ${tenant.lastName}'),
                    _buildInfoRow('Email', tenant.email),
                    _buildInfoRow('Phone', tenant.phoneNumber),
                    _buildInfoRow('Status', tenant.tenancyStatus.toUpperCase(),
                        valueColor: tenant.tenancyStatus == 'active'
                            ? Colors.green
                            : Colors.red),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  title: 'Unit Information',
                  children: [
                    _buildInfoRow('Unit Number', tenant.unitName),
                    _buildInfoRow('Building', tenant.buildingName),
                    _buildInfoRow('Floor', 'Floor ${tenant.floorNumber}'),
                    _buildInfoRow('Unit Type', tenant.unitType),
                    _buildInfoRow(
                        'Rent', 'Ksh. ${tenant.rent.toStringAsFixed(2)}'),
                    _buildInfoRow('Water Cost',
                        'Ksh. ${tenant.waterCost.toStringAsFixed(2)}'),
                    _buildInfoRow('Garbage Fee',
                        'Ksh. ${tenant.garbageFee.toStringAsFixed(2)}'),
                    _buildInfoRow(
                      'Status',
                      tenant.unitStatus,
                      valueColor: tenant.unitStatus == 'Occupied'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // _buildInfoCard(
                //   context,
                //   title: 'Payment Information',
                //   children: [
                //     _buildInfoRow('Current Balance',
                //         'Ksh. ${tenant.ledger.balance.toStringAsFixed(2)}',
                //         valueColor: tenant.ledger.balance > 0
                //             ? Colors.red
                //             : Colors.green),
                //     Divider(),
                //     Text('Recent Transactions',
                //         style: Theme.of(context).textTheme.titleMedium),
                //     SizedBox(height: 8),
                //     ...tenant.ledger.transactions
                //         .take(5)
                //         .map((tx) => _buildTransactionItem(tx))
                //         .toList(),
                //     SizedBox(height: 16),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //       children: [
                //         ElevatedButton.icon(
                //           icon: Icon(Icons.add),
                //           label: Text('Add Payment'),
                //           onPressed: () =>
                //               _showAddPaymentDialog(context, tenant),
                //         ),
                //         ElevatedButton.icon(
                //           icon: Icon(Icons.history),
                //           label: Text('View All'),
                //           onPressed: () => Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (ctx) =>
                //                   TransactionHistoryScreen(tenantId: tenant.id),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    return ListTile(
      dense: true,
      leading: Icon(
        tx.type == 'payment' ? Icons.arrow_downward : Icons.arrow_upward,
        color: tx.type == 'payment' ? Colors.green : Colors.red,
      ),
      title: Text(tx.description),
      subtitle: Text(DateFormat('MMM d, y').format(tx.date)),
      trailing: Text(
        'Ksh. ${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: tx.type == 'payment' ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showVacateConfirmDialog(
    BuildContext context,
    tenant,
    TenantProvider tenantProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Vacate'),
        content: Text('Are you sure you want to mark this tenant as vacated?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await tenantProvider.updateTenantStatus(tenant, 'vacated');
        await tenantProvider.fetchBuildingTenants(tenant.buildingId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tenant marked as vacated')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update tenant status')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    tenant,
    TenantProvider tenantProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this tenant?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await tenantProvider.deleteTenant(tenant.id);
        await tenantProvider.fetchBuildingTenants(tenant.buildingId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tenant deleted successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete tenant')),
          );
        }
      }
    }
  }

  Future<void> _showAddPaymentDialog(
      BuildContext context, Tenant tenant) async {
    final _formKey = GlobalKey<FormState>();
    double? amount;
    String? description;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Payment'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Ksh. ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter description' : null,
                onSaved: (value) => description = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && amount != null && description != null) {
      try {
        // await Provider.of<PaymentProvider>(context, listen: false)
        //     .addPayment(tenant.id, amount!, description!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add payment')),
        );
      }
    }
  }
}
