import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/building_provider.dart';
import '../providers/tenant_provider.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      title: 'Buildings',
      icon: Icons.business,
      route: '/buildings',
      color: Colors.blue,
      description: 'Manage your properties',
    ),
    DashboardItem(
      title: 'Tenants',
      icon: Icons.people,
      route: '/buildings/select-for-tenants',
      color: Colors.orange,
      description: 'View and manage tenants',
    ),
    DashboardItem(
      title: 'Payments',
      icon: Icons.payment,
      route: '/payments',
      color: Colors.green,
      description: 'Track rent payments',
    ),
    DashboardItem(
      title: 'Reports',
      icon: Icons.bar_chart,
      route: '/reports',
      color: Colors.purple,
      description: 'View financial reports',
    ),
  ];

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator()),
      );

      await AuthService().logout();

      // Clear all providers
      Provider.of<BuildingProvider>(context, listen: false).clearBuildings();
      Provider.of<TenantProvider>(context, listen: false).clearTenants();

      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.1,
        ),
        itemCount: _dashboardItems.length,
        itemBuilder: (context, index) {
          final item = _dashboardItems[index];
          return _buildDashboardCard(context, item);
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, DashboardItem item) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.7),
                item.color.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final String description;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    required this.description,
  });
}
