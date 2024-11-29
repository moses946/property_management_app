import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/building_provider.dart';
import '../tenants/tenant_list_screen.dart';

class SelectBuildingScreen extends StatelessWidget {
  final String purpose;

  SelectBuildingScreen({this.purpose = 'tenants'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Building'),
      ),
      body: FutureBuilder(
        future: Provider.of<BuildingProvider>(context, listen: false)
            .fetchBuildings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Consumer<BuildingProvider>(
            builder: (ctx, buildingProvider, _) {
              final buildings = buildingProvider.buildings;

              if (buildings.isEmpty) {
                return Center(
                  child: Text('No buildings available. Add a building first.'),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: buildings.length,
                itemBuilder: (ctx, index) {
                  final building = buildings[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.business),
                      title: Text(building.name),
                      subtitle: Text(building.location),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => TenantListScreen(
                              buildingId: building.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
