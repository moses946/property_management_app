import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Providers
import 'providers/auth_provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/building_provider.dart';
import 'providers/payment_provider.dart';

// Models
import 'models/building.dart';
import 'models/unit.dart';
import 'models/tenant.dart';

// Auth Screens
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_signup_screen.dart';
import 'screens/dashboard_screen.dart';

// Building Screens
import 'screens/buildings/building_list_screen.dart';
import 'screens/buildings/add_building_screen.dart';
import 'screens/buildings/view_building_screen.dart';
import 'screens/buildings/select_building_screen.dart';

// Unit Screens
import 'screens/units/add_unit_screen.dart';
import 'screens/units/edit_unit_screen.dart';
import 'screens/units/view_units_screen.dart';

// Tenant Screens
import 'screens/tenants/tenant_list_screen.dart';
import 'screens/tenants/add_tenant_screen.dart';
import 'screens/tenants/edit_tenant_screen.dart';
import 'screens/tenants/view_tenant_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => BuildingProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Property Management System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Add consistent card theme
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Add consistent input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // Building Routes
            case '/buildings/view':
              final building = settings.arguments as Building;
              return MaterialPageRoute(
                builder: (_) => ViewBuildingScreen(building: building),
              );

            // Unit Routes
            case '/units/edit':
              final unit = settings.arguments as Unit;
              return MaterialPageRoute(
                builder: (_) => EditUnitScreen(unit: unit),
              );
            case '/units/add':
              final buildingId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => AddUnitScreen(buildingId: buildingId),
              );

            // Tenant Routes
            case '/tenants':
              final buildingId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => TenantListScreen(buildingId: buildingId),
              );
            case '/tenants/add':
              final buildingId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => AddTenantScreen(buildingId: buildingId),
              );
            case '/tenants/view':
              final tenantId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => ViewTenantScreen(tenantId: tenantId),
              );
            case '/tenants/edit':
              final tenant = settings.arguments as Tenant;
              return MaterialPageRoute(
                builder: (_) => EditTenantScreen(tenant: tenant),
              );
          }
          return null;
        },
        routes: {
          // Auth Routes
          '/': (context) => AdminLoginPage(),
          '/admin/signup': (context) => AdminSignupScreen(),
          '/dashboard': (context) => DashboardScreen(),

          // Building Routes
          '/buildings': (context) => BuildingListScreen(),
          '/buildings/add': (context) => AddBuildingScreen(),
          '/buildings/select-for-tenants': (context) =>
              SelectBuildingScreen(purpose: 'tenants'),
        },
      ),
    );
  }
}
