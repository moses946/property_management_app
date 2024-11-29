import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/building_provider.dart';
import 'add_building_screen.dart';
import 'view_building_screen.dart';

class BuildingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buildings'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/buildings/add'),
          ),
        ],
      ),
      body: Consumer<BuildingProvider>(
        builder: (ctx, buildingProvider, _) {
          if (buildingProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (buildingProvider.error != null) {
            return Center(child: Text(buildingProvider.error!));
          }

          if (!buildingProvider.hasBuildings) {
            return Center(
              child: Text('No buildings found. Add your first building!'),
            );
          }

          return ListView.builder(
            itemCount: buildingProvider.buildings.length,
            itemBuilder: (ctx, i) {
              final building = buildingProvider.buildings[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  title: Text(building.name),
                  subtitle: Text(building.location),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/buildings/view',
                      arguments: building,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
