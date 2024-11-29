// screens/tenant/tenant_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tenant_provider.dart';
import '../../models/tenant.dart';
import 'add_tenant_screen.dart';
import 'view_tenant_screen.dart';

class TenantListScreen extends StatefulWidget {
  final String buildingId;

  TenantListScreen({required this.buildingId});

  @override
  _TenantListScreenState createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  bool _isInit = false;
  String _selectedStatus = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _fetchTenants();
      _isInit = true;
    }
  }

  Future<void> _fetchTenants() async {
    final status = _selectedStatus == 'all' ? null : _selectedStatus;
    await Provider.of<TenantProvider>(context, listen: false)
        .fetchBuildingTenants(widget.buildingId, status: status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tenants'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      AddTenantScreen(buildingId: widget.buildingId),
                ),
              );
              if (result == true) {
                _fetchTenants();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedStatus,
                    items: [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Tenants')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'vacated', child: Text('Vacated')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                        _fetchTenants();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TenantProvider>(
              builder: (ctx, tenantProvider, _) {
                if (tenantProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (tenantProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tenantProvider.error!),
                        if (tenantProvider.error ==
                            'Failed to load tenants') ...[
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchTenants,
                            child: Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final tenants = tenantProvider.tenants;
                if (tenants.isEmpty) {
                  return Center(
                    child: Text('No tenants found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchTenants,
                  child: ListView.builder(
                    itemCount: tenants.length,
                    itemBuilder: (ctx, index) {
                      final tenant = tenants[index];
                      return TenantListItem(tenant: tenant);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TenantListItem extends StatelessWidget {
  final Tenant tenant;

  const TenantListItem({required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${tenant.firstName[0]}${tenant.lastName[0]}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${tenant.firstName} ${tenant.lastName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tenant.phoneNumber),
            Text(
              tenant.tenancyStatus.toUpperCase(),
              style: TextStyle(
                color: tenant.tenancyStatus == 'active'
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (ctx) => ViewTenantScreen(tenantId: tenant.id),
            ),
          )
              .then((result) {
            if (result == true) {
              Provider.of<TenantProvider>(context, listen: false)
                  .fetchBuildingTenants(tenant.unitId);
            }
          });
        },
      ),
    );
  }
}
